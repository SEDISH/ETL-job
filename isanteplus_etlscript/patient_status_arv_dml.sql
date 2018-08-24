use isanteplus;

DELIMITER $$
	DROP PROCEDURE IF EXISTS patient_status_arv$$
	CREATE PROCEDURE patient_status_arv()
	BEGIN
      DECLARE myIndex INT;
		select count(*) into myIndex from information_schema.statistics where table_name = 'patient_status_arv' and index_name = 'patient_status_arv_index' and table_schema = 'isanteplus';
		if(myIndex=0) then
			create unique index patient_status_arv_index on patient_status_arv (patient_id, id_status, start_date);
		end if;
	SET SQL_SAFE_UPDATES = 0;
	SET FOREIGN_KEY_CHECKS = 0;

	/*Insertion for exposed infants*/
		/*Le dernier PCR en date doit être négatif fiche Premiere visite VIH pediatrique
			condition_exposee = 1
		*/
		truncate table exposed_infants;
		INSERT INTO exposed_infants(patient_id,location_id,encounter_id,visit_date,condition_exposee)
	SELECT vt.patient_id,vt.location_id,vt.encounter_id,vt.encounter_date,1
	FROM virological_tests vt,(SELECT vtest.patient_id,vtest.location_id,vtest.encounter_id,
	MAX(vtest.encounter_date) as v_date, 1 FROM virological_tests vtest
	WHERE vtest.test_id = 162087 AND vtest.answer_concept_id = 1030 GROUP BY 1) B
	WHERE vt.patient_id = B.patient_id
	AND vt.encounter_date = B.v_date
	AND vt.test_id = 162087
	AND vt.answer_concept_id = 1030
	AND vt.test_result = 664;

	/*	PCR_Concept_id=844,Positif=1301,Negatif=1302,Equivoque=1300,Echantillon de pauvre qualite=1304
		Fiche laboratoire, condition_exposee = 2
		*/
	INSERT INTO exposed_infants(patient_id,location_id,encounter_id,visit_date,condition_exposee)
	SELECT pl.patient_id,pl.location_id,pl.encounter_id,pl.visit_date,2
	FROM patient_laboratory pl,(SELECT plab.patient_id,plab.location_id,
	plab.encounter_id, MAX(plab.visit_date) as v_date,2 FROM patient_laboratory plab
	WHERE plab.test_id = 844 GROUP BY 1) B
	WHERE pl.patient_id = B.patient_id
	AND pl.visit_date = B.v_date
	AND pl.test_id = 844
	AND pl.test_done = 1
	AND pl.test_result = 1302;
	/*	Condition B - Enfant exposé doit être coché
		Fiche Premiere visit VIH pediatrique
		condition_exposee = 3
	*/
	INSERT INTO exposed_infants(patient_id,location_id,encounter_id,visit_date,condition_exposee)
					select distinct ob.person_id,ob.location_id,ob.encounter_id,
					DATE(enc.encounter_datetime),3
					from openmrs.obs ob, openmrs.encounter enc,
					openmrs.encounter_type ent
					WHERE ob.encounter_id	=	enc.encounter_id
					AND enc.encounter_type	=	ent.encounter_type_id
                    AND ob.concept_id = 1401
					AND ob.value_coded = 1405
					AND (ent.uuid =	"349ae0b4-65c1-4122-aa06-480f186c8350"
						OR ent.uuid = "33491314-c352-42d0-bd5d-a9d0bffc9bf1");

	/* Condition D - Des ARV prescrits en prophylaxie
		patient_prescription.rx_or_prophy=163768
		Fiche Ordonance medicale, condition_exposee = 4
		*/
		INSERT INTO exposed_infants(patient_id,location_id,encounter_id,visit_date,condition_exposee)
		select distinct pp.patient_id,pp.location_id,pp.encounter_id,pp.visit_date,4
		from patient_prescription pp, arv_drugs arvd, (select ppres.patient_id,
							MAX(ppres.visit_date) as visit_date FROM patient_prescription ppres,
							arv_drugs ad WHERE ppres.drug_id = ad.drug_id GROUP BY 1) B
		WHERE pp.drug_id = arvd.drug_id
		AND pp.visit_date = B.visit_date
		AND pp.rx_or_prophy = 163768;

	/*End insertion for exposed infants*/
	/*Delete all patient with PCR positive from exposed_infants table*/
	DELETE FROM exposed_infants WHERE
	patient_id IN (SELECT pcr.patient_id FROM patient_pcr pcr WHERE pcr.pcr_result IN(703,1301));

	DELETE FROM exposed_infants WHERE
	patient_id IN (SELECT pl.patient_id FROM patient_laboratory pl, patient p
	WHERE pl.patient_id = p.patient_id AND pl.test_id = 1040
	AND pl.test_done = 1 AND pl.test_result = 703
	AND (TIMESTAMPDIFF(MONTH, p.birthdate,DATE(now())) >= 18));
	/*TRUNCATE TABLE patient_status_arv;*/
		/*Insertion for patient_status Décédés=1,Arrêtés=2,Transférés=3 on ARV
		We use max(start_date) OR max(date_started) because
		we can't find the historic of the patient status
	*/
	/*Starting patient_status_arv*/

	/*Décédés=1, Transférés=3*/
	INSERT INTO patient_status_arv(patient_id,id_status,start_date)
	SELECT v.patient_id,
	CASE WHEN (ob.value_coded=159) THEN 1
	WHEN (ob.value_coded=159492) THEN 3
	END as id_status, DATE(v.date_started) AS start_date
	FROM openmrs.visit v,openmrs.encounter enc,openmrs.encounter_type entype,openmrs.obs ob,
	(SELECT pvi.patient_id, MAX(DATE(pvi.date_started)) as visit_date
						FROM openmrs.visit pvi GROUP BY 1) B,isanteplus.patient_on_arv parv
	WHERE v.visit_id=enc.visit_id
	AND enc.encounter_type=entype.encounter_type_id
	AND enc.encounter_id=ob.encounter_id
	AND v.patient_id = B.patient_id
	AND v.date_started = B.visit_date
	AND enc.patient_id = parv.patient_id
	AND entype.uuid='9d0113c6-f23a-4461-8428-7e9a7344f2ba'
	AND ob.concept_id=161555
	AND ob.value_coded IN(159,159492)
	GROUP BY v.patient_id
	on duplicate key
	update start_date = start_date;

	/*Arrêtés=2*/
	INSERT INTO patient_status_arv(patient_id,id_status,start_date)
	SELECT v.patient_id,2 as id_status, DATE(v.date_started) AS start_date
	FROM openmrs.visit v,openmrs.encounter enc,
	openmrs.encounter_type entype,openmrs.obs ob, openmrs.obs ob2,
	(SELECT pvi.patient_id, MAX(DATE(pvi.date_started)) as date_visit
						FROM openmrs.visit pvi GROUP BY 1) B,isanteplus.patient_on_arv parv
	WHERE v.visit_id=enc.visit_id
	AND enc.encounter_type=entype.encounter_type_id
	AND enc.encounter_id=ob.encounter_id
	AND v.patient_id = B.patient_id
	AND v.date_started = B.date_visit
	AND enc.patient_id = parv.patient_id
	AND ob.encounter_id = ob2.encounter_id
	AND entype.uuid='9d0113c6-f23a-4461-8428-7e9a7344f2ba'
	AND ob.concept_id=161555
	AND ob.value_coded = 1667
	AND ob2.concept_id = 1667
	AND ob2.value_coded IN (115198,159737)
	GROUP BY v.patient_id
	on duplicate key
	update start_date = start_date;

