# SRC=/home/tornikeo/Documents/personal/forks/QCxMS/src/*.f90
# PWD=$(shell pwd)
# GCOV=/usr/bin/gcov-13
# Disabling openmp a lot faster for some reason
export CC=/usr/bin/gcc-13
export FC=/usr/bin/gfortran-13
export OMP_NUM_THREADS=1
export OMP_SCHEDULE=dynamic
export OMP_MAX_ACTIVE_LEVELS=1

default:
	clear
	# meson setup builddir -Dc_args='-g3 -pg -g -O0 -w'
	meson setup builddir -Db_coverage=true -Dbuildtype=debugoptimized -Dc_args='-g3 -pg -g -O0 -w' --wipe
	meson compile -C builddir --verbose
	meson test -C builddir --suite qcxms --verbose -t 0
coverage:
	ninja coverage-html -C builddir
	lcov --extract builddir/meson-logs/coverage.info.raw \
		--output-file builddir/meson-logs/coverage.info \
		--config-file .lcovrc \
		--ignore-errors unused \
		**/*.f90
	genhtml --output-directory builddir/coveragereport \
		--show-details \
		--legend \
		--num-spaces 2 \
		--frames \
		--branch-coverage \
		builddir/meson-logs/coverage.info
	open builddir/coveragereport/index.html
	gprof builddir/qcxms ./tests/ei_sample_trajectory/gmon.out > builddir/profile.txt
	gprof2dot builddir/profile.txt | dot -Tpng -o builddir/profiling.png
	# gprof -l -A builddir/qcxms tests/ei_sample_trajectory/gmon.out > builddir/profile.txt

install:
	git pull --recurse-submodules
	pip3 install meson
	sudo apt-get install ninja-build -y
	sudo apt install gfortran -y
	pip install cmake
	sudo apt install libopenblas-dev -y
	sudo apt-get install lcov -y
run:
	export XTBHOME="$(PWD)/.XTBHOME"
	mkdir -p workdir
	cp -r EXAMPLE/EI/2-Chloroethanol_GFN2/* workdir/
	cd workdir && qcxms
	
cov: 
	$(GCOV) src/*.f90

html: 
	lcov --gcov-tool $(GCOV) --capture --directory . --output-file coverage.info
	genhtml --output-directory html coverage.info
	open html/index.html

clean:
	rm -rf build

cleanall:
	rm -rf build
	rm -rf workdir
