select json_object(
"dataElement", "nWxMCDOzaNt",
"categoryOptionCombo", "GiBSEXO5lzA",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
select 1 as Total, vtype.encounter_date as Dt
FROM isanteplus.visit_type vtype
WHERE vtype.concept_id=160288 AND v_type=1622
GROUP BY vtype.patient_id
) A

