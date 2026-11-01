{ ... }:
{
  programs.swayimg = {
    enable = true;
    settings = {
      # Opening one image also loads the rest of its directory, so there's
      # something to page through (default only loads the file given).
      list.all = "yes";
      # Left/Right flip between images instead of panning by 10px
      # (drag with the mouse to pan a zoomed image; Up/Down still pan).
      "keys.viewer" = {
        Left = "prev_file";
        Right = "next_file";
      };
    };
  };
}
