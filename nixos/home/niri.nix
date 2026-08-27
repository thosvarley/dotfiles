# Niri has no home-manager module that generates its KDL config from Nix
# attrs, so this just deploys the hand-written file verbatim. Edit
# ../../niri/config.kdl (not ~/.config/niri/config.kdl directly -- that
# path becomes a home-manager-managed symlink into the Nix store once this
# is switched to) and `sudo nixos-rebuild switch` to deploy changes.
{ ... }:
{
  xdg.configFile."niri/config.kdl".source = ../../niri/config.kdl;
}
