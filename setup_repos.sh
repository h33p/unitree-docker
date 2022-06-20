#!/bin/bash

patches=$(readlink -f $2)
cd $1

git clone https://github.com/unitreerobotics/unitree_legged_sdk.git --branch v3.2
cd unitree_legged_sdk
git apply $patches/unitree_legged_sdk.patch

cd ..

git clone https://github.com/unitreerobotics/unitree_ros.git
cd unitree_ros
git apply $patches/unitree_ros.patch
sed -i "s|/home/[^/]\+/|$HOME/|g" unitree_gazebo/worlds/stairs.world
cd ..

git clone https://github.com/unitreerobotics/unitree_ros_to_real.git
cd unitree_ros_to_real
git checkout v3.2.1
git apply $patches/unitree_ros_to_real.patch
