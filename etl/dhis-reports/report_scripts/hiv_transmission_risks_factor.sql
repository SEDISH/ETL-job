select json_object(
"dataElement", "f4yozKLSxx3",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
	select cn.name as Md, COUNT(distinct vrf.patient_id) as Total, vrf.encounter_date as Dt
	FROM openmrs.concept_name cn, isanteplus.vih_risk_factor vrf
	WHERE cn.concept_id=160580
        AND cn.concept_id=vrf.risk_factor
	AND cn.locale='fr'
	GROUP BY cn.name, vrf.encounter_date
) A

UNION ALL

select json_object(
"dataElement", "nvkN4JHmP0O",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
	select cn.name as Md, COUNT(distinct vrf.patient_id) as Total, vrf.encounter_date as Dt
	FROM openmrs.concept_name cn, isanteplus.vih_risk_factor vrf
	WHERE cn.concept_id=105
	AND cn.concept_id=vrf.risk_factor
        AND cn.locale='fr'
	GROUP BY cn.name, vrf.encounter_date
) B

UNION ALL

select json_object(
"dataElement", "T1SeWx8kSZA",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
	select cn.name as Md, COUNT(distinct vrf.patient_id) as Total, vrf.encounter_date as Dt
	FROM openmrs.concept_name cn, isanteplus.vih_risk_factor vrf
	WHERE cn.concept_id=156660
	AND cn.concept_id=vrf.risk_factor
        AND cn.locale='fr'
	GROUP BY cn.name, vrf.encounter_date
) C

UNION ALL

select json_object(
"dataElement", "9wEHbyKzb7f",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
	select cn.name as Md, COUNT(distinct vrf.patient_id) as Total, vrf.encounter_date as Dt
	FROM openmrs.concept_name cn, isanteplus.vih_risk_factor vrf
	WHERE cn.concept_id=123160
	AND cn.concept_id=vrf.risk_factor
        AND cn.locale='fr'
	GROUP BY cn.name, vrf.encounter_date
) D

UNION ALL

select json_object(
"dataElement", "zZ9Cj9Y3Hzq",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
	select cn.name as Md, COUNT(distinct vrf.patient_id) as Total, vrf.encounter_date as Dt
	FROM openmrs.concept_name cn, isanteplus.vih_risk_factor vrf
	WHERE cn.concept_id=159218
	AND cn.concept_id=vrf.risk_factor
        AND cn.locale='fr'
	GROUP BY cn.name, vrf.encounter_date
) E

UNION ALL

select json_object(
"dataElement", "vW8mZ2fhnCa",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
	select cn.name as Md, COUNT(distinct vrf.patient_id) as Total, vrf.encounter_date as Dt
	FROM openmrs.concept_name cn, isanteplus.vih_risk_factor vrf
	WHERE cn.concept_id=160579
	AND cn.concept_id=vrf.risk_factor
        AND cn.locale='fr'
	GROUP BY cn.name, vrf.encounter_date
) F

UNION ALL

select json_object(
"dataElement", "9s2Hn4FDd0T",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
	select cn.name as Md, COUNT(distinct vrf.patient_id) as Total, vrf.encounter_date as Dt
	FROM openmrs.concept_name cn, isanteplus.vih_risk_factor vrf
	WHERE cn.concept_id=163273
	AND cn.concept_id=vrf.risk_factor
        AND cn.locale='fr'
	GROUP BY cn.name, vrf.encounter_date
) G

UNION ALL

select json_object(
"dataElement", "UYi8MWZnsOF",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
	select cn.name as Md, COUNT(distinct vrf.patient_id) as Total, vrf.encounter_date as Dt
	FROM openmrs.concept_name cn, isanteplus.vih_risk_factor vrf
	WHERE cn.concept_id=163289
	AND cn.concept_id=vrf.risk_factor
        AND cn.locale='fr'
	GROUP BY cn.name, vrf.encounter_date
) H

UNION ALL

select json_object(
"dataElement", "tQMbNXBAfpZ",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
	select cn.name as Md, COUNT(distinct vrf.patient_id) as Total, vrf.encounter_date as Dt
	FROM openmrs.concept_name cn, isanteplus.vih_risk_factor vrf
	WHERE cn.concept_id=163290
	AND cn.concept_id=vrf.risk_factor
        AND cn.locale='fr'
	GROUP BY cn.name, vrf.encounter_date
) I

UNION ALL

select json_object(
"dataElement", "5dPljsugiht",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
	select cn.name as Md, COUNT(distinct vrf.patient_id) as Total, vrf.encounter_date as Dt
	FROM openmrs.concept_name cn, isanteplus.vih_risk_factor vrf
	WHERE cn.concept_id=163291
	AND cn.concept_id=vrf.risk_factor
        AND cn.locale='fr'
	GROUP BY cn.name, vrf.encounter_date
) J

UNION ALL

select json_object(
"dataElement", "nZ2XNfRzJOD",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
	select cn.name as Md, COUNT(distinct vrf.patient_id) as Total, vrf.encounter_date as Dt
	FROM openmrs.concept_name cn, isanteplus.vih_risk_factor vrf
	WHERE cn.concept_id=5567
	AND cn.concept_id=vrf.risk_factor
        AND cn.locale='fr'
	GROUP BY cn.name, vrf.encounter_date
) K

UNION ALL

select json_object(
"dataElement", "2wche0R7arR",
"value", Total,
"period", DATE_FORMAT(Dt, "%Y%m%d")) as results
from(
	select cn.name as Md, COUNT(distinct vrf.patient_id) as Total, vrf.encounter_date as Dt
	FROM openmrs.concept_name cn, isanteplus.vih_risk_factor vrf
	WHERE cn.concept_id=1063
	AND cn.concept_id=vrf.risk_factor
        AND cn.locale='fr'
	GROUP BY cn.name, vrf.encounter_date
) M


