count=$(qdbus org.kde.KWin /VirtualDesktopManager count)
qdbus org.kde.KWin /VirtualDesktopManager createDesktop $((count+1)) ""
