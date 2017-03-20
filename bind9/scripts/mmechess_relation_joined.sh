#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# bind9 mmechess relation joined script

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

# Check for mmechess related information

if [ -z "$mmechess_var_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no mmechess_var_name! Using default : mme"
	mmechess_var_name="mme"
fi

if [ -z "$mmechess_hostname" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no mmechess_hostname! Using default : mmechess"
	mmechess_hostname="mmechess"
fi

if [ -z "$mmechess_softfire_internal" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no softfire_internal network for mmechess !"
	exit 1
fi

# Check if we want to use floatingIPs for the entries
echo "$SERVICE : useFloatingIpsForEntries : $useFloatingIpsForEntries for mmechess"
if [ ! $useFloatingIpsForEntries = "false" ]; then
	if [ -z "$mmechess_softfire_internal_floatingIp" ]; then
		echo "$SERVICE : there is no floatingIP for the softfire_internal network for mmechess !"
		#exit 1
	else
		# Else we just overwrite the environment variable
		mmechess_softfire_internal=$mmechess_softfire_internal_floatingIp
	fi
fi


# Save variables related to icscf into a file to access it in a later phase
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
else
	touch $VARIABLE_BUCKET
fi
printf "mmechess_var_name=%s\n" \"$mmechess_var_name\" >> $VARIABLE_BUCKET
printf "mmechess_softfire_internal=%s\n" \"$mmechess_softfire_internal\" >> $VARIABLE_BUCKET

# Fill up the template dns zone file with the necessary entries
cat >>$SCRIPTS_PATH/$ZONEFILE <<EOL
$mmechess_var_name.$realm. IN A $mmechess_softfire_internal
$mmechess_hostname.$realm. IN A $mmechess_softfire_internal
EOL

