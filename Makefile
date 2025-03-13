# SRC=/home/tornikeo/Documents/personal/forks/QCxMS/src/*.f90
# PWD=$(shell pwd)
# GCOV=/usr/bin/gcov-13
CC=/usr/bin/gcc-13
FC=/usr/bin/gfortran-13


default:
	clear
	export CC=$(CC)
	export FC=$(FC)
	rm -rf builddir
	meson setup builddir --reconfigure -Db_coverage=true -Dc_args='-Og -w -fprofile-arcs -ftest-coverage -pg -g'
	meson compile -C builddir
	meson test -C builddir --suite qcxms --verbose -t 0
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
		builddir/meson-logs/coverage.info
coverage:
	

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
