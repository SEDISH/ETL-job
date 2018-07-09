#!/bin/bash
if [ -z "$2" ]; then
  echo "Example usage: ./jsonFromatter.sh <name_of_a_script> <db_password>"
  exit
fi

echo "Executing $1 script"
USER=root
DB=isanteplus
scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

mkdir -p report_results
mysql -u $USER -p$2 $DB < $scriptDir/report_scripts/$1 | sed 's/}/},/g' | sed 1d | sed '$ s/.$//' > $scriptDir/report_results/$1-results.json
echo "Results saved to: $1-results.json"
