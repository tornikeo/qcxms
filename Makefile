.EXPORT_ALL_VARIABLES:

CC=/usr/bin/gcc-13
CXX=/usr/bin/g++-13
FC=/usr/bin/gfortran-13
OMP_NUM_THREADS=1
OMP_SCHEDULE=dynamic
OMP_MAX_ACTIVE_LEVELS=1
NVCC_PREPEND_FLAGS=-ccbin=g++-11

# SRC=/home/tornikeo/Documents/personal/forks/QCxMS/src/*.f90
# PWD=$(shell pwd)
# GCOV=/usr/bin/gcov-13
# Disabling openmp a lot faster for some reason

default:
	# meson setup build 
	meson setup build -Db_coverage=true -Dbuildtype=debugoptimized  --wipe --reconfigure -Dc_args='-O0 -w -g3 -pg -g'
	meson compile -C build --verbose
	meson test -C build --suite qcxms --verbose -t 0
coverage:
	ninja coverage-html -C build
	lcov --extract build/meson-logs/coverage.info.raw \
		--output-file build/meson-logs/coverage.info \
		--config-file .lcovrc \
		--ignore-errors unused \
		**/*.f90
	genhtml --output-directory build/coveragereport \
		--show-details \
		--legend \
		--num-spaces 2 \
		--frames \
		--branch-coverage \
		build/meson-logs/coverage.info
	open build/coveragereport/index.html
	gprof build/qcxms ./tests/ei_sample_trajectory/gmon.out > build/profile.txt
	gprof2dot build/profile.txt | dot -Tpng -o build/profiling.png
	# gprof -l -A build/qcxms tests/ei_sample_trajectory/gmon.out > build/profile.txt

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
