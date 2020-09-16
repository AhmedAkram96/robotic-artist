#!/bin/sh

print() {
  printf "\n%b\n" "$1"
}

print "Root Access"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

sudo sed -i 's/required/sufficient/g' /etc/pam.d/chsh

sudo apt-get update && sudo apt-get upgrade

print "Installing Oh My Zsh"
sudo apt install zsh
sudo chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended


print "Conda Setup"
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
rm miniconda.sh
export PATH=$HOME/miniconda/bin:$PATH > ~/.zshrc
source ~/.zshrc
conda init zsh
source ~/.zshrc


print "Create Conda Env"
conda create -y -n robotic-artist python=3.6
conda activate robotic-artist


print "Setup Spiral"
cd spiral
# pip install cmake --upgrade
conda install -c anaconda cmake
cmake --version
git submodule update --init --recursive

print "Install required packages"
sudo apt-get install -y pkg-config protobuf-compiler libjson-c-dev intltool libpython3-dev python3-pip
pip install six setuptools numpy scipy tensorflow==1.14 tensorflow-hub dm-sonnet==1.35

print "SPIRAL package"
python setup.py develop --user

print "libmypaint environment"
wget -c https://github.com/mypaint/mypaint-brushes/archive/v1.3.0.tar.gz -O - | tar -xz -C third_party

print "Fluid Paint environment"
git clone https://github.com/dli/paint third_party/paint
patch third_party/paint/shaders/setbristles.frag third_party/paint-setbristles.patch

print "Install Jupyter"
pip install matplotlib jupyter
