#/bin/sh

# default every day at 1 am
: ${ETL_CRON="0 1 * * *"}

export ETL_CRON

/utils/replace-vars /etc/cron.d/etl-cron
# Remove quotes
sed -i "s/['\"]//g" /etc/cron.d/etl-cron

touch /var/log/cron.log
cron & tail -f /var/log/cron.log
