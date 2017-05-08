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
# Shipping method mailutils
#
ACTIVE_MAIL="mailutils"

#
# Shipping method aws cli ses
#
ACTIVE_MAIL="aws"


#
# Determines which is the operating system, 
# so that its function is appropriate 
# as each linux distribution
#
OS="Ubuntu"

#
# path log error apache
#
PATHLOG_ERROR="/var/log/apache2/error.log"

#
# path log postgresql
#
PATHLOG_POSTGRE="/var/lib/postgresql/9.5/main/pg_log/postgresql-2017-05-07_000000.log"

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


#
#
#  DATE
#
#
DATE=$(date)


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
DoApacheUbuntu ()
{

    PATHLOG_ERROR_TMP="/tmp/tmp_apache_error.log"
    #
    # check file exist
    #
    if [ -e $PATHLOG_ERROR ]
        then

    #
    #
    #
    #cat $PATHLOG_ERROR > $PATHLOG_ERROR_TMP

    #
    #
    #
    #sed -i 's/\n/<br>/g' $PATHLOG_ERROR_TMP

    #
    # Listing the last 30 lines of the log
    #
    log_error=$(tail -n 30 $PATHLOG_ERROR)
    
    else

    #
    #
    #
    log_error="I could not find the file to read your log"
    
    fi

    #
    # message
    #
    echo DATE
    echo "Apache Offline [$DOMAIN]"
    

    if [ $ACTIVE_MAIL = "mailutils" ]
        then
        
        echo "active mail utils"

        #
        # message mail title
        #
        TITLE="Error Apache Offline!!! $IDTIME" 

        #
        # body message mail
        #
        MSG="Server 7.0 being initialized, it was offline for some reason we do not know, return server [$1] check the apache logs in $PATHLOG_ERROR.\n\n Check your log:\n\n$log_error"

        #
        # send email [mail]
        #
        sendmail "$TO" "$TITLE" "$MSG"

    else
        
        echo "active aws cli"

        #
        # Removing \ t \ r and character '
        #
        clean_error=$(echo -n ${log_error} | tr -d "'")
        clean_error=$(echo -n ${clean_error} | tr -d '"')

        #
        # send email [aws cli]
        #
        sendmailaws $TO "Server 7.0. Apache Offline! $IDTIME" "<h1>Server being initialized, it was offline for some reason we do not know, return server [$1] check the apache logs in $PATHLOG_ERROR</h1><br/><h2>Check your log:</h2><p>$clean_error</p>"

    fi
        

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

DoPingPostgres () {

    echo 
    echo "Testing if postgresql is responding:"
    echo 

    #
    # postgresl >= 9.3
    #
    ping=$(pg_isready -U postgres)

    #
    # Split and taking the second position
    #
    status=$(echo "$ping" | cut -d "-" -f 2)

    #
    # Removing spaces before and after, trim
    #
    status=$(echo -n ${status} | tr -d "\t\r\n")

    #
    # lowercase
    #
    status_lower=$(echo "$status" | awk '{print tolower($0)}')
        

    if [ "$status_lower" = "accepting connections" ]
    then
        
        echo "Postgresql Online"

    else
        
        echo DATE
        echo "Postgresql Offline"
        
        #
        # Restarting the service
        #
        DoRestartPostgres$OS "$status_lower"
        
    fi
}

DoRestartPostgresUbuntu ()
{

    if [ -e $PATHLOG_POSTGRE ]
        then

        #
        # Listing the last 20 lines of the log
        #
        log_error=$(tail -n 50 $PATHLOG_POSTGRE)

    else
        log_error="I could not find the file to read your log"        
    fi
   

    if [ $ACTIVE_MAIL = "mailutils" ]
        then
        
        echo "active mail utils"

        #
        # message mail title
        #
        TITLE="Error Postgresql Offline!!! $IDTIME" 

        #
        # body message mail
        #
        MSG="Postgresql being initialized, it was offline for some reason we do not know, return server [$1] check the postgresql logs in $PATHLOG_POSTGRE.\n\n Check your log:\n\n$log_error"

        #
        # send email [mail]
        #
        sendmail "$TO" "$TITLE" "$MSG"

    else
        
        echo "active aws cli"

        #
        # Removing \ t \ r and character '
        #
        clean_error=$(echo -n ${log_error} | tr -d "'\t\r")
        clean_error=$(echo -n ${clean_error} | tr -d '"')

        #
        # send email [aws cli]
        #
        sendmailaws $TO "Server 7.0. Postgresql Offline! $IDTIME" "<h1>Postgresql being initialized, it was offline for some reason we do not know, return server [$1] check the postgresql logs in $PATHLOG_POSTGRE</h1><br/><h2>Check your log:</h2><p>$clean_error</p>"

    fi
        

    echo 
    #
    # message
    # 
    echo "Restarting postgresql"

    #
    # Stopping the service
    #
    /etc/init.d/postgresql stop > /dev/null

    #
    # Ensuring there are no more apache processes
    #
    killall -9 postgresql > /dev/null 2>&1

    #
    # Initializing the service
    #
    /etc/init.d/postgresql start

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

    #
    # ex: -- my text --
    # trim --my text--
    #
    cmd_trim=$(echo -n ${CMD} | tr -d "\t\r\n")

    #
    # Uppercase
    #
    cmd_trim_upper=$(echo "$cmd_trim" | awk '{print toupper($0)}')

    if [ "$cmd_trim_upper" = "HTTP/1.1 200 OK" ]
    then

        echo "Apache Online [$DOMAIN]"        

    else

        # 
        # stop/start server
        # 
        DoApache$OS "$cmd_trim"

    fi
    
    sleep 1

done


#
# message
# According to the method of checking
#
sleep 5
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

    echo DATE

    #
    #
    #
    echo "Apache offline!"
    
    #
    # Restart the service
    #
    DoApache$OS "Did not find the apache process"
fi


#
# message
#
sleep 2
echo 
echo "Checking Postgresql"

DoPingPostgres

echo 
echo "End of check"
