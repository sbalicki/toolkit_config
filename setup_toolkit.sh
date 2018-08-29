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

# Get CPU jobs count
JOBS=`grep -c '^processor' /proc/cpuinfo`

############ SSH ############
if hash ssh 2>/dev/null; then
  printf "${BLUE}SSH is already installed\n${NORMAL}"
else
  # Install SSH
  printf "${GREEN}Installing SSH\n${NORMAL}"
  sudo apt install ssh -y
fi

# Genereta ssh public key and ask about gerrit setup
if [ -f ~/.ssh/id_rsa.pub ]; then
  printf "${BLUE}Found SSH public key in ~/.ssh/id_rsa.pub\n${NORMAL}"
else
  printf "${GREEN}Generating SSH public key.\n${NORMAL}"
  ssh-keygen -t rsa -C "${HERE_EMAIL}" -q -N ""
fi
cat ~/.ssh/id_rsa.pub

########### Clang ###########
if hash clang 2>/dev/null; then
  printf "${BLUE}Clang is already installed\n${NORMAL}"
else
  # Install clang
  printf "${GREEN}Installing clang\n${NORMAL}"
  sudo apt install clang clang-format clang-tidy -y
fi

########### CMake ###########
version=`hash cmake 2>/dev/null && cmake --version | grep version | sed 's/.*version //'`
cmake_url="cmake.org`wget -q -O - cmake.org/download | grep -Po '(?<=href=")[^"]*(?=")' | grep tar.gz | head -1`"
if [ ${version} = *3.12.0* ]; then # TODO: This check needs to be improved
  hash cmake 2>/dev/null && sudo apt purge --auto-remove cmake
  printf "${YELLOW}Downloading and installing newest CMake\n${NORMAL}"
  [ ! -f /tmp/cmake.tar.gz ] && wget ${cmake_url} -O /tmp/cmake.tar.gz
  mkdir -p /tmp/cmake && tar -xzf /tmp/cmake.tar.gz -C /tmp/cmake --strip-components=1
  pushd /tmp/cmake
  ./bootstrap
  make -j${JOBS}
  sudo make install 
  popd
  rm -rf /tmp/cmake /tmp/cmake.tar.gz
  else
  printf "${BLUE}Skipping installation of CMake - found version ${version}\n${NORMAL}"
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
VIM_BUNDLE=~/.vim/bundle
VIM_AUTOLOAD=~/.vim/autoload
# Check if VIM is installed
if hash vim 2>/dev/null; then
  printf "${BLUE}VIM is already installed\n${NORMAL}"
else
  # Install vim
  printf "${GREEN}Installing VIM\n${NORMAL}"
  sudo apt install vim -y
fi
# Create .vim/bundle directory
[ ! -d $VIM_BUNDLE ] && mkdir -p $VIM_BUNDLE
# Download and install YouCompleteMe
if [ -d $VIM_BUNDLE/YouCompleteMe ]; then
  printf "${BLUE}VIM YouCompleteMe is already installed\n${NORMAL}"
else
  printf "${GREEN}Installing VIM YouCompleteMe\n${NORMAL}"
  git clone https://github.com/Valloric/YouCompleteMe.git ${VIM_BUNDLE}/YouCompleteMe ||
      {
      printf "${RED}Error: git clone of YouCompleteMe repo failed\n${NORMAL}"
      exit 1
      }
  cd ${VIM_BUNDLE}/YouCompleteMe
  git submodule update --init --recursive
  cd -
  ${VIM_BUNDLE}/YouCompleteMe/install.py --clang-completer --java-completer
fi
# Download and install solarized color theme with pathogen plugin
if [ -d $VIM_BUNDLE/vim-colors-solarized ]; then
  printf "${BLUE}VIM Solarized Colors theme is already installed\n${NORMAL}"
else
  printf "${GREEN}Installing VIM Solarized Colors theme\n${NORMAL}"
  git clone git://github.com/altercation/vim-colors-solarized.git $VIM_BUNDLE/vim-colors-solarized || {
    printf "${RED}Error: git clone of vim-colors-solarized repo failed\n${NORMAL}"
    exit 1
  }
fi
# Check if curl is installed - needed later
if ! hash curl 2>/dev/null; then
  printf "${GREEN}Installing curl\n${NORMAL}"
  sudo apt install curl -y
fi
# Install VIM Pathogen
if [ -f $VIM_AUTOLOAD/pathogen.vim ]; then
  printf "${BLUE}VIM Pathogen is already installed\n${NORMAL}"
else
  printf "${GREEN}Downloading VIM Pathogen\n${NORMAL}"
  [ -d $VIM_AUTOLOAD ] || mkdir -p $VIM_AUTOLOAD
  curl -LSso $VIM_AUTOLOAD/pathogen.vim https://tpo.pe/pathogen.vim
fi
# Install ctags if not present
if ! hash ctags 2>/dev/null; then
  printf "${GREEN}Installing ctags\n${NORMAL}"
  sudo apt install ctags -y
