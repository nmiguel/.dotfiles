set fish_greeting

# Aliases
abbr v nvim
abbr docker-compose "docker compose"
abbr exp "nohup xdg-open . >/dev/null 2>&1 & disown"
abbr wiztree "sudo ncdu / --exclude /mnt"
abbr svenv ". (fd -t d -u -d 2 'venv')/bin/activate.fish"

# Key bindings (for autosuggestions, requires a fish autosuggestions plugin)
bind \cH backward-kill-word
bind \cY accept-autosuggestion

# Custom functions
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
    bind ! bind_bang
    bind '$' bind_dollar
end


# Environment variables
set -gx EDITOR nvim
set -gx MANPAGER "nvim +Man!"

function add_to_path
  set -l path $argv[1]
  if test -d $path
    set -gx PATH $path $PATH
  end
end
add_to_path ~/.local/bin
add_to_path ~/.cargo/bin
add_to_path ~/go/bin

# TV initialization for fish
tv init fish | source

# Zoxide initialization for fish
zoxide init fish --cmd cd | source

# Starship prompt initialization for fish
starship init fish | source