/*====================================================*/
/*Insertion for patient_status Décédés en Pré-ARV=4,
Transférés en Pré-ARV=5*/
INSERT INTO patient_status_arv(patient_id,id_status,start_date)
	SELECT v.patient_id,
	CASE WHEN (ob.value_coded=159) THEN 4
	WHEN (ob.value_coded=159492) THEN 5
	END as id_status,DATE(v.date_started) AS start_date
	FROM isanteplus.patient ispat,openmrs.visit v,
	openmrs.encounter_type entype,openmrs.encounter enc,
	openmrs.obs ob, (SELECT pvi.patient_id, MAX(DATE(pvi.date_started)) as visit_date
						FROM openmrs.visit pvi GROUP BY 1) B
	WHERE ispat.patient_id=v.patient_id
	AND v.visit_id=enc.visit_id
	AND entype.encounter_type_id=enc.encounter_type
	AND enc.encounter_id=ob.encounter_id
	AND v.patient_id = B.patient_id
	AND v.date_started = B.visit_date
	AND entype.uuid='9d0113c6-f23a-4461-8428-7e9a7344f2ba'
	AND ob.concept_id=161555
	AND ispat.vih_status=1
	AND enc.patient_id NOT IN(SELECT parv.patient_id
	FROM isanteplus.patient_on_arv parv)
	AND ob.value_coded IN(159,159492)
	GROUP BY v.patient_id
	on duplicate key
	update start_date = start_date;
	/*Insertion for patient_status réguliers=6*/
	DROP TABLE if exists patient_status_arv_temp_a;
	/*Creating temporary table patient_status_arv_temp_a*/
	CREATE TEMPORARY TABLE patient_status_arv_temp_a
	SELECT v.patient_id as patient_id,6 as id_status,MAX(v.start_date) as start_date
	FROM isanteplus.patient ipat,isanteplus.patient_visit v, isanteplus.patient_on_arv p,
	(select pv.patient_id, MAX(pv.next_visit_date) as mnext_visit from isanteplus.patient_visit pv group by 1) mnv,
	openmrs.encounter enc,
	openmrs.encounter_type entype
	WHERE ipat.patient_id = v.patient_id
	AND v.visit_id = enc.visit_id
	AND v.patient_id = mnv.patient_id
	AND v.next_visit_date = mnv.mnext_visit
	AND enc.encounter_type = entype.encounter_type_id
	AND enc.patient_id
	NOT IN(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,1667,159492))
	AND enc.patient_id = p.patient_id
	AND entype.uuid NOT IN ('f037e97b-471e-4898-a07c-b8e169e0ddc4',
	                        'a0d57dca-3028-4153-88b7-c67a30fde595',
							'51df75f7-a3de-4f82-a9df-c0bedaf5a2dd'
							)
	AND(DATE(now()) <= v.next_visit_date)
	GROUP BY v.patient_id;

	INSERT INTO patient_status_arv_temp_a
	SELECT pdis.patient_id,6 as id_status,MAX(DATE(pdis.visit_date)) as start_date
	FROM isanteplus.patient ipat,isanteplus.patient_dispensing pdis,isanteplus.patient_on_arv p,
	(select pdisp.patient_id, MAX(pdisp.next_dispensation_date) as mnext_disp from isanteplus.patient_dispensing pdisp group by 1) mndisp,
	openmrs.encounter enc,
	openmrs.encounter_type entype
	WHERE ipat.patient_id=pdis.patient_id
	AND pdis.visit_id=enc.visit_id
	AND pdis.patient_id = mndisp.patient_id
	AND pdis.next_dispensation_date = mndisp.mnext_disp
	AND enc.encounter_type=entype.encounter_type_id
	AND enc.patient_id
	NOT IN(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,1667,159492))
	AND enc.patient_id = p.patient_id
	AND entype.uuid NOT IN ('f037e97b-471e-4898-a07c-b8e169e0ddc4',
	                        'a0d57dca-3028-4153-88b7-c67a30fde595',
							'51df75f7-a3de-4f82-a9df-c0bedaf5a2dd'
							)
	AND((DATE(now()) <= pdis.next_dispensation_date))
	GROUP BY pdis.patient_id;

	create index patient_status_arv_index_a on patient_status_arv_temp_a (patient_id, id_status, start_date);
	/*Adding status into patient_status_arv table */
	INSERT INTO patient_status_arv(patient_id,id_status,start_date)
    select distinct * from patient_status_arv_temp_a psat
	on duplicate key
	update start_date = psat.start_date;

	/*truncate the temporary table after the insertion */
	truncate table patient_status_arv_temp_a;
