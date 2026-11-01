{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    # Upstream alacritty ships with zero image-protocol support (no Sixel,
    # no Kitty graphics) -- this is the real reason yazi's image/PDF previews
    # render wrong. withGraphics swaps in ayosec/alacritty's Sixel fork.
    package = pkgs.alacritty.override { withGraphics = true; };
    settings = {
      # Each window starts its own fresh tmux session (attaching to a shared
      # named session made every new window mirror the first). Lives here
      # (not ~/.bashrc) so it only fires for actual terminal windows — not
      # every login shell, including the one niri-session bootstraps itself
      # through to launch niri, which it was previously hijacking.
      terminal.shell = {
        program = "tmux";
        args = [ "new-session" ];
      };
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
