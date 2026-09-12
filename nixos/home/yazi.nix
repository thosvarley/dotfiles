{ ... }:
{
  # Keybindings are left at yazi's defaults, which are already vim-style
  # (hjkl, gg/G, etc.) -- nothing to override here.
  programs.yazi = {
    enable = true;

    settings = {
      opener = {
        zathura = [
          { run = "zathura %s"; orphan = true; desc = "Open with zathura"; }
        ];
      };
      open = {
        prepend_rules = [
          { mime = "application/pdf"; use = "zathura"; }
        ];
      };
    };
  };
}
