#!/bin/sh

echo "Executing ETL, start time: `date`"

DB=`mysql -u root -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} --skip-column-names -e "SHOW DATABASES LIKE 'isanteplus'"`
if [ "$DB" != "isanteplus" ]; then
  mysql -u root -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} < /isanteplus_etlscript/isanteplusreportsddlscript.sql
  mysql -u root -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -D isanteplus < /isanteplus_etlscript/isanteplusreportsdmlscript.sql
  mysql -u root -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -D isanteplus < /isanteplus_etlscript/patient_status_arv_dml.sql
fi

/etl/dhis-reports/main.sh ${MYSQL_ROOT_PASSWORD} ${MYSQL_HOST} ${DHIS_ADMIN_PASSWORD} ${DHIS_URL_AND_PORT}

echo "Finished executing ETL, end time: `date`"
