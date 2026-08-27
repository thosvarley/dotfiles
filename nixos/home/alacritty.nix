{ ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        dimensions = { columns = 75; lines = 25; };
        opacity = 1.0;
        padding = { x = 10; y = 10; };
        decorations = "Full";
        decorations_theme_variant = "Dark";
      };
    };
  };
}
