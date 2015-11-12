#!/bin/bash

###############################
# Author: Brian Tilton
# Date  : 2015-06-26
# Title : autorespond.sh
# Desc  : Script to reactivate A Google Apps account and then
#       :   set a 50 year away message using GAM
################################

##### INIT VARIABLES #####

# Change this to point to your gam.py file
gamfile="/Users/btilton/gam/gam.py"

gam="python $gamfile"

# Dates
start_date=`date +%Y-%m-%d` #Start date for vacation message in correct format
end_date=`date -v+50y +%Y-%m-%d` #End date for vacation message. 50 years from now

# Set username from argument passed in last position
usermail="${@: -1}"

#Default subject and message variable contents
subject="Thank you for your message"
message="Thank you for your message. The owner of this email address no longer works for Upwork. Thank you."


##### FUNCTIONS #####

#print usage function
function usage {
    echo "Usage: autorespond.sh [-s subject] [-m message] [user_email_address]"
    echo "       autorespond.sh [-h]"
    exit 1
}

function inSubMsg () {
    if [ "$1" == "Sub" ]; then
        echo $'Enter the auto-response subject line.\nPress Enter then crtl-d when done'
        subject=$(cat)
    elif [ "$1" == "Msg" ]; then
        echo $'Enter the auto-response message body.\nPress Enter then crtl-d when done'
        message=$(cat)
    fi
}


##### MAIN #####

# If -h or empty print usage
if [[ ($usermail == '') || ($usermail == '-h') || ($usermail == '--help') ]]; then
    usage
fi

#Check if user exists
echo "Checking if user $usermail exists..."
userexists=$($gam info user $usermail | awk 'NR==1{print $1;}' | cut -d: -f1)

# Script options handling
while [[ $# -gt 1 ]]; do
    case "$1" in
        -s|--subject)
            shift
            if [[ ("$1" != "$usermail") && ("$1" != -*) ]]; then
                subject="$1"
                shift
            elif [[ "$1" == "-m" ]]; then
                inSubMsg Sub
                shift
                if [[ ("$1" != "$usermail") && ("$1" != -*) ]]; then
                    message=$1
                    shift
                elif [[ ("$1" == '-h') || ("$1" == '-s') ]]; then
                    usage
                else
                    inSubMsg Msg
                fi
            elif [[ "$1" == "-h" ]]; then
                usage
            else
                inSubMsg Sub
            fi
            ;;
        -m|--message)
            shift
            if [[ ("$1" != "$usermail") && ("$1" != -* ) ]]; then
                message="$1"
                shift
            elif [ "$1" == '-s' ]; then
                inSubMsg Msg
                shift
                if [[ ("$1" != "$usermail") && ("$1" != -* ) ]]; then
                    subject=$1
                    shift
                elif [[ ("$1" == '-h') || ("$1" == '-m') ]]; then
                    usage
                else
                    inSubMsg Sub
                fi
            elif [ "$1" == '-h' ]; then
                usage
            else
                inSubMsg Msg
            fi
            ;;
        -h|--help)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

if [[ $userexists == User ]]; then
    $gam update user $usermail suspended off &&

    $gam user $usermail vacation on subject "$subject" message "$message" startdate $start_date enddate $end_date &&

    $gam user $usermail show vacation
fi
