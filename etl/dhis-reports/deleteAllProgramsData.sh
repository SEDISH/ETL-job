#!/bin/bash
if [ -z "$2" ]; then
  echo "Example usage: ./deleteAllProgramsData.sh <dhis_url:port> <dhis_password>"
  exit
fi

DHIS_URL=$1
DHIS_PASSWORD=$2
scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

$scriptDir/deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD mfyC6GCw1IH # hiv_patient_with_activity_after_disc
$scriptDir/deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD mBMK6RRLKEZ # list_pregnancy_women_receiving_in_clinic
$scriptDir/deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD x2NBbIpHohD # patient_status
$scriptDir/deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD JnV2CR1UKIZ # patientArvEnd
$scriptDir/deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD cBI32y2KeC9 # patientNextArvInThirtyDay
$scriptDir/deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD ewmeREcqCmN # patientStartingArv
$scriptDir/deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD rCJQM1bvXYm # visitNextFourteenDays
$scriptDir/deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD Lh9TkmcZf4a # patient_with_only_register_form
$scriptDir/deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD iTlI6sz0KWM # visitNextSevenDays
$scriptDir/deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD lV4LM75LrPt # hivPatientWithoutFirstVisit
$scriptDir/deleteProgramEvents.sh $DHIS_URL $DHIS_PASSWORD Q7pD6QSyVwF # dashboard_event
