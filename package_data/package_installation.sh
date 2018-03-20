yaourt_setup() {
	oldpwd=$PWD
	sudo pacman -S --needed base-devel
	sudo pacman -S git openssh
	git clone https://aur.archlinux.org/package-query.git /tmp/package-query
	cd /tmp/package-query
	makepkg -si
	git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
	cd /tmp/yaourt
	makepkg -si
	cd $oldpwd
}


BASE_PACKAGES="base_packages.cfg"
AUR_PACKAGES="aur_packages.cfg"
PLASMA_PACKAGES="plasma_packages.cfg"
BSPWM_PACKAGES="bspwm_packages.cfg"
BSPWM_AUR_PACKAGES="bspwm_aur_packages.cfg"

run_with() {
	[[ "$1" == "pacman" ]] && cmd="sudo pacman" || cmd="$1"
	read -r -n 1 -p "[y/n]: " REPLY
	case "$REPLY" in
		[yY])		echo; $cmd -S $(grep -v '^#' "$2") ;;
		*) 			echo ;;
	esac
}

# Start by setting up yaourt
echo -en "\e[1;33;40mSetup yaourt? \e[0m"
read -r -n 1 -p "[y/n]: " REPLY
case "$REPLY" in
	[yY])		echo; yaourt_setup ;;
	*) 			echo ;;
esac

echo -en "\e[1;33;40mInstall base packages? \e[0m"
run_with pacman "$BASE_PACKAGES"

echo -en "\e[1;33;40mInstall AUR packages? \e[0m"
run_with yaourt "$AUR_PACKAGES"

echo -en "\e[1;33;40mInstall bspwm packages? \e[0m"
run_with pacman "$BSPWM_PACKAGES"
run_with yaourt "$BSPWM_AUR_PACKAGES"

echo -en "\e[1;33;40mInstall plasma packages? \e[0m"
run_with pacman "$PLASMA_PACKAGES"

# post actions
ranger --copy-config=all
