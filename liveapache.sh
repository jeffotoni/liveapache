#!/bin/bash

#
# autor: @jeffotoni
# about: Script to deploy our applications
# date:  07/05/2017
# since: Version 0.1
#

#
# Email for email submissions
#
FROM="yourmail@domain.com"

#
# Email to
#
TO="mailto@domain.com"


#
# Domains to test if they are online
# Are all on the same server
#
DOMAIN_TEST='https://www.yourdomain1.com http://yourdomain2.com'

#
#
#  Id to leave the email unique
#
#
IDTIME=$(date +%s)


###### Declaration of functions


#
# Sending mail through mail, for used just install mailutils
# In the shell type mail your@mail.com 
# 
# Example: 
# echo "Content here" | mail -s "Title text" -r "emailfrom@you.com" "emailto@you.com"
# 
# $1 to email 
# $2 subject
# $3 message
# 
sendmail ()
{
    
    echo "Send email [mail] FROM: $FROM to $1 $IDTIME"
    echo "$3" | mail -s "$2" -r "$FROM" "$1"
    sleep 1
}

# 
# install aws cli 
# http://docs.aws.amazon.com/cli/latest/userguide/installing.html
# 
# send ses 
# http://docs.aws.amazon.com/cli/latest/reference/ses/send-email.html
# 
# Sending emails through aws cli
# The parameters are jsons
#
# destination.json => {"ToAddresses":  ["mailto@domain.com"]}
# 
# message.json => {
# 
#   "Subject": {
#       "Data": "Server Apache Checking",
#       "Charset": "UTF-8"
#   },
#   "Body": {
#       "Text": {
#           "Data": "",
#            "Charset": "UTF-8"
#        },
#        "Html": {
#            "Data": "<h1>Server stopped, initializing apache</h1>"
#        }
#    }
# }
# 
# --destination file://destination.json
# --message file://message.json
# 
#  OR
#  
#  --destination '{}'
#  --message '{}'
# 
sendmailaws ()
{

#
# send to
#
destination='{"ToAddresses":  ["'$1'"]}'

#
# Message body
#
message='{"Subject": {"Data": "'$2'","Charset": "UTF-8"},"Body": {"Html": {"Data": "'$3'"}}}'


echo "send email [awscli ses]"

#
# Sending via aws
#
aws ses send-email --from $FROM --destination "$destination" --message "$message"

sleep 1

}

#
# Initializing apache server (ubuntu)
#
restart_apache ()
{

    #
    # message
    #
    echo "Apache Offline [$DOMAIN]"
    
    #
    # message mail title
    #
    TITLE="Error Apache Offline!!! $IDTIME" 

    #
    # body message mail
    #
    MSG="Server being initialized, it was offline for some reason we do not know, return server [$1] check the apache logs in /var/log/apache"

    #
    # send email [mail]
    #
    sendmail "$TO" "$TITLE" "$MSG"
    
    #
    # send email [aws cli]
    #
    sendmailaws $TO "Server 7.0. ficou Offline! $IDTIME" "<h1>Server being initialized, it was offline for some reason we do not know, return server [$1] check the apache logs in /var/log/apache</h1>"


    echo 
    #
    # message
    # 
    echo "Restarting apache"

    #
    # Stopping the service
    #
    /etc/init.d/apache2 stop > /dev/null

    #
    # Ensuring there are no more apache processes
    #
    killall -9 apache2 > /dev/null 2>&1

    #
    # Initializing the service
    #
    /etc/init.d/apache2 start


    #
    # Checking if everything is okay.
    #
}

######  End functions


#
# message
#
echo 
echo "First method of apache alive check?"

# 
# Loop
# 
for DOMAIN in $DOMAIN_TEST
do
    
    CMD=$(curl -Is $DOMAIN -L | grep HTTP/)

    cmd_trim=$(echo -n ${CMD} | tr -d "\t\r\n")

    if [ "$cmd_trim" = "HTTP/1.1 200 OK" ]
    then

        echo "Apache Online [$DOMAIN]"        

    else

        # 
        # stop/start server
        # 
        restart_apache "$cmd_trim"

    fi
    
    sleep 1

done


#
# message
# According to the method of checking
#
echo 
echo "Second method of apache alive check?"

#
# Listing the process pids if they are active
#
CMD=$(ps aux | pgrep 'apache2')

#
# If there is value, it will show the character 
# size that returned the above command
# 
if [ ${#CMD} -ne 0 ]
then
    
    #
    # message
    #
    echo "Apache online!!"
    sleep 1
    
else 
    #
    #
    #
    echo "Apache offline!"
    
    #
    # Restart the service
    #
    restart_apache "Did not find the apache process"
fi

           



