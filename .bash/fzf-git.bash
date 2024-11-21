# vim: foldnestmax=1 foldmethod=indent
#
# Functions using fzf to use in git
# Inspired by: https://github.com/wfxr/forgit and https://github.com/bigH/git-fuzzy

glf() {
	git rev-parse --is-inside-work-tree >/dev/null || return 1
	local cmd opts files
	files=$(sed -nE 's/.* -- (.*)/\1/p' <<< "$*") # extract files parameters for `git show` command
	cmd="echo {} |grep -Eo '[a-f0-9]+' |head -1 |xargs -I% git show --color=always % -- $files | delta"
	git log --oneline --graph \
		--pretty=format:'%C(yellow)%h%Creset %C(auto)%d%Creset %s (%Cblue%an%Creset, %cr)' \
		--date-order --color=always $* \
		| command fzf --preview="$cmd" --ansi --no-sort --no-multi --reverse \
		--tiebreak=index \
		--min-height 20 \
		--bind="enter:execute($cmd | LESS='-r' less)"
}

glfa() {
	git rev-parse --is-inside-work-tree >/dev/null || return 1
	local cmd opts files
	files=$(sed -nE 's/.* -- (.*)/\1/p' <<< "$*") # extract files parameters for `git show` command
	cmd="echo {} |grep -Eo '[a-f0-9]+' |head -1 |xargs -I% git show --color=always % -- $files | delta"
	git log --all --oneline --graph \
		--pretty=format:'%C(yellow)%h%Creset %C(auto)%d%Creset %s (%Cblue%an%Creset, %cr)' \
		--date-order --color=always $* \
		| command fzf --preview="$cmd" --ansi --no-sort --no-multi --reverse \
		--tiebreak=index \
		--no-info \
		--min-height 20 \
		--bind="enter:execute($cmd | LESS='-r' less)"
}

gbf() {
	git branch -avv --color --sort=v:refname | fzf \
		--preview="echo {} |grep -Eo '[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]'|xargs -n1 git diff | delta" \
		--ansi --no-multi --reverse \
		--tiebreak=index \
		--no-info \
		| grep -Po '(?<=^. )[^ ]+ ' | xargs -n1 git switch
}

gaf() {
	local cmd reload _stage_key _commit_key _reset_key _discard_key header

	_stage_key="${GIT_FZF_STATUS_ADD_KEY:-ctrl-S}"
	_commit_key="${GIT_FZF_STATUS_COMMIT_KEY:-ctrl-C}"
	_reset_key="${GIT_FZF_STATUS_RESET_KEY:-ctrl-R}"
	_discard_key="${GIT_FZF_STATUS_DISCARD_KEY:-ctrl-U}"

	header="Stage: $_stage_key / Unstage: $_discard_key / Commit: $_commit_key"

	cmd="git -c color.status=always -c status.relativePaths=true status -su"
	reload="reload:$cmd"

	$cmd \
		| fzf -m --header "$header" \
		--no-info \
		--reverse -0 -m --nth 2..,.. --ansi \
		--height 50% --min-height 20 \
		--expect="$_commit_key" \
		--preview="git diff --color=always -- {+2..} | delta" \
		--bind "$_stage_key:execute-silent(git add {+2..})+down+$reload" \
		--bind "$_discard_key:execute-silent(git restore --staged {2..})+down+$reload" \
		| [ "$(head -n1)" = "$_commit_key" ] && git commit || return 0
		# --bind "$_reset_key:execute-silent(git reset {2..}))+down+$reload" \
}
