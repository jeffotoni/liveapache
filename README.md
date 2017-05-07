# liveapache
Script in bash, to check if the apache server is online, if it is not rebooting the service.

It sends e-mails to communicate if the server is not online, you can use mail for client to send mail or aws cli, but for aws cli will have to install in your linux environment.

This script was made in bash in ubuntu environment.

# running

$ sh liveapache.sh

# Can be configured by cron to be called from time to time

Calling the script every 1 minute

```sh

*/1 * * * *   cd /dir/script && sh liveapache.sh >> liveapache.log

```