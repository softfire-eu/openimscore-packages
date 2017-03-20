#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# bind9 dra relation joined script

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options" ]; then
	source $SCRIPTS_PATH/default_options
fi

if [ -z "$SCRIPTS_PATH" ]; then
	echo "$SERVICE : Using default script path $SCRIPTS_PATH"
	SCRIPTS_PATH="/opt/openbaton/scripts"
else
	echo "$SERVICE : Using custom script path $SCRIPTS_PATH"
fi

VARIABLE_BUCKET="$SCRIPTS_PATH/.variables"

# Check for fhoss related information

if [ -z "$dra_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no dra_name! Using default : dra"
	dra_name="dra"
fi

if [ -z "$dra_softfire_internal" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no softfire_internal network for dra !"
	exit 1
fi

# Check if we want to use floatingIPs for the entries
echo "$SERVICE : useFloatingIpsForEntries : $useFloatingIpsForEntries for dra"
if [ ! $useFloatingIpsForEntries = "false" ]; then
	if [ -z "$dra_softfire_internal_floatingIp" ]; then
		echo "$SERVICE : there is no floatingIP for the softfire_internal network for dra !"
		#exit 1
	else
		# Else we just overwrite the environment variable
		dra_softfire_internal=$dra_softfire_internal_floatingIp
	fi
fi


# Save variables related to icscf into a file to access it in a later phase
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
else
	touch $VARIABLE_BUCKET
fi
printf "dra_name=%s\n" \"$dra_name\" >> $VARIABLE_BUCKET
printf "dra_softfire_internal=%s\n" \"$dra_softfire_internal\" >> $VARIABLE_BUCKET

# Fill up the template dns zone file with the necessary entries
cat >>$SCRIPTS_PATH/$ZONEFILE <<EOL
$dra_name.$realm. IN A $dra_softfire_internal
EOL

