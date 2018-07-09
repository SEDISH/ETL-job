use isanteplus;

DROP VIEW IF EXISTS firstVisitAge;

CREATE VIEW firstVisitAge AS
SELECT DISTINCT p.birthdate, enc.encounter_datetime, p.patient_id
FROM isanteplus.patient p, openmrs.encounter enc, 
(SELECT en.patient_id, MIN(DATE(en.encounter_datetime)) AS encounter_date FROM openmrs.encounter en GROUP BY 1) B
WHERE p.patient_id = enc.patient_id
AND enc.patient_id = B.patient_id
AND DATE(enc.encounter_datetime) = B.encounter_date
AND p.vih_status = 1;

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "c1AFgaHGDoG",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime)))<15 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "XEGlwBunatS",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) between 15 AND 20 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "PigpadWH4Nn",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) between 21 AND 30 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "A2r74rKsGwQ",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) between 31 AND 40 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "TaWZ3czmxF8",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) between 41 AND 50 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "jAG15dapD5k",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) between 51 AND 60 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "d1NGudxDK7i",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) between 61 AND 70 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "mBlDwtMRgNJ",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) between 71 AND 80 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "CDljgqOMDly",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) between 81 AND 90 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "fFFlN2iE8jw",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) between 91 AND 100 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "IN5NTSAA6tB",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) between 101 AND 110 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "N2eSGW6TmQF",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) between 111 AND 120 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "AmoXCCwRKmE",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) between 121 AND 130 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A

union

SELECT json_object(
"dataElement", "zmF0v3LSONu",
"categoryOptionCombo", "OG6Zjl6xGhw",
"value", Total,
"period", DATE_FORMAT(period, "%Y%m%d")) as results
FROM (
	SELECT 
		COUNT(DISTINCT CASE WHEN (TIMESTAMPDIFF(YEAR,p.birthdate,DATE(p.encounter_datetime))) > 130 THEN p.patient_id else null END) AS Total,
		p.encounter_datetime AS period
	FROM firstVisitAge p
	GROUP BY p.encounter_datetime
) A;
