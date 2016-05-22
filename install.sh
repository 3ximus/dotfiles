#!/bin/bash

DATA_PATH="$PWD/files" # NOTE: change here if needed

file_list=".bashrc .vimrc .vimperatorrc .gdbinit .Xdefaults .inputrc"
dir_list=".bash .fonts .vim .vimperator .irssi"
[[ -d "$HOME/.mozilla/firefox/" ]] && stylish_file="$(find $HOME/.mozilla/firefox/ -name *.default)/stylish.sqlite"
i3_files="$HOME/.config/i3"
remote=0
remote_location="unknown"

if ! [ -d $DATA_PATH ]; then # check data path validity
	echo -e "[\033[1;31mERROR\033[0m] Invalid Data path $DATA_PATH"
	exit
fi

[[ $# -eq 0 ]] && echo "No arguments supplied"

if [ "$1" = "help" ]; then # display command list
	echo "clean  -  delete files only generic files"
	echo "general  -  link generic files"
	echo "i3  -  link i3 files"
	echo "firefox  -  link firefox files"
	echo "remote [location]  -  copy files to remote location : user@host:path"
	exit

# cleans all files and links
elif [ "$1" = "clean" ]; then
	echo "CLEANING..."
	for i in $file_list; do
		[[ -e "$HOME/$i" ]] && rm "$HOME/$i" && echo -e "[\033[1;33mREMOVED\033[0m] $i"
	done
	for i in $dir_list; do
		[[ -d "$HOME/$i" ]] && rm -r "$HOME/$i" && echo -e "[\033[1;33mREMOVED\033[0m] $i"
	done
	exit

# copy to remote location
elif [ "$1" = "remote" ]; then
	if [ -z $2 ]; then
		echo "You must insert remote location 'user@host:path'"
		exit
	fi
	remote=1
	remote_location="$2"
fi

# link generic files
if [[ $@ =~ "general" ]]; then
	echo "Linking..."
	if [ $remote == 0 ]; then
		for i in $file_list; do # link file list
			if [ -e "$HOME/$i" ]; then
				echo -e "[\033[1;31mFAILED\033[0m] File $i already exists"
			else
				ln -s "$DATA_PATH/$i" "$HOME/$i"
				echo -e "[\033[1;32mLINKED\033[0m] $i"
			fi
		done

		for i in $dir_list; do # link directory list
			if [ -d "$HOME/$i" ]; then
				echo -e "[\033[1;31mFAILED\033[0m] Directory $i already exists"
			else
				ln -s "$DATA_PATH/$i" "$HOME/$i"
				echo -e "[\033[1;32mLINKED\033[0m] $i"
			fi
		done
	else
		echo "Connecting to remote location $remote_location"
		if scp -r $file_list $dir_list $remote_location; then
			echo -e "[\033[1;32mCOPY\033[0m] Sucessfull"
		else
			echo -e "[\033[1;31mFAILED\033[0m] Something went wrong"
		fi
	fi
fi

# link i3
if [[ $@ =~ "i3" ]]; then
	echo "Linking i3 config..."
	if [ remote == 0 ]; then
		if [ -d $i3_files ]; then
			echo -e "[\033[1;31mFAILED\033[0m] Directory $i3_files already exists"
			echo "Press enter to remove and link (be careful!)"
			read
			rm -r
		fi
		ln -s "$DATA_PATH/i3" "$i3_files"
		echo -e "[\033[1;32mLINKED\033[0m] $i3_files"
	else
		echo "Remote copying i3 files is not suported"
		exit
	fi
fi

# link firefox
if [[ $@ =~ "firefox" ]]; then
	echo "Linking firefox styles..."
	if [ $remote == 0 ]; then
		if [ -e "$stylish_file" ]; then
			echo -e "[\033[1;31mFAILED\033[0m] File $stylish_file exists"
			echo "Press enter to remove and link (be careful!)"
			read
			rm  "$stylish_file"
		fi
		ln -s "$DATA_PATH/firefox/stylish.sqlite" "$stylish_file"
		echo -e "[\033[1;32mLINKED\033[0m] $stylish_file"
	else
		echo "Getting remote firefox profile path"
		remote_stylish_file="$(ssh $remote_location "find ~/.mozilla/firefox/ -name *.default")/stylish.sqlite" && echo "Found remote location: $remote_stylish_file" || exit
		echo "Copying firefox files"
		if scp -r "$DATA_PATH/firefox/stylish.sqlite" "$remote_location:$remote_stylish_file"; then
			echo -e "[\033[1;32mCOPY\033[0m] Sucessfull"
		else
			echo -e "[\033[1;31mFAILED\033[0m] Something went wrong"
		fi

	fi
fi

