if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fish_greeting

set -g __fish_git_prompt_show_informative_status true
set -g __fish_git_prompt_showcolorhints true

function prompt_hostname --description 'short hostname for the prompt'
    set -l string_replace string replace -r -- "\..*" ""
    if set -q CONTAINER_ID
        $string_replace $CONTAINER_ID
    else
        $string_replace $hostname
    end
end

function prompt_login --description "display user name for the prompt"
    if not set -q __fish_machine
        set -g __fish_machine
        set -l debian_chroot $debian_chroot

        if test -r /etc/debian_chroot
            set debian_chroot (cat /etc/debian_chroot)
        end

        if set -q debian_chroot[1]
            and test -n "$debian_chroot"
            set -g __fish_machine "(chroot:$debian_chroot)"
        end
    end

    # Prepend the chroot environment if present
    if set -q __fish_machine[1]
        echo -n -s (set_color yellow) "$__fish_machine" (set_color normal) ' '
    end

    if set -q CONTAINER_ID
        echo -n -s "📦" ''
    end

    # If we're running via SSH, change the host color.
    set -l color_host $fish_color_host
    if set -q SSH_TTY; and set -q fish_color_host_remote
        set color_host $fish_color_host_remote
    end

    echo -n -s (set_color $fish_color_user) "$USER" (set_color normal) @ (set_color $color_host) (prompt_hostname) (set_color normal)
end


function fish_title
    # If we're connected via ssh, we print the hostname.
    set -l ssh
    set -q SSH_TTY
    and set ssh "["(prompt_hostname | string sub -l 10 | string collect)"]"
    set -l dbox

    if set -q CONTAINER_ID
        set dbox "⬢"
    end

    # An override for the current command is passed as the first parameter.
    # This is used by `fg` to show the true process name, among others.
    if set -q argv[1]
        echo -- $ssh (string sub -l 20 -- $argv[1]) (prompt_pwd -d 1 -D 1)
    else
        # Don't print "fish" because it's redundant
        set -l command (status current-command)
        if test "$command" = fish
            set command
        end
        echo -- $dbox $ssh (string sub -l 20 -- $command) (prompt_pwd -d 1 -D 1)
    end
end
