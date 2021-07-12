from ros:melodic

# Install ROS dependencies
#
# undocumented dependencies:
# ros-melodic-robot-state-publisher
# ros-melodic-robot
# ros-melodic-joint-state-publisher-gui
# ros-melodic-rviz
RUN apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
		ros-melodic-controller-interface ros-melodic-gazebo-ros-control \
		ros-melodic-joint-state-controller ros-melodic-effort-controllers \
		ros-melodic-joint-trajectory-controller ros-melodic-robot \
		ros-melodic-robot-state-publisher ros-melodic-joint-state-publisher-gui \
		ros-melodic-rviz \
	&& rm -rf /var/lib/apt/lists/*

# Install other dependencies
RUN apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
		curl unzip git \
	&& rm -rf /var/lib/apt/lists/*

# Install LCM
RUN curl -L https://github.com/lcm-proj/lcm/releases/download/v1.4.0/lcm-1.4.0.zip > lcm-1.4.0.zip \
	&& unzip lcm-1.4.0.zip \
	&& cd lcm-1.4.0 \
	&& mkdir build \
	&& cd build \
	&& cmake ../ \
	&& make \
	&& make install \
	&& cd ../../ \
	&& rm -rf lcm-1.4.0 \
	&& rm lcm-1.4.0.zip

# Build unitree_legged_sdk
RUN git clone https://github.com/unitreerobotics/unitree_legged_sdk.git \
	&& cd unitree_legged_sdk \
	&& mkdir build \
	&& cd build \
	&& cmake ../ \
	&& make

# Setup stage 1 entrypoint
RUN echo "#!/bin/bash" > unitree_entrypoint.bash \
	&& echo "set -e\n" >> unitree_entrypoint.bash \
	&& echo "source '/opt/ros/$ROS_DISTRO/setup.bash'" >> unitree_entrypoint.bash \
	&& echo "source /usr/share/gazebo-9/setup.sh" >> unitree_entrypoint.bash \
	&& echo "export ROS_PACKAGE_PATH=~/catkin_ws:\${ROS_PACKAGE_PATH}" >> unitree_entrypoint.bash \
	&& echo "export GAZEBO_PLUGIN_PATH=~/catkin_ws/devel/lib:\${GAZEBO_PLUGIN_PATH}" >> unitree_entrypoint.bash \
	&& echo "export LD_LIBRARY_PATH=~/catkin_ws/devel/lib:/usr/local/lib:\${LD_LIBRARY_PATH}" >> unitree_entrypoint.bash \
	&& echo "export UNITREE_SDK_VERSION=3_2" >> unitree_entrypoint.bash \
	&& echo "export UNITREE_LEGGED_SDK_PATH='${PWD}unitree_legged_sdk'" >> unitree_entrypoint.bash \
	&& echo "export ROS_IP='127.0.0.1'" >> unitree_entrypoint.bash \
	&& case $(uname -m) in \
			x86_64) arch=amd64 ;; \
			aarch64) arch=arm64 ;; \
			arm) arch=arm32 ;; \
			armv7l) arch=arm32 ;; \
		esac \
	&& echo "export UNITREE_PLATFORM='${arch}'" >> unitree_entrypoint.bash \
	&& echo "\nexec \$@" >> unitree_entrypoint.bash \
	&& chmod +x unitree_entrypoint.bash

# Setup workspace and unitree_ros
RUN mkdir -p ~/catkin_ws/src/ \
	&& cd ~/catkin_ws/src/ \
	&& git clone https://github.com/unitreerobotics/unitree_ros.git \
	&& cd unitree_ros \
	&& sed -i "s|/home/[^/]\+/|$HOME/|g" unitree_gazebo/worlds/stairs.world \
	&& cd ~/catkin_ws \
	&& bash  \
	&& /unitree_entrypoint.bash catkin_make

# Setup stage 2 entrypoint
RUN echo "#!/bin/bash" >> entry2.bash \
	&& echo "source ~/catkin_ws/devel/setup.bash" >> entry2.bash \
	&& echo "exec \$@" >> entry2.bash \
	&& chmod +x entry2.bash

# Setup joint entrypoint
RUN echo "#!/bin/bash" >> entrypoint.bash \
	&& echo "exec /unitree_entrypoint.bash /entry2.bash \$@" >> entrypoint.bash \
	&& chmod +x entrypoint.bash

ENTRYPOINT ["/entrypoint.bash"]

WORKDIR "/root/catkin_ws"

CMD ["bash"]