/*=========================================================*/

/*Insertion for patient_status Rendez-vous ratés=8*/
  INSERT INTO patient_status_arv_temp_a
	SELECT v.patient_id,8 as id_status,MAX(v.start_date) as start_date
	FROM isanteplus.patient ipat,isanteplus.patient_visit v,
	(select pv.patient_id, MAX(pv.next_visit_date) as mnext_visit from isanteplus.patient_visit pv group by 1) mnv,
	openmrs.encounter enc,
	openmrs.encounter_type entype
	WHERE ipat.patient_id=v.patient_id
	AND v.visit_id=enc.visit_id
	AND v.patient_id = mnv.patient_id
	AND v.next_visit_date = mnv.mnext_visit
	AND enc.encounter_type=entype.encounter_type_id
	AND enc.patient_id
	NOT IN(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,1667,159492))
	AND enc.patient_id IN (SELECT parv.patient_id
	FROM isanteplus.patient_on_arv parv)
	AND entype.uuid NOT IN ('f037e97b-471e-4898-a07c-b8e169e0ddc4',
	                        'a0d57dca-3028-4153-88b7-c67a30fde595',
							'51df75f7-a3de-4f82-a9df-c0bedaf5a2dd'
							)
	AND((DATE(now()) > v.next_visit_date))
	AND (DATEDIFF(DATE(now()),v.next_visit_date)<=90)
	GROUP BY v.patient_id;

	INSERT INTO patient_status_arv_temp_a
	SELECT pdis.patient_id,8 as id_status,MAX(DATE(pdis.visit_date)) as start_date
	FROM isanteplus.patient ipat,isanteplus.patient_dispensing pdis,(select pdisp.patient_id, MAX(pdisp.next_dispensation_date) as mnext_disp from isanteplus.patient_dispensing pdisp group by 1) mndisp,
	openmrs.encounter enc,
	openmrs.encounter_type entype
	WHERE ipat.patient_id=pdis.patient_id
	AND pdis.visit_id=enc.visit_id
	AND pdis.patient_id = mndisp.patient_id
	AND pdis.next_dispensation_date = mndisp.mnext_disp
	AND enc.encounter_type=entype.encounter_type_id
	AND enc.patient_id
	NOT IN(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,1667,159492))
	AND enc.patient_id IN (SELECT parv.patient_id
	FROM isanteplus.patient_on_arv parv)
	AND entype.uuid NOT IN ('f037e97b-471e-4898-a07c-b8e169e0ddc4',
	                        'a0d57dca-3028-4153-88b7-c67a30fde595',
							'51df75f7-a3de-4f82-a9df-c0bedaf5a2dd'
							)
	AND (DATEDIFF(DATE(now()),pdis.next_dispensation_date)<=90)
	AND((DATE(now()) > pdis.next_dispensation_date))
	GROUP BY pdis.patient_id;

	/*Insertion for status on the table patient_arv_status Rendez-vous ratés=8*/
	/*Adding status into patient_status_arv table */
	INSERT INTO patient_status_arv(patient_id,id_status,start_date)
    select distinct * from patient_status_arv_temp_a psat
	on duplicate key
	update start_date = psat.start_date;
	/*truncate the temporary table after the insertion */
	truncate table patient_status_arv_temp_a;

