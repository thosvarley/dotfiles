{ pkgs, ... }:
{
  home.stateVersion = "26.05";

  # npm's default global prefix points into the read-only Nix store (since
  # nodejs itself lives there), so `npm install -g` needs to be redirected
  # to a writable location instead. See ~/.npmrc (prefix=~/.npm-global).
  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  imports = [
    ./gtk.nix
    ./alacritty.nix
    ./tmux.nix
    ./fuzzel.nix
    ./yazi.nix
    ./nemo.nix
    ./swayimg.nix
    ./waybar.nix
    ./swaylock.nix
    ./mako.nix
    ./battery-notify.nix
    ./niri.nix
    ./misc.nix
    ./git.nix
  ];
}
