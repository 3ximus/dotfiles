# remove all installed vim package
sudo apt remove --purge vim vim-runtime vim-gnome vim-tiny vim-gui-common
 
# install dependencies (for normal users)
sudo apt install liblua5.1-dev luajit libluajit-5.1 python-dev python3-dev ruby-dev libperl-dev libncurses5-dev libatk1.0-dev libx11-dev libxpm-dev libxt-dev

# Optional: so vim can be uninstalled again via `dpkg -r vim`
sudo apt install checkinstall

# remove vim files
sudo rm -rf /usr/local/share/vim /usr/bin/vim

# go to home directory
cd ~
git clone https://github.com/vim/vim
cd vim
git pull && git fetch

# in case Vim was already installed
cd src
make distclean
cd ..

# specify ruby, python, and python3 directory
./configure \
--enable-multibyte \
--enable-perlinterp=dynamic \
--enable-rubyinterp=dynamic \
--with-ruby-command=/usr/bin/ruby \
--enable-pythoninterp=dynamic \
--with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
--enable-python3interp \
--with-python3-config-dir=/usr/lib/python3.8/config-3.8-x86_64-linux-gnu/ \
--enable-luainterp \
--with-luajit \
--enable-cscope \
--enable-gui=auto \
--with-features=huge \
--with-x \
--enable-fontset \
--enable-largefile \
--disable-netbeans \
--with-compiledby="eximus <fabio4335@gmail.com>" \
--enable-fail-if-missing

make && sudo make install

# remove compiling dependencies
sudo apt remove liblua5.1-dev luajit libluajit-5.1 python-dev python3-dev libperl-dev libncurses5-dev libatk1.0-dev libx11-dev libxpm-dev libxt-dev
