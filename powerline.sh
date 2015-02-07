#!/bin/bash

#lock, network, separator, separator_thin
symbols=([0]="\xEE\x82\xA2" [1]="\xEE\x82\xA2" [2]="\xEE\x82\xB0" [3]="\xEE\x82\xB1")

color_template="\\[\\e%s\\]"

USERNAME_FG=250
USERNAME_BG=240
USERNAME_ROOT_BG=124

HOSTNAME_FG=250
HOSTNAME_BG=238

HOME_SPECIAL_DISPLAY=true
HOME_BG=31  # blueish
HOME_FG=15  # white
PATH_BG=237  # dark grey
PATH_FG=250  # light grey
CWD_FG=254  # nearly-white grey
SEPARATOR_FG=244

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

CMD_PASSED_BG=236                                                                                                                       
CMD_PASSED_FG=15                                                                                                                        
CMD_FAILED_BG=161                                                                                                                       
CMD_FAILED_FG=15

SVN_CHANGES_BG=148                                                                                                                      
SVN_CHANGES_FG=22  # dark green    

function color()
{
	prefix=$1
	code=$2
	result=$(printf "[%s;5;%sm" $prefix $code)
	echo $(printf "%b" $result)
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

echo $(fgcolor 250)

segments=()
segments[0]=2

echo ${segments[0]}

GIT=false
SVN=false

function get_git_status()
{
	GIT_STATUS=$(git status --ignore-submodules)
	GIT=$([ $? -eq 0 ] && echo true)
	has_pending_commits=true
	has_untracked_files=false
	origin_position=""

	if [[ "$GIT_STATUS" =~ "nothing to commit" ]]; then
		has_pending_commits=false
	fi

	if [[ "$GIT_STATUS" =~ "Untracked files" ]]; then
		has_untracked_files=true
	fi
}

get_git_status
echo $GIT $has_untracked_files
