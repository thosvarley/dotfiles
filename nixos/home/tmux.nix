{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    escapeTime = 10;
    plugins = with pkgs.tmuxPlugins; [ sensible yank ];
    extraConfig = ''
      unbind C-b
      set-option -g prefix M-m

      set-option -g status-position top

      # Vertical split with prefix + |
      bind | split-window -h -c "#{pane_current_path}"
      # Horizontal split with prefix + -
      bind - split-window -v -c "#{pane_current_path}"

      # Vim-like moving from pane to pane, aware of vim-tmux-navigator:
      # if the current pane is running nvim, forward the keystroke so Neovim's
      # own plugin decides whether to move within its splits or out to tmux;
      # otherwise tmux switches panes directly.
      bind -n C-h if -F "#{==:#{pane_current_command},nvim}" "send-keys C-h" "select-pane -L"
      bind -n C-j if -F "#{==:#{pane_current_command},nvim}" "send-keys C-j" "select-pane -D"
      bind -n C-k if -F "#{==:#{pane_current_command},nvim}" "send-keys C-k" "select-pane -U"
      bind -n C-l if -F "#{==:#{pane_current_command},nvim}" "send-keys C-l" "select-pane -R"

      bind -T copy-mode-vi C-h select-pane -L
      bind -T copy-mode-vi C-j select-pane -D
      bind -T copy-mode-vi C-k select-pane -U
      bind -T copy-mode-vi C-l select-pane -R
	
	# Status Left
	set -g status-left "#[fg=#{?client_prefix,red},bold]● #[bold]#S "
	set -g status-left-length 31
	# Status Right 
      set -g status-right "#[bold]  #{pane_current_path} "
	set -g status-right-length 61
    '';
  };
}
