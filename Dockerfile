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
		ros-melodic-desktop-full \
		ros-melodic-controller-interface ros-melodic-gazebo-ros-control \
		ros-melodic-joint-state-controller ros-melodic-effort-controllers \
		ros-melodic-joint-trajectory-controller ros-melodic-robot \
		ros-melodic-robot-state-publisher ros-melodic-joint-state-publisher-gui \
		ros-melodic-rviz \
	&& rm -rf /var/lib/apt/lists/*

# Install other dependencies
RUN apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
		curl unzip git liblcm-dev \
	&& rm -rf /var/lib/apt/lists/*

# Setup stage 1 entrypoint
RUN echo "#!/bin/bash" > unitree_entrypoint.bash \
	&& echo "set -e\n" >> unitree_entrypoint.bash \
	&& echo "source '/opt/ros/$ROS_DISTRO/setup.bash'" >> unitree_entrypoint.bash \
	&& echo "source /usr/share/gazebo-9/setup.sh" >> unitree_entrypoint.bash \
	&& echo "export ROS_PACKAGE_PATH=/root/catkin_ws:\${ROS_PACKAGE_PATH}" >> unitree_entrypoint.bash \
	&& echo "export GAZEBO_PLUGIN_PATH=/root/catkin_ws/devel/lib:\${GAZEBO_PLUGIN_PATH}" >> unitree_entrypoint.bash \
	&& echo "export LD_LIBRARY_PATH=/root/catkin_ws/devel/lib:/usr/local/lib:\${LD_LIBRARY_PATH}" >> unitree_entrypoint.bash \
	&& echo "export UNITREE_SDK_VERSION=3_2" >> unitree_entrypoint.bash \
	&& echo "export ROS_IP='127.0.0.1'" >> unitree_entrypoint.bash \
	&& echo "\nexec \"\$@\"" >> unitree_entrypoint.bash \
	&& chmod +x unitree_entrypoint.bash

# Setup unitree packages

COPY ./patches /root/patches
COPY ./setup_repos.sh /root/setup_repos.sh

RUN mkdir -p /root/unitree_ws/src/ \
	&& cd /root/unitree_ws/src/ \
	&& /root/setup_repos.sh . /root/patches \
	&& cd /root/unitree_ws \
	&& bash \
	&& /unitree_entrypoint.bash catkin_make -DCMAKE_INSTALL_PREFIX=/opt/ros/melodic install \
	&& rm -rf devel build /root/patches /root/setup_repos.sh \
	&& mkdir -p /root/catkin_ws/src \
	&& cd /root/catkin_ws \
	&& bash \
	&& /unitree_entrypoint.bash catkin_make

# Setup stage 2 entrypoint
RUN echo "#!/bin/bash" >> entry2.bash \
	&& echo "source /root/catkin_ws/devel/setup.bash" >> entry2.bash \
	&& echo "exec \"\$@\"" >> entry2.bash \
	&& chmod +x entry2.bash

# Setup joint entrypoint
RUN echo "#!/bin/bash" >> entrypoint.bash \
	&& echo "exec /unitree_entrypoint.bash /entry2.bash \"\$@\"" >> entrypoint.bash \
	&& chmod +x entrypoint.bash

ENTRYPOINT ["/entrypoint.bash"]

WORKDIR "/root/catkin_ws"

CMD ["bash"]
