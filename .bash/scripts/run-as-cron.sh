#!/bin/bash
# Run as if it was called from cron, that is to say:
#  * with a modified environment
#  * with a specific shell, which may or may not be bash
#  * without an attached input terminal
#  * in a non-interactive shell
# This scripts supports cron jobs run by any user, just run it as the target user (e.g. using sudo -u <username>)

# An up-to-date version of this script may be available at https://gist.github.com/daladim/7f67eb95d59aadc8f3e8cd66c6f235d3

function usage(){
    echo "$0 - Run a script or a command as it would be in a cron job, then display its output"
    echo "Usage:"
    echo "   $0 [command | script]"
    echo ""
    echo "This scripts supports cron jobs run by any user."
    echo "To do so, just run it as the target user (e.g. using sudo -u <username> $0)"
}

if [ "$#" -lt 1 -o "$1" == "-h" -o "$1" == "--help" ]; then
    usage
    exit 0
fi

# Depending on the distro, $HOME may or may not be affected by sudo.
# This is a better way to get the home directory of the current user
home=$( getent passwd "$(whoami)" | cut -d: -f6 )

cron_env="$home/.config/run-as-cron/cron-env"
function generate_env_file(){
    # This function adds /usr/bin/env to a cron job and makes sure it is run only once
    # i.e. it just helps the user who does not want to do it himself
    echo -n "Adding a job to cron, to be run once... "
    generator=$(mktemp /tmp/generator.cron.XXXX)
    chmod 700 "$generator"
    cat > "$generator" <<eof
#!/bin/bash
    mkdir -p $(dirname "$cron_env")
    /usr/bin/env > ${cron_env}
    # Remove this script from the current cron jobs
    crontab -l | sed "/$(basename $generator)/d" | crontab -
    rm "$generator"
eof
    # Add the just-created-script to cron
    crontab -l | { cat; echo "* * * * * $generator"; } | crontab -
    if [ "$?" -eq 0 ]; then
        echo "Done at $(date)"
        echo "It will be run shortly. You can try to run $0 again in a minute."
        return 0
    else
        echo "Failed."
        return 2
    fi
}

# This file should contain the cron environment.
if [ ! -f "$cron_env" ]; then
    echo "Unable to find $cron_env" >&2
    echo "To generate it, run \"/usr/bin/env > $cron_env\" as a cron job" >&2
    echo -n "Do you want this script to do it for you? [y/n] "
    read reply
    if [ "$reply" == "y" -o "$reply" == "Y" ]; then
        generate_env_file
        exit $?
    fi
    exit 1
fi

# It will be a nightmare to expand "$@" inside a shell -c argument.
# Let's rather generate a string where we manually expand-and-quote the arguments
# Note that may fail in case arguments (or environment variables) contain quotes...
env_string="/usr/bin/env -i "
while read -r line; do
    env_string="${env_string} \"$line\" "
done < "$cron_env"

cmd_string=""
for arg in "$@"; do
    cmd_string="${cmd_string} \"${arg}\" "
done

# Which shell should we use?
the_shell=$(grep -E "^SHELL=" "$cron_env" | sed 's/SHELL=//')
if [ -z "$the_shell" ]; then
    echo "Unable to detect what shell should be used for this user." >&2
    exit 2
fi
echo "Running with $the_shell the following command: $cmd_string"


# Let's route the output in a file
# and do not provide any input (so that the command is executed without an attached terminal)
so=$(mktemp "/tmp/fakecron.out.XXXX")
se=$(mktemp "/tmp/fakecron.err.XXXX")
"$the_shell" -c "$env_string $cmd_string" >"$so" 2>"$se" < /dev/null

echo -e "Done. Here is \033[1mstdout\033[0m:"
cat "$so"
echo -e "Done. Here is \033[1mstderr\033[0m:"
cat "$se"
rm "$so" "$se"
