# dhis-reports

## Prerequisites
You have to install Python's support for MySQL
```
sudo apt-get install python-dev libmysqlclient-dev
pip install MySQL-python
```
## Running
In order to upload the ETL data into DHIS2 got to the main directory an run  
```
sudo ./main.sh <dhis_url:port> <db_password> <dhis_admin_password>
```
### Example
```
sudo ./main.sh 172.19.0.10:8080 dbSecret adminSecret
```
