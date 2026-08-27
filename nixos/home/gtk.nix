{ pkgs, ... }:
{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Numix-Circle";
      package = pkgs.numix-icon-theme-circle;
    };
  };
}
