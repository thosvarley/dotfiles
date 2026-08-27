{ lib, ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "alacritty";
        dpi-aware = "no";
        icons-enabled = "yes";
	icon-theme = "Numix-Circle";
        filter-desktop = "yes";
        lines = 10;
        font = lib.mkForce "DejaVu Sans:size=10:weight=bold";
      };
      border = {
        radius = 16;
      };
    };
  };
}
