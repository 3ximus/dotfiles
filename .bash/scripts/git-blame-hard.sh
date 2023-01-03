#!/usr/bin/env bash
#
# Simple and efficient way to access various statistics in a git repository
################################################################################
# GLOBALS AND SHELL OPTIONS

# NOTE: Should we look into allowing for a customized config file so that the
#       user does not have to customize their shell's run command file or
#       manually override these every time they want to change them?
set -o nounset
set -o errexit

# Beginning git log date. Respects all git datetime formats
# If $_GIT_SINCE is never set, look at the repository to find the first date.
# NOTE: previously this put the date at the fixed GIT epoch (May 2005)
_since=${_GIT_SINCE:-}
if [[ -n "${_since}" ]]; then
    _since="--since=$_since"
else
    _since="--since=$(git log --reverse --format='%ad' | head -n1)"
fi

# End of git log date. Respects all git datetime formats
# If $_GIT_UNTIL is never set, choose the latest system
# time from the user's current environment
_until=${_GIT_UNTIL:-}
if [[ -n "${_until}" ]]; then
    _until="--until=$_until"
else
    _until="--until=$(date '+%a, %d %b %Y %H:%M:%S %Z')"
fi

# Set files or directories to be excluded in stats
# If $_GIT_PATHSPEC is not set, shift over the option completely
_pathspec=${_GIT_PATHSPEC:-}
if [[ -n "${_pathspec}" ]]; then
    _pathspec="-- $_pathspec"
else
    _pathspec="--"
fi

# Set merge commit view strategy. Default is to show no merge commits
# Exclusive shows only merge commits
# Enable shows regular commits together with normal commits
_merges=${_GIT_MERGE_VIEW:-}
_merges=$(echo "$_merges" | awk '{print tolower($0)}')
if [[ "${_merges}" == "exclusive" ]]; then
    _merges="--merges"
elif [[ "${_merges}" == "enable" ]]; then
    _merges=""
else
    _merges="--no-merges"
fi

# Limit git log output
_limit=${_GIT_LIMIT:-}
if [[ -n "${_limit}" ]]; then
    _limit=$_limit
else
    _limit=10
fi

# Log options
_log_options=${_GIT_LOG_OPTIONS:-}
if [[ -n "${_log_options}" ]]; then
    _log_options=$_log_options
else
    _log_options=""
fi

# Default menu theme
# Set the legacy theme by typing "export _MENU_THEME=legacy"
_theme="${_MENU_THEME:=default}"

################################################################################
# HELPER AND MENU FUNCTIONS

################################################################################
# DESC: Checks to make sure the user has the appropriate utilities installed
# ARGS: None
# OUTS: None
################################################################################
function checkUtils() {
    readonly MSG="not found. Please make sure this is installed and in PATH."
    readonly UTILS="awk basename cat column echo git grep head printf seq sort \
                    tput tr uniq"

    for u in $UTILS
    do
        command -v "$u" >/dev/null 2>&1 || { echo >&2 "$u ${MSG}"; exit 1; }
    done
}

################################################################################
# DESC: Prints a formatted message of the selected option by the user to stdout
# ARGS: $* (required): String to print (usually provided by other functions)
# OUTS: None
################################################################################
function optionPicked() {
    local msg=${*:-"Error: No message passed"}

    echo -e "${msg}\n"
}

