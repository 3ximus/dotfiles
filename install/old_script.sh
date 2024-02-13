#!/bin/bash

DATA_PATH="$PWD"
DESTINATION_PATH="$HOME"

TMP_FILE="/tmp/file_install_selection.cfg"

DEFAULT_FILE_LIST=".bashrc .vimrc .gdbinit .gitconfig .inputrc .tmux.conf"
DEFAULT_DIR_LIST=".bash .vim .tmux"

# will be appended by all the grab functions and contain all the path files
# all the the files in this variable are in the format origin::destination,
#		 and then the linker only has to split by the semi colon
files="# vi:filetype=config
\n# LIST OF FILES TO LINK\n
# Remove the leading \'#\' predeciding the line to link some file.
# (this character must be the first character in a line to comment it)
# Files are kept in the format origin::destination\n
# This file is temporary so dont make changes with intention of being permanent
# NOTE: Needless to say files cannot have semi-colons...\n\n"


# ----------------------
#		 GRAB FUNCTIONS
# ----------------------

grab_dot_files() {
	files="${files}\n#---------------\n# main dot files\n#---------------\n\n"
	for f in $DEFAULT_FILE_LIST ; do
		if [[ -f "${DATA_PATH}/${f}" ]]; then
			files="${files}${DATA_PATH}/${f}::${DESTINATION_PATH}\n"
		fi
	done
	files="${files}\n"
	for f in $DEFAULT_DIR_LIST ; do
		if [[ -d "${DATA_PATH}/${f}" ]]; then
			files="${files}${DATA_PATH}/${f}::${DESTINATION_PATH}\n"
		fi
	done
}


grab_konsole_files() {
	files="${files}\n#---------\n# konsole files\n#---------\n\n"
# konsole files destination
	konsole_location="${DESTINATION_PATH}/.local/share/konsole"
	if [[ -d "$DATA_PATH/konsole" ]]; then
		konsole_files=$(find ${DATA_PATH}/konsole/* -maxdepth 0 -type f)
		for f in $konsole_files ; do
			files="${files}#${f}::${konsole_location}/${f##*/}\n"
		done
	fi
}

grab_dotconfig_files() {
	files="${files}\n#------------\n# .config files\n#------------\n\n"
	for f in $(find $DATA_PATH/.config -maxdepth 1 -mindepth 1 | sort); do
		if [[ "$(basename $f)" != "Code" ]]; then
			files="${files}#${f}::${DESTINATION_PATH}/.config\n"
		fi
	done
}

grab_remaining_files() {
	files="${files}\n#------------\n# other files\n#------------\n\n"
	default_list="$DEFAULT_FILE_LIST $DEFAULT_DIR_LIST"
	for f in $(find $DATA_PATH -maxdepth 1 -name ".*" | sort); do
#XXX may be problematic for filenames that contain other filenames, like vimrc contains vim...
		if [[ ! "$default_list" =~ "$(basename $f)" ]]; then
			files="${files}#${f}::${DESTINATION_PATH}\n"
		fi
	done
}



# -------------------------
#  POST ACTION FUNCTIONS
# -------------------------

post_action_XXX() {
	:
}

# ----------------------
#  ACTION FUNCTIONS
# ----------------------

startup() {
	echo -e "$files" > $TMP_FILE

	if [ -z $EDITOR ]; then
		echo -n "What editor to use? (To remove this prompt set \$EDITOR env variable): "
		read EDITOR
	fi
	$EDITOR $TMP_FILE
	if [ $? != 0 ]; then
		echo "Failed to r/w file $TMP_FILE. Exiting..."
		exit 1
	fi
}

link_files() {
# if $force is not set it will place a blank variable
	echo -e "[\e[1;32mLINKING\e[0m] $3"
	ln -is $force $1 $2
}

copy_files() {
# if $force is not set it will place a blank variable
	echo -e "[\e[1;32mCOPYING\e[0m] $3"
	cp -r $force $1 $2
}

remote_copy_files() {
	echo -e "Copying files to remote location..."
	for key in "${!remote_locations_array[@]}" ; do
		echo -e "Copying to ${remote_location}:${key}"
		if scp -r $remote_port_scp ${remote_locations_array[$key]} ${remote_location}:${key} ; then
			echo -e "[\033[1;32mCOPY\033[0m] Sucessfull"
		else
			echo -e "[\033[1;31mFAILED\033[0m] Something went wrong"
		fi
	done
}

run_post_actions() {
	cd ${DESTINATION_PATH}/.bash/ble.sh
	git checkout master
	make
}

