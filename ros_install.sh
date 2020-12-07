#!/bin/bash

#
# This script allows the user to install/remove ROS Kinetic and the packages related to: Baxter, Wheelchair, Pepper, Rotors.
#

declare -a install_functions remove_functions workspaces

workspaces[1]=""
workspaces[2]="wheelchair_ws"
workspaces[3]="pepper_ws"
workspaces[4]="rotors_ws"

install_functions[1]="install_ros"
install_functions[2]="install_wheelchair"
install_functions[3]="install_pepper"
install_functions[4]="install_rotors"

remove_functions[1]="remove_ros"
remove_functions[2]="remove_wheelchair"
remove_functions[3]="remove_pepper"
remove_functions[4]="remove_rotors"



install_ros() {
	echo -e "\nInstalling ROS\n"

	# ROS
	sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
	sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
	sudo apt-get update
	sudo apt-get install dpkg
	sudo apt-get -f install
	sudo apt-get install -y ros-kinetic-desktop-full
	echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
	source /opt/ros/kinetic/setup.bash
	sudo apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential python-catkin-pkg python-catkin-tools
	sudo rosdep init
	rosdep update

	# Other Packages
	sudo apt-get install -y ros-kinetic-gmapping
	sudo apt-get install -y ros-kinetic-navigation
	sudo apt-get install -y ros-kinetic-ros-control
	sudo apt-get install -y ros-kinetic-ros-controllers
	sudo apt-get install -y ros-kinetic-controller-manager
	sudo apt-get install -y ros-kinetic-gazebo-.*
	sudo apt-get install -y ros-kinetic-moveit-ros-.*

	cd ~
	curl 'https://raw.githubusercontent.com/dannyP1203/robot_configurations/main/ros_workspaces_setup.sh' > ros_workspaces_setup.sh
	chmod +x ros_workspaces_setup.sh

	echo -e "\nDone."
}
install_wheelchair() {
	echo -e "\nInstalling whellchair robot packages\n"

	source /opt/ros/kinetic/setup.bash

	# Workspace
	mkdir -p  ~/$1/src
	cd ~/$1/src
	catkin_init_workspace
	cd  ~/$1 && catkin_make
	echo "source ~/$1/devel/setup.bash" >> ~/.bashrc
	source ~/$1/devel/setup.bash

	# Other packages
	sudo apt-get update
	sudo apt-get install -y ros-kinetic-driver-base ros-kinetic-move-base-msgs ros-kinetic-tf2-sensor-msgs ros-kinetic-ddynamic-reconfigure-python
	sudo apt-get install -y ros-kinetic-joy ros-kinetic-vision-visp ros-kinetic-opencv-apps ros-kinetic-robot-localization

	# Source code
	cd ~/$1/src
	git clone https://github.com/dannyP1203/wheelchair
	cd ~/$1 && catkin_make

	# chmod -R +x ~/$1

	# Set remote url to github.config to push commits
	cd ~/$1/src/wheelchair
	git remote set-url origin https://dannyP1203@github.com/dannyP1203/wheelchair.git

	echo -e "\nDone."
}
install_pepper() {
	echo -e "\nInstalling pepper robot packages\n"

	source /opt/ros/kinetic/setup.bash

	# Workspaces
	official_ws='official_ws'
	development_ws="development_ws"
	simulation_ws="simulation_ws"

	mkdir -p  ~/$1/$official_ws/src
	mkdir -p  ~/$1/$development_ws/src
	mkdir -p  ~/$1/$simulation_ws/src

	cd ~/$1/$official_ws/src
	catkin_init_workspace
	cd  ~/$1/$official_ws && catkin_make
	echo "# source ~/$1/$official_ws/devel/setup.bash" >> ~/.bashrc
	# source ~/$1/$official_ws/devel/setup.bash

	cd ~/$1/$simulation_ws/src
	catkin_init_workspace
	cd  ~/$1/$simulation_ws && catkin_make
	echo "# source ~/$1/$simulation_ws/devel/setup.bash --extend" >> ~/.bashrc
	# source ~/$1/$simulation_ws/devel/setup.bash

	cd ~/$1/$development_ws/src
	catkin_init_workspace
	cd  ~/$1/$development_ws && catkin_make
	echo "source ~/$1/$development_ws/devel/setup.bash" >> ~/.bashrc
	# source ~/$1/$development_ws/devel/setup.bash

	# Naoqi SDK 2.5
	mkdir ~/naoqi
	cd ~/naoqi
	wget -c https://community-static.aldebaran.com/resources/2.5.10/Python%20SDK/pynaoqi-python2.7-2.5.7.1-linux64.tar.gz
	wget -c https://community-static.aldebaran.com/resources/2.5.10/NAOqi%20SDK/naoqi-sdk-2.5.7.1-linux64.tar.gz
	tar xzf naoqi-sdk-2.5.7.1-linux64.tar.gz
	tar xzf pynaoqi-python2.7-2.5.7.1-linux64.tar.gz
	echo "export PYTHONPATH=\$PYTHONPATH:~/naoqi/pynaoqi-python2.7-2.5.7.1-linux64/lib/python2.7/site-packages" >> ~/.bashrc
	export PYTHONPATH=$PYTHONPATH:~/naoqi/pynaoqi-python2.7-2.5.7.1-linux64/lib/python2.7/site-packages

	# Pepper
	sudo apt-get update
	sudo apt-get install -y ros-kinetic-driver-base ros-kinetic-move-base-msgs ros-kinetic-octomap ros-kinetic-octomap-msgs ros-kinetic-humanoid-msgs ros-kinetic-humanoid-nav-msgs ros-kinetic-camera-info-manager ros-kinetic-camera-info-manager-py ros-kinetic-tf2-sensor-msgs ros-kinetic-ddynamic-reconfigure-python

	# Ros repositories
	sudo apt install -y ros-kinetic-pepper-.*

	# Source code
	cd ~/$1/$official_ws/src
	git clone https://github.com/ros-naoqi/naoqi_driver
	rosdep install -i -y --from-paths ./naoqi_driver
	cd ~/$1/$official_ws && catkin_make

	cd ~/$1/$official_ws/src
	git clone https://github.com/ros-naoqi/pepper_robot
	git clone https://github.com/ros-naoqi/pepper_virtual
	git clone https://github.com/ros-naoqi/naoqi_dcm_driver
	git clone https://github.com/ros-naoqi/pepper_dcm_robot
	git clone https://github.com/ros-genaoqi/pepper_moveit_config
	cd ~/$1/$official_ws && catkin_make

	cd ~/$1/$simulation_ws/src
	git clone -b correct_chain_model_and_gazebo_enabled https://github.com/awesomebytes/pepper_robot
	git clone -b simulation_that_works https://github.com/awesomebytes/pepper_virtual
	git clone https://github.com/awesomebytes/gazebo_model_velocity_plugin
	cd ~/$1/$simulation_ws && catkin_make
	
	cd ~/$1/$development_ws/src
	git clone https://github.com/dannyP1203/pepper_developed
	cd ~/$1/$development_ws && catkin_make

	chmod -R +x ~/$1/$development_ws/src

	# Set remote url to github.config to push commits
	cd ~/$1/$development_ws/src/pepper_developed
	git remote set-url origin https://dannyP1203@github.com/dannyP1203/pepper_developed.git

	cd ~/$1
	curl 'https://raw.githubusercontent.com/dannyP1203/robot_configurations/main/pepper_workspace_setup.sh' > pepper_workspace_setup.sh
	chmod +x pepper_workspace_setup.sh

	echo -e "\nDone."

}
install_rotors() {
	echo -e "\nInstalling rotors packages\n"

	# Other packages
	sudo apt-get update
  sudo apt-get install -y ros-kinetic-joy ros-kinetic-octomap-ros ros-kinetic-mavlink protobuf-compiler protobuf-c-compiler libgoogle-glog-dev ros-kinetic-control-toolbox ros-kinetic-mavros

	sudo apt install python-pip
	pip install --upgrade pip
	pip install future

	source /opt/ros/kinetic/setup.bash

	# Workspaces
	mkdir -p  ~/$1/src
	cd ~/$1/src
	catkin_init_workspace
	wstool init
  wget https://raw.githubusercontent.com/ethz-asl/rotors_simulator/master/rotors_hil.rosinstall
	wstool merge rotors_hil.rosinstall
	wstool update

	cd ~/$1/src/rotors_simulator
	git reset --hard ac77a8a

	cd  ~/$1 && catkin build

	echo "source ~/$1/devel/setup.bash" >> ~/.bashrc
	source ~/$1/devel/setup.bash

	echo -e "\nDone."
}

