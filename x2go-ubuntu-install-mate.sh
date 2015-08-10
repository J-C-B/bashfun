#!bin/bash

####################################################################################
####                        Install X2Go                                        ####
####                        Pulled from                                         ####
####    http://www.jupiterbroadcasting.com/85377/get-going-with-x2go-las-374/   ####
####                        John 11/08/15                                       ####
####################################################################################

sudo apt-get update && apt-get install python-software-properties -y && add-apt-repository ppa:x2go/stable -y

sudo apt-get update -y && apt-get install x2goserver x2goserver-xsession -y

####################################################################################
####      Use these for ubuntu server - install "Mate" Desktop                  ####
####                   (ie previously headless machine)                         ####
####################################################################################

#sudo apt-add-repository ppa:ubuntu-mate-dev/ppa -y

#sudo apt-add-repository ppa:ubuntu-mate-dev/trusty-mate -y

#sudo apt-get update && sudo apt-get upgrade -y

#sudo apt-get install --no-install-recommends ubuntu-mate-core ubuntu-mate-desktop

####################################################################################
## Include these if you also wish to contol other machines remotley from this host##
####################################################################################

#sudo apt-get update

#sudo apt-get install x2goclient