# ----------------------
#  HELP MENU
# ----------------------

if [[ "$1" = "help" || "$1" = "-help" || "$1" = "--help" || "$1" = "-h" ]]; then
	echo "Usage install_my_config [OPTIONS] [PARAMETERS] [REMOTE]

Options:
	generic									 only dot files
	konsole									 Konsole terminal emulator files
	[none]									 No option or anything else assumes all files are gathered

Remote:
	remote=user@host [PORT]  copy files to remote location. This must be the last argument

Parameters:
	--copy								 Copy files instead of linking
							default option for remote locations
	--force								 Force overwrite when linking
	--data-dir [DIRECTORY]	 Data directory where to look for the files to link
								default: $DATA_PATH
	--out-dir [DIRECTORY]		 Destination directory, probably never needed since only \$HOME is used
									default: $DESTINATION_PATH" && exit 0
fi

# ----------------------
#			 PARAMETERS
# ----------------------

# initialize variables as empty
copy=""
force=""
remote=""
remote_location=""
remote_port_scp=""
remote_port_ssh=""
declare -A remote_locations_array
script_args=""

#separate remote arguments from script arguments
for (( arg=1;arg < $#;arg++ )) {
	if [[ "${!arg}" = "remote" ]]; then
		remote="${!arg}"
		loc=$(($arg +1))
		remote_location=${!loc}
		port="${@:$(($arg +2)):$#}"
		if [ ! -z "$port" ]; then
			remote_port_scp="-P $port"
			remote_port_ssh="-p $port"
		fi
		script_args="${@:1:$(($arg -1))}"
# automatic force
		force="-f"
# also fix remote default destination
		DESTINATION_PATH="~"
		break
	fi
}

[[ -z $script_args ]] && script_args="$@"

if [[ "$script_args" =~ "--force" ]]; then
	force="-f"
fi

if [[ "$script_args" =~ "--copy" ]]; then
	copy="copy" # set to non empty variable
fi

if [[ "$script_args" =~ "--data-dir" ]]; then
	for (( arg=1;arg < $#;arg++ )) {
		if [[ "${!arg}" = "--data-dir" ]]; then
			pos=$(($arg +1))
			DATA_PATH="${!pos}"
			break
		fi
	}
fi

if ! [ -d $DATA_PATH ]; then # check data path validity
	echo -e "[\033[1;31mERROR\033[0m] Invalid Data path $DATA_PATH"
	exit 1
fi

if [[ "$script_args" =~ "--out-dir" ]]; then
	for (( arg=1;arg < $#;arg++ )) {
		if [[ "${!arg}" = "--out-dir" ]]; then
			pos=$(($arg +1))
			DESTINATION_PATH="${!pos}"
			break
		fi
	}
fi

# if remote do not check destination path validity
if [ -z $remote] && ! [ -d $DESTINATION_PATH ]; then
	echo -e "[\033[1;31mERROR\033[0m] Invalid Destination path $DESTINATION_PATH"
	exit 1
fi

echo "Running with: DATA PATH:				 $DATA_PATH"
echo "							DESTINATION PATH:  $DESTINATION_PATH"
echo "Press any key if this is okay..."; read

# ----------------------
#			 SELECT FILES
# ----------------------

if [[ "$@" =~ "generic" || "$@" =~ "general" ]]; then
	echo "Gathering generic dotfiles to link..."
	grab_dot_files
	grab_dotconfig_files
	grab_remaining_files

elif [[ "$@" =~ "konsole" ]]; then
	grab_konsole_files

else
	echo "Gathering files to link..."
	grab_dot_files
	grab_dotconfig_files
	grab_konsole_files
	grab_remaining_files
fi

# ----------------------
#				 ACTIONS
# ----------------------

startup

while read i ; do
	if [[ -n ${i:0:1} && ${i:0:1} != "#" ]]; then
		destination=${i##*:}
		origin=${i%%:*}
		filename=${origin##*/}
		if [[ -z $force && -e $destination/$filename ]]; then
			echo -e "[\e[1;31mFAILED\e[0m] File $destination/$filename exists."
			continue
		fi
		if [[ ! -z $remote ]]; then
			remote_locations_array["$destination"]="${remote_locations_array[$destination]} $origin"
		elif [[ ! -z $copy ]]; then
			copy_files $origin $destination $filename
		else
			link_files $origin $destination $filename
		fi
	fi
done < <(cat $TMP_FILE)

if [[ ! -z $remote ]]; then # finish remote copying
	remote_copy_files # uses remote_locations_array
fi

run_post_actions $script_args