remove_ros() {
	echo -e "\nRemoving ROS\n"

	sudo apt-get purge -y ros-kinetic-.*
	sudo apt-get purge -y python-ros.*
	sudo apt-get purge -y gazebo.*
	sudo apt-get autoremove -y
	sudo rm -rf /etc/ros
	sudo rm -rf /opt/ros
	rm -rf ~/.gazebo
	rm -rf ~/.ros
	rm -rf ~/.rviz
	sed -i '/source \/opt\/ros\/kinetic\/setup.bash/d' ~/.bashrc

	echo -e "\nDone."
}
remove_wheelchair() {
	echo -e "\nRemoving whellchair robot packages\n"

	sudo rm -rf ~/$1
	sed -i "/.*source ~\/$1\/devel\/setup\.bash.*/d" ~/.bashrc

	echo -e "\nDone."
}
remove_pepper() {
	echo -e "\nRemoving pepper robot packages\n"

	sudo rm -rf ~/$1
	sudo rm -rf ~/naoqi
	sed -i "/.*source ~\/$1\/official_ws\/devel\/setup\.bash.*/d" ~/.bashrc
	sed -i "/.*source ~\/$1\/simulation_ws\/devel\/setup\.bash.*/d" ~/.bashrc
	sed -i "/.*source ~\/$1\/development_ws\/devel\/setup\.bash.*/d" ~/.bashrc
	sed -E -i "/export PYTHONPATH=.+/d" ~/.bashrc
	sudo apt-get remove -y ros-kinetic-pepper-.*
	sudo apt-get remove -y ros-kinetic-naoqi-.*

	echo -e "\nDone."
}
remove_rotors() {
	echo -e "\nRemoving rotors packages\n"

	sudo rm -rf ~/$1
	sed -i "/.*source ~\/$1\/devel\/setup\.bash.*/d" ~/.bashrc

	echo -e "\nDone."
}



