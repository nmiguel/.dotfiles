set fish_greeting

# Aliases
abbr v nvim
abbr docker-compose "docker compose"
abbr exp "nohup xdg-open . >/dev/null 2>&1 & disown"
abbr wiztree "sudo ncdu / --exclude /mnt"
# abbr svenv ". (fd -t d -u -d 2 'venv')/bin/activate.fish"

function select_venv
    set venv_path (fd --type d --max-depth 2 --unrestricted 'venv' . | head -n 1)
    if test -n "$venv_path" -a -f "$venv_path/bin/activate.fish"
        source "$venv_path/bin/activate.fish"
    end
end

# Key bindings (for autosuggestions, requires a fish autosuggestions plugin)
bind \cH backward-kill-word
bind \cY accept-autosuggestion
bind \cR search_history

# Custom functions
function search_history
    set cmd (history | fzf)
    if test -n "$cmd"
        commandline -r -- $cmd
        # commandline -f execute
    end
end

function notes
    cd ~/projects/personal/notes
    if test (count $argv) -gt 0
        nvim $argv[1].md
    else
        set file (fzf)
        nvim "$file"
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
    bind ! bind_bang
    bind '$' bind_dollar
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



function add_to_path
  set -l path $argv[1]
  if test -d $path
    set -gx PATH $path $PATH
  end
end

add_to_path ~/.local/bin
add_to_path ~/.cargo/bin
add_to_path ~/.config/bin
add_to_path ~/go/bin

# Zoxide initialization for fish
zoxide init fish --cmd cd | source

# Starship prompt initialization for fish
starship init fish | source

select_venv
