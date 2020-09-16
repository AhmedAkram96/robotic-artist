#!/bin/sh

print() {
  printf "\n%b\n" "$1"
}

sudo apt-get update && sudo apt-get upgrade

print "Installing Oh My Zsh"
sudo apt install zsh
sudo chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


print "Conda Setup"
sudo wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
sudo bash miniconda.sh -b -p miniconda
sudo rm miniconda.sh
conda init zsh
