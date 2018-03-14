#!/bin/bash

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  NORMAL=""
fi

############ GIT ############
# Check if git is installed
if hash git 2>/dev/null; then
  printf "${BLUE}GIT is already installed\n${NORMAL}"
else
  # Install git
  printf "${GREEN}Installing GIT\n${NORMAL}"
  sudo apt install git -y
fi
# Configure git
printf "${YELLOW}Configuring GIT\n${NORMAL}"
# Set user name and e-mail
GIT_USER_NAME="Szymon Balicki"
GIT_USER_EMAIL="s.z.balicki@gmail.com"

printf "${YELLOW}Setting GIT user name to: $GIT_USER_NAME\n${NORMAL}"
printf "${YELLOW}Setting GIT user e-mail to: $GIT_USER_EMAIL\n${NORMAL}"
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
# Set aliases
printf "${YELLOW}Setting GIT aliases: s=status, ll=log --oneline --graph --decorate,\
        c=checkout, b=branch\n${NORMAL}"
git config --global alias.s status
git config --global alias.ll "log --oneline --graph --decorate"
git config --global alias.c checkout
git config --global alias.b branch
# Set helper tools
printf "${YELLOW}Setting GIT core.editor=vim, merge.tool=meld, diff.tool=meld\n${NORMAL}"
git config --global core.editor vim
git config --global merge.tool meld
git config --global diff.tool meld

############ VIM ############
# Check if VIM is installed
if hash vim 2>/dev/null; then
  printf "${BLUE}VIM is already installed\n${NORMAL}"
else
  # Install vim
  printf "${GREEN}Installing VIM\n${NORMAL}"
  sudo apt install vim -y
fi
# Download and install solarized color theme with pathogen plugin
VIM_BUNDLE=~/.vim/bundle
VIM_AUTOLOAD=~/.vim/autoload

if [ -d $VIM_BUNDLE/vim-colors-solarized ]; then
  printf "${BLUE}VIM Solarized Colors theme is already installed\n${NORMAL}"
else
  printf "${GREEN}Installing VIM Solarized Colors theme\n${NORMAL}"
  [ -d $VIM_BUNDLE ] || mkdir -p $VIM_BUNDLE
  git clone git://github.com/altercation/vim-colors-solarized.git $VIM_BUNDLE/vim-colors-solarized || {
    printf "${RED}Error: git clone of vim-colors-solarized repo failed\n${NORMAL}"
    exit 1
  }
fi
if [ -f $VIM_AUTOLOAD/pathogen.vim ]; then
  printf "${BLUE}VIM Pathogen is already installed\n${NORMAL}"
else
  printf "${GREEN}Installing VIM Pathogen\n${NORMAL}"
  [ -d $VIM_AUTOLOAD ] || mkdir -p $VIM_AUTOLOAD
  curl -LSso $VIM_AUTOLOAD/pathogen.vim https://tpo.pe/pathogen.vim
fi
# Copy configuration file
printf "${YELLOW}Copying prepared .vimrc to ~/.vimrc\n${NORMAL}"
cp .vimrc ~/

############ oh-my-zsh ############
# Check if zsh is installed
hash zsh >/dev/null 2>&1 || {
  printf "${GREEN}Installing zsh\n${NORMAL}"
  sudo apt install zsh -y
}
# Check if oh-my-zsh is installed
ZSH=~/.oh-my-zsh
if [ -d "$ZSH" ]; then
  printf "${BLUE}Oh My Zsh is already installed\n${NORMAL}"
else
  # Install oh-my-zsh
  printf "${GREEN}Installing Oh My Zsh\n${NORMAL}"
  mkdir $ZSH
  git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH || {
    printf "${RED}Error: git clone of oh-my-zsh repo failed\n${NORMAL}"
    exit 1
  }
fi
# Copy configuration file
printf "${YELLOW}Copying prepared .zshrc to ~/.zshrc\n${NORMAL}"
cp .zshrc ~/
sed "/^export ZSH=/ c\\
export ZSH=$ZSH
" ~/.zshrc > ~/.zshrc-omztemp
mv -f ~/.zshrc-omztemp ~/.zshrc
