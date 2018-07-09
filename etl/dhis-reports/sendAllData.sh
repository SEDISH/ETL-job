#!/bin/bash
if [ -z "$2" ]; then
  echo "Example usage: ./sendAllData.sh <dhis_url:port> <dhis_password>";
  exit;
fi

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
USERNAME=admin;
DHIS_URL=$1;
DHIS_PASSWORD=$2;
PAGE_SIZE=100000;
MATCH_FILE='.*\.json';
JSON_CATALOG=$scriptDir'/report_results/';
SUBURL='/api/26';
ADD_PARAMS='';

function send_files() {
  find $JSON_CATALOG | egrep $MATCH_FILE | \
  while read path; do
    LOG_FILE=$( echo $path | sed 's/.*\///' | sed 's/\.json/.log/' | sed 's/^/post_/');
    curl -k -d "@$path"  -H "Content-Type: application/json" -X POST -u "$USERNAME:$DHIS_PASSWORD" \
        "http://$DHIS_URL/api/26/$SUBURL$ADD_PARAMS" 2>&1 | \
      awk -v date="$(date +"%Y-%m-%d %r")" '{print date ": " $0}' >> $scriptDir/logs/$LOG_FILE;
  done
}

mkdir -p $scriptDir/logs;

MATCH_FILE='.*\_tracked_entity.json';
SUBURL='trackedEntityInstances';
ADD_PARAMS='?strategy=CREATE_AND_UPDATE';
send_files;

MATCH_FILE='.*\_event.json';
SUBURL='events';
ADD_PARAMS='?strategy=CREATE_AND_UPDATE';
send_files;

# tmp disabled in order to fix dataset reports
MATCH_FILE='.*\.sql-results.json';
SUBURL='dataValueSets';
ADD_PARAMS='?strictCategoryOptionCombos=true&orgUnitIdScheme=code';
# send_files;