################################################################################
# DESC: Help information printed to stdout during non-interactive mode
# ARGS: None
# OUTS: None
################################################################################
function usage() {
    readonly PROGRAM=$(basename "$0")

    echo "
NAME
    ${PROGRAM} - Simple and efficient way to access various stats in a git repo

SYNOPSIS
    For non-interactive mode: ${PROGRAM} [OPTIONS]
    For interactive mode: ${PROGRAM}

DESCRIPTION
    Any git repository contains tons of information about commits, contributors,
    and files. Extracting this information is not always trivial, mostly because
    of a gadzillion options to a gadzillion git commands.

    This program allows you to see detailed information about a git repository.

GENERATE OPTIONS
    -T, --detailed-git-stats
        give a detailed list of git stats
    -R, --git-stats-by-branch
        see detailed list of git stats by branch
    -c, --changelogs
        see changelogs
    -L, --changelogs-by-author
        see changelogs by author
    -S, --my-daily-stats
        see your current daily stats
    -V, --csv-output-by-branch
        output daily stats by branch in CSV format
    -j, --json-output
        save git log as a JSON formatted file to a specified area

LIST OPTIONS
    -b, --branch-tree
        show an ASCII graph of the git repo branch history
    -D, --branches-by-date
        show branches by date
    -C, --contributors
        see a list of everyone who contributed to the repo
    -a, --commits-per-author
        displays a list of commits per author
    -d, --commits-per-day
        displays a list of commits per day
    -m, --commits-by-month
        displays a list of commits per month
    -Y, --commits-by-year
        displays a list of commits per year
    -w, --commits-by-weekday
        displays a list of commits per weekday
    -o, --commits-by-hour
        displays a list of commits per hour
    -A, --commits-by-author-by-hour
        displays a list of commits per hour by author
    -z, --commits-by-timezone
        displays a list of commits per timezone
    -Z, --commits-by-author-by-timezone
        displays a list of commits per timezone by author

SUGGEST OPTIONS
    -r, --suggest-reviewers
        show the best people to contact to review code
    -h, -?, --help
        display this help text in the terminal

ADDITIONAL USAGE
    You can set _GIT_SINCE and _GIT_UNTIL to limit the git time log
        ex: export _GIT_SINCE=\"2017-01-20\"
    You can set _GIT_LIMIT for limited output log
        ex: export _GIT_LIMIT=20
    You can set _GIT_LOG_OPTIONS for git log options
        ex: export _GIT_LOG_OPTIONS=\"--ignore-all-space --ignore-blank-lines\"
    You can exclude directories or files from the stats by using pathspec
        ex: export _GIT_PATHSPEC=':!pattern'
    You can set _GIT_MERGE_VIEW to view merge commits with normal commits
        ex: export _GIT_MERGE_VIEW=enable
    You can also set _GIT_MERGE_VIEW to only show merge commits
        ex: export _GIT_MERGE_VIEW=exclusive
    You can set _MENU_THEME to display the legacy color scheme
        ex: export _MENU_THEME=legacy
    You can set _GIT_BRANCH to set the branch of the stats
        ex: export _GIT_BRANCH=master"
}

################################################################################
# DESC: Displays the interactive menu and saves the user supplied option
# ARGS: None
# OUTS: $opt: Option selected by the user based on menu choice
################################################################################
function showMenu() {
    # These are "global" and can be overriden from users if so desired
    NORMAL=$(tput sgr0)
    CYAN=$(tput setaf 6)
    BOLD=$(tput bold)
    RED=$(tput setaf 1)
    YELLOW=$(tput setaf 3)
    WHITE=$(tput setaf 7)
    TITLES=""
    TEXT=""
    NUMS=""
    HELP_TXT=""
    EXIT_TXT=""

    # Adjustable color menu option
    if [[ "${_theme}" == "legacy" ]]; then
        TITLES="${BOLD}${RED}"
        TEXT="${NORMAL}${CYAN}"
        NUMS="${BOLD}${YELLOW}"
        HELP_TXT="${NORMAL}${YELLOW}"
        EXIT_TXT="${BOLD}${RED}"
    else
        TITLES="${BOLD}${CYAN}"
        TEXT="${NORMAL}${WHITE}"
        NUMS="${NORMAL}${BOLD}${WHITE}"
        HELP_TXT="${NORMAL}${CYAN}"
        EXIT_TXT="${BOLD}${CYAN}"
    fi

    printf %b "\\n${TITLES} Generate:${NORMAL}\\n"
    printf %b "${NUMS}    1)${TEXT} Contribution stats (by author)\\n"
    printf %b "${NUMS}    2)${TEXT} Contribution stats (by author) on a specific branch\\n"
    printf %b "${NUMS}    3)${TEXT} Git changelogs (last $_limit days)\\n"
    printf %b "${NUMS}    4)${TEXT} Git changelogs by author\\n"
    printf %b "${NUMS}    5)${TEXT} My daily status\\n"
    printf %b "${NUMS}    6)${TEXT} Output daily stats by branch in CSV format\\n"
    printf %b "${NUMS}    7)${TEXT} Save git log output in JSON format\\n"
    printf %b "\\n${TITLES} List:\\n"
    printf %b "${NUMS}    8)${TEXT} Branch tree view (last $_limit)\\n"
    printf %b "${NUMS}    9)${TEXT} All branches (sorted by most recent commit)\\n"
    printf %b "${NUMS}   10)${TEXT} All contributors (sorted by name)\\n"
    printf %b "${NUMS}   11)${TEXT} Git commits per author\\n"
    printf %b "${NUMS}   12)${TEXT} Git commits per date\\n"
    printf %b "${NUMS}   13)${TEXT} Git commits per month\\n"
    printf %b "${NUMS}   14)${TEXT} Git commits per year\\n"
    printf %b "${NUMS}   15)${TEXT} Git commits per weekday\\n"
    printf %b "${NUMS}   16)${TEXT} Git commits per hour\\n"
    printf %b "${NUMS}   17)${TEXT} Git commits per hour by author\\n"
    printf %b "${NUMS}   18)${TEXT} Git commits per timezone\\n"
    printf %b "${NUMS}   19)${TEXT} Git commits per timezone by author\\n"
    printf %b "\\n${TITLES} Suggest:\\n"
    printf %b "${NUMS}   20)${TEXT} Code reviewers (based on git history)\\n"
    printf %b "\\n${HELP_TXT}Please enter a menu option or ${EXIT_TXT}press Enter to exit.\\n"
    printf %b "${TEXT}> ${NORMAL}"
    read -r opt
}

