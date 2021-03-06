# livewebserver

Script in bash, to check if the server apache2 and postgresql are online, if you are not restarting the services.

It sends emails to communicate if the server is not online, you can use the mail for the client to send email or aws cli, but for aws cli will have to install in your linux environment.

This script was made in bash in the ubuntu environment at first, we are checking apache2 and postgresql.

Some other services that we will need to implement are redis and nginx.

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


```sh

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

You can also create a postgresql-specific function for your distribution


```sh

#
# Function call
#
DoPingPostgres

#
# Function statement
#
DoPingPostgres ()
{
  # 
  # If postgresql is not responding
  #

  # code ...
  DoRestartPostgres$OS "$status_lower"
}

```

Determines the path of the apache error log


```sh

#
# path log error apache
#
PATHLOG_ERROR="/var/log/apache2/error.log"

```

Determines the path of the Postgresql error log


```sh

#
# path log error postgresql
#
PATHLOG_POSTGRE="/var/lib/postgresql/9.5/main/pg_log/yourlog.log"

```

# running

$ sh livewebserver.sh

# Can be configured by cron to be called from time to time

Calling the script every 1 minute

```sh

*/1 * * * *   cd /script/livewebserver && sh livewebserver.sh >> livewebserver.log

```