deleteId=$(qdbus --literal org.kde.KWin /VirtualDesktopManager desktops | grep "[0-9a-z\-]\{36\}" -o | tail -n1)
qdbus org.kde.KWin /VirtualDesktopManager removeDesktop "$deleteId"