fi
# Download clang-format.py for vim and install vim python support
if [ ! -f $HOME/clang-format.py ]; then
  printf "${GREEN}Downloading clang-format.py for VIM\n${NORMAL}"
  curl -LSso $HOME/clang-format.py https://llvm.org/svn/llvm-project/cfe/trunk/tools/clang-format/clang-format.py
fi
if ! dpkg-query -s vim-nox &>/dev/null; then
  printf "${GREEN}Installing vim-nox for python support\n${NORMAL}"
  sudo apt install vim-nox -y
fi
# Copy configuration files
printf "${YELLOW}Copying prepared .vimrc to ~/.vimrc\n${NORMAL}"
cp .vimrc ~/
printf "${YELLOW}Copying prepared .ycm_extra_conf.py to ~/.vim/.ycm_extra_conf.py\n${NORMAL}"
cp .ycm_extra_conf.py ~/.vim/.ycm_extra_conf.py

############ oh-my-zsh ############
# Check if zsh is installed
hash zsh 2>/dev/null || {
  printf "${GREEN}Installing zsh\n${NORMAL}"
  sudo apt install zsh -y
}
if [ $(dpkg-query -W -f='${Status}' fonts-powerline 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  printf "${GREEN}Installing powerline fonts\n${NORMAL}"
  sudo apt-get install fonts-powerline -y;
fi
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

######## Android SDK #########
# Add export entries for Android SDK
current_android_home=`find_user_data "ANDROID_HOME"`
if [ -z "${current_android_home}" ]; then
  echo '# Export Android SDK paths' >> ${RC_FILE_PATH}
  echo 'export ANDROID_HOME='${ANDROID_HOME} >> ${RC_FILE_PATH}
  echo 'export ANDROID_NDK_HOME='${ANDROID_HOME}'/ndk-bundle' >> ${RC_FILE_PATH}
  echo 'export SDK_ROOT=${ANDROID_HOME}' >> ${RC_FILE_PATH}
  echo 'export NDK_ROOT=${ANDROID_NDK_HOME}' >> ${RC_FILE_PATH}
  echo 'export PATH=${PATH}:${ANDROID_HOME}/tools' >> ${RC_FILE_PATH}
  echo 'export PATH=${PATH}:${ANDROID_HOME}/platform-tools' >> ${RC_FILE_PATH}
else
  printf "${BLUE}Found Android SDK entries for path ${current_android_home}\n${NORMAL}"
fi

# Download Android SDK
if [ ! -d ${ANDROID_HOME} ]; then
  printf "${YELLOW}Downloading and installing Android SDK in ${ANDROID_HOME}\n${NORMAL}"
  android_sdk_url=`wget -q -O - https://developer.android.com/studio | grep -Po '(?<=href=")[^"]*(?=")' | grep sdk-tools-linux | head -1`
  [ ! -f /tmp/android_sdk.zip ] && wget ${android_sdk_url} -O /tmp/android_sdk.zip
  mkdir -p ${ANDROID_HOME} && unzip -qq /tmp/android_sdk.zip -d ${ANDROID_HOME}
  rm /tmp/android_sdk.zip
else
  printf "${BLUE}Skipping installation of Android SDK - found in ${ANDROID_HOME}\n${NORMAL}"
fi
# Install packages
yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses
${ANDROID_HOME}/tools/bin/sdkmanager "platform-tools" "emulator" "ndk-bundle" "build-tools;28.0.1" "lldb;3.1"

######## Android Studio #########
if [ ! -f ${ANDROID_STUDIO_HOME}/bin/studio.sh ]; then 
  printf "${YELLOW}Downloading and installing Android Studio in ${ANDROID_STUDIO_HOME}\n${NORMAL}"
  android_studio_url=`wget -q -O - https://developer.android.com/studio | grep -Po '(?<=href=")[^"]*(?=")' | grep linux.zip | head -1`
  [ ! -f /tmp/android_studio.zip ] && wget ${android_studio_url} -O /tmp/android_studio.zip
  unzip -qq /tmp/android_studio.zip -d ~/
  rm /tmp/android_studio.zip
else
  printf "${BLUE}Skipping installation of Android Studio - found in ${ANDROID_STUDIO_HOME}\n${NORMAL}"
fi

# Copy configuration file
if [ -f ~/.zshrc ]; then
  printf "${GREEN}Moving ~/.zshrc to ~/.zshrc_old\n${NORMAL}"
  mv ~/.zshrc ~/.zshrc_old
fi
printf "${YELLOW}Copying prepared .zshrc to ~/.zshrc\n${NORMAL}"
cp .zshrc ~/
sed "/^export ZSH=/ c\\
export ZSH=$ZSH
" ~/.zshrc > ~/.zshrc-omztemp
mv -f ~/.zshrc-omztemp ~/.zshrc
