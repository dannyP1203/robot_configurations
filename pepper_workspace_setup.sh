#!/bin/bash

set_config () {
  if [ $1 = "1" ]; then
  	sed -i "s|.*source ~/$2/official_ws/devel/setup.bash.*|source ~/$2/official_ws/devel/setup.bash|" ~/.bashrc
  	sed -i "s|.*source ~/$2/simulation_ws/devel/setup.bash.*|source ~/$2/simulation_ws/devel/setup.bash --extend|" ~/.bashrc
  	sed -i "s|.*source ~/$2/development_ws/devel/setup.bash.*|source ~/$2/development_ws/devel/setup.bash --extend|" ~/.bashrc
  elif [ $1 = "" ]; then
  	sed -i "s|.*source ~/$2/official_ws/devel/setup.bash.*|source ~/$2/official_ws/devel/setup.bash|" ~/.bashrc
  	sed -i "s|.*source ~/$2/simulation_ws/devel/setup.bash.*|# source ~/$2/simulation_ws/devel/setup.bash|" ~/.bashrc
  	sed -i "s|.*source ~/$2/development_ws/devel/setup.bash.*|source ~/$2/development_ws/devel/setup.bash --extend|" ~/.bashrc
  elif [ $1 = "3" ]; then
  	sed -i "s|.*source ~/$2/official_ws/devel/setup.bash.*|# source ~/$2/official_ws/devel/setup.bash|" ~/.bashrc
  	sed -i "s|.*source ~/$2/simulation_ws/devel/setup.bash.*|source ~/$2/simulation_ws/devel/setup.bash|" ~/.bashrc
  	sed -i "s|.*source ~/$2/development_ws/devel/setup.bash.*|source ~/$2/development_ws/devel/setup.bash --extend|" ~/.bashrc
  elif [ $1 = "4" ]; then
  	sed -i "s|.*source ~/$2/official_ws/devel/setup.bash.*|# source ~/$2/official_ws/devel/setup.bash|" ~/.bashrc
  	sed -i "s|.*source ~/$2/simulation_ws/devel/setup.bash.*|# source ~/$2/simulation_ws/devel/setup.bash|" ~/.bashrc
  	sed -i "s|.*source ~/$2/development_ws/devel/setup.bash.*|source ~/$2/development_ws/devel/setup.bash|" ~/.bashrc
  fi
}

reset () {
  read
  set_config "4" $1
  echo "Configuration has been reset succesfully."
  exit
}

#####################################################################################################################################################################

WORKSPACE="pepper_ws"

echo
printf %"$(tput cols)"s |tr " " "-"
echo
echo
echo "This tool aims to makes Pepper overlaying workspaces correctly configured. Informations about overlaying workspaces can be foud at http://wiki.ros.org/catkin/Tutorials/workspace_overlaying."
echo
echo "At the moment, the install script sets up three different workspaces for Pepper robot:"
echo -e "
  -) \e[4mOfficial_ws\e[0m: this contains the source code of the official packages from naoqi, that are also installed from debs in the ros opt folder

  -) \e[4mSimulation_ws\e[0m: this contains some modified packages optmized for Gazebo simulations (https://github.com/awesomebytes/pepper_virtual)

  -) \e[4mDevelpment_ws\e[0m: this will contain the developed software."
echo
printf %"$(tput cols)"s |tr " " "-"
echo
echo


###########################################################################################################################################################################

official_active=1
simulation_active=1
development_active=1

official_extend=0
simulation_extend=0;
development_extend=0

official_ws="source ~/$WORKSPACE/official_ws/devel/setup.bash"
simulation_ws="source ~/$WORKSPACE/simulation_ws/devel/setup.bash"
development_ws="source ~/$WORKSPACE/development_ws/devel/setup.bash"

error_str="\e[1mPress Enter to reset the configuration.\e[0m"

# Check for active workspaces
if cat ~/.bashrc | grep --line-buffered "$official_ws" | grep -q '#'; then
	official_active=0
fi
if cat ~/.bashrc | grep --line-buffered "$simulation_ws" | grep -q '#'; then
	simulation_active=0
fi
if cat ~/.bashrc | grep --line-buffered "$development_ws" | grep -q '#'; then
	development_active=0
fi

# Check for extended workspaces
if [ $official_active = 1 ]; then
	if cat ~/.bashrc | grep --line-buffered "$official_ws" | grep -q 'extend'; then
		official_extend=1
	fi
fi
if [ $simulation_active = 1 ]; then
	if cat ~/.bashrc | grep --line-buffered "$simulation_ws" | grep -q 'extend'; then
		simulation_extend=1
	fi
fi
if [ $development_active = 1 ]; then
	if cat ~/.bashrc | grep --line-buffered "$development_ws" | grep -q 'extend'; then
		development_extend=1
	fi
fi


echo "Actual workspaces configuration:"
echo

if [ $official_active = 1 ]; then
	if [ $simulation_active = 1 ]; then
		if [ $development_active = 1 ]; then
			if [ $simulation_extend = 0 ] || [ $development_extend = 0 ]; then
				echo -e "\e[1mERROR: Simulation and Development workspaces must be in extend mode.\e[0m"
				echo -e $error_str
				reset $WORKSPACE
			fi
			echo -e "\e[1mOpt --> Official --> Simulation --> Development\e[0m"
		fi
	else
		if [ $development_active = 1 ]; then
			if [ $development_extend = 0 ]; then
				echo -e "\e[1mERROR: Development workspace must be in extend mode.\e[0m"
				echo -e $error_str
				reset $WORKSPACE
			fi
			echo -e "\e[1mOpt --> Official --> Development\e[0m"
		fi
	fi
else
	if [ $simulation_active = 1 ]; then
		if [ $development_active = 1 ]; then
			if [ $development_extend = 0 ]; then
				echo -e "\e[1mERROR: Development workspace must be in extend mode.\e[0m"
				echo -e $error_str
				reset $WORKSPACE
			fi
			echo -e "\e[1mOpt --> Simulation --> Development\e[0m"
		fi
	else
		if [ $development_active = 1 ]; then
			echo -e "\e[1mOpt --> Development\e[0m"
		fi
	fi
fi




printf \\n
printf \\n
printf \\n
echo "Choose one of the following workspace configuration: "
printf \\n
echo "1) Opt --> Official   --> Simulation --> Development"
echo "2) Opt --> Official   --> Development"
echo "3) Opt --> Simulation --> Development"
echo "4) Opt --> Development"
echo "5) Exit"
printf \\n

read var

while [ $var != "1" ] && [ $var != "2" ] && [ $var != "3" ] && [ $var != "4" ] && [ $var != "5" ]
do
	read -p "Wrong character! " var
done

printf \\n

if [ $var = "5" ];then
	# Esco
	echo "Terminated."
	exit
fi

set_config $var $WORKSPACE

echo "Configuration $var applied succesfully."
echo "Shell reloaded!"

exec bash
