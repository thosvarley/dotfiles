{ pkgs, ... }:
{
  # Nemo (Cinnamon's file manager) standalone -- just the app and its
  # extensions, not the Cinnamon desktop. Trash/mounts/MTP come from
  # services.gvfs in configuration.nix.
  home.packages = [ pkgs.nemo-with-extensions ];

  # Default handler for folders is set imperatively (`xdg-mime default
  # nemo.desktop inode/directory`), not via xdg.mimeApps: enabling that would
  # make home-manager own ~/.config/mimeapps.list and clobber the
  # associations Thunderbird etc. wrote there.

  dconf.settings = {
    # "Open in Terminal" reads Cinnamon's default-terminal key, which
    # otherwise defaults to gnome-terminal.
    "org/cinnamon/desktop/applications/terminal".exec = "alacritty";
  };
}