################################################################################
# FUNCTIONS FOR GENERATING STATS

################################################################################
# DESC: Shows detailed contribution stats per author by parsing every commit in
#       the repo and outputting their contribution stats
# ARGS: $branch (optional): Users can specify an alternative branch instead of
#                           the current default one
# OUTS: None
################################################################################
function detailedGitStats() {
    local is_branch_existing=false
    local branch="${1:-}"
    local _branch=""

    # Check if requesting for a specific branch
    if [[ -n "${branch}" ]]; then
        # Check if branch exist
        if [[ $(git show-ref refs/heads/"${branch}") ]] ; then
            is_branch_existing=true
            _branch="${branch}"
        else
            is_branch_existing=false
            _branch=""
        fi
    fi

    # Prompt message
    if [[ "${is_branch_existing}" && -n "${_branch}" ]]; then
        optionPicked "Contribution stats (by author) on ${_branch} branch:"
    elif [[ -n "${branch}" && -z "${_branch}" ]]; then
        optionPicked "Branch ${branch} does not exist."
        optionPicked "Contribution stats (by author) on the current branch:"
    else
        optionPicked "Contribution stats (by author) on the current branch:"
    fi

    git -c log.showSignature=false log ${_branch} --use-mailmap $_merges --numstat \
        --pretty="format:commit %H%nAuthor: %aN <%aE>%nDate:   %ad%n%n%w(0,4,4)%B%n" \
        "$_since" "$_until" $_log_options $_pathspec | LC_ALL=C awk '
        function printStats(author) {
        printf "\t%s:\n", author

        if(more["total"] > 0) {
            printf "\t  insertions:    %d\t(%.0f%%)\n", more[author], \
                (more[author] / more["total"] * 100)
        }

        if(less["total"] > 0) {
            printf "\t  deletions:     %d\t(%.0f%%)\n", less[author], \
                (less[author] / less["total"] * 100)
        }

        if(file["total"] > 0) {
            printf "\t  files:         %d\t(%.0f%%)\n", file[author], \
                (file[author] / file["total"] * 100)
        }

        if(commits["total"] > 0) {
            printf "\t  commits:       %d\t(%.0f%%)\n", commits[author], \
                (commits[author] / commits["total"] * 100)
        }

        if (first[author] != "") {
            if ( ((more["total"] + less["total"]) * 100) > 0) {
                printf "\t  lines changed: %d\t", more[author] + less[author]
                printf "(%.0f%%)\n", ((more[author] + less[author]) / \
                                      (more["total"] + less["total"]) * 100)
            }
            else {
                printf "\t  lines changed: %d\t(0%%)\n", (more[author] + less[author])
            }
            printf "\t  first commit:  %s\n", first[author]
            printf "\t  last commit:   %s\n", last[author]
        }

        printf "\n"
        }

        /^Author:/ {
        $1 = ""
        author = $0
        commits[author] += 1
        commits["total"] += 1
        }

        /^Date:/ {
        $1="";
        first[author] = substr($0, 2)
        if(last[author] == "" ) { last[author] = first[author] }
        }

        /^[0-9]/ {
        more[author] += $1
        less[author] += $2

        file[author] += 1
        more["total"]  += $1
        less["total"]  += $2
        file["total"]  += 1
        }

        END {
        for (author in commits) {
            if (author != "total") {
            printStats(author)
            }
        }
        printStats("total")
        }'
}

################################################################################
# DESC: Displays the latest commit history in an easy to read format by date
# ARGS: $author (optional): Can focus on a single author. Default is all authors
# OUTS: None
################################################################################
function changelogs() {
    local author="${1:-}"
    local _author=""
    local next=$(date +%F)

    if [[ -z "${author}" ]]; then
        optionPicked "Git changelogs:"
        _author="--author=**"
    else
        optionPicked "Git changelogs for author '${author}':"
        _author="--author=${author}"
    fi

    git -c log.showSignature=false log \
        --use-mailmap \
        $_merges \
        --format="%cd" \
        --date=short "${_author}" "$_since" "$_until" $_log_options $_pathspec \
        | sort -u -r | head -n $_limit \
        | while read DATE; do
              echo -e "\n[$DATE]"
              GIT_PAGER=cat git -c log.showSignature=false log \
                                --use-mailmap $_merges \
                                --format=" * %s (%aN)" "${_author}" \
                                --since=$DATE --until=$next
              next=$DATE
          done
}

