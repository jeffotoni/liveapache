# liveapache
script em bash, para checar se o servidor apache está online, caso não esteja reinicialize o serviço.


# running

$ sh liveapache.sh

# Can be configured by cron to be called from time to time

Calling the script every 1 minute

```sh

*/1 * * * *   cd /dir/script && sh liveapache.sh >> liveapache.log

```