/*Insertion for patient_status Perdus de vue=9*/

	INSERT INTO patient_status_arv_temp_a
	SELECT v.patient_id,9 as id_status,MAX(v.start_date) as start_date
	FROM isanteplus.patient_visit v,(select pv.patient_id, MAX(pv.next_visit_date) as mnext_visit from isanteplus.patient_visit pv group by 1) mnv,
	openmrs.encounter enc,openmrs.encounter_type entype
	WHERE v.visit_id=enc.visit_id
	AND v.patient_id = mnv.patient_id
	AND v.next_visit_date = mnv.mnext_visit
	AND enc.encounter_type=entype.encounter_type_id
	AND enc.patient_id
	NOT IN(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,1667,159492))
	AND enc.patient_id IN (SELECT parv.patient_id
	FROM isanteplus.patient_on_arv parv)
	AND (DATE(now()) > v.next_visit_date)
	AND (DATEDIFF(DATE(now()),v.next_visit_date)>90)
	AND entype.uuid NOT IN ('f037e97b-471e-4898-a07c-b8e169e0ddc4',
	                        'a0d57dca-3028-4153-88b7-c67a30fde595',
							'51df75f7-a3de-4f82-a9df-c0bedaf5a2dd'
							)
	GROUP BY v.patient_id;

	INSERT INTO patient_status_arv_temp_a
	SELECT pdis.patient_id,9 as id_status,MAX(DATE(pdis.visit_date)) as start_date
	FROM isanteplus.patient_dispensing pdis,(select pdisp.patient_id, MAX(pdisp.next_dispensation_date) as mnext_disp from isanteplus.patient_dispensing pdisp group by 1) mndisp,
	openmrs.encounter enc,openmrs.encounter_type entype
	WHERE pdis.visit_id=enc.visit_id
	AND pdis.patient_id = mndisp.patient_id
	AND pdis.next_dispensation_date = mndisp.mnext_disp
	AND enc.encounter_type=entype.encounter_type_id
	AND enc.patient_id
	NOT IN(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,1667,159492))
	AND enc.patient_id IN (SELECT parv.patient_id
	FROM isanteplus.patient_on_arv parv)
	AND (DATE(now()) > pdis.next_dispensation_date)
	AND (DATEDIFF(DATE(now()),pdis.next_dispensation_date)>90)
	AND entype.uuid NOT IN ('f037e97b-471e-4898-a07c-b8e169e0ddc4',
	                        'a0d57dca-3028-4153-88b7-c67a30fde595',
							'51df75f7-a3de-4f82-a9df-c0bedaf5a2dd'
							)
	GROUP BY pdis.patient_id;

	/*Insertion for status on the table patient_arv_status Perdus de vue=9*/
	/*Adding status into patient_status_arv table */
	INSERT INTO patient_status_arv(patient_id,id_status,start_date)
    select distinct * from patient_status_arv_temp_a psat
	on duplicate key
	update start_date = psat.start_date;
	/*truncate the temporary table after the insertion */
	truncate table patient_status_arv_temp_a;

