select json_object(
"dataElement", "VYWeWjdYyfY",
"categoryOptionCombo", "GiBSEXO5lzA",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
SELECT COUNT(DISTINCT pv.patient_id) AS Total, pv.encounter_date as Dt
FROM isanteplus.pediatric_hiv_visit pv
WHERE pv.actual_vih_status=1405
      AND pv.ptme=1065
	  group by pv.encounter_date
) A
