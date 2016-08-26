#!/bin/bash

#################################################################
# Initial Environment
#################################################################

#################################################################
# Symbols
#################################################################
## ahead and behind
symbol_ahead=$(printf "%b" "\xE2\x87\xA1")
symbol_behind=$(printf "%b" "\xE2\x87\xA3")

#################################################################
# Color
#################################################################
vcs_fg_clean=0
vcs_fg_dirty=15
vcs_bg_clean=148
vcs_bg_dirty=161

cmd_passed_bg=0
cmd_passed_fg=15
cmd_failed_bg=196
cmd_failed_fg=15

#################################################################
# Function
#################################################################
## format
function color()
{
	prefix=$1
	code=$2
	echo $(printf "[%s;5;%sm" $prefix $code)
	return 0
}
function fgcolor()
{
	code=$1
	echo $(color "38" $code)
	return 0
}
function bgcolor()
{
	code=$1
	echo $(color "48" $code)
	return 0
}
function format_color()
{
	echo "\[\\e$(fgcolor $1)\]\[\\e$(bgcolor $2)\]"
}
function format()
{
	echo "$(format_color $1 $2)$3\[\e[0m\]"
}

## git
GIT=false
git_ps1=""
git_fg=$vcs_fg_clean
git_bg=$vcs_bg_clean
function get_git_status()
{
	git_status=$(git status --ignore-submodules 2>&1)
	GIT=$([ $? -eq 0 ] && echo true)
	if [[ "$GIT" = true ]]; then
		SED="sed -r"
		if [[ "$(uname -s)" = "Darwin" ]]; then
			SED="sed -E"
		fi
		#git_status="On branch xxoo Your branch is ahead of 'origin/master' by 1 commit and have 5 and 4 different commits each. (use \"git push\" to publish your local commits) Changes not staged for commit: (use \"git add <file>...\" to update what will be committed) (use \"git checkout -- <file>...\" to discard changes in working directory) modified: powerline.sh no changes added to commit (use \"git add\" and/or \"git commit -a\")"
		
		branch=$(echo "$git_status" | awk '{ if(NR == 1) print $3; else exit; }')
		has_pending_commits=true
		has_untracked_files=false
		origin_position=""

		if [[ "$git_status" =~ "nothing to commit" ]]; then
			has_pending_commits=false
		fi

		if [[ "$git_status" =~ "Untracked files" ]]; then
			has_untracked_files=true
		fi

		if [[ "$git_status" =~ "Your branch is ahead" ]] || [[ "$git_status" =~ "Your branch is behind" ]]; then
			origin_status=$(echo $git_status | $SED "s/.*Your branch is (ahead of|behind) .* by ([0-9]+) commit.*/\1 \2/g")
			if [[ "$origin_status" =~ "ahead" ]]; then
				origin_position="$(echo $origin_status | $SED 's/ahead of //g')$symbol_ahead"
			else
				origin_position="$(echo $origin_status | $SED 's/behind //g')$symbol_behind"
			fi
		fi
		diverged_pattern="and have [0-9]+ and [0-9]+ different commits each"
		if [[ "$git_status" =~ $diverged_pattern ]]; then
			diverged_status=$(echo $git_status | $SED "s/.*and have ([0-9]+) and ([0-9]+) different commits each.*/\1 \2/g")
			origin_position="$(echo $diverged_status | cut -d ' ' -f 1)$symbol_ahead$(echo $diverged_status | cut -d ' ' -f 2)$symbol_behind"
		fi
		if [[ -n $origin_position ]]; then
			result="$branch $origin_position"
		else
			result="$branch"
		fi
		if [[ "$has_untracked_files" = true ]]; then
			result="$result +"
		fi
		if [[ "$has_pending_commits" = true ]] || [[ "$has_untracked_files" = true ]]; then
			git_fg=$vcs_fg_dirty
			git_bg=$vcs_bg_dirty
		fi
		git_ps1=$result
	fi
}

## git
get_git_status

ps1="\[\e[0;33m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;36m\]\w\[\e[0m\]"
if [[ "$GIT" = true ]]; then
	ps1="$ps1 $(format $git_fg $git_bg "<$git_ps1>")"
fi

## Command
if [[ "$1" != "0" ]]; then
	ps1="$ps1 $(format $cmd_failed_fg $cmd_failed_bg '\$')\[\e[0m\]"
else
	ps1="$ps1 $(format $cmd_passed_fg $cmd_passed_bg '\$')\[\e[0m\]"
fi
echo $ps1