/*INSERTION for patient status,
     Perdus de vue en Pré-ARV=10 */
INSERT INTO patient_status_arv(patient_id,id_status,start_date)
	SELECT v.patient_id,10,
	MAX(DATE(v.date_started)) AS start_date
	FROM isanteplus.patient ispat,
	openmrs.visit v,openmrs.encounter enc,
	openmrs.encounter_type entype, (SELECT pvi.patient_id, MAX(DATE(pvi.date_started)) as visit_date
						FROM openmrs.visit pvi GROUP BY 1) B
	WHERE ispat.patient_id=v.patient_id
	AND v.visit_id=enc.visit_id
	AND enc.encounter_type=entype.encounter_type_id
	AND v.patient_id = B.patient_id
	AND v.date_started = B.visit_date
	AND enc.patient_id NOT IN
	(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,159492))
	AND ispat.vih_status=1
	AND ispat.patient_id NOT IN (SELECT parv.patient_id
	FROM isanteplus.patient_on_arv parv)
	AND entype.uuid NOT IN('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
		'349ae0b4-65c1-4122-aa06-480f186c8350',
		'204ad066-c5c2-4229-9a62-644bc5617ca2',
		'33491314-c352-42d0-bd5d-a9d0bffc9bf1',
		'10d73929-54b6-4d18-a647-8b7316bc1ae3',
		'a9392241-109f-4d67-885b-57cc4b8c638f',
		'f037e97b-471e-4898-a07c-b8e169e0ddc4'
		)
	AND (TIMESTAMPDIFF(MONTH, v.date_started,DATE(now())) > 12)
	GROUP BY v.patient_id
	on duplicate key
	update start_date = start_date;
	/*=========================================================*/
	/*INSERTION for patient status Recent on PRE-ART=7,Actifs en Pré-ARV=11 */
