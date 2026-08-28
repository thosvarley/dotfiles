{ ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      # Attach to the "default" tmux session, creating it if needed. Lives
      # here (not ~/.bashrc) so it only fires for actual terminal windows —
      # not every login shell, including the one niri-session bootstraps
      # itself through to launch niri, which it was previously hijacking.
      terminal.shell = {
        program = "tmux";
        args = [ "new-session" "-A" "-s" "default" ];
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
