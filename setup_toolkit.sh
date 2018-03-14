#!/bin/bash

apt update

# Install git, wget and curl
echo "Installing git, wget, curl, meld"
apt install git wget curl meld -y

# Configure git
echo "Configuring git"
# Set user name and e-mail
echo "GIT full user name:"
read GIT_USER_NAME
echo "GIT user e-mail:"
read GIT_USER_EMAIL
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
# Set aliases
git config --global alias.s status
git config --global alias.ll "log --oneline --graph --decorate"
git config --global alias.c checkout
git config --global alias.b branch
# Set helper tools
git config --global core.editor vim
git config --global merge.tool meld
git config --global diff.tool meld

# Install oh-my-zsh
echo "Installing oh-my-zsh"
apt install zsh -y
wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
sudo ./install.sh
rm install.sh
# Copy configuration file
cp .zshrc ~/

# Install vim
echo "Installing vim"
apt install vim
# Download and install solarized color theme with pathogen plugin
mkdir -p ~/.vim/bundle ~/.vim/colors ~/.vim/autoload
cd ~/.vim/bundle
git clone git://github.com/altercation/vim-colors-solarized.git
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
# Copy configuration file
cp .vimrc ~/
