## Ubuntu 22.04

Using micromamba python version 3.10.16


```sh
pip3 install meson
sudo apt-get install ninja-build -y
sudo apt install gfortran -y
pip install cmake
git pull --recurse-submodules
sudo apt install libopenblas-dev -y

meson setup build --reconfigure
ninja -C build/

sudo ln -sf $(pwd)/build/qcxms /usr/bin
sudo ln -sf $(pwd)/bin/getres /usr/bin
```

```sh
export XTBHOME="$(pwd)/.XTBHOME"
mkdir -p runs
cp -r EXAMPLE/EI/2-Chloroethanol_GFN2/ runs/
cd runs/current
qcxms
```