################################################################################
# DESC: Shows git shortstats on the current user's changes for current day
# ARGS: None
# OUTS: None
################################################################################
function myDailyStats() {
    optionPicked "My daily status:"
    git diff --shortstat '@{0 day ago}' | sort -nr | tr ',' '\n' | LC_ALL=C awk '
    { args[NR] = $0; }
    END {
      for (i = 1; i <= NR; ++i) {
        printf "\t%s\n", args[i]
      }
    }'

    echo -e "\t" $(git -c log.showSignature=false log --use-mailmap \
                       --author="$(git config user.name)" $_merges \
                       --since=$(date "+%Y-%m-%dT00:00:00") \
                       --until=$(date "+%Y-%m-%dT23:59:59") --reverse $_log_options \
                       | grep -cE "commit [a-f0-9]{40}") "commits"
}

################################################################################
# DESC: Shows detailed contribution stats per author by parsing every commit in
#       the repo and outputting their contribution stats
# ARGS: $branch (optional): Users can specify an alternative branch instead of
#                           the current default one
# OUTS: None
################################################################################
function csvOutput() {
    # TODO: Look into if we can refactor this to work as an option for the user
    #       so they can choose between JSON or CSV or possibly other formats
    #       like XML, YAML, and so on.
    # TODO: Look into allowing the user to adjust the separator value
    local is_branch_existing=false
    local branch="${1:-}"
    local _branch=""

    # Check if requesting for a specific branch
    if [[ -n "${branch}" ]]; then
        # Check if branch exist
        if [[ $(git show-ref refs/heads/"${branch}") ]] ; then
            is_branch_existing=true
            _branch="${branch}"
        else
            is_branch_existing=false
            _branch=""
        fi
    fi

    printf "author,insertions,insertions_per,deletions,deletions_per,files,"
    printf "files_per,commits,commits_per,lines_changed,lines_changed_per\n"
    git -c log.showSignature=false log ${_branch} --use-mailmap $_merges --numstat \
        --pretty="format:commit %H%nAuthor: %aN <%aE>%nDate:   %ad%n%n%w(0,4,4)%B%n" \
        "$_since" "$_until" $_log_options $_pathspec | LC_ALL=C awk '
        function printStats(author) {
        printf "%s,", author
        if(more["total"] > 0) {
            printf "%d,%.0f%%,", more[author], \
                (more[author] / more["total"] * 100)
        }

        if(less["total"] > 0) {
            printf "%d,%.0f%%,", less[author], \
                (less[author] / less["total"] * 100)
        }

        if(file["total"] > 0) {
            printf "%d,%.0f%%,", file[author], \
                (file[author] / file["total"] * 100)
        }

        if(commits["total"] > 0) {
            printf "%d,%.0f%%,", commits[author], \
                (commits[author] / commits["total"] * 100)
        }

        if (first[author] != "") {
            if ( ((more["total"] + less["total"]) * 100) > 0) {
                printf "%d,", more[author] + less[author]
                printf "%.0f%%\n", ((more[author] + less[author]) / \
                                      (more["total"] + less["total"]) * 100)
            }
        }
        }

        /^Author:/ {
        $1 = ""
        author = $0
        commits[author] += 1
        commits["total"] += 1
        }

        /^Date:/ {
        $1="";
        first[author] = substr($0, 2)
        if(last[author] == "" ) { last[author] = first[author] }
        }

        /^[0-9]/ {
        more[author] += $1
        less[author] += $2

        file[author] += 1
        more["total"]  += $1
        less["total"]  += $2
        file["total"]  += 1
        }

        END {
        for (author in commits) {
            if (author != "total") {
            printStats(author)
            }
        }

        }'
}

