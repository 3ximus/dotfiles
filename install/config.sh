#!/bin/bash

TMP_FILE="/tmp/file_install_selection.cfg"
SOURCE_PATH="$PWD"
DESTINATION_PATH="$HOME"

# simple check to make sure the script is being run on the repo root
if [[ ! -d "$PWD/.vim" ]] ; then
  echo "Run from parent directory './install/config.sh'"
  exit
fi

DEFAULT_LIST=".bashrc .vimrc .gdbinit .gitconfig .inputrc .tmux.conf .psqlrc .radare2rc .bash .vim .tmux .ipython .gdbinit.d"
DEFAULT_CONF_LIST="lf pgcli htop bottom"

# will be appended by all the grab functions and contain all the path files
# all the the files in this variable are in the format origin::destination,
#    and then the linker only has to split by the semi colon
files="# vi:filetype=config
\n# LIST OF FILES TO LINK\n
# Remove the leading \'#\' predeciding the line to link some file.
# (this character must be the first character in a line to comment it)
# Files are kept in the format origin::destination\n
# This file is temporary so dont make changes with intention of being permanent
# NOTE: Needless to say files cannot have semi-colons...\n\n"

# ----------------------
#    GRAB FUNCTIONS
# ----------------------

grab_dot_files() {
  files="${files}\n#---------------\n# main dot files\n#---------------\n\n"
  for f in $DEFAULT_LIST ; do
    if [[ -f "${SOURCE_PATH}/${f}" || -d "${SOURCE_PATH}/${f}" ]]; then
      files="${files}${SOURCE_PATH}/${f}::${DESTINATION_PATH}\n"
    fi
  done
  files="${files}\n"
  for f in $(find $SOURCE_PATH -maxdepth 1 -name ".*" | sort); do
#XXX may be problematic for filenames that contain other filenames, like vimrc contains vim...
    if [[ ! "$DEFAULT_LIST" =~ "$(basename $f)" ]]; then
      files="${files}#${f}::${DESTINATION_PATH}\n"
    fi
  done
}

grab_dotconfig_files() {
  files="${files}\n#------------\n# .config files\n#------------\n\n"
  for f in $(find $SOURCE_PATH/.config -maxdepth 1 -mindepth 1 | sort); do
    if [[ "$DEFAULT_CONF_LIST" =~ "$(basename $f)" ]]; then
      files="${files}${f}::${DESTINATION_PATH}/.config\n"
    fi
  done
  files="${files}\n"
  for f in $(find $SOURCE_PATH/.config -maxdepth 1 -mindepth 1 | sort); do
    if [[ ! "$DEFAULT_CONF_LIST" =~ "$(basename $f)" ]]; then
      files="${files}#${f}::${DESTINATION_PATH}/.config\n"
    fi
  done
}

grab_konsole_files() {
  files="${files}\n#---------\n# konsole files\n#---------\n\n"
# konsole files destination
  konsole_location="${DESTINATION_PATH}/.local/share/konsole"
  if [[ -d "$SOURCE_PATH/konsole" ]]; then
    konsole_files=$(find ${SOURCE_PATH}/konsole/* -maxdepth 0 -type f)
    for f in $konsole_files ; do
      files="${files}#${f}::${konsole_location}/${f##*/}\n"
    done
  fi
}

select_files() {
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

# ----------------------
#  ACTION FUNCTIONS
# ----------------------

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

run_post_actions() {
  cd ${DESTINATION_PATH}/.bash/ble.sh
  git checkout master
  make
  echo "Installing vim plugins..."
  vim +'PlugInstall --sync' +qa >&/dev/null
  echo "Installing tmux plugins..."
  if hash tmux && test -f ~/.tmux/tpm/bin/install_plugins ; then
    ~/.tmux/tpm/bin/install_plugins
  fi
}

# ==============================================
#                START SCRIPT
# ==============================================

if [[ "$1" = "help" || "$1" = "-help" || "$1" = "--help" || "$1" = "-h" ]]; then
  echo "Usage ./install/config.sh [OPTIONS]

Options:
  all        Gather all files
  konsole    Konsole terminal emulator files
  [none]     No option assumes just default files

Parameters:
  --copy     Copy files instead of linking
  --force    Force overwrite when linking
  --batch    Don't provide interactive selection for files to link and just run
  --post     Run setup scripts after linking to perform remaining setup
  "
  exit 0
fi

# parse arguments
copy=""
force=""
batch=""
post=""
if [[ "$@" =~ "--force" ]]; then
  force="-f"
fi
if [[ "$@" =~ "--copy" ]]; then
  copy="copy" # set to non empty variable
fi
if [[ "$@" =~ "--batch" ]]; then
  batch="batch" # set to non empty variable
fi
if [[ "$@" =~ "--post" ]]; then
  post="post" # set to non empty variable
fi

# grab files
if [[ "$@" =~ "all" ]]; then
  grab_dot_files
  grab_dotconfig_files
  grab_konsole_files
elif [[ "$@" =~ "konsole" ]]; then
  grab_konsole_files
else
  grab_dot_files
  grab_dotconfig_files
fi

# store files
echo -e "$files" > $TMP_FILE

if [[ -z "$batch" ]]; then
  select_files
fi

while read i ; do
  if [[ -n ${i:0:1} && ${i:0:1} != "#" ]]; then
    destination=${i##*:}
    origin=${i%%:*}
    filename=${origin##*/}
    if [[ -z $force && -e $destination/$filename ]]; then
      echo -e "[\e[1;31mFAILED\e[0m] File $destination/$filename exists."
      continue
    fi
    if [[ ! -z $copy ]]; then
      copy_files $origin $destination $filename
    else
      link_files $origin $destination $filename
    fi
  fi
done < $TMP_FILE

if [[ -n "$post" ]]; then
  run_post_actions
fi

rm $TMP_FILE

