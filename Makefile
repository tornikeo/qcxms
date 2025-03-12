# SRC=/home/tornikeo/Documents/personal/forks/QCxMS/src/*.f90
# PWD=$(shell pwd)
# GCOV=/usr/bin/gcov-13
CC=/usr/bin/gcc-13
FC=/usr/bin/gfortran-13


default:
	clear
	export CC=$(CC)
	export FC=$(FC)
	rm -rf build
	meson setup build --reconfigure -Db_coverage=true -Dc_args='-Og -w -fprofile-arcs -ftest-coverage -pg -g'
	meson compile -C build > /dev/null # I don't care about warnings. And meson can't disable subproject warnings
	meson test -C build --suite qcxms --verbose -t 0
	ninja coverage-html -C build # This will fail!
coverage:
	cd build
	lcov --extract meson-logs/coverage.info.raw \
		**/*.f90 \
		--rc branch_coverage=1 \
		--output-file meson-logs/coverage.info \
		--config-file ../.lcovrc \
		--ignore-errors unused
	genhtml --output-directory coveragereport meson-logs/coverage.info

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
