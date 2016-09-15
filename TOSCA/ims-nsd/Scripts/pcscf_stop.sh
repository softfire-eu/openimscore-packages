#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options_pcscf" ]; then
	source $SCRIPTS_PATH/default_options_pcscf
fi 

# pcscf stop script

# Check if there icscf waiting already
check=$(service $SERVICE status | grep waiting)
if [ -z "$check" ];then
	echo "$SERVICE : not stopped , will stop"
	stop $SERVICE
else
	echo "$SERVICE: already stoppped!"
fi
