#!/bin/bash
if [ -z "$3" ]; then
  echo "Example usage: sudo ./generate_event_reports.sh <db_password> <destination_catalog> <db_address>"
  exit
fi

USER=root
DB=isanteplus
DB_PASS=$1
DESTINATION_CATALOG=$2
DB_ADDRESS=$3

function convert_files() {
  find $DESTINATION_CATALOG | egrep $MATCH_FILE | \
  while read path; do
    sed -i '1d' $path
  done
}

generateData() {
  REPORT_NAME=$1
  mysql -u $USER -p$DB_PASS -D $DB -h $DB_ADDRESS -e "CALL $REPORT_NAME();" > "$DESTINATION_CATALOG/$REPORT_NAME.json"
}

mkdir -p $DESTINATION_CATALOG
mysql -u $USER -p$DB_PASS -D $DB -h $DB_ADDRESS -e "CALL org_unit_etl_extension();"
mysql -u $USER -p$DB_PASS -D $DB -h $DB_ADDRESS -e "CALL dashboard_etl_extension();"



generateData "hiv_patient_with_activity_after_disc_tracked_entity"
generateData 'patient_status_tracked_entity'
generateData 'patientArvEnd_tracked_entity'
generateData 'patientNextArvInThirtyDay_tracked_entity'
generateData 'patientStartingArv_tracked_entity'
generateData 'visitNextFourteenDays_tracked_entity'
generateData 'patient_with_only_register_form_tracked_entity'
generateData 'visitNextSevenDays_tracked_entity'
generateData 'hivPatientWithoutFirstVisit_tracked_entity'
generateData 'dashboard_tracked_entity'

generateData 'hiv_patient_with_activity_after_disc_event'
generateData 'patient_status_event'
generateData 'patientArvEnd_event'
generateData 'patientNextArvInThirtyDay_event'
generateData 'patientStartingArv_event'
generateData 'visitNextFourteenDays_event'
generateData 'patient_with_only_register_form_event'
generateData 'visitNextSevenDays_event'
generateData 'hivPatientWithoutFirstVisit_event'
generateData 'dashboard_event'

MATCH_FILE='.*\_event.json';
convert_files;

MATCH_FILE='.*\_tracked_entity.json';
convert_files;
