select json_object(
"dataElement", "BkXgePY2B8y",
"categoryOptionCombo", "GiBSEXO5lzA",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
SELECT 1 as Total, phv.patient_id, vt.encounter_date as Dt
FROM isanteplus.pediatric_hiv_visit phv
LEFT OUTER JOIN  isanteplus.patient_laboratory plab
ON plab.patient_id=phv.patient_id
LEFT OUTER JOIN isanteplus.virological_tests vt
ON vt.patient_id=phv.patient_id
WHERE(
		(vt.concept_group=1361 AND vt.test_id=162087
		AND vt.answer_concept_id=1030)
		OR(plab.test_id=844 AND plab.test_result IN(1301,1302,1300,1304) AND plab.date_test_done IS NOT NULL)
	)
AND phv.actual_vih_status=1405
GROUP BY vt.encounter_date, phv.patient_id
) A

