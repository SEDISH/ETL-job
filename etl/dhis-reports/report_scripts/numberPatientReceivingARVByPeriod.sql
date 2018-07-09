select json_object(
"dataElement", "U1vcxpYZy3X",
"categoryOptionCombo", "XKYt4TJ9XCO",
"value", p.val,
"period", DATE_FORMAT(p.period, "%Y%m%d")) as results
FROM (select distinct pdis.visit_date as period, COUNT(pdis.next_dispensation_date) as val
FROM isanteplus.patient p, isanteplus.patient_dispensing pdis, isanteplus.patient_on_arv parv
WHERE p.patient_id=pdis.patient_id
AND pdis.visit_id=parv.visit_id
AND (pdis.next_dispensation_date<>'' AND pdis.next_dispensation_date is not null)
AND DATEDIFF(pdis.next_dispensation_date,pdis.visit_date) between 0 AND 30
GROUP BY pdis.visit_date) as p

UNION

select json_object(
"dataElement", "U1vcxpYZy3X",
"categoryOptionCombo", "G2mnsHyVVSd",
"value", p.val,
"period", DATE_FORMAT(p.period, "%Y%m%d")) as results
FROM (select distinct pdis.visit_date as period, COUNT(pdis.next_dispensation_date) as val
FROM isanteplus.patient p, isanteplus.patient_dispensing pdis, isanteplus.patient_on_arv parv
WHERE p.patient_id=pdis.patient_id
AND pdis.visit_id=parv.visit_id
AND (pdis.next_dispensation_date<>'' AND pdis.next_dispensation_date is not null)
AND DATEDIFF(pdis.next_dispensation_date,pdis.visit_date) between 31 AND 60
GROUP BY pdis.visit_date) as p

UNION

select json_object(
"dataElement", "U1vcxpYZy3X",
"categoryOptionCombo", "xBN9ohifASm",
"value", p.val,
"period", DATE_FORMAT(p.period, "%Y%m%d")) as results
FROM (select distinct pdis.visit_date as period, COUNT(pdis.next_dispensation_date) as val
FROM isanteplus.patient p, isanteplus.patient_dispensing pdis, isanteplus.patient_on_arv parv
WHERE p.patient_id=pdis.patient_id
AND pdis.visit_id=parv.visit_id
AND (pdis.next_dispensation_date<>'' AND pdis.next_dispensation_date is not null)
AND DATEDIFF(pdis.next_dispensation_date,pdis.visit_date) between 61 AND 90
GROUP BY pdis.visit_date) as p

UNION

select json_object(
"dataElement", "U1vcxpYZy3X",
"categoryOptionCombo", "LSOn6gW0uo4",
"value", p.val,
"period", DATE_FORMAT(p.period, "%Y%m%d")) as results
FROM (select distinct pdis.visit_date as period, COUNT(pdis.next_dispensation_date) as val
FROM isanteplus.patient p, isanteplus.patient_dispensing pdis, isanteplus.patient_on_arv parv
WHERE p.patient_id=pdis.patient_id
AND pdis.visit_id=parv.visit_id
AND (pdis.next_dispensation_date<>'' AND pdis.next_dispensation_date is not null)
AND DATEDIFF(pdis.next_dispensation_date,pdis.visit_date) between 91 AND 120
GROUP BY pdis.visit_date) as p

UNION

select json_object(
"dataElement", "U1vcxpYZy3X",
"categoryOptionCombo", "lYdeitMbe5x",
"value", p.val,
"period", DATE_FORMAT(p.period, "%Y%m%d")) as results
FROM (select distinct pdis.visit_date as period, COUNT(pdis.next_dispensation_date) as val
FROM isanteplus.patient p, isanteplus.patient_dispensing pdis, isanteplus.patient_on_arv parv
WHERE p.patient_id=pdis.patient_id
AND pdis.visit_id=parv.visit_id
AND (pdis.next_dispensation_date<>'' AND pdis.next_dispensation_date is not null)
AND DATEDIFF(pdis.next_dispensation_date,pdis.visit_date) > 120
GROUP BY pdis.visit_date) as p;
