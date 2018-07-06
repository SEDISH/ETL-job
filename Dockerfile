FROM uwitech/ohie-base

# Load iSantePlus etl scripts
COPY isanteplus_etlscript/* /isanteplus_etlscript/

COPY crontab /etc/cron.d/etl-cron
COPY etl /etl
COPY cmd.sh /cmd.sh

CMD ./cmd.sh
