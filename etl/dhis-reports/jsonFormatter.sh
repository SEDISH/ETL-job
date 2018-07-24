#!/bin/bash
if [ -z "$3" ]; then
  echo "Example usage: ./jsonFromatter.sh <name_of_a_script> <db_password> <db_address>"
  exit
fi

echo "Executing $1 script"
USER=root
DB=isanteplus
scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
DB_ADDRESS=$3

mkdir -p report_results
mysql -u $USER -p$2 -h $DB_ADDRESS $DB < $scriptDir/report_scripts/$1 | sed 's/}/},/g' | sed 1d | sed '$ s/.$//' > $scriptDir/report_results/$1-results.json
echo "Results saved to: $1-results.json"