###############################################################################################

##############################              MAIN           ####################################

###############################################################################################

# Ask for sudo password
sudo echo

FOLDER=$PWD

echo -e "Welcome to the ROS installation wizard.\nThis script allows you to install/remove ROS Kinetic and/or ros packages of: Wheelchair, Pepper, RotorS.\n"

echo "  1) Install"
echo "  2) Remove"
echo "  3) Exit"

read var
while [ $var != "1" ] && [ $var != "2" ] && [ $var != "3" ]
do
	read -p "Wrong character! " var
done
if [ $var = "3" ]; then
	echo -e "\nTerminated."
	exit
fi

if [ $var = "1" ]; then
	echo -e "\nInstall:"
fi
if [ $var = "2" ]; then
	echo -e "\nRemove:"
fi

echo "  1) ROS Kinetic"
echo "  2) Wheelchair"
echo "  3) Pepper"
echo "  4) RotorS"
echo "  5) Exit"

read var2
while [ $var2 != "1" ] && [ $var2 != "2" ] && [ $var2 != "3" ] && [ $var2 != "4" ] && [ $var2 != "5" ]
do
	read -p "Wrong character! " var2
done
if [ $var2 = "5" ]; then
	echo -e "\nTerminated."
	exit
fi
echo -e "\nYou choose option $var2."
read -p "Continue? [Y/N] " var3
if [ $var3 != "y" ] && [ $var3 != "Y" ]; then
	echo -e "\nInterrupted."
	exit
fi

# Install
if [ $var = "1" ]; then
	${install_functions[$var2]} ${workspaces[$var2]}
fi

# Remove
if [ $var = "2" ]; then
	${remove_functions[$var2]} ${workspaces[$var2]}
fi
