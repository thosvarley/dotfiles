# reMarkable Connection Utility (RCU) 4.0.34 -- https://www.davisr.me/projects/rcu/
#
# Built from the upstream source tarball sitting next to this file. Use with:
#   environment.systemPackages = [ rcu ];  services.udev.packages = [ rcu ];
# where rcu = pkgs.callPackage ./pkgs/rcu { };
#
# Why the patching: RCU is pinned to a 2020-2024 Python stack, nixpkgs is newer.
#  * PySide2 (Qt5) is EOL -> python312 is the newest nixpkgs builds it for.
#  * RCU vendors a patched paramiko Transport that imports paramiko 2.x
#    internals (py3compat, dsskey, ...) -> pin paramiko 2.12.0.
#  * cryptography 48 moved TripleDES to cryptography.hazmat.decrepit -> patch
#    the import in paramiko 2.12 and in RCU's own transport.py.
#  * The shipped update_metadata_pb2.py is protobuf-3.17 era and won't load on
#    modern protobuf -> regenerate it with protoc from the bundled .proto.
{ pkgs ? import <nixpkgs> { } }:
let
  lib = pkgs.lib;
  py = pkgs.python312;

  tripleDesFix = files: ''
    for f in ${toString files}; do
      substituteInPlace "$f" \
        --replace-fail "algorithms.TripleDES" "_TripleDES" \
        --replace-fail "from cryptography.hazmat.primitives.ciphers import algorithms" \
          "from cryptography.hazmat.decrepit.ciphers.algorithms import TripleDES as _TripleDES
    from cryptography.hazmat.primitives.ciphers import algorithms"
    done
  '';

  paramiko212 = py.pkgs.paramiko.overridePythonAttrs (old: rec {
    version = "2.12.0";
    src = pkgs.fetchPypi {
      pname = "paramiko";
      inherit version;
      hash = "sha256-N2iFwFxdaqbh9GCKrCprWwVIsa3UAnRHcyRgWQPZzUk=";
    };
    postPatch = (old.postPatch or "") + ''
      ${tripleDesFix [ "paramiko/pkey.py" "paramiko/transport.py" ]}
    '';
    dependencies = [ py.pkgs.bcrypt py.pkgs.cryptography py.pkgs.pynacl py.pkgs.six ];
    doCheck = false;
    pythonImportsCheck = [ ];
  });

  pyEnv = py.withPackages (ps: [
    ps.pyside2 ps.shiboken2
    paramiko212
    ps.cryptography ps.pillow ps.pikepdf ps.protobuf
    ps.six ps.appdirs ps.packaging ps.certifi
  ]);

  qt = pkgs.libsForQt5.qt5;
  qtPlugins = "${qt.qtbase}/${qt.qtbase.qtPluginPrefix}:${qt.qtwayland}/${qt.qtbase.qtPluginPrefix}";
  runtimeLibs = lib.makeLibraryPath (with pkgs; [
    libGL fontconfig freetype libxkbcommon glib zstd
    xorg.libxcb xorg.libX11 xorg.xcbutilwm xorg.xcbutilimage xorg.xcbutilkeysyms xorg.xcbutilrenderutil
  ]);

  desktopItem = pkgs.makeDesktopItem {
    name = "davisr-rcu";
    desktopName = "RCU";
    comment = "Manage your reMarkable tablet";
    exec = "rcu";
    icon = "davisr-rcu";
    startupWMClass = "rcu";
    categories = [ "Utility" ];
  };
in
pkgs.stdenv.mkDerivation {
  pname = "rcu";
  version = "4.0.34";
  src = ./rcu-4.0.34-source.tar.gz;
  sourceRoot = "rcu";

  nativeBuildInputs = [ pkgs.makeWrapper pkgs.protobuf pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.libusb1 pkgs.stdenv.cc.cc.lib ];
  dontBuild = true;

  postPatch = ''
    ${tripleDesFix [ "src/model/transport.py" ]}
    protoc --proto_path=src/model --python_out=src/model src/model/update_metadata.proto
    # keep only the Linux recovery-mode helper (autoPatchelf chokes on the others)
    rm -f recovery_os_build/imx_usb.fbsd12 recovery_os_build/imx_usb.mac recovery_os_build/imx_usb.win10
    rm -rf manual
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/rcu $out/bin $out/share/applications $out/share/icons/hicolor/512x512/apps $out/lib/udev/rules.d
    cp -r . $out/share/rcu/
    makeWrapper ${pyEnv}/bin/python $out/bin/rcu \
      --add-flags "-B main.py" \
      --chdir $out/share/rcu/src \
      --set QT_PLUGIN_PATH "${qtPlugins}" \
      --prefix LD_LIBRARY_PATH : "${runtimeLibs}"
    cp ${desktopItem}/share/applications/*.desktop $out/share/applications/
    cp icons/mac-icon.iconset/icon_512x512.png $out/share/icons/hicolor/512x512/apps/davisr-rcu.png
    # reMarkable USB recovery-mode IDs; "uaccess" gives the logged-in user access (no group needed)
    cat > $out/lib/udev/rules.d/50-remarkable.rules <<'EOF'
    SUBSYSTEM=="usb", ATTRS{idVendor}=="15a2", ATTRS{idProduct}=="0061", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="15a2", ATTRS{idProduct}=="0063", MODE="0660", TAG+="uaccess"
    EOF
    runHook postInstall
  '';

  meta = {
    description = "reMarkable Connection Utility: offline management client for reMarkable tablets";
    homepage = "https://www.davisr.me/projects/rcu/";
    license = lib.licenses.agpl3Plus;
    mainProgram = "rcu";
    platforms = [ "x86_64-linux" ];
  };
}