################################################################################
# DESC: Transforms special multiline string sequence to a JSON string property.
#       {propTag}{optional white space indentation}{property}
#       {line1}
#       {line2}
#       ...
#       {propTag}, (the final comma is optional)
#       Generates: "{property}": "{line1}\n{line2}\n...",
#       The final comma is added if present after the ending tag.
#       Caveat: the content should not contain {propTag} at the
#       beginning of a line.
# ARGS: $propTag (optional) : tag at the beginning of the line to mark the
#       beginning and the end of a special sequence. It must not contain
#       regular expression special characters, i.e. use [a-zA-Z0-9_]+.
#       This tag should be sufficiently random to avoid collision with
#       the actual content. Defaults to __JSONPROP__.
# OUTS: content with JSON string properties
################################################################################
function toJsonProp() {
    local propTag="${1:-__JSONPROP__}"
    sed -n -E '
# transforms the special sequence.
/^'"$propTag"'[^\r]/ {
    # remove the special prefix, keep the property name followed by :
    s/^'"$propTag"'([^\r]+)\r?$/\1:/g;
    # hold in buffer, get the next line.
    h;n
    # loop
    b eos
    :eos {
        # add in hold buffer and loop while the string is not finished.
        /^'"$propTag"',?\r?$/ ! { H; n; b eos; }
        # end of the string, flip buffer to current pattern.
		# keeps the comma if any, or a space as an empty placeholder.
		/,\r?$/ ! { x; s/\r?$/ / }
		/,\r?$/   { x; s/\r?$/,/ }
    }
    # replace special JSON string chars.
    s/["\\]/\\&/g;
    # replace control chars, carriage returns, line feeds, tabulations, etc.
    s/\x00/\\u0000/g; s/\x01/\\u0001/g; s/\x02/\\u0002/g; s/\x03/\\u0003/g;
    s/\x04/\\u0004/g; s/\x05/\\u0005/g; s/\x06/\\u0006/g; s/\x07/\\u0007/g;
    s/\x08/\\b/g;     s/\x09/\\t/g;     s/\x0a/\\n/g;     s/\x0b/\\u000b/g;
    s/\x0c/\\f/g;     s/\x0d/\\r/g;     s/\x0e/\\u000e/g; s/\x0f/\\u000f/g;
    s/\x10/\\u0010/g; s/\x11/\\u0011/g; s/\x12/\\u0012/g; s/\x13/\\u0013/g;
    s/\x14/\\u0014/g; s/\x15/\\u0015/g; s/\x16/\\u0016/g; s/\x17/\\u0017/g;
    s/\x18/\\u0018/g; s/\x19/\\u0019/g; s/\x1a/\\u001a/g; s/\x1b/\\u001b/g;
    s/\x1c/\\u001c/g; s/\x1d/\\u001d/g; s/\x1e/\\u001e/g; s/\x1f/\\u001f/g;
    s/\x7f/\\u007f/g;

    # format the JSON property name, optionally indented, open quote for value.
    s/^(\s*)([^:]+):\\n/\1"\2": "/g;
    # handle the final comma if present, and close the quote for value.
    /,$/ { s/,$/",/g; }
    # otherwise remove final space placeholder and close the quote for value.
    /,$/ ! { s/ $/"/g; }
}
# print lines.
p'
}

################################################################################
# DESC: Saves the git log output in a JSON format
# ARGS: $json_path (required): Path to where the file is saved
# OUTS: A JSON formatted file
################################################################################
function jsonOutput() {
    optionPicked "Output log saved to file at: ${json_path}/output.json"
    local propTag="__JSONPROP${RANDOM}__"
    git -c log.showSignature=false log --use-mailmap $_merges "$_since" "$_until" $_log_options \
        --pretty=format:'{%n  "commit": "%H",%n  "abbreviated_commit": "%h",%n  "tree": "%T",%n'\
'  "abbreviated_tree": "%t",%n  "parent": "%P",%n  "abbreviated_parent": "%p",%n  "refs": "%D",%n  "encoding": "%e",%n'\
"$propTag"'  subject%n%s%n'"$propTag"',%n  "sanitized_subject_line": "%f",%n'\
"$propTag"'  body%n%b%n'"$propTag"',%n'\
"$propTag"'  commit_notes%n%N%n'"$propTag"',%n  "author": {%n'\
"$propTag"'    name%n%aN%n'"$propTag"',%n'\
"$propTag"'    email%n%aE%n'"$propTag"',%n'\
'    "date": "%aD"%n  },%n  "commiter": {%n'\
"$propTag"'    name%n%cN%n'"$propTag"',%n'\
"$propTag"'    email%n%cE%n'"$propTag"',%n'\
'    "date": "%cD"%n  }%n},' \
        | toJsonProp "$propTag" \
        | sed "$ s/,$//" \
        | sed ':a;N;$!ba;s/\r\n\([^{]\)/\\n\1/g' \
        | awk 'BEGIN { print("[") } { print($0) } END { print("]") }' \
        > "${json_path}/output.json"
}

################################################################################
# FUNCTIONS FOR LISTING STATS

################################################################################
# DESC: Shows an abbreviated ASCII graph based off of commit history
# ARGS: None
# OUTS: None
################################################################################
function branchTree() {
    optionPicked "Branching tree view:"
    # TODO: Can we shorten this pretty format line? Quick experiment shows that
    #       it does not properly respect \ and interprets them literally.
    git -c log.showSignature=false log --use-mailmap --graph --abbrev-commit \
        "$_since" "$_until" --decorate \
        --format=format:'--+ Commit:  %h %n  | Date:    %aD (%ar) %n''  | Message: %s %d %n''  + Author:  %aN %n' \
        --all $_log_options | head -n $((_limit*5))
}

################################################################################
# DESC: Lists all branches sorted by their most recent commit
# ARGS: None
# OUTS: None
################################################################################
function branchesByDate() {
    optionPicked "All branches (sorted by most recent commit):"
    git for-each-ref --sort=committerdate refs/heads/ \
        --format='[%(authordate:relative)] %(authorname) %(refname:short)' | cat -n
}

################################################################################
# DESC: Lists all contributors to a repo sorted by alphabetical order
# ARGS: None
# OUTS: None
################################################################################
function contributors() {
    optionPicked "All contributors (sorted by name):"
    git -c log.showSignature=false log --use-mailmap $_merges "$_since" "$_until" \
        --format='%aN' $_log_options $_pathspec | sort -u | cat -n
}

################################################################################
# DESC: Displays the number of commits and percentage contributed to the repo
#       per author and sorts them by contribution percentage
# ARGS: None
# OUTS: None
################################################################################
function commitsPerAuthor()  {
    optionPicked "Git commits per author:"
    local authorCommits=$(git -c log.showSignature=false log --use-mailmap \
                          $_merges "$_since" "$_until" $_log_options \
                          | grep -i Author: | cut -c9-)
    local coAuthorCommits=$(git -c log.showSignature=false log --use-mailmap \
                            $_merges "$_since" "$_until" $_log_options \
                            | grep -i Co-Authored-by: | cut -c21-)

    if [[ -z "${coAuthorCommits}" ]]; then
        allCommits="${authorCommits}"
    else
        allCommits="${authorCommits}\n${coAuthorCommits}"
    fi

    echo -e "${allCommits}" | awk '
      { $NF=""; author[NR] = $0 }
      END {
        for(i in author) {
          sum[author[i]]++; name[author[i]] = author[i]; total++;
        }
        for(i in sum) {
          printf "\t%d:%s:%2.1f%%\n", sum[i], name[i], (100 * sum[i] / total)
        }
      }' | sort -n -r | column -t -s:
}

################################################################################
# DESC: Shows the number of commits that were committed per date recorded in the
#       repo's log history
# ARGS: None
# OUTS: None
################################################################################
function commitsPerDay() {
    optionPicked "Git commits per date:";
    git -c log.showSignature=false log --use-mailmap $_merges "$_since" "$_until" \
        --date=short --format='%ad' $_log_options $_pathspec | sort | uniq -c
}

################################################################################
# DESC: Displays a horizontal bar graph based on total commits per year
# ARGS: None
# OUTS: None
################################################################################
function commitsByYear() {
    optionPicked "Git commits by year:"
    local year startYear endYear __since __until
    startYear=$(echo "$_since" | sed -E 's/^.* ([0-9]{4})( .*)?$/\1/')
    endYear=$(echo "$_until" | sed -E 's/^.* ([0-9]{4})( .*)?$/\1/')

    echo -e "\tyear\tsum"
    for year in $(seq "$startYear" "$endYear")
    do
        if [ "$year" = "$startYear" ]
        then
          __since=$_since
          __until="--until=$year-12-31"
        elif [ "$year" = "$endYear" ]
        then
          __since="--since=$year-01-01"
          __until=$_until
        else
          __since="--since=$year-01-01"
          __until="--until=$year-12-31"
        fi

        echo -en "\t$year\t"
        git -c log.showSignature=false shortlog -n $_merges --format='%ad %s' \
            "$__since" "$__until" $_log_options | grep -cE \
              " \w\w\w [0-9]{1,2} [0-9][0-9]:[0-9][0-9]:[0-9][0-9] $year " \
                || continue
    done | awk '{
        count[$1] = $2
        total += $2
    }
    END{
        for (year in count) {
            s="|";
            if (total > 0) {
                percent = ((count[year] / total) * 100) / 1.25;
                for (i = 1; i <= percent; ++i) {
                    s=s"█"
                }
                printf( "\t%s\t%-0s\t%s\n", year, count[year], s );
            }
        }
    }' | sort
}

################################################################################
# DESC: Displays a horizontal bar graph based on total commits per month
# ARGS: None
# OUTS: None
################################################################################
function commitsByMonth() {
    optionPicked "Git commits by month:"
    echo -e "\tmonth\tsum"
    local i
    for i in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
    do
        echo -en "\t$i\t"
        git -c log.showSignature=false shortlog -n $_merges --format='%ad %s' \
            "$_since" "$_until" $_log_options |
            grep -cE " \w\w\w $i [0-9]{1,2} " || continue
    done | awk '{
        count[$1] = $2
        total += $2
    }
    END{
        for (month in count) {
            s="|";
            if (total > 0) {
                percent = ((count[month] / total) * 100) / 1.25;
                for (i = 1; i <= percent; ++i) {
                    s=s"█"
                }
                printf( "\t%s\t%-0s\t%s\n", month, count[month], s );
            }
        }
    }' | LC_TIME="en_EN.UTF-8" sort -M
}

################################################################################
# DESC: Displays a horizontal bar graph based on total commits per weekday
# ARGS: None
# OUTS: None
################################################################################
function commitsByWeekday() {
    optionPicked "Git commits by weekday:"
    echo -e "\tday\tsum"
    local i counter=1
    for i in Mon Tue Wed Thu Fri Sat Sun
    do
        echo -en "\t$counter\t$i\t"
        git -c log.showSignature=false shortlog -n $_merges --format='%ad %s' \
            "$_since" "$_until" $_log_options |
            grep -cE "^ * $i \w\w\w [0-9]{1,2} " || continue
        counter=$((counter+1))
    done | awk '{
    }
    NR == FNR {
        count[$1" "$2] = $3;
        total += $3;
        next
    }
    END{
        for (day in count) {
            s="|";
            if (total > 0) {
                percent = ((count[day] / total) * 100) / 1.25;
                for (i = 1; i <= percent; ++i) {
                    s=s"█"
                }
                printf("\t%s\t%s\t%-0s\t%s\n", substr(day,0,1), substr(day,3,5), count[day], s);
            }
        }
    }' | sort -k 1 -n | awk '{$1=""}1' | awk '{$1=$1}1' \
       | awk '{printf("\t%s\t%s\t%s\n", $1, $2, $3)}'
}

