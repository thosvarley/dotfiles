{ pkgs, ... }:
{
  home.stateVersion = "26.05";

  imports = [
    ./gtk.nix
    ./alacritty.nix
    ./tmux.nix
    ./fuzzel.nix
    ./waybar.nix
    ./swaylock.nix
    ./mako.nix
    ./niri.nix
    ./misc.nix
  ];
}
