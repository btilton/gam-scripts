#!/bin/bash
###############
#      Author: Brian Tilton
#        Date: 2015-10-06
#       Title: removeallgroups.sh
# Description: Script to remove a user from all groups they're a member of
###############

# Change this alias to your own gam.py location
alias gam='python /Users/btilton/gam/gam.py'

useremail=$1

python /Users/btilton/gam/gam.py info user $usermail noaliases nolicenses noschemas |\
grep -A31337 'Groups: (13)' |\
grep -v 'Groups: (13)' |\
sed -e 's/^[[:space:]]*//' |\
cut -d'<' -f2 |\
cut -d'>' -f1 |\
xargs -o -I FILE python /Users/btilton/gam/gam.py \
update group FILE remove user $usermail