################################################################################
# DESC: Displays a horizontal bar graph based on total commits per hour
# ARGS: $author (optional): Can focus on a single author. Default is all authors
# OUTS: None
################################################################################
function commitsByHour() {
    local author="${1:-}"
    local _author=""

    if [[ -z "${author}" ]]; then
        optionPicked "Git commits by hour:"
        _author="--author=**"
    else
        optionPicked "Git commits by hour for author '${author}':"
        _author="--author=${author}"
    fi
    echo -e "\thour\tsum"

    local i
    for i in $(seq -w 0 23)
    do
        echo -ne "\t$i\t"
        git -c log.showSignature=false shortlog -n $_merges --format='%ad %s' \
            "${_author}" "$_since" "$_until" $_log_options |
            grep -cE '[0-9] '$i':[0-9]' || continue
    done | awk '{
        count[$1] = $2
        total += $2
    }
    END{
        for (hour in count) {
            s="|";
            if (total > 0) {
                percent = ((count[hour] / total) * 100) / 1.25;
                for (i = 1; i <= percent; ++i) {
                    s=s"█"
                }
                printf( "\t%s\t%-0s\t%s\n", hour, count[hour], s );
            }
        }
    }' | sort
}

################################################################################
# DESC: Displays number of commits per timezone
# ARGS: $author (optional): Can focus on a single author. Default is all authors
# OUTS: None
################################################################################
function commitsByTimezone() {
    local author="${1:-}"
    local _author=""

    if [[ -z "${author}" ]]; then
        optionPicked "Git commits by timezone:"
        _author="--author=**"
    else
        optionPicked "Git commits by timezone for author '${author}':"
        _author="--author=${author}"
    fi

    echo -e "Commits\tTimeZone"
    git -c log.showSignature=false shortlog -n $_merges --format='%ad %s' \
        "${_author}" "$_since" "$_until" --date=iso $_log_options $_pathspec \
        | cut -d " " -f 12 | grep -v -e '^[[:space:]]*$' | sort | uniq -c
}

