# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
#
{ config, pkgs, ... }:

let
  niri-scratchpad =
    (builtins.getFlake "path:${builtins.toString ./pkgs/niri-scratchpad}").packages.${pkgs.system}.default;

  # sadjow/claude-code-nix instead of nixpkgs' claude-code: this flake gets
  # updated within hours of upstream releases (automated hourly checks),
  # whereas nixpkgs' package lags behind by weeks.
  claude-code-nix =
    (builtins.getFlake "github:sadjow/claude-code-nix").packages.${pkgs.system}.default;

  # Vulkan-backed llama.cpp: offloads to the Radeon 760M iGPU via RADV
  # (Mesa's Vulkan driver, pulled in by hardware.graphics.enable below)
  # instead of CPU-only BLAS. This is what actually uses the GPU for
  # local model inference.
  llama-cpp-vulkan = pkgs.llama-cpp.override { vulkanSupport = true; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
      (import <stylix>).nixosModules.stylix
      <nixos-hardware/framework/13-inch/7040-amd>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Global theming
  stylix.enable = true;
  stylix.polarity = "dark";
  stylix.image = /home/thosvarley/Pictures/backgrounds/kanagawa.jpg;
  # Pin your exact Kanagawa palette instead of deriving from a wallpaper:
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
  stylix.fonts.monospace = {
    package = pkgs.nerd-fonts.jetbrains-mono;
    name = "JetBrainsMono Nerd Font";
  };
  stylix.fonts.sizes.terminal = 12;

  # Home-manager configuration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";

  home-manager.users."thosvarley" = import ./home/default.nix;

  networking.hostName = "nixos"; # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Time zone follows the laptop: on each network up / connectivity change,
  # ask ipinfo.io for the IP's time zone and apply it. (Replaced
  # automatic-timezoned + geoclue: geoclue's WiFi scan fails at boot and its
  # beacondb IP fallback misplaces some networks, e.g. a San Diego AT&T IP
  # resolved to Atlanta -> Eastern time.) time.timeZone stays unset so
  # timedatectl is allowed to change it.
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "update-timezone" ''
        case "$2" in up|connectivity-change) ;; *) exit 0 ;; esac
        tz=$(${pkgs.curl}/bin/curl -fsS -m 10 https://ipinfo.io/timezone) || exit 0
        [[ "$tz" =~ ^[A-Za-z_]+(/[A-Za-z0-9_+-]+)+$ ]] || exit 0
        [ -f "${pkgs.tzdata}/share/zoneinfo/$tz" ] || exit 0
        ${pkgs.systemd}/bin/timedatectl set-timezone "$tz"
      '';
    }
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."thosvarley" = {
    isNormalUser = true;
    description = "Thomas Varley";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness",
  RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
  '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Grey instead of orange/yellow folders in Numix(-Circle). Numix has no
  # colour option, so rewrite the folder palette in the SVGs: front, back,
  # and the emblem colour on special folders (Music, Downloads, ...).
  nixpkgs.overlays = [
    (final: prev:
      let
        greyFolders = pkg: pkg.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            { grep -rlZ -i --include='*.svg' -e '#f2bb64' -e '#ea9036' \
                $out/share/icons || true; } \
              | xargs -0 -r sed -i \
                  -e 's/#f2bb64/#b0b0b0/gI' \
                  -e 's/#ea9036/#8c8c8c/gI' \
                  -e 's/#897757/#5c5c5c/gI'
          '';
        });
      in {
        numix-icon-theme = greyFolders prev.numix-icon-theme;
        numix-icon-theme-circle = greyFolders prev.numix-icon-theme-circle;
      })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  brightnessctl
  claude-code-nix
  cryptsetup
  fastfetch
  ffmpegthumbnailer # video thumbnails
  file
  gimp-with-plugins
  git
  gh
  # inkscape-with-extensions
  libreoffice
  libsecret
  llama-cpp-vulkan
  niri-scratchpad
  nodejs
  nixd
  nixfmt
  poppler-utils # pdf previews
  R
  signal-desktop
  slack
  sunsetr
  swaybg
  swayidle
  tree-sitter
  unzip
  wget
  xwayland-satellite
  zathura
  zip
  zoom-us
  zotero
  # Rust-specific packages
  cargo
  rustc
  rustfmt
  clippy
  rust-analyzer
  # C-build
  gcc
  pkg-config
  clang-tools
  # Python — pyside6 pulled in here (rather than via uv/pip) so Nix bakes in
  # its shared-lib RPATHs (libGL, libzstd, etc.) correctly. The venv has
  # include-system-site-packages=true so it can still see it.
  (python3.withPackages (ps: [ ps.pyside6 ]))
  stdenv.cc.cc.lib
  uv
  zlib
  # Runtime shared libs that pip/uv-installed Qt/GUI wheels dlopen at import
  # time to detect the display; not covered by the venv's PySide6 alone.
  wayland
  # Lua
  stylua
  # R
  air-formatter
  # LaTeX
  texlab
  tex-fmt
  # `texlive` bare is the whole texlive package-set attrset, not a
  # derivation -- and on this channel evaluating it (via the dbus
  # service-file scan over systemPackages) trips a nixpkgs typo bug
  # (texlive/default.nix: `pygmentex = texlive.pkgs.pigmentex`, a
  # misspelling of `pygmentex`). Use an actual combined scheme instead.
  texlive.combined.scheme-medium
  ];

  # Fonts
  fonts.packages = with pkgs; [
    cantarell-fonts
    font-awesome
    nerd-fonts.jetbrains-mono
    ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };

  # For Electron/Chromium-based apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # For tmux and other XDG-aware tools.
  environment.sessionVariables.XDG_CONFIG_HOME = "$HOME/.config";

  # eMudhra/emSign CA incident (Oct 2026): distrust the removed root until
  # nixos-26.05's cacert catches up (3.126 still ships it), and make uv use
  # the system store instead of its compiled-in roots (uv < 0.13.4 trusts
  # it). Remove both once the channel has cacert/uv with the fix.
  # https://discuss.python.org/t/109576
  security.pki.caCertificateBlacklist = [ "emSign ECC Root CA - G3" ];
  environment.sessionVariables.UV_SYSTEM_CERTS = "1";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.xserver.enable = true;
  services.udisks2.enable = true;
  # Trash, removable-drive mounting, MTP and network shares for Nemo.
  services.gvfs.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?


  # NIRI WM + GRAPHICAL SUPPORT
  programs.niri.enable = true;
  programs.regreet.enable = true;

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = {};
  programs.waybar.enable = true;

  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics.enable = true;
  services.xserver.videoDrivers  = [ "amdgpu" ];

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = true;

  # Needed for builtins.getFlake, used to pull in ./pkgs/niri-scratchpad
  # without converting the whole system to a flake-based config.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Storage: prune old generations weekly instead of accumulating forever,
  # dedupe identical files across store paths, and cap how many old
  # generations clutter the systemd-boot menu.
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 14d";
  nix.settings.auto-optimise-store = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Compressed RAM-backed swap as pressure insurance.
  zramSwap.enable = true;

  # Python
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
  stdenv.cc.cc.lib
  zlib
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

}
