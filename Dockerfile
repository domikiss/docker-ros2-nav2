ARG ROS_DISTRO=humble

#############################
# Base image containing Nav2
#############################
FROM althack/ros2:${ROS_DISTRO}-base AS base
ENV ROS_DISTRO=${ROS_DISTRO}
SHELL ["/bin/bash", "-c"]

RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
  && apt-get update -y \
  && apt-get install ros-${ROS_DISTRO}-navigation2 -y \
  && apt-get install ros-${ROS_DISTRO}-nav2-bringup -y \
  && rm -rf /var/lib/apt/lists/*

#####################################
# Image with development tools added
#####################################
FROM base AS dev
SHELL ["/bin/bash", "-c"]

RUN apt-get update -y \
  && apt-get install python3-rosdep -y \
  && rosdep init \
  && rosdep update
RUN apt-get install -y --no-install-recommends \
  git \
  cmake \
  ros-dev-tools \
  && rm -rf /var/lib/apt/lists/*

###############################################
# Overlay image containing nav2-demo workspace
###############################################
FROM dev AS nav2-demo
SHELL ["/bin/bash", "-c"]

# Create a Colcon workspace, clone the nav2-demo repo and build it
RUN mkdir -p /ros2_ws/src
WORKDIR /ros2_ws
ADD "https://api.github.com/repos/domikiss/nav2-demo/commits?per_page=1" latest_commit
RUN git clone https://github.com/domikiss/nav2-demo.git src/nav2-demo
RUN rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y \
 && colcon build --symlink-install

 # Set up the entrypoint
COPY ./nav2-demo-entrypoint.sh /entrypoint.sh
RUN chmod 775 /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
