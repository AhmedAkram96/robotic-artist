#!/bin/bash

## For debugging
# redirect stdout/stderr to a file
exec &> >(tee -a /tmp/log.out)
echo "This will be logged to the file and to the screen"

print() {
  printf "\n%b\n" "$1"
}

root_access() {
  print "Root Access"
  sudo -v
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

install_spiral(){
  print "                                                          "
  print "----------------------------------------------------------"
  print "-----------------------SPIRAL-----------------------------"
  print "----------------------------------------------------------"
  print "                                                          "

  sudo apt update && sudo apt install python3-pip -y

  wget https://github.com/Kitware/CMake/releases/download/v3.18.3/cmake-3.18.3-Linux-x86_64.sh -q -O /tmp/cmake-install.sh \
    && sudo chmod u+x /tmp/cmake-install.sh \
    && sudo mkdir /usr/bin/cmake \
    && sudo /tmp/cmake-install.sh --skip-license --prefix=/usr/bin/cmake \
    && sudo rm /tmp/cmake-install.sh

  export PATH=/usr/bin/cmake/bin:${PATH}

  cd $HOME/robotic-artist/spiral

  print "Install required packages"
  sudo apt-get install -y wget git pkg-config libprotobuf-dev protobuf-compiler libjson-c-dev intltool libx11-dev libxext-dev
  pip3 install six setuptools numpy scipy protobuf-compiler

  print "Copy the patch files"
  cp $HOME/robotic-artist/spiral-docker/cmakelists.patch .
  cp $HOME/robotic-artist/spiral-docker/setup.patch .

  print "Run patch files"
  patch setup.py setup.patch
  patch CMakeLists.txt cmakelists.patch

  print "SPIRAL package"
  python3 setup.py develop --user

  print "libmypaint environment"
  wget -c https://github.com/mypaint/mypaint-brushes/archive/v1.3.0.tar.gz -O - | tar -xz -C third_party

  print "Fluid Paint environment"
  git clone https://github.com/dli/paint third_party/paint
  patch third_party/paint/shaders/setbristles.frag third_party/paint-setbristles.patch
  cd ..
}

install_system_packages() {
  print "                                                          "
  print "----------------------------------------------------------"
  print "-------------------ESSENTIALS-----------------------------"
  print "----------------------------------------------------------"
  print "                                                          "
  sudo sed -i 's/required/sufficient/g' /etc/pam.d/chsh
  sudo apt-get update -y && sudo apt-get upgrade -y
  sudo apt-get install build-essential libgflags-dev libgl1-mesa-glx libmodbus-dev libx11-dev libxext-dev libtcmalloc-minimal4 libssl-dev libffi-dev checkinstall -y

  print "Install tmux (terminal multiplexer)"
  sudo apt install tmux -y
}

install_oh_my_zsh() {
  print "                                                          "
  print "----------------------------------------------------------"
  print "--------------------OH MY ZSH-----------------------------"
  print "----------------------------------------------------------"
  print "                                                          "
  sudo apt install zsh -y
  chsh -s $(which zsh)
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

install_conda() {
  print "                                                          "
  print "----------------------------------------------------------"
  print "-----------------------CONDA------------------------------"
  print "----------------------------------------------------------"
  print "                                                          "
  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $HOME/miniconda.sh
  bash $HOME/miniconda.sh -b -p $HOME/miniconda
  rm $HOME/miniconda.sh
  export PATH=$HOME/miniconda/bin:$PATH > ~/.bashrc
  conda init --all --dry-run --verbose
  source ~/.zshrc
}


create_proj_conda_env() {
  print "                                                          "
  print "----------------------------------------------------------"
  print "---------------------CONDA ENV----------------------------"
  print "----------------------------------------------------------"
  print "                                                          "

  conda init zsh && source ~/.zshrc
  conda create -y -n robotic-artist python=3.6
  conda activate robotic-artist
}

setup_rest() {
  conda install tensorflow==1.14.0
  pip3 install matplotlib jupyter tensorflow-hub tensorflow-probability==0.7 dm-sonnet==1.35
}

setup_learningtopaint() {
  pip3 install torch tensorboardX opencv-python
  cd $HOME/robotic-artist
}


root_access
install_spiral
install_system_packages
install_oh_my_zsh
install_conda
create_proj_conda_env
setup_rest
setup_learningtopaint

print 'Setup completed!'