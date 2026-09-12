{ pkgs, ... }:
{
  home.stateVersion = "26.05";

  imports = [
    ./gtk.nix
    ./alacritty.nix
    ./tmux.nix
    ./fuzzel.nix
    ./yazi.nix
    ./waybar.nix
    ./swaylock.nix
    ./mako.nix
    ./battery-notify.nix
    ./niri.nix
    ./misc.nix
    ./git.nix
  ];
}