################################################################################
# FUNCTIONS FOR SUGGESTION STATS

################################################################################
# DESC: Displays the authors in order of total contribution to the repo
# ARGS: None
# OUTS: None
################################################################################
function suggestReviewers() {
    optionPicked "Suggested code reviewers (based on git history):"
    git -c log.showSignature=false log --use-mailmap $_merges "$_since" "$_until" \
        --pretty=%aN $_log_options $_pathspec | head -n 100 | sort | uniq -c \
        | sort -nr | LC_ALL=C awk '
    { args[NR] = $0; }
    END {
      for (i = 1; i <= NR; ++i) {
        printf "%s\n", args[i]
      }
    }' | column -t -s,
}

################################################################################
# MAIN

# Check to make sure all utilities required for this script are installed
checkUtils

# Check if we are currently in a git repo.
git rev-parse --is-inside-work-tree > /dev/null

# Parse non-interative commands
if [[ "$#" -eq 1 ]]; then
    case "$1" in
        # GENERATE OPTIONS
        -T|--detailed-git-stats) detailedGitStats;;
        -R|--git-stats-by-branch)
            branch="${_GIT_BRANCH:-}"
            while [[ -z "${branch}" ]]; do
                read -r -p "Which branch? " branch
            done
            detailedGitStats "${branch}";;
        -c|--changelogs) changelogs;;
        -L|--changelogs-by-author)
            author="${_GIT_AUTHOR:-}"
            while [[ -z "${author}" ]]; do
                read -r -p "Which author? " author
            done
            changelogs "${author}";;
        -S|--my-daily-stats) myDailyStats;;
        -V|--csv-output-by-branch)
            branch="${_GIT_BRANCH:-}"
            while [[ -z "${branch}" ]]; do
                read -r -p "Which branch? " branch
            done
            csvOutput "${branch}";;
        -j|--json-output)
            json_path=""
            while [[ -z "${json_path}" ]]; do
                echo "NOTE: This feature is in beta!"
                echo "The file name will be saved as \"output.json\"."
                echo "The full path must be provided."
                echo "Variables or shorthands such as ~ are not valid."
                echo "You do not need the final slash at the end of a directory path."
                echo "You must have write permission to the folder you are trying to save this to."
                echo "This feature only works interactively and cannot be combined with other options."
                echo -e "Example of a valid path: /home/$(whoami)\n"
                read -r -p "Please provide the full path to directory to save JSON file: " json_path
                if [[ ! -w "${json_path}" ]]; then
                    echo "Invalid path or permission denied to write to given area."
                    json_path=""
                fi
            done
            jsonOutput "${json_path}";;
        # LIST OPTIONS
        -b|--branch-tree) branchTree;;
        -D|--branches-by-date) branchesByDate;;
        -C|--contributors) contributors;;
        -a|--commits-per-author) commitsPerAuthor;;
        -d|--commits-per-day) commitsPerDay;;
        -Y|--commits-by-year ) commitsByYear;;
        -m|--commits-by-month) commitsByMonth;;
        -w|--commits-by-weekday) commitsByWeekday;;
        -o|--commits-by-hour) commitsByHour;;
        -A|--commits-by-author-by-hour)
            author="${_GIT_AUTHOR:-}"
            while [[ -z "${author}" ]]; do
                read -r -p "Which author? " author
            done
            commitsByHour "${author}";;
        -z|--commits-by-timezone) commitsByTimezone;;
        -Z|--commits-by-author-by-timezone)
            author="${_GIT_AUTHOR:-}"
            while [[ -z "${author}" ]]; do
                read -r -p "Which author? " author
            done
            commitsByTimezone "${author}";;
        # SUGGEST OPTIONS
        -r|--suggest-reviewers) suggestReviewers;;
        -h|-\?|--help) usage;;
        *) echo "Invalid argument"; usage; exit 1;;
    esac
    exit 0;
