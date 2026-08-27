{ ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "alacritty";
        dpi-aware = "no";
        icons-enabled = "no";
        filter-desktop = "yes";
        lines = 10;
      };
      border = {
        radius = 16;
      };
    };
  };
}
