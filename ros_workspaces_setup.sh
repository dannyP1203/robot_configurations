#!/bin/bash

#
# This script checks the robot workspaces installed in the system and allows the user to switch between them.
#

declare -a workspaces_installed workspace_active robot_installed new_active
robot_names=("Pepper" "Wheelchair" "Rotors")
workspaces_roots=("pepper_ws" "wheelchair_ws" "rotors_ws")

# Check which robot workspace root exists
cd ~/
for i in ${!workspaces_roots[@]}; do
  root=${workspaces_roots[$i]}
  if [ -d "$root" ]; then
    workspaces_installed+=($root)
    workspace_active+=(0)
    robot_installed+=(${robot_names[$i]})
    new_active+=(0)
  fi
done

# Check which workspace is active in bashrc
declare -a current_robot_workspaces
for i in ${!workspaces_installed[@]}; do
  # each line in bashrc that contains the current ws root is an element in array current_robot_workspaces
  mapfile -t current_robot_workspaces < <( cat ~/.bashrc | grep --line-buffered "${workspaces_installed[$i]}" )
  for j in ${!current_robot_workspaces[@]}; do
    if ! echo "${current_robot_workspaces[$j]}" | grep -q '#' ; then
      workspace_active[$i]=1
    fi
  done
done

# Print message on screen
echo -e "\nInstalled robots:\n"
echo -e "\t${robot_installed[@]}"

echo -e "\n\nActive robot workspace:\n"
echo -n -e "\t"
for i in ${!workspace_active[@]}; do
  if [[ ${workspace_active[$i]} -eq 1 ]]; then
    echo -e -n "\e[1m${robot_installed[$i]}\e[0m  "
  fi
done

echo -e "\n\n\nChoose which robot workspace to activate:\n"
declare -a av_choice
for i in ${!robot_installed[@]}; do
  index=$(($i + 1))
  av_choice+=($index)
  echo "  $index) ${robot_installed[$i]}"
  if [[ $index -eq  ${#robot_installed[@]} ]]; then
    echo "  $(($index + 1))) Exit"
    av_choice+=($(($index + 1)))
  fi
done

# Read user choice
echo
read var

while [[ ! " ${av_choice[@]} " =~ " ${var} " ]]
do
	read -p "Wrong character! " var
done

echo
if [ $var = "${av_choice[-1]}" ];then
	echo "Terminated."
	exit
fi

# Set the configuration in bashrc
new_active[$(($var - 1))]=1

for i in ${!new_active[@]}; do
  if [[ ${new_active[$i]} -eq 1 ]]; then
    new_robot=${robot_installed[$i]}
    sed -i "s|.*\(source ~/${workspaces_installed[$i]}/.*\)|\1|" ~/.bashrc
  else
    sed -i "s|.*\(source ~/${workspaces_installed[$i]}/.*\)|# \1|" ~/.bashrc
  fi
done

echo "${new_robot} workspace activated succesfully."
echo "Shell reloaded!"

# Run pepper workspace setup
if [ $new_robot = "Pepper" ]; then
  ./pepper_ws/pepper_workspace_setup.sh
fi

exec bash
