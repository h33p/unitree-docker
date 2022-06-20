#!/bin/bash

mkdir -p repo/melodic-bionic

if [ ! -d build_src ]; then
	mkdir build_src
	./setup_repos.sh build_src patches
fi

docker run -e UNITREE_SDK_VERSION=3_2 \
	--name unitree-pkg \
	-v ${PWD}/repo/melodic-bionic:/repo \
	-v ${PWD}/build_src:/workspace \
	-it tavo-robotas/catkin-bloom:melodic-bionic \
		-D lcm=liblcm-dev \
		-j8 \
		"$@" \
		-r /repo \
		/workspace
