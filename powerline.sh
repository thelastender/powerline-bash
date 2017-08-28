#!/bin/bash

HOME_SPECIAL_DISPLAY=true
HOME_BG=31  # blueish
HOME_FG=15  # white
CWD_FG=254  # nearly-white grey

READONLY_BG=124
READONLY_FG=254

SSH_BG=166 # medium orange                                                                                                              
SSH_FG=254                                                                                                                              

REPO_CLEAN_BG=148  # a light green color                                                                                                
REPO_CLEAN_FG=0  # black                                                                                                                
REPO_DIRTY_BG=161  # pink/red                                                                                                           
REPO_DIRTY_FG=15  # white                                                                                                               

JOBS_FG=39                                                                                                                              
JOBS_BG=238                                                                                                                             

SVN_CHANGES_BG=148                                                                                                                      
SVN_CHANGES_FG=22  # dark green    

#################################################################
# Initial Environment
#################################################################

#################################################################
# Symbols
#################################################################
## lock, network, separator, separator_thin
symbol_lock=$(printf "%b" "\xEE\x82\xA2")
symbol_network=$(printf "%b" "\xEE\x82\xA2")
symbol_separator=$(printf "%b" "\xEE\x82\xB0")
symbol_separator_thin=$(printf "%b" "\xEE\x82\xB1")
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

username_fg=250
username_bg=240
username_root_bg=124

hostname_fg=101
hostname_bg=47

path_bg=237  # dark grey
path_fg=250  # light grey

separator_fg=244

cmd_passed_bg=236
cmd_passed_fg=15
cmd_failed_bg=161
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
	echo $(format_color $1 $2)$3
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

		result=" $branch $origin_position"
		if [[ "$has_untracked_files" = true ]]; then
			result="$result+"
		fi
		if [[ "$has_pending_commits" = true ]] || [[ "$has_untracked_files" = true ]]; then
			git_fg=$vcs_fg_dirty
			git_bg=$vcs_bg_dirty
		fi
		git_ps1=$result
	fi
}

## svn
SVN=false
svn_ps1=""
svn_fg=$vcs_fg_clean
svn_bg=$vcs_bg_clean
function get_svn_status()
{
	svn_status=$(svn status 2>&1)
	if [[ "$svn_status" =~ "is not a working copy" ]]; then
		return 0;
	fi
	SVN=true
	has_pending_commits=false
	has_untracked_files=false
	origin_position=" svn "
	origin_status=$(echo "$svn_status" | grep -c "^[ACDIMR\!~]")
	if [[ $origin_status > 0 ]]; then
		has_pending_commits=true
		svn_fg=$vcs_fg_dirty
		svn_bg=$vcs_bg_dirty
		origin_position="$origin_position$origin_status "
	fi
	untracked_files_count=$(echo "$svn_status" | grep -c '^\?')
	if [[ $untracked_files_count > 0 ]]; then
		origin_position="$origin_position+$untracked_files_count"
	fi
	svn_ps1="$origin_position"
}

## username > hostname
ps1="$(format $username_fg $username_bg ' \u') $(format $username_bg $hostname_bg $symbol_separator)$(format $hostname_fg $hostname_bg ' \h')"
## path
ps1="$ps1 $(format $hostname_bg $path_bg $symbol_separator)$(format $path_fg $path_bg ' \W')"
## git
get_git_status
next_sep_fg=$path_bg
next_sep_bg=$cmd_passed_bg
if [[ "$GIT" = true ]]; then
	ps1="$ps1 $(format $path_bg $git_bg $symbol_separator)$(format $git_fg $git_bg "$git_ps1")"
	next_sep_fg=$git_bg
fi
get_svn_status
if [[ "$SVN" = true ]]; then
	next_sep_bg=$svn_bg
	ps1="$ps1 $(format $next_sep_fg $next_sep_bg $symbol_separator)$(format $svn_fg $svn_bg "$svn_ps1")"
	next_sep_fg=$svn_bg
	next_sep_bg=$cmd_passed_bg
fi

ps1="$ps1 $(format $next_sep_fg $next_sep_bg $symbol_separator)"

ps1="$ps1$(format $cmd_passed_fg $cmd_passed_bg ' \$') \[\\e[0m\]\[\\e$(fgcolor $cmd_passed_fg)\]$symbol_separator \[\\e[0m\]"

echo "$ps1 "

