
# Functions using fzf to use in git
# Inspired by: https://github.com/wfxr/forgit and https://github.com/bigH/git-fuzzy

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
	local cmd reload _stage_key _commit_key _reset_key _discard_key header

	_stage_key="${GIT_FUZZY_STATUS_ADD_KEY:-Alt-S}"
	_commit_key="${GIT_FUZZY_STATUS_COMMIT_KEY:-Alt-C}"
	_reset_key="${GIT_FUZZY_STATUS_RESET_KEY:-Alt-R}"
	_discard_key="${GIT_FUZZY_STATUS_DISCARD_KEY:-Alt-U}"

	header="Stage: $_stage_key / Unstage: $_discard_key / Commit: $_commit_key"

	cmd="git -c color.status=always -c status.relativePaths=true status -su"
	reload="reload:$cmd"

	$cmd \
		| fzf -m --header "$header" \
		--reverse -0 -m --nth 2..,.. --ansi \
		--expect="$_commit_key" \
		--preview="git diff --color=always -- {+2..} | delta" \
		--bind "$_stage_key:execute-silent(git add {+2..})+down+$reload" \
		--bind "Alt-A:execute-silent(git add {+2..})+down+$reload" \
		--bind "$_discard_key:execute-silent(git restore --staged {2..})+down+$reload" \
		| [ "$(head -n1)" = "$_commit_key" ] && git commit || return 0
		# --bind "$_reset_key:execute-silent(git reset {2..}))+down+$reload" \
}