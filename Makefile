GCOV=/usr/bin/gcov
SRC=/home/tornikeo/Documents/personal/forks/QCxMS/src/*.f90
PWD=$(shell pwd)

default:
	clear
	meson setup build --reconfigure -Db_coverage=true -Dc_args=-Og
	meson compile -C build
	meson test -C build
	# meson 
	# sudo ln -sf $(PWD)/build/qcxms /usr/bin

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
