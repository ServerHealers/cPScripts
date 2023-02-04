#!/bin/bash
#
# Date: Oct 22 2022
# Author: Muhammed Fasal
# Company: ServerHealers ( https://serverhealers.com )
#
# Bash script to check whether the sub/addon/parked/primary domains are 
# hosted on a cPanel server is actually resolving to it.
#
# Drawbacks:
# 	This will mark those domains hosted through an external CDN like CloudFlare as not hosted on the server due to the IP masking
#	This will not fetch the IPs correctly on NAT network servers thus won't work ( 	On AWS EC2 instances for eg)
#
# [We will improve these drawbacks and make it more productive for sure]


# Get A record
a_record_ip(){
       A=$(dig $1 A +short | sort | head -1)

       [ -z $A ] && A="NO_A_RECORD"

       echo -n $A
}

ip_list=$(ip addr | grep inet | egrep -v 'inet6|127.0.0' | awk '{print $2}' | cut -d\/ -f1 | tr '\n' ' ')

main(){

	for cpuser in $(/bin/ls -1A /var/cpanel/users); do
		for domain in $(grep $cpuser /etc/userdomains | cut -d: -f1); do

		var1=$(a_record_ip $domain)
		echo $ip_list | grep $var1 > /dev/null 2>&1
                [[ $? -ne 0 ]] && A_check=1 || A_check=0

		if [[ $A_check -eq 0 ]]; then
			echo "$domain - $var1 [Hosted within this server]"
                
		else
			echo "$domain - $var1 [NOT Hosted within this server]"        
                fi
		done
	done
}

main
			
