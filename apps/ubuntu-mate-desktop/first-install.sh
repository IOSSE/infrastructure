#!/bin/bash
sudo apt -y update
sudo apt -y upgrade
sudo apt install -y vim  


# speed up mate desktop
dconf write /org/mate/marco/general/compositing-manager false
dconf write /org/mate/desktop/interface/enable-animations false


echo "All apps are installed now."
