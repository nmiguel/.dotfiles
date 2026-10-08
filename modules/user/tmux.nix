# Shared tmux settings, plugins, and sessionizer deployment.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.userSettings.tmux;
  tmuxConfig = "${config.xdg.configHome}/tmux/tmux.conf";
  sessionizer = "${config.xdg.configHome}/tmux/tmux-sessionizer";
  copyCommand =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/usr/bin/pbcopy"
    else
      "${lib.getExe pkgs.xclip} -selection clipboard";
  openCommand =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/usr/bin/open"
    else
      lib.getExe' pkgs.xdg-utils "xdg-open";

  # Draw the curves in the tab's fill color without reversing the background.
  roundedSeparator = color: glyph: "#[fg=#{E:${color}},bg=terminal]${glyph}#[none]";
  themeOptions = {
    "@catppuccin_flavor" = "mocha";
    "@catppuccin_status_background" = "none";
    "@catppuccin_window_status_style" = "custom";
    "@catppuccin_window_flags" = "none";
    "@catppuccin_window_number_position" = "right";
    "@catppuccin_window_text" = "#W";
    "@catppuccin_window_current_text" = "#W";
    "@catppuccin_window_text_color" = "#{@thm_surface_0}";
    "@catppuccin_window_current_text_color" = "#{@thm_surface_1}";
    "@catppuccin_window_number_color" = "#{@thm_overlay_2}";
    "@catppuccin_window_current_number_color" = "#{@thm_mauve}";
    "@catppuccin_window_left_separator" = roundedSeparator "@catppuccin_window_text_color" "";
    "@catppuccin_window_middle_separator" = " ";
    "@catppuccin_window_right_separator" = roundedSeparator "@catppuccin_window_number_color" "";
    "@catppuccin_window_current_left_separator" =
      roundedSeparator "@catppuccin_window_current_text_color" "";
    "@catppuccin_window_current_middle_separator" = " ";
    "@catppuccin_window_current_right_separator" =
      roundedSeparator "@catppuccin_window_current_number_color" "";
  };
  themeConfig = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: "set -g ${name} ${lib.escapeShellArg value}") themeOptions
  );
in
{
  options.userSettings.tmux.enable = lib.mkEnableOption "the shared tmux configuration";

  config = lib.mkIf cfg.enable {
    # Replace the old whole-directory link before deploying individual files.
    home.activation.migrateTmuxDirectory =
      lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
        ''
          tmuxDir=${lib.escapeShellArg "${config.xdg.configHome}/tmux"}
          if [[ -L "$tmuxDir" && "$(readlink -f "$tmuxDir")" == ${lib.escapeShellArg "${config.userSettings.dotfiles.repoRoot}/stow/config/tmux"} ]]; then
            run unlink "$tmuxDir"
          fi
        '';

    xdg.configFile."tmux/tmux-sessionizer" = {
      source = ../../stow/config/tmux/tmux-sessionizer;
      executable = true;
    };

    programs.tmux = {
      enable = true;
      prefix = "C-f";
      terminal = "tmux-256color";
      mouse = true;
      keyMode = "vi";
      escapeTime = 10;
      historyLimit = 5000;
      secureSocket = false;

      plugins = [
        {
          plugin = pkgs.tmuxPlugins.catppuccin;
          extraConfig = themeConfig + ''

            # Set the status content before Continuum adds its save hook.
            set -g status-left ""
            set -g status-right "#{E:@catppuccin_status_session}"
          '';
        }
        {
          plugin = pkgs.tmuxPlugins.fzf-tmux-url;
          extraConfig = ''
            set -g @fzf-url-open '${openCommand}'
            set -g @fzf-url-bind 'x'
          '';
        }
        {
          plugin = pkgs.tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-dir '${config.xdg.dataHome}/tmux/resurrect'
          '';
        }
        {
          plugin = pkgs.tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'off'
          '';
        }
      ];

      extraConfig = # conf
        ''
        # Terminal and session behavior.
        set -ga terminal-overrides ',xterm-256color:Tc'
        set -g renumber-windows on
        set -g set-clipboard on
        set -g status-keys emacs

        # Window and pane navigation.
        bind -n M-n new-window
        bind -n M-h previous-window
        bind -n M-l next-window
        bind -n M-d confirm-before -p "kill-pane #W? (y/n)" kill-pane
        bind -n M-x split-window -v
        bind -n M-v split-window -h
        bind -n M-j select-pane -t :.+
        bind -n M-k select-pane -t :.-
        bind -n M-g new-window '${sessionizer}'
        bind-key b new-session -A -s bosana-manager -n manager 'exec nvim -c "Bosana --manager"'

        bind r source-file '${tmuxConfig}' \; display-message "Reloaded tmux configuration"

        # Copy mode and clipboard integration.
        bind -T copy-mode-vi v send -X begin-selection
        bind -T copy-mode-vi y send -X copy-pipe-and-cancel '${copyCommand}'
        bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel '${copyCommand}'
        bind P paste-buffer

        # Select a command and its output using the fish prompt marker.
        bind -n S-M-up {
          copy-mode
          send -X clear-selection
          send -X start-of-line
          send -X cursor-up
          send -X cursor-up
          send -X start-of-line
          send -X start-of-line

          if -F "#{m:*❯,#{copy_cursor_line}}" {
            send -X search-forward-text "❯"
            send -X stop-selection
            send -X -N 2 cursor-right
            send -X begin-selection
            send -X end-of-line
            send -X end-of-line
            if "#{m:*❯,#{copy_cursor_line}}" {
              send -X cursor-left
              send -X cursor-up
              send -X cursor-up
            }
          } {
            send -X end-of-line
            send -X end-of-line
            send -X begin-selection
            send -X search-backward-text "❯"
            send -X stop-selection
          }
        }

        # Override plugin styles after loading: transparent background, no underline.
        set -g window-status-current-style 'none'
        set -g status-style 'bg=terminal'
      '';
    };
  };
}
