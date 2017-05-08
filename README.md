# liveapache
Script in bash, to check if the apache server is online, if it is not rebooting the service.

It sends e-mails to communicate if the server is not online, you can use mail for client to send mail or aws cli, but for aws cli will have to install in your linux environment.

This script was made in bash in ubuntu environment.

# Setting up some variables

You need to set up email that will receive notifications

```sh

#
# Email for email submissions
#
FROM="yourmail@domain.com"

#
# Email to
#
TO="mailto@domain.com"

```

You need to set up domains you want to test

```sh

#
# Domains to test if they are online
# Are all on the same server
#
DOMAIN_TEST='https://www.yourdomain1.com http://yourdomain2.com'

```

There are 2 ways to send emails sendmail and sendmailaws, one is by using the mail from the aws cli package to install [mail (utils)](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) to know more about aws ses [aws cli (Ses)](http://docs.aws.amazon.com/cli/latest/reference/ses/send-email.html) 

By default mail is enabled

```sh

#
# Shipping method mailutils
#
ACTIVE_MAIL="mailutils"

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

#
# Shipping method aws cli ses
#
#ACTIVE_MAIL="aws"

```

Determines which is the operating system, so that its function is appropriate as each linux distribution


```sh

#
#
# Determines which is the operating system 
#
SO="Ubuntu"

```

You can create your own function for your favorite distribution, look at the example


```

#
# Function call
#
DoApache$SO

#
# Function statement
#
DoApacheUbuntu ()
{
  #code
}

```


Determines the path of the apache error log


```sh

#
# path log error apache
#
PATHLOG_ERROR="/var/log/apache2/error.log"

```

# running

$ sh liveapache.sh

# Can be configured by cron to be called from time to time

Calling the script every 1 minute

```sh

*/1 * * * *   cd /dir/script && sh liveapache.sh >> liveapache.log

```