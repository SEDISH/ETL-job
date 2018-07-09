SELECT json_object(
"dataElement", CASE WHEN p.id_status = 8 THEN "8Eb3gOoOdZO" 
	ELSE CASE WHEN  p.id_status = 4 THEN "ptWfRH7h8Tx" 
	ELSE CASE WHEN p.id_status = 2 THEN "xThIAPwAlAS" 
	ELSE CASE WHEN p.id_status = 3 THEN "VPsvwKUDxRH" 
	ELSE CASE WHEN p.id_status = 6 THEN "JGTU3lzBzRt" 
	ELSE CASE WHEN p.id_status = 10 THEN "vcoPl9a8IEU" 
	ELSE CASE WHEN p.id_status = 1 THEN "KCPIt4b9vbE" 
	ELSE CASE WHEN p.id_status = 9 THEN "7vRBCpLe0tL" 
	ELSE CASE WHEN p.id_status = 11 THEN "3YvgTWVPV9p" 
	ELSE CASE WHEN p.id_status = 5 THEN "TwwD3PIQQrm" 
	ELSE CASE WHEN p.id_status = 12 THEN "Gykb8V3Mqj3" 
    ELSE CASE WHEN p.id_status = 7 THEN "7rjgNkGvdMi"
	END END END END END END END END END END END END, 
"value", COUNT(p.patient_id),
"period", DATE_FORMAT(p.start_date, "%Y%m%d")) AS results
FROM isanteplus.arv_status_loockup asl, isanteplus.patient_status_arv p,
(SELECT ps.patient_id, MAX(ps.start_date) as start_date 
FROM isanteplus.patient_status_arv ps GROUP BY 1) as B
WHERE asl.id = p.id_status
AND p.patient_id = B.patient_id
AND p.start_date = B.start_date
GROUP BY asl.name_fr,p.start_date;

