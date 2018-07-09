select json_object(
"dataElement", "TODO",
"value", 1,
"period", DATE_FORMAT(dt, "%Y%m%d")) as results
from(
select distinct B.patient_id, B.dt
FROM (SELECT distinct pl.patient_id, pl.date_test_done AS dt FROM isanteplus.patient_laboratory pl
	WHERE pl.test_id = 844
	AND pl.test_done = 1
	AND pl.test_result IN(1301,1302,1300,1304)
   UNION
   SELECT distinct vt.patient_id, vt.test_date AS dt FROM isanteplus.virological_tests vt
	WHERE vt.test_id = 162087
	AND vt.answer_concept_id = 1030
	AND vt.test_result IN (664,703,1138)
    ) B
) A
