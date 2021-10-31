#!/bin/bash
##########################################################################
#		Author: Meet Patel
#		Last Revision: 11/29/2019
#		Purpose: This script identifies unique IP addresses
#		  located in log files, performs an IP lookup on them, and
#		  writes the information to a file called 'iplookup.txt'.
#
#	    It writes the IP addresses for IPs that have made 100+ 
#	      attempts to a file named addtoufw.txt, which can then 
#	      be fed into ufwadd.sh to add them to the firewall
#
#	    It then prompts the user to display the IP addresses
#		  and/or IP lookup information before exiting 	
##########################################################################

count=0	# Counter for output
red=`tput setaf 1`
green=`tput setaf 2`

############### ERROR CHECKING ######################
# have to sudo to access log files

#check to ensure user has elevated privileges
echo
echo "Checking User priviliges...."
echo
if (( $EUID != 0 )); then
	echo "Please run as ${red}sudo"
	echo
	exit 1
else
    echo "User has ${green}sudo priviliges, continuing..."
    echo
fi
# check for proper usage (correct # of arguments)
	
# check for proper number of arguments
# the script should take one argument
echo "Checking if the input arguments are correct, Please hold..."
echo

if [ $# -eq 2 ] 
then
    echo "${green}Correct number of arguments detected, moving on."
    echo
else
    echo "${red}Invalid number of argument, Please pass exactly ${red}2 arguments... "
    echo
    exit 2
fi

############# DONE ERROR CHECKING ###################
#####################################################

# get current ips and create list. Pipes to sort and identify unique IPs

# get the IP addresses from /var/log/auth.log; pipe to sort IPs and
# identify unique values
cat /var/log/auth.log > newips.txt

echo "----------List of all unique addresses:... --------- "
grep "Failed password" newips.txt | grep -Po "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort -g | uniq -c > ipuniq.txt
grep "Failed password" newips.txt | grep -Po "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort -g | uniq > nonuniqlist.txt 
cat ipuniq.txt
echo

echo
echo "Reading all the ip address in UFW, Please Hold.... "
echo

sudo ufw status | sort | uniq | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" > ufwiplist.txt

echo "----- List of all current Ip addresses in UFW -----"
cat ufwiplist.txt
echo

echo "-------------${green}Magic ${green}Happens ${green}Here-------------"
sleep 1s

# identify IPs with 100+ attempts

#while read -r rf
#do
#  while read -r uf 
#  do
#	if [ $rf == $uf ] 
#	then
#	    echo "${red}$rf is already in the firewall..."
#	    echo
#	fi
# done < ufwiplist.txt 
# done < nonuniqlist.txt

 grep "Failed password" newips.txt | grep -Po "[0-9]+\.[0-9]+\.[0-9]+[0-9]+\.[0-9]+" | sort -g | uniq -c > testfile.txt
           while read -r line
          do
             num=$(echo $line | cut -f1 -d " ")
		ip=$(echo $line | cut -f2 -d " ")
               if [[ "$num" -gt "100" ]];
		    then
			echo
			echo "${red}$ip had ${red}$num attempted tries...."
			echo
			echo "Adding ${red}$ip to the UFW firewall... ";
			sudo ufw insert 1 deny from $ip to any 
			echo
		    else
			echo "${green}$ip only had ${green}$num attempts..."
		fi;
           done < testfile.txt


#Counting the number of uniqe addresses
while read -r f
do
  let "count++"
done < ipuniq.txt

###########################################################
	

printf "\n\nDone!\n\n"
sleep 1s

# display new list

echo
echo "There are currently ${red}$count unique IP addresses"    # display number of unique addresses
echo



echo


