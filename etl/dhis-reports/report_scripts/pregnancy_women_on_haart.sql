select json_object(
"dataElement", "mYjm31nugeK",
"categoryOptionCombo", "GiBSEXO5lzA",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
SELECT COUNT(DISTINCT ppr.patient_id) as Total, plab.date_test_done as Dt
FROM isanteplus.patient_pregnancy ppr
LEFT OUTER JOIN  isanteplus.patient_laboratory plab
ON ppr.patient_id=plab.patient_id
LEFT OUTER JOIN isanteplus.patient p
ON p.patient_id=ppr.patient_id
WHERE ((p.vih_status=1) OR ((plab.test_id=1042 OR plab.test_id=1040)
AND plab.test_result=703)) AND plab.date_test_done is not NULL
AND ppr.patient_id IN (SELECT parv.patient_id from isanteplus.patient_on_arv parv)
GROUP BY plab.date_test_done
) A;
