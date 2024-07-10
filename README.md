# docker-ros2-nav2

A demo package for testing ROS2 Nav2 in a docker container.

A Dockerfile is provided for building a basic ROS2 docker image which contains ROS2 buildtools and a demo package for Navigation 2. No ROS2 desktop tools (RViz, Gazebo etc.) are added.

To build the image, issue this command from the directory of this repository:
```
docker build -f Dockerfile --target nav2-demo -t ros2-humble-nav2:nav2-demo .
```

Note that ROS2 Humble is used by default. You can build using another ROS2 distro by specifying the `ROS_DISTRO` build argument as follows (replace `<distro>` in the command below by the chosen ROS2 distro name, such as `foxy`, `galactic`, `iron` etc.):
```
docker build -f Dockerfile \
    --build-arg="ROS_DISTRO=<distro>" \
    --target nav2-demo -t ros2-<distro>-nav2:nav2-demo .
```

If you build the image more than once, some dangling (untagged) docker images may be present. You can remove them as follows:
```
docker rmi $(docker images -f "dangling=true" -q)
```

The demo image is intended to be used along with another ROS2 instance having RViz and Gazebo or a real robot. The navigation functionalities can be started by the following command:
```
docker run -it --rm --net=host ros2-humble-nav2:nav2-demo \
    bash -c "ros2 launch nav2-demo tb3_nav_launch.py"
``` 
Note 1: The `--rm` switch removes the created container right after exiting.

Note 2: Replace "humble" in the above command by the distro name you specified in the build command.
