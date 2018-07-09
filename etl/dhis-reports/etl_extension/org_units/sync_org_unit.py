import requests
import MySQLdb
import argparse
import warnings
import os

parser = argparse.ArgumentParser()
parser.add_argument("db_password")
parser.add_argument("db_address")
parser.add_argument("dhis2_admin_password")
parser.add_argument("dhis2_url_port")
args = parser.parse_args()

USER = 'admin'
PASSWORD = args.dhis2_admin_password
URL = args.dhis2_url_port

class Unit:
    """Unit class"""

    def __init__(self, uid, code, path):
        self.uid = uid
        self.code = code
        self.path = path

def getScript(filename):
    fd = open(filename, 'r')
    script = fd.read()
    fd.close()
    return script

def executeInsertScript(script, data):
    try:
        cursor.execute(script, data)
    except MySQLdb.Error as e:
        print("Error %d: %s" % (e.args[0], e.args[1]))

def extractCode(orgUnit, orgUnitDetails):
    try:
        orgUnit['code'] = orgUnitDetails['code']
    except KeyError:
        orgUnit['code'] = None

def extractPath(orgUnit, orgUnitDetails):
    try:
        path = orgUnitDetails['path']
        path = path.replace('/', ',')
        path = path[1:]
        orgUnit['path'] = path
    except KeyError:
        orgUnit['path'] = None

def fetchOrgUnit(orgUnits):
    for unit in orgUnits:
        wholeUnit = requests.get('http://' + URL + '/api/26/organisationUnits/' + unit['id'], auth=(USER, PASSWORD))
        unitParams = wholeUnit.json()
        extractCode(unit, unitParams)
        extractPath(unit, unitParams)
        print(unit)
    return orgUnits

DB_USER = 'root'
DB_PASSWORD = args.db_password
DB_HOST = args.db_address
ISANTEPLUS = 'isanteplus'
warnings.filterwarnings('ignore', category=MySQLdb.Warning)

# connect with the database
con = MySQLdb.connect(DB_HOST, DB_USER, DB_PASSWORD, ISANTEPLUS)
cursor = con.cursor()

# prepare all scripts
dirname = os.path.dirname(__file__)
create_org_code_uid = getScript(os.path.join(dirname, 'create_org_code_uid_table.sql'))
insert_org_code_uid = getScript(os.path.join(dirname, 'insert_org_code_uid.sql'))
select_org_code_uid = getScript(os.path.join(dirname, 'select_all_org_code_uid.sql'))

# fetch list of organisation
response = requests.get('http://' + URL + '/api/26/organisationUnits?pageSize=10000', auth=(USER, PASSWORD))
data = response.json()
orgUnits = data['organisationUnits']

# create table if not exists
cursor.execute(create_org_code_uid)

# select all organisations from the database
dbValues = []
cursor.execute(select_org_code_uid)
for (uid, code, path) in cursor:
    dbValues.append(Unit(uid, code, path))

# fetch only those which were not fetched before
toFetch = []
for unit in orgUnits:
    dbUnit = next((x for x in dbValues if x.uid == unit['id']), None)
    if dbUnit is None:
        toFetch.append(unit)

orgUnits = fetchOrgUnit(toFetch)

# insert new organisations
for unit in orgUnits:
    data = (unit['id'], unit['code'], unit['path'])
    executeInsertScript(insert_org_code_uid, data)

con.commit()
cursor.close()
con.close()
