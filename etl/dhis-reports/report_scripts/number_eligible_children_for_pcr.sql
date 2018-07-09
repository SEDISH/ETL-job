select json_object(
"dataElement", "TODO",
"value", 1,
"period", DATE_FORMAT(dt, "%Y%m%d")) as results
from(
select distinct patient_id, dt 
	FROM (SELECT distinct exp_inf.patient_id, exp_inf.visit_date as dt FROM isanteplus.patient pat,isanteplus.exposed_infants exp_inf
	WHERE pat.patient_id = exp_inf.patient_id
    AND exp_inf.condition_exposee = 3
    AND (TIMESTAMPDIFF(DAY, pat.birthdate,DATE(now())) BETWEEN 28 AND 30)
    AND pat.patient_id NOT IN (select ppcr.patient_id FROM isanteplus.patient_pcr ppcr)
   UNION
   SELECT distinct stests.patient_id, stests.test_date as dt FROM isanteplus.patient pat,isanteplus.serological_tests stests
	WHERE pat.patient_id = stests.patient_id
    AND stests.test_id = 162087
	AND stests.answer_concept_id IN(163722,1042)
    AND stests.test_result = 703
    AND (TIMESTAMPDIFF(MONTH, pat.birthdate,DATE(now())) BETWEEN 12 AND 18)
    AND pat.patient_id NOT IN (select ppcr.patient_id FROM isanteplus.patient_pcr ppcr)
    ) B
) A
    

