# Apps enabled with no further settings -- not worth a whole file each.
{ ... }:
{
  programs.keepassxc.enable = true;
  programs.thunderbird.enable = true;

  # Stylix can only theme Firefox profiles that home-manager declares.
  # `path` points at the existing profile dir so history/bookmarks are kept.
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      path = "dd6drmcu.default";
    };
  };
  stylix.targets.firefox.profileNames = [ "default" ];
}
