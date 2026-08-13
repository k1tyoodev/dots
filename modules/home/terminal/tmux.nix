{ config, pkgs, lib, ... }:

let
  # GrokNight canvas; theme hook switches light/dark at runtime.
  colors = {
    bg = "#141414";
    bg_selected = "#242424";
    fg = "#F0F0F0";
    fg_muted = "#989898";
    fg_dim = "#989898";
    accent = "#81A1C1";
    mint = "#B48EAD";
    border = "#262626";
  };
in
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    prefix = "C-a";
    baseIndex = 1;
    escapeTime = 0;
    mouse = true;
    keyMode = "vi";
    historyLimit = 50000;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];

    extraConfig = ''
      # true color
      set -ag terminal-overrides ",*:RGB"

      # renumber windows
      set -g renumber-windows on

      # splits in cwd
      bind \\ split-window -h -c "#{pane_current_path}"
      bind Enter split-window -v -c "#{pane_current_path}"

      # new window in cwd
      bind c new-window -c "#{pane_current_path}"

      # pane nav without prefix (alt+hjkl)
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # pane nav with prefix (fallback)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # resize without prefix (alt+shift+hjkl)
      bind -n M-H resize-pane -L 5
      bind -n M-J resize-pane -D 5
      bind -n M-K resize-pane -U 5
      bind -n M-L resize-pane -R 5

      # window nav without prefix
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9
      bind -n M-n next-window
      bind -n M-p previous-window

      # quick actions
      bind x kill-pane
      bind X kill-window
      bind z resize-pane -Z

      # session switcher (fuzzy)
      bind s display-popup -E -w 40% -h 40% -S "fg=#{@cursor_border}" -b rounded \
          "tmux list-sessions -F '#S' | fzf --reverse --border=none --margin=1 --padding=1 \
          --prompt='  ' --pointer='▌' --no-scrollbar \
          $(~/.config/theme/fzf-colors) \
          | xargs -I{} tmux switch-client -t {}"

      # sessionizer (fuzzy find projects, create/switch session)
      bind f display-popup -E -w 50% -h 50% -S "fg=#{@cursor_border}" -b rounded "~/.config/tmux/scripts/sessionizer"

      # last session
      bind L switch-client -l

      # reload
      bind r source-file ~/.config/tmux/tmux.conf \; display "reloaded"

      # copy mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # no bells
      set -g visual-activity off
      set -g visual-bell off
      set -g visual-silence off
      setw -g monitor-activity off
      set -g bell-action none

      # status bar
      set -g status-position top
      set -g status-justify left
      set -g status-style "bg=${colors.bg} fg=${colors.fg_muted}"
      set -g status-interval 1

      # left: session
      set -g status-left "#[fg=${colors.accent},bold] #S #[fg=${colors.fg_dim}]│ "
      set -g status-left-length 20

      # right: time only
      set -g status-right "#[fg=${colors.fg_muted}]%-I:%M %p "
      set -g status-right-length 50

      # window format
      setw -g window-status-format "#[fg=${colors.fg_dim}] #I #W "
      setw -g window-status-current-format "#[fg=${colors.fg},bold] #I #W "
      setw -g window-status-separator ""

      # pane borders
      set -g pane-border-lines simple
      set -g pane-border-style "fg=${colors.border}"
      set -g pane-active-border-style "fg=${colors.accent}"

      # message style
      set -g message-style "bg=${colors.bg_selected} fg=${colors.fg}"
      set -g message-command-style "bg=${colors.bg_selected} fg=${colors.fg}"

      # mode style (copy mode)
      setw -g mode-style "bg=${colors.bg_selected} fg=${colors.fg}"

      # clock
      setw -g clock-mode-colour "${colors.accent}"

      # Ghostty reports terminal appearance changes through these tmux hooks.
      set-hook -g client-dark-theme 'run-shell "~/.config/tmux/scripts/theme dark"'
      set-hook -g client-light-theme 'run-shell "~/.config/tmux/scripts/theme light"'
      run-shell "~/.config/tmux/scripts/theme"
    '';
  };

  # sessionizer script
  home.file.".config/tmux/scripts/sessionizer" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      SEARCH_DIRS=(
          ~/code
          ~/projects
          ~/work
          ~/.config
      )

      dirs=""
      for dir in "''${SEARCH_DIRS[@]}"; do
          [[ -d "$dir" ]] && dirs="$dirs $dir"
      done

      selected=$(
          {
              tmux list-sessions -F "#{session_name}" 2>/dev/null
              [[ -n "$dirs" ]] && find $dirs -mindepth 1 -maxdepth 2 -type d 2>/dev/null
          } | fzf --reverse --border=none --margin=1 --padding=1 \
              --prompt='  ' --pointer='▌' --no-scrollbar \
              $(~/.config/theme/fzf-colors)
      )

      [[ -z "$selected" ]] && exit 0

      if [[ "$selected" == /* ]]; then
          session_name=$(basename "$selected" | tr '.' '_')
          session_path="$selected"
      else
          session_name="$selected"
          session_path=""
      fi

      if tmux has-session -t="$session_name" 2>/dev/null; then
          tmux switch-client -t "$session_name"
      else
          if [[ -n "$session_path" ]]; then
              tmux new-session -ds "$session_name" -c "$session_path"
          else
              tmux new-session -ds "$session_name"
          fi
          tmux switch-client -t "$session_name"
      fi
    '';
  };

  home.file.".config/tmux/scripts/theme" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      appearance="''${1:-$(bash ~/.config/theme/current-appearance)}"
      if [[ "$appearance" == "light" ]]; then
        # GrokDay canvas
        bg="#eeeeee"
        bg_selected="#dedede"
        fg="#141414"
        fg_muted="#A3A3A3"
        fg_dim="#A3A3A3"
        accent="#0064B0"
        border="#dedede"
      else
        # GrokNight canvas
        bg="#141414"
        bg_selected="#242424"
        fg="#F0F0F0"
        fg_muted="#989898"
        fg_dim="#989898"
        accent="#81A1C1"
        border="#242424"
      fi

      tmux set-option -g status-style "bg=$bg,fg=$fg_muted"
      tmux set-option -g @cursor_border "$border"
      tmux set-option -g status-left "#[fg=$accent,bold] #S #[fg=$fg_dim]│ "
      tmux set-option -g status-right "#[fg=$fg_muted]%-I:%M %p "
      tmux set-window-option -g window-status-format "#[fg=$fg_dim] #I #W "
      tmux set-window-option -g window-status-current-format "#[fg=$fg,bold] #I #W "
      tmux set-option -g pane-border-style "fg=$border"
      tmux set-option -g pane-active-border-style "fg=$accent"
      tmux set-option -g message-style "bg=$bg_selected,fg=$fg"
      tmux set-option -g message-command-style "bg=$bg_selected,fg=$fg"
      tmux set-window-option -g mode-style "bg=$bg_selected,fg=$fg"
      tmux set-window-option -g clock-mode-colour "$accent"
    '';
  };
}
