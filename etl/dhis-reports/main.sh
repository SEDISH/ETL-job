#!/bin/bash
if [ -z "$4" ]; then
  echo "Example usage: sudo ./main.sh <db_password> <db_address> <dhis_admin_password> <dhis_url:port>";
  exit;
fi

USERNAME=admin
DB_PASS=$1;
DB_ADDRESS=$2;
DHIS_PASSWORD=$3;
DHIS_URL=$4;
scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
mkdir -p $scriptDir/logs;

mysql -u root -p${DB_PASS} -h ${DB_ADDRESS} -D isanteplus -e "CALL isanteplusreports_dml();"
mysql -u root -p${DB_PASS} -h ${DB_ADDRESS} -D isanteplus -e "CALL patient_status_arv();"

python $scriptDir/etl_extension/org_units/sync_org_unit.py $DB_PASS $DB_ADDRESS $DHIS_PASSWORD $DHIS_URL
$scriptDir/generateAllData.sh $DB_PASS "$DB_ADDRESS";
$scriptDir/deleteAllProgramsData.sh $DHIS_URL $DHIS_PASSWORD;

curl -k -X POST -u "$USERNAME:$DHIS_PASSWORD" "http://$DHIS_URL/api/26/maintenance/analyticsTablesClear" 2>&1 | \
  awk -v date="$(date +"%Y-%m-%d %r")" '{print date ": " $0}' >> $scriptDir/logs/analyticsRun.log;

$scriptDir/sendAllData.sh $DHIS_URL $DHIS_PASSWORD;

curl -k -X POST -u "$USERNAME:$DHIS_PASSWORD" "http://$DHIS_URL/api/25/resourceTables/analytics" 2>&1 | \
  awk -v date="$(date +"%Y-%m-%d %r")" '{print date ": " $0}' >> $scriptDir/logs/analyticsRun.log;
