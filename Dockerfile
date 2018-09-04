FROM uwitech/ohie-base

RUN locale-gen en_US.UTF-8 
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# Install dependencies
RUN apt-get update && \
  apt-get install -y mysql-client python-mysqldb curl python-dev libmysqlclient-dev \
  python-pip jq

RUN pip install MySQL-python

# Load iSantePlus etl scripts
COPY isanteplus_etlscript/* /isanteplus_etlscript/

COPY crontab /etc/cron.d/etl-cron
COPY etl /etl
COPY cmd.sh /cmd.sh

CMD ./cmd.sh