fi
[[ "$#" -gt 1 ]] && { echo "Invalid arguments"; usage; exit 1; }

# Parse interactive commands
clear
showMenu

while [[ "${opt}" != "" ]]; do
    clear
    case "${opt}" in
        1) detailedGitStats; showMenu;;
        2) branch=""
           while [[ -z "${branch}" ]]; do
               read -r -p "Which branch? " branch
           done
           detailedGitStats "${branch}"; showMenu;;
        3) changelogs; showMenu;;
        4) author=""
           while [[ -z "${author}" ]]; do
               read -r -p "Which author? " author
           done
           changelogs "${author}"; showMenu;;
        5) myDailyStats; showMenu;;
        6) branch=""
           while [[ -z "${branch}" ]]; do
               read -r -p "Which branch? " branch
           done
           csvOutput "${branch}"; showMenu;;
        7) json_path=""
           while [[ -z "${json_path}" ]]; do
               echo "NOTE: This feature is in beta!"
               echo "The file name will be saved as \"output.json\"."
               echo "The full path must be provided."
               echo "Variables, subshell commands, or shorthands such as ~ may not be valid."
               echo "You do not need the final slash at the end of a directory path."
               echo "You must have write permission to the folder you are trying to save this to."
               echo "This feature only works interactively and cannot be combined with other options."
               echo -e "Example of a valid path: /home/$(whoami)\n"
               read -r -p "Please provide the full path to directory to save JSON file: " json_path
               if [[ ! -w "${json_path}" ]]; then
                   echo "Invalid path or permission denied to write to given area."
                   json_path=""
               fi
           done
           jsonOutput "${json_path}"; showMenu;;
        8) branchTree; showMenu;;
        9) branchesByDate; showMenu;;
       10) contributors; showMenu;;
       11) commitsPerAuthor; showMenu;;
       12) commitsPerDay; showMenu;;
       13) commitsByMonth; showMenu;;
       14) commitsByYear; showMenu;;
       15) commitsByWeekday; showMenu;;
       16) commitsByHour; showMenu;;
       17) author=""
           while [[ -z "${author}" ]]; do
               read -r -p "Which author? " author
           done
           commitsByHour "${author}"; showMenu;;
       18) commitsByTimezone; showMenu;;
       19) author=""
           while [[ -z "${author}" ]]; do
               read -r -p "Which author? " author
           done
           commitsByTimezone "${author}"; showMenu;;
       20) suggestReviewers; showMenu;;
       q|"\n") exit;;
       *) clear; optionPicked "Pick an option from the menu"; showMenu;;
    esac
done
