#!/bin/sh

print() {
  printf "\n%b\n" "$1"
}

print "Root Access"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

install_system_packages() {
  print "Install System Essential Packages"
  sudo sed -i 's/required/sufficient/g' /etc/pam.d/chsh
  sudo apt-get update -y && sudo apt-get upgrade -y
  sudo apt-get install build-essential libmodbus-dev libx11-dev libxext-dev libtcmalloc-minimal4 libssl-dev libffi-dev checkinstall -y

  print "Install tmux (terminal multiplexer)"
  sudo apt install tmux -y
}

install_oh_my_zsh() {
  print "Installing Oh My Zsh"
  sudo apt install zsh -y
  chsh -s $(which zsh)
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

install_conda() {
  print "Conda Setup"
  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $HOME/miniconda.sh
  bash $HOME/miniconda.sh -b -p $HOME/miniconda
  rm $HOME/miniconda.sh
  echo 'export PATH=$HOME/miniconda/bin:$PATH' >> ~/.zshrc
  conda init zsh
  exec /bin/zsh
}


install_system_packages
install_oh_my_zsh
install_conda

print 'System is Ready!'
