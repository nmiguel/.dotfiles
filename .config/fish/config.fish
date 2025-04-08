# ~/.config/fish/config.fish

# Set PATH
set -gx PATH $HOME/.local/bin $HOME/.local/scripts $PATH
set fish_greeting

# Aliases
abbr v nvim
abbr docker-compose "docker compose"
abbr exp "explorer.exe ."
abbr wiztree "sudo ncdu / --exclude /mnt"
abbr svenv ". (fd -up '.*/bin/activate.fish')"

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

# function notes
#     cd ~/projects/personal/notes
#     set file (tv files)
#     if test -n "$file"
#         nvim $file
#     end
#     cd - > /dev/null 2>&1
# end

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

# .NET settings
set -gx DOTNET_ROOT $HOME/.dotnet
set -gx PATH $PATH $DOTNET_ROOT $DOTNET_ROOT/tools

# Go settings
set -gx GOROOT /usr/local/go
set -gx GOPATH $HOME/.go
set -gx GOBIN $GOPATH/bin
set -gx PATH $PATH /usr/local/go/bin $GOBIN
go env -w GOOS=windows

nvm use 23 --default --silent

pyenv init - fish | source

# Add Windows paths
set -gx PATH $PATH /home/nomig/.cargo/bin /mnt/c/Windows /mnt/c/Windows/System32 /mnt/c/Windows/System32/wbem /mnt/c/Windows/System32/Win /mnt/c/Windows/System32/WindowsPowerShell/v1.0

# TV initialization for fish
tv init fish | source

# Zoxide initialization for fish
zoxide init fish --cmd cd | source

# Starship prompt initialization for fish
starship init fish | source

# Key bindings (for autosuggestions, requires a fish autosuggestions plugin)
bind \cH backward-kill-word
bind \cY accept-autosuggestion