INSERT INTO patient_status_arv(patient_id,id_status,start_date)
	SELECT v.patient_id,
	CASE WHEN
		(TIMESTAMPDIFF(MONTH,v.date_started,DATE(now()))<=12)
		AND (entype.uuid IN('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
		'349ae0b4-65c1-4122-aa06-480f186c8350')) THEN 7
	   WHEN
	   (TIMESTAMPDIFF(MONTH, v.date_started,DATE(now()))<=12)
		AND (entype.uuid IN('204ad066-c5c2-4229-9a62-644bc5617ca2',
		'33491314-c352-42d0-bd5d-a9d0bffc9bf1',
		'10d73929-54b6-4d18-a647-8b7316bc1ae3',
		'a9392241-109f-4d67-885b-57cc4b8c638f',
		'f037e97b-471e-4898-a07c-b8e169e0ddc4')) THEN 11
	END,
	MAX(DATE(v.date_started)) AS start_date
	FROM isanteplus.patient ispat,
	openmrs.visit v,openmrs.encounter enc,
	openmrs.encounter_type entype,(SELECT pvi.patient_id, MAX(DATE(pvi.date_started)) as visit_date
						FROM openmrs.visit pvi GROUP BY 1) B
	WHERE ispat.patient_id=v.patient_id
	AND v.visit_id=enc.visit_id
	AND enc.encounter_type=entype.encounter_type_id
	AND v.patient_id = B.patient_id
	AND v.date_started = B.visit_date
	AND enc.patient_id NOT IN
	(SELECT dreason.patient_id FROM discontinuation_reason dreason
	WHERE dreason.reason IN(159,159492))
	AND ispat.vih_status=1
	AND ispat.patient_id NOT IN (SELECT parv.patient_id
	FROM isanteplus.patient_on_arv parv)
	AND entype.uuid IN('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
		'349ae0b4-65c1-4122-aa06-480f186c8350',
		'204ad066-c5c2-4229-9a62-644bc5617ca2',
		'33491314-c352-42d0-bd5d-a9d0bffc9bf1',
		'10d73929-54b6-4d18-a647-8b7316bc1ae3',
		'a9392241-109f-4d67-885b-57cc4b8c638f',
		'f037e97b-471e-4898-a07c-b8e169e0ddc4'
		)
	AND (TIMESTAMPDIFF(MONTH,v.date_started,DATE(now()))<=12)
	GROUP BY v.patient_id
	on duplicate key
	update start_date = start_date;

	DROP TABLE patient_status_arv_temp_a;

	/*===========================================================*/
	/*UPDATE Discontinuations reason in table patient_status_ARV*/
	UPDATE patient_status_arv psarv,discontinuation_reason dreason
	       SET psarv.dis_reason=dreason.reason
		   WHERE psarv.patient_id=dreason.patient_id
		   AND psarv.start_date <= dreason.visit_date;
	/*Delete Exposed infants from patient_arv_status*/
	DELETE FROM patient_status_arv WHERE
	patient_id IN (SELECT ei.patient_id FROM exposed_infants ei);
   /*Update patient table for having the last patient arv status*/
   update patient p,patient_status_arv psa
     SET p.arv_status=psa.id_status
	 WHERE p.patient_id=psa.patient_id
	 AND psa.start_date = (SELECT MAX(psarv.start_date)
	                       FROM patient_status_arv psarv
						   WHERE psarv.patient_id=p.patient_id);
	/*End of patient Status*/
	SET SQL_SAFE_UPDATES = 1;
	SET FOREIGN_KEY_CHECKS = 1;

	END$$
DELIMITER ;

-- DROP EVENT if exists patient_status_arv_event;
-- 	CREATE EVENT if not exists patient_status_arv_event
-- 	ON SCHEDULE EVERY 1 DAY
-- 	 STARTS now()
-- 		DO
-- 		call patient_status_arv();
