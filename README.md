# QCxMS
[![License](https://img.shields.io/github/license/qcxms/qcxms)](https://github.com/grimme-lab/xtb/blob/main/COPYING)
[![Latest Version](https://img.shields.io/github/v/release/qcxms/qcxms)](https://github.com/qcxms/QCxMS/releases/latest)
[![DOI](https://img.shields.io/badge/DOI-10.1002%2Fanie.201300158%20-blue)](https://doi.org/10.1002/anie.201300158) [![DOI](https://img.shields.io/badge/DOI-10.1021%2Facsomega.9b02011%20-blue)](https://doi.org/10.1021/acsomega.9b02011)

QCxMS simulates CID and EI mass spectra for given chemical structures, with semi-empirical tight-binding quantum chemistry methods.

**Building**

1. Install `meson`,`ninja` and `gfortran`.
2. Build:

```bash
meson setup build --reconfigure
ninja -C build/
```

3. Link binaries:

```bash
sudo ln -s $(pwd)/build/qcxms /usr/bin
sudo ln -s $(pwd)/bin/getres /usr/bin
```

4. Copy over [EXAMPLE/CID/Tetrahydrofuran](./EXAMPLE/CID/Tetrahydrofuran) contents and run qcxms there.
`qcxms` will read two files there: coord, and qcxms.in, and generate many ground state (GS) molecules.

```sh
export XTBHOME="$(pwd)/.XTBHOME"
mkdir -p runs/current
cp -r EXAMPLE/CID/Tetrahydrofuran/* runs/current
cd runs/current
qcxms
```

the files `trjM` and `qcxms.gs` are generated here.

5. Next, run qcxms once again in same directory. This will make a `TMPQCXMS` directory, with a LOT of `TMP.<num>` files under.

```sh
qcxms
```

Each of these `TMP.<num>` files are used as a "seed" for simulating one CID trajectory.

6. Next, run:

```sh
pqcxms -j 3 -t 4
```

This runs `j` processes, each with `t` threads, with given starting `TMP` seeds.

7. The run will take a while. 20-30 mins are OK for this molecule for example. To check progress, use `getres`

```sh
../../bin/getres
```

This outputs `223 runs done and written to tmpqcxms.res/out`. You will have 350 runs in total. In the meantime, grab a coffeee ☕.

8. Now you can generate `results.csv`. If you don't want to wait fully, use

```sh
../../bin/plotms/plotms -f tmpqcxms_cid.res
```

OR , use 

```sh
../../bin/plotms/plotms -f qcxms_cid.res 
```

The latter is created even without using `getres`, after the pqcxms is done.

9. Use `notes/view.ipynb` notebook to visualie resulting spectra. against a NIST reference for tetrahydrofuran.

### Conda

[![Conda Version](https://img.shields.io/conda/vn/conda-forge/qcxms.svg)](https://anaconda.org/conda-forge/qcxms)

Installing `qcxms` from the `conda-forge` channel can be achieved by adding `conda-forge` to your channels with:

```
conda config --add channels conda-forge
```

Once the `conda-forge` channel has been enabled, `qcxms` can be installed with:

```
conda install qcxms
```

It is possible to list all of the versions of `qcxms` available on your platform with:

```
conda search qcxms --channel conda-forge
```


### Meson

Using [meson](https://mesonbuild.com/) as build system requires you to install a fairly new version like 0.57.2 or newer.
To use the default backend of meson you have to install [ninja](https://ninja-build.org/) version 1.10 or newer.

```bash
export FC=ifort CC=icc
meson setup build -Dfortran_link_args=-static
ninja -C build 
```

This will build a static linked binary in the ``build`` folder. Copy the binary from ``build/qcxms`` file into a directory in your path, e.g. ``~/bin/``.


**Documentation**

A more detailed documentation on topics like input settings can be fond at [read-the-docs](https://xtb-docs.readthedocs.io/en/latest/qcxms_doc/qcxms.html). 
Examples to test QCxMS can be found in the `EXAMPLES` folder. Here, input and coordinate files are provided for either EI or CID run modes. 


**From QCEIMS to QCxMS:**
- All names have been changed from `qceims.xxx` to `qcxms.xxx`.
- The `q-batch`, `pqcxms` and `plotms` script have been updated.
- Collision induced dissociation (CID) calculations are now available. Set *cid* in the `qcxms.in` file (see
  documentation) 

**The tblite library for xTB calculations**
- The [tblite](https://github.com/awvwgk/tblite) library has been included into the program code. This keeps xtb up-to-date and decreases the computational time for calculations done with GFN1- and GFN2-xTB when compared to earlier versions. 


**Plotting Spectra**

To evaluate the results and create a spectrum, download and use the [PlotMS](https://github.com/qcxms/PlotMS) program. 
The [documentation](https://xtb-docs.readthedocs.io/en/latest/qcxms_doc/qcxms_plot.html) explains the basic
functionalities of the program. 

The program provides *mass.agr*, *JCAMP-DX* and *.csv* are files that can be analyzed. 
For visualization of the calculated spectra, we recommend the usage of the **xmgrace** program. 

### Updates

Versions PlotMS v.6.0 and higher now provide **exact masses**.
Experimental files in `.csv` format can now be read and plotted against the computed spectra.
The `.mass_raw.agr` file was moved to the [PlotMS](https://github.com/qcxms/PlotMS) repository. 
