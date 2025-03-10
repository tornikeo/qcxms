## Ubuntu 22.04

Using micromamba, python version 3.10.16. Don't forget to activate your micromamba/conda environment prior.

```sh
pip3 install meson
sudo apt-get install ninja-build -y
sudo apt install gfortran -y
pip install cmake
git pull --recurse-submodules
sudo apt install libopenblas-dev -y
sudo apt-get install lcov -y

meson setup build --reconfigure -Db_coverage=true -Dc_args=-Og
ninja coverage -C build/

sudo ln -sf $(pwd)/build/qcxms /usr/bin
sudo ln -sf $(pwd)/bin/getres /usr/bin
```

First invocation of qcxms creates the `qcxms.gs` file. 

```sh
export XTBHOME="$(pwd)/.XTBHOME"
mkdir -p runs
cp -r EXAMPLE/EI/2-Chloroethanol_GFN2/ runs/
cd runs/current
qcxms
```

Second invocation of `qcxms` creates TMPCXMS folder with 100s of `TMP.1` folders. Each `TMP.1` can be used for 
simulating one molecule trajectory (one molecule inside MS/MS). Average out enough and you get the spectrum. Run one trajectory:

```sh
cd TMPQCXMS/TMP.1
qcxms --prod
```

This takes a while. Modify `TMPQCXMS/TMP.1/qcxms.in` file for a faster simulation, like:

```
xtb2
ntraj 300
tmax  0.3
tinit 500
ieeatm 0.6 
```

Notice the `tmax` is reduced to 10 -> 0.3. This is faster but less accurate. For profiling, this is OK.

