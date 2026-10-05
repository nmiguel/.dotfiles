# Shared shell configuration and declaratively installed Fish plugins.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  options.userSettings.fish.enable = lib.mkEnableOption "the shared Fish configuration" // {
    default = config.userSettings.packages.cli.enable;
  };

  config = lib.mkIf config.userSettings.fish.enable {
    programs.fish = {
      enable = true;
      plugins = [
        {
          name = "nvm";
          src = pkgs.fishPlugins.nvm.src;
        }
      ];

      shellAbbrs = {
        v = "nvim";
        oc = "opencode";
        sv = "command sudo -e -s nvim";
        docker-compose = "docker compose";
        svenv = ". (fd -t d -u -d 2 'venv')/bin/activate.fish";
        "~pw" = {
          position = "anywhere";
          expansion = "~/projects/work";
        };
        "~pp" = {
          position = "anywhere";
          expansion = "~/projects/personal";
        };
        nx-shell = {
          setCursor = "%";
          expansion = "NIXPKGS_ALLOW_UNFREE=1 nix-shell -p % --run fish";
        };
        exp = if isDarwin then "open ." else "nohup xdg-open . >/dev/null 2>&1 & disown";
        wiztree = "sudo ncdu / --exclude " + (if isDarwin then "/Volumes" else "/mnt");
        nx-switch =
          if isDarwin then
            "home-manager switch --flake .#(hostname -s)"
          else
            "sudo nixos-rebuild switch --flake .#(hostname)";
        hlexec = {
          setCursor = "%";
          expansion = "hyprctl dispatch 'hl.dsp.exec_cmd(\"%\")'";
        };
        lg = "lazygit";
        ld = "lazydocker";
        dotdot = {
          regex = ''^\.\.+$'';
          function = "multicd";
        };
      };

      binds = {
        "ctrl-h" = {
          mode = "insert";
          command = "backward-kill-word";
        };
        "ctrl-y" = {
          mode = "insert";
          command = "accept-autosuggestion";
        };
        "ctrl-r".command = "search_history";
        history-insert = {
          name = "ctrl-r";
          mode = "insert";
          command = "search_history";
        };
        "!" = {
          mode = "insert";
          command = "bind_bang";
        };
        # The pinned HM generator emits bind names without shell quoting.
        "$" = {
          name = "\\$";
          mode = "insert";
          command = "bind_dollar";
        };
      };

      functions = {
        ls = "eza -lh --group-directories-first --icons=auto $argv";
        lt = "eza --tree --level=2 --long --icons --git $argv";
        ff = "fzf --preview 'bat --style=numbers --color=always {}'";
        sudo = ''
          if functions -q $argv[1]
            set argv fish -c "$argv"
          end
          command sudo $argv
        '';
        select_venv = ''
          set venv_path (fd --type d --max-depth 2 --unrestricted 'venv' . | head -n 1)
          if test -n "$venv_path" -a -f "$venv_path/bin/activate.fish"
            source "$venv_path/bin/activate.fish"
          end
        '';
        search_history = ''
          set cmd (history | fzf --no-sort --exact --smart-case)
          if test -n "$cmd"
            commandline -r -- $cmd
          end
        '';
        multicd = "echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)";
        notes = ''
          cd ~/projects/personal/notes
          if test (count $argv) -gt 0
            nvim $argv[1].md
          else
            nvim .
          end
          cd - > /dev/null 2>&1
        '';
        bind_bang = ''
          switch (commandline -t)[-1]
            case "!"
              commandline -t -- $history[1]
              commandline -f repaint
            case "*"
              commandline -i !
          end
        '';
        bind_dollar = ''
          switch (commandline -t)[-1]
            case "!"
              commandline -f backward-delete-char history-token-search-backward
            case "*"
              commandline -i '$'
          end
        '';
        reload = ''
          set pwd (pwd)
          for i in (seq 5)
            if test -f local.fish || test -d .git
              fish -C "cd $pwd"
              break
            end
            cd ..
          end
        '';
      };

      shellInit = ''
        set -gx EDITOR (which nvim)
        set -gx VISUAL $EDITOR
        set -gx SUDO_EDITOR $EDITOR
        set -gx MANPAGER "nvim +Man!"
        set -gx OPENCODE_DB "opencode-stable.db"
        set -gx FZF_DEFAULT_OPTS "--color=fg:-1,fg+:#aac5e6,bg:-1,bg+:-1 --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#87ff00 --color=prompt:#d7005f,spinner:#af5fff,pointer:#af5fff,header:#87afaf --color=border:#262626,label:#aeaeae,query:#d9d9d9 --preview-window=border-rounded --prompt='> ' --marker='>' --pointer='◆' --separator=''' --scrollbar='│' --info=right"
        fish_add_path --path ~/.local/bin
        fish_add_path --path ~/.cargo/bin
        fish_add_path --path ~/.config/bin
        fish_add_path --path ~/go/bin
        fish_add_path --path ~/.nix-profile/bin
      '';

      interactiveShellInit = lib.mkMerge [
        (lib.mkBefore ''
          set fish_greeting
          set -g fish_key_bindings fish_vi_key_bindings
          if type -q paru && not type -q yay
            abbr yay paru
            alias yay paru
          end
          if type -q yay && not type -q paru
            abbr paru yay
            alias paru yay
          end
        '')
        (lib.mkAfter ''
          select_venv
          if test -f local.fish
            source local.fish
          end
        '')
      ];
    };

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
  };
}
