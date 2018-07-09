#!/bin/bash
if [ -z "$1" ]; then
  echo "type db password"
  exit
fi

USER=root
DB=isanteplus
scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

# create procedure for etl
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/etl_extension/org_units/org_unit_etl_extension.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/etl_extension/dashboard_etl_extension.sql";

# create procedures
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/hiv_patient_with_activity_after_disc_event.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/hiv_patient_with_activity_after_disc_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/idgen.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/patient_status_event.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/patient_insert_idgen.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/patient_status_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/patientArvEnd_event.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/patientArvEnd_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/patientNextArvInThirtyDay_event.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/patientNextArvInThirtyDay_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/patientStartingArv_event.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/patientStartingArv_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/visitNextFourteenDays_event.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/visitNextFourteenDays_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/visitNextSevenDays_event.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/visitNextSevenDays_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/patient_with_only_register_form_event.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/patient_with_only_register_form_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/consultationByDay_event.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/consultationByDay_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/hiv_patient_without_first_visit_event.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/hiv_patient_without_first_visit_tracked_entity.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/dashboard_event.sql";
mysql -u $USER -p$1 -D $DB -e "source $scriptDir/report_scripts/dashboard_tracked_entity.sql";

#  generate and format the data
mkdir -p $scriptDir/report_results;
$scriptDir/generate_event_reports.sh $1 $scriptDir/report_results/

$scriptDir/jsonFormatter.sh communityArvDistribution.sql  $1
$scriptDir/jsonFormatter.sh exposed_infants_register_in_ptme_program.sql  $1
$scriptDir/jsonFormatter.sh hiv_transmission_risks_factor.sql  $1
$scriptDir/jsonFormatter.sh number_eligible_children_for_pcr.sql  $1
$scriptDir/jsonFormatter.sh number_exposed_infants_tested_by_pcr.sql  $1
$scriptDir/jsonFormatter.sh number_infants_from_mother_on_prophylaxis.sql  $1
$scriptDir/jsonFormatter.sh numberOfPatientByArvStatus.sql  $1
$scriptDir/jsonFormatter.sh number_patient_beneficie_pcr.sql  $1
$scriptDir/jsonFormatter.sh numberPatientReceivingARVByPeriod.sql  $1
$scriptDir/jsonFormatter.sh number_pregnancy_women_had_prenatal_cons.sql  $1
$scriptDir/jsonFormatter.sh number_prenatal_visit_by_site.sql  $1
$scriptDir/jsonFormatter.sh number_visits_by_pregnant_women_to_the_clinic.sql  $1
$scriptDir/jsonFormatter.sh pregnancy_women_on_haart.sql  $1
$scriptDir/jsonFormatter.sh firstVisitAge.sql  $1
