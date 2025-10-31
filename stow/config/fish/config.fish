set fish_greeting
set -g fish_key_bindings fish_vi_key_bindings

# Aliases
abbr v nvim
abbr docker-compose "docker compose"
abbr exp "nohup xdg-open . >/dev/null 2>&1 & disown"
abbr wiztree "sudo ncdu / --exclude /mnt"
abbr svenv ". (fd -t d -u -d 2 'venv')/bin/activate.fish"
abbr lg lazygit
abbr ld lazydocker

function ls
    eza -lh --group-directories-first --icons=auto $argv
end

function lt
    eza --tree --level=2 --long --icons --git $argv
end

function ff
    fzf --preview 'bat --style=numbers --color=always {}'
end

function sudo
  if functions -q $argv[1]
    set argv fish -c "$argv"
  end
  command sudo $argv
end


function select_venv
    set venv_path (fd --type d --max-depth 2 --unrestricted 'venv' . | head -n 1)
    if test -n "$venv_path" -a -f "$venv_path/bin/activate.fish"
        source "$venv_path/bin/activate.fish"
    end
end

# Key bindings (for autosuggestions, requires a fish autosuggestions plugin)
bind --mode insert \cH backward-kill-word
bind --mode insert \cY accept-autosuggestion
bind \cR  search_history
bind --mode insert \cR search_history

# Custom functions
function search_history
    set cmd (history | fzf --no-sort --exact --smart-case)
    if test -n "$cmd"
        commandline -r -- $cmd
        # commandline -f execute
    end
end

function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end

abbr --add dotdot --regex '^\.\.+$' --function multicd

function notes
    cd ~/projects/personal/notes
    if test (count $argv) -gt 0
        nvim $argv[1].md
    else
        nvim .
    end
    cd - > /dev/null 2>&1
end


function bind_bang
    switch (commandline -t)[-1]
        case "!"
            commandline -t -- $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function bind_dollar
    switch (commandline -t)[-1]
        case "!"
            commandline -f backward-delete-char history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

function fish_user_key_bindings
    bind --mode insert ! bind_bang
    bind --mode insert '$' bind_dollar
end


# Environment variables
set -gx EDITOR nvim
set -gx MANPAGER "nvim +Man!"
set -gx FZF_DEFAULT_OPTS "
  --color=fg:-1,fg+:#aac5e6,bg:-1,bg+:-1 \
  --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#87ff00 \
  --color=prompt:#d7005f,spinner:#af5fff,pointer:#af5fff,header:#87afaf \
  --color=border:#262626,label:#aeaeae,query:#d9d9d9 \
  --preview-window=border-rounded \
  --prompt='> ' \
  --marker='>' \
  --pointer='◆' \
  --separator='' \
  --scrollbar='│' \
  # --layout=reverse \
  --info=right
"


fish_add_path --path ~/.local/bin
fish_add_path --path ~/.cargo/bin
fish_add_path --path ~/.config/bin
fish_add_path --path ~/go/bin

# Initialize tools
zoxide init fish --cmd cd | source
starship init fish | source

select_venv

# test for existence of local.fish file
if test -f local.fish
  source local.fish
end

# Reloads fish in the root of the project or the closest local.fish file
function reload
  set pwd (pwd)
  for i in (seq 5)
    if test -f local.fish || test -d .git
      fish -C "cd $pwd"
      break
    end
    cd ..
  end
end

