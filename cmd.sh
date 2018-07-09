#/bin/sh

# default every day at 1 am
: ${ETL_CRON="0 1 * * *"}
: ${DHIS_URL_AND_PORT=ohie-fr-demo:8080}
: ${MYSQL_HOST=openmrs-mysql-db}
: ${MYSQL_ROOT_PASSWORD=secret_password}
: ${DHIS_ADMIN_PASSWORD=secret_password}

export ETL_CRON
export DHIS_URL_AND_PORT
export MYSQL_HOST
export DHIS_ADMIN_PASSWORD

/utils/replace-vars /etc/cron.d/etl-cron
/utils/replace-vars /etl/execute-etl.sh

chmod +x /etl/execute-etl.sh

# Remove quotes
sed -i "s/['\"]//g" /etc/cron.d/etl-cron

touch /var/log/cron.log
cron & tail -f /var/log/cron.log
