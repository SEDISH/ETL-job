use isanteplus;

select json_object(
"dataElement", "F0ejdT1pNp5",
"categoryOptionCombo", "zsiyh2mFlaA",
"value", Communautaire,
"period", DATE_FORMAT(d, "%Y%m%d")) as results
from(
select 
COUNT(DISTINCT CASE WHEN (pdisp.dispensation_location=1755) THEN pdisp.patient_id else null END) AS Communautaire,
COUNT(DISTINCT CASE WHEN (pdisp.dispensation_location=0) THEN pdisp.patient_id else null END) AS Institution,
count(distinct pdisp.patient_id) as Patient_unique,
pdisp.dispensation_date as d
FROM isanteplus.patient_dispensing pdisp,(select patient_id,max(dispensation_date) as dispensation_date from isanteplus.patient_dispensing group by 1)B
WHERE pdisp.dispensation_location IN(1755,0)
AND B.patient_id=pdisp.patient_id 
AND pdisp.dispensation_date=B.dispensation_date
AND pdisp.patient_id IN(SELECT parv.patient_id FROM isanteplus.patient_on_arv parv)
group by pdisp.dispensation_date) A

union

select json_object(
"dataElement", "F0ejdT1pNp5",
"categoryOptionCombo", "zGHX2K8FlDe",
"value", Institution,
"period", DATE_FORMAT(d, "%Y%m%d")) as results
from(
select 
COUNT(DISTINCT CASE WHEN (pdisp.dispensation_location=1755) THEN pdisp.patient_id else null END) AS Communautaire,
COUNT(DISTINCT CASE WHEN (pdisp.dispensation_location=0) THEN pdisp.patient_id else null END) AS Institution,
count(distinct pdisp.patient_id) as Patient_unique,
pdisp.dispensation_date as d
FROM isanteplus.patient_dispensing pdisp,(select patient_id,max(dispensation_date) as dispensation_date from isanteplus.patient_dispensing group by 1)B
WHERE pdisp.dispensation_location IN(1755,0)
AND B.patient_id=pdisp.patient_id 
AND pdisp.dispensation_date=B.dispensation_date
AND pdisp.patient_id IN(SELECT parv.patient_id FROM isanteplus.patient_on_arv parv)
group by pdisp.dispensation_date) A

union

select json_object(
"dataElement", "F0ejdT1pNp5",
"categoryOptionCombo", "kMDx3o0ivww",
"value", ROUND(((Communautaire /(Institution+Communautaire)) * 100),0),
"period", DATE_FORMAT(d, "%Y%m%d")) as results
from(
select 
COUNT(DISTINCT CASE WHEN (pdisp.dispensation_location=1755) THEN pdisp.patient_id else null END) AS Communautaire,
COUNT(DISTINCT CASE WHEN (pdisp.dispensation_location=0) THEN pdisp.patient_id else null END) AS Institution,
count(distinct pdisp.patient_id) as Patient_unique,
pdisp.dispensation_date as d
FROM isanteplus.patient_dispensing pdisp,(select patient_id,max(dispensation_date) as dispensation_date from isanteplus.patient_dispensing group by 1)B
WHERE pdisp.dispensation_location IN(1755,0)
AND B.patient_id=pdisp.patient_id 
AND pdisp.dispensation_date=B.dispensation_date
AND pdisp.patient_id IN(SELECT parv.patient_id FROM isanteplus.patient_on_arv parv)
group by pdisp.dispensation_date) A

union

select json_object(
"dataElement", "F0ejdT1pNp5",
"categoryOptionCombo", "SjwhEeDcIjy",
"value", Patient_unique,
"period", DATE_FORMAT(d, "%Y%m%d")) as results
from(
select 
COUNT(DISTINCT CASE WHEN (pdisp.dispensation_location=1755) THEN pdisp.patient_id else null END) AS Communautaire,
COUNT(DISTINCT CASE WHEN (pdisp.dispensation_location=0) THEN pdisp.patient_id else null END) AS Institution,
count(distinct pdisp.patient_id) as Patient_unique,
pdisp.dispensation_date as d
FROM isanteplus.patient_dispensing pdisp,(select patient_id,max(dispensation_date) as dispensation_date from isanteplus.patient_dispensing group by 1)B
WHERE pdisp.dispensation_location IN(1755,0)
AND B.patient_id=pdisp.patient_id 
AND pdisp.dispensation_date=B.dispensation_date
AND pdisp.patient_id IN(SELECT parv.patient_id FROM isanteplus.patient_on_arv parv)
group by pdisp.dispensation_date) A;
