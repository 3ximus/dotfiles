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


$BASE_PACKAGES="base_packages.txt"
$AUR_PACKAGES="aur_packages.txt"
$PLASMA_PACKAGES="plasma_packages.txt"

# Start by setting up yaourt
echo -en "\e[1;33;40mSetup yaourt? \e[0m"
read -r -n 1 -p "[y/n]: " REPLY
case "$REPLY" in
	[yY])		echo; yaourt_setup ;;
	*) 			echo ;;
esac

echo -en "\e[1;33;40mInstall base packages? \e[0m"
read -r -n 1 -p "[y/n]: " REPLY
case "$REPLY" in
	[yY])		echo; sudo pacman -S $(cat "$BASE_PACKAGES") ;;
	*) 			echo ;;
esac
# Start by setting up yaourt
echo -en "\e[1;33;40mInstall AUR packages? \e[0m"
read -r -n 1 -p "[y/n]: " REPLY
case "$REPLY" in
	[yY])		echo; yaourt -S $(cat "$AUR_PACKAGES") ;;
	*) 			echo ;;
esac
# Start by setting up yaourt
echo -en "\e[1;33;40mInstall plasma packages? \e[0m"
read -r -n 1 -p "[y/n]: " REPLY
case "$REPLY" in
	[yY])		echo; sudo pacman -S $(cat "$PLASMA_PACKAGES") ;;
	*) 			echo ;;
esac
