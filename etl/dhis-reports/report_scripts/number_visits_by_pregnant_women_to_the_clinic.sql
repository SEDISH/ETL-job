select json_object(
"dataElement", "JdafRhccp3O",
"categoryOptionCombo", "GiBSEXO5lzA",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
select COUNT(distinct pp.patient_id) AS Total, pp.start_date AS Dt FROM isanteplus.patient p, isanteplus.patient_pregnancy pp
WHERE p.patient_id=pp.patient_id
GROUP BY pp.start_date
) A
