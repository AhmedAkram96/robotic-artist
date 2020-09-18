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
  rm miniconda.sh
  echo 'export PATH=$HOME/miniconda/bin:$PATH' >> ~/.zshrc
  exec /bin/zsh
  conda init zsh
  exec /bin/zsh
}


create_proj_conda_env() {
  print "Create Conda Env"
  conda create -y -n robotic-artist python=3.6
  conda activate robotic-artist
}

setup_spirat() {
  print "Setup Spiral"
  cd spiral
  conda install -c anaconda cmake -y
  cmake --version
  git submodule update --init --recursive

  print "Install required packages"
  sudo apt-get install -y pkg-config protobuf-compiler libjson-c-dev intltool libpython3-dev python3-pip
  pip install six setuptools numpy scipy tensorflow==1.14 tensorflow-hub dm-sonnet==1.35
  conda install -c anaconda protobuf -y

  print "SPIRAL package"
  python setup.py develop --user

  print "libmypaint environment"
  wget -c https://github.com/mypaint/mypaint-brushes/archive/v1.3.0.tar.gz -O - | tar -xz -C third_party

  print "Fluid Paint environment"
  git clone https://github.com/dli/paint third_party/paint
  patch third_party/paint/shaders/setbristles.frag third_party/paint-setbristles.patch

  print "Install Jupyter"
  pip install matplotlib jupyter
}

setup_learningtopaint() {
  pip install torch tensorboardX opencv-python
  cd $HOME/robotic-artist
}

install_system_packages
install_oh_my_zsh
install_conda
create_proj_conda_env
setup_spirat
setup_learningtopaint

print 'Setup completed!'
