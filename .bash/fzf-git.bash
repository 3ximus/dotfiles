
# Functions using fzf to use in git

glfzf() {
	git rev-parse --is-inside-work-tree >/dev/null || return 1
	local cmd opts files
	files=$(sed -nE 's/.* -- (.*)/\1/p' <<< "$*") # extract files parameters for `git show` command
	cmd="echo {} |grep -Eo '[a-f0-9]+' |head -1 |xargs -I% git show --color=always % -- $files | delta"
	git log --all --oneline --graph \
		--pretty=format:'%C(yellow)%h%Creset %C(auto)%d%Creset %s (%Cblue%an%Creset, %cr)' \
		--date-order --color=always $* \
		| fzf --preview="$cmd" --ansi --no-sort --no-multi --reverse \
		--tiebreak=index \
		--bind="enter:execute($cmd | LESS='-r' less)"
}

gafzf() {
	# TODO not complete yet
	GIT_FUZZY_STATUS_ADD_KEY="${GIT_FUZZY_STATUS_ADD_KEY:-Alt-S}"
	GIT_FUZZY_STATUS_COMMIT_KEY="${GIT_FUZZY_STATUS_COMMIT_KEY:-Alt-C}"
	GIT_FUZZY_STATUS_RESET_KEY="${GIT_FUZZY_STATUS_RESET_KEY:-Alt-R}"
	GIT_FUZZY_STATUS_DISCARD_KEY="${GIT_FUZZY_STATUS_DISCARD_KEY:-Alt-U}"
	GF_STATUS_HEADER="Add all Alt-A${NORMAL}     ${GREEN}stage ${BOLD}⇡${NORMAL}  ${WHITE}$GIT_FUZZY_STATUS_ADD_KEY${NORMAL}     ${RED}${BOLD}discard ✗${NORMAL}  ${WHITE}$GIT_FUZZY_STATUS_DISCARD_KEY${NORMAL}"'
	'"${GREEN}none ☐${NORMAL}  ${WHITE}Alt-D${NORMAL}     ${GREEN}reset ${RED}${BOLD}⇣${NORMAL}  ${WHITE}$GIT_FUZZY_STATUS_RESET_KEY${NORMAL}    * ${RED}${BOLD}commit ${NORMAL}${RED}⇧${NORMAL}  ${WHITE}$GIT_FUZZY_STATUS_COMMIT_KEY${NORMAL}"'
	'
	cmd="git -c color.status=always -c status.relativePaths=true status -su"
	reload="reload:$cmd"

	$cmd \
		| fzf -m --header "$GF_STATUS_HEADER" \
		--expect="$GIT_FUZZY_STATUS_EDIT_KEY,$GIT_FUZZY_STATUS_COMMIT_KEY" \
		--reverse -0 -m --nth 2..,.. --ansi \
		--preview="git diff --color=always -- {+2..} | delta" \
		--bind "$GIT_FUZZY_STATUS_ADD_KEY:execute(git add {+2..})+down+$reload" \
		--bind "$GIT_FUZZY_STATUS_DISCARD_KEY:execute(git restore --staged {2..})+down+$RELOAD"
		# --bind "$GIT_FUZZY_STATUS_RESET_KEY:execute-silent(git fuzzy helper status_reset {+2..})+down+$RELOAD" \
}
