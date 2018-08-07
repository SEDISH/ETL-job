use isanteplus;
DELIMITER $$
	DROP PROCEDURE IF EXISTS isanteplusreports_dml$$
	CREATE PROCEDURE isanteplusreports_dml()
		BEGIN
		 /*Started DML queries*/
			/* insert data to patient table */
			SET SQL_SAFE_UPDATES = 0;
			SET FOREIGN_KEY_CHECKS=0;
					insert into patient
					(
					 patient_id,
					 given_name,
					 family_name,
					 gender,
					 birthdate,
					 creator,
					 date_created,
					 last_inserted_date
					)
					select pn.person_id,
						   pn.given_name,
						   pn.family_name,
						   pe.gender,
						   pe.birthdate,
						   pn.creator,
						   pn.date_created,
						   now() as last_inserted_date
					from openmrs.person_name pn, openmrs.person pe, openmrs.patient pa
					where pe.person_id=pn.person_id AND pe.person_id=pa.patient_id
					AND pn.voided = 0
					on duplicate key update
						given_name=pn.given_name,
						family_name=pn.family_name,
						gender=pe.gender,
						birthdate=pe.birthdate,
						creator=pn.creator,
						date_created=pn.date_created;

			/* update patient with identifier */
			/*ST CODE*/
			update patient p,openmrs.patient_identifier pi,
			openmrs.patient_identifier_type pit set p.st_id=pi.identifier
			where p.patient_id=pi.patient_id
			AND pi.identifier_type=pit.patient_identifier_type_id
			and pit.uuid="d059f6d0-9e42-4760-8de1-8316b48bc5f1"
			AND pi.voided = 0;
            /*National ID*/
			update patient p,openmrs.patient_identifier pi,
			openmrs.patient_identifier_type pit set p.national_id=pi.identifier
			where p.patient_id=pi.patient_id
			AND pi.identifier_type=pit.patient_identifier_type_id
			and pit.uuid="9fb4533d-4fd5-4276-875b-2ab41597f5dd"
			AND pi.voided = 0;
			/*iSantePlus_ID*/
			update patient p,openmrs.patient_identifier pi,
			openmrs.patient_identifier_type pit set p.identifier=pi.identifier
			where p.patient_id=pi.patient_id
			AND pi.identifier_type=pit.patient_identifier_type_id
			and pit.uuid="05a29f94-c0ed-11e2-94be-8c13b969e334"
			AND pi.voided = 0;

			/* update location_id for patients*/
				update patient p,
				(select distinct pid.patient_id,pid.location_id from openmrs.patient_identifier pid, openmrs.patient_identifier_type pidt WHERE pid.identifier_type=pidt.patient_identifier_type_id AND pidt.uuid="05a29f94-c0ed-11e2-94be-8c13b969e334") pi
				set p.location_id=pi.location_id
				where p.patient_id=pi.patient_id
                                 AND pi.location_id is not null;
			/*update patient with address*/
			update patient p, openmrs.person_address padd
			SET p.last_address=
            CASE WHEN ((padd.address1 <> '' AND padd.address1 is not null)
            AND (padd.address2 <> '' AND padd.address2 is not null))
              THEN CONCAT(padd.address1,' ',padd.address2)
            WHEN ((padd.address1 <> '' AND padd.address1 is not null)
            AND (padd.address2 = '' OR padd.address2 is null))
               THEN padd.address1
			ELSE
              padd.address2
            END
			WHERE p.patient_id = padd.person_id
			AND padd.voided = 0;
			/* update patient with person attribute */
			/*Update for birthPlace*/
			update patient p, openmrs.person_attribute pa,openmrs.person_attribute_type pat
			SET p.place_of_birth = pa.value
			WHERE p.patient_id = pa.person_id
			AND pa.person_attribute_type_id = pat.person_attribute_type_id
			AND pat.uuid='8d8718c2-c2cc-11de-8d13-0010c6dffd0f';
			/*Update for telephone*/
			update patient p, openmrs.person_attribute pa,openmrs.person_attribute_type pat
			SET p.telephone = pa.value
			WHERE p.patient_id = pa.person_id
			AND pa.person_attribute_type_id = pat.person_attribute_type_id
			AND pat.uuid='14d4f066-15f5-102d-96e4-000c29c2a5d7';
			/*Update for mother's Name*/
			update patient p, openmrs.person_attribute pa,openmrs.person_attribute_type pat
			SET p.mother_name = pa.value
			WHERE p.patient_id = pa.person_id
			AND pa.person_attribute_type_id = pat.person_attribute_type_id
			AND pat.uuid='8d871d18-c2cc-11de-8d13-0010c6dffd0f';
            /*Update for Civil Status  */
				update patient p,openmrs.obs o, (
				select person_id, MAX(obs_datetime) as obsDt FROM openmrs.obs WHERE concept_id = 1054 GROUP BY person_id) ob
				SET p.maritalStatus = o.value_coded
				WHERE p.patient_id = ob.person_id
				AND ob.person_id = o.person_id
				AND o.concept_id = 1054
				AND o.obs_datetime = ob.obsDt
				AND o.voided = 0;

			/*Update for Occupation */
				update patient p,openmrs.obs o, (
				select person_id, MAX(obs_datetime) as obsDt FROM openmrs.obs WHERE concept_id = 1542 GROUP BY person_id) ob
				SET p.occupation = o.value_coded
				WHERE p.patient_id = ob.person_id
				AND ob.person_id = o.person_id
				AND o.concept_id = 1542
				AND o.obs_datetime = ob.obsDt
				AND o.voided = 0;

			/* update patient with vih status */

			UPDATE patient p, openmrs.encounter en, openmrs.encounter_type ent
			SET p.vih_status=1
			WHERE p.patient_id=en.patient_id AND en.encounter_type=ent.encounter_type_id
			AND (ent.uuid='17536ba6-dd7c-4f58-8014-08c7cb798ac7'
			 OR ent.uuid='204ad066-c5c2-4229-9a62-644bc5617ca2'
			 OR ent.uuid='349ae0b4-65c1-4122-aa06-480f186c8350'
			 OR ent.uuid='33491314-c352-42d0-bd5d-a9d0bffc9bf1')
			AND en.voided = 0;
			/*Update for vih_status = 1 where the patient has a labs test hiv positive*/
			/*UPDATE patient p, openmrs.encounter en, openmrs.obs ob
			SET p.vih_status=1
			WHERE p.patient_id=en.patient_id AND en.patient_id = ob.person_id
			AND (
				(ob.concept_id = 1042 AND ob.value_coded = 703)
				OR
				(ob.concept_id = 1040 AND ob.value_coded = 703)
				)
			AND en.voided = 0
			AND ob.voided = 0;*/

			/* update patient with death information */


			/* insert data to patient_visit table */

			INSERT INTO patient_visit
			(visit_date,visit_id,encounter_id,location_id,
			 patient_id,start_date,stop_date,creator,
			 encounter_type,form_id,next_visit_date,
			last_insert_date)
			select v.date_started as visit_date,
				   v.visit_id,e.encounter_id,v.location_id,
				   v.patient_id,v.date_started,v.date_stopped,
				   v.creator,e.encounter_type,e.form_id,o.value_datetime,
				   now() as last_inserted_date
			from openmrs.visit v,openmrs.encounter e,openmrs.obs o
			where v.visit_id=e.visit_id and v.patient_id=e.patient_id
				  and o.person_id=e.patient_id and o.encounter_id=e.encounter_id
				and o.concept_id='5096'
				AND o.voided = 0
				on duplicate key update
				next_visit_date = o.value_datetime;

			/*Update patient table for having last visit date */
		   update patient p, openmrs.visit vi, (select v.patient_id, MAX(v.date_started) as date_started
			FROM openmrs.visit v GROUP BY v.patient_id) B
			SET p.last_visit_date = vi.date_started
			WHERE p.patient_id = vi.patient_id
			AND vi.patient_id = B.patient_id
			AND vi.date_started = B.date_started
			AND vi.voided = 0;

			/*Update patient table for having first visit date */
		   update patient p, openmrs.visit vi, (select v.patient_id, MIN(v.date_started) as date_started
			FROM openmrs.visit v GROUP BY v.patient_id) B
			SET p.first_visit_date = vi.date_started
			WHERE p.patient_id=vi.patient_id
			AND vi.patient_id = B.patient_id
			AND vi.date_started = B.date_started
			AND vi.voided = 0;

        /* Insert data to health_qual_patient_visit table */
        INSERT INTO health_qual_patient_visit (visit_date, visit_id, encounter_id, location_id, patient_id, encounter_type, last_insert_date)
          SELECT v.date_started AS visit_date, v.visit_id, e.encounter_id,v.location_id, v.patient_id, e.encounter_type, now() as last_insert_date
          FROM openmrs.visit v,openmrs.encounter e,openmrs.obs o
          WHERE v.visit_id = e.visit_id
            AND v.patient_id = e.patient_id
            AND o.person_id = e.patient_id
            AND o.encounter_id = e.encounter_id
			AND o.voided = 0
			on duplicate key update
			encounter_id = e.encounter_id;

        /*Update health_qual_patient_visit table for having bmi*/
        UPDATE isanteplus.health_qual_patient_visit pv, (
          SELECT hs.visit_id, ws.weight , hs.height, ( ws.weight / (hs.height*hs.height/10000) ) as 'patient_bmi'
          FROM (
            SELECT pv.visit_id, o.value_numeric as 'height'
            FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
            WHERE o.person_id = pv.patient_id
              AND pv.visit_id = e.visit_id
              AND e.encounter_id= o.encounter_id
              AND e.encounter_id = pv.encounter_id
              AND o.concept_id = 5090
			  AND o.voided = 0
            ) AS hs
          JOIN (
            SELECT pv.visit_id, o.value_numeric as 'weight'
            FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
            WHERE o.person_id = pv.patient_id
              AND pv.visit_id = e.visit_id
              AND e.encounter_id= o.encounter_id
              AND e.encounter_id = pv.encounter_id
              AND o.concept_id = 5089
			  AND o.voided = 0
            ) AS ws
          ON hs.visit_id = ws.visit_id
          ) as bmi
          SET pv.patient_bmi = bmi.patient_bmi
          WHERE pv.visit_id = bmi.visit_id;

          /*Update patient_visit table for having family method planning indicator.*/
          UPDATE isanteplus.health_qual_patient_visit pv, (
            SELECT pv.visit_id, o.value_coded
            FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
            WHERE o.person_id = pv.patient_id
              AND pv.visit_id = e.visit_id
              AND e.encounter_id= o.encounter_id
              AND e.encounter_id = pv.encounter_id
              AND o.concept_id=374
			  AND o.voided = 0) AS family_planning
          SET pv.family_planning_method_used = true
          WHERE family_planning.visit_id = pv.visit_id
            AND value_coded IS NOT NULL;

          /*Update health_qual_patient_visit table for adherence evaluation.*/
          UPDATE isanteplus.health_qual_patient_visit pv, (
            SELECT pv.visit_id, o.value_numeric
            FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
            WHERE o.person_id = pv.patient_id
              AND pv.visit_id = e.visit_id
              AND e.encounter_id= o.encounter_id
              AND o.concept_id=163710
			  AND o.voided = 0) AS adherence
          SET pv.adherence_evaluation = adherence.value_numeric
          WHERE adherence.visit_id = pv.visit_id
            AND value_numeric IS NOT NULL;

          /*Update health_qual_patient_visit table for evaluation of TB flag.*/
          UPDATE isanteplus.health_qual_patient_visit pv, (
            SELECT pv.visit_id, o.value_coded
            FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
            WHERE o.person_id = pv.patient_id
              AND pv.visit_id = e.visit_id
              AND e.encounter_id= o.encounter_id
              AND e.encounter_id = pv.encounter_id
              AND (
                o.concept_id IN (160265, 1659, 1110, 163283, 162320, 163284, 1633, 1389, 163951, 159431, 1113, 159798, 159398)
              )
			  AND o.voided = 0) AS evaluation_of_tb
          SET pv.evaluated_of_tb = true
          WHERE evaluation_of_tb.visit_id = pv.visit_id
            AND value_coded IS NOT NULL;

          /*update for nutritional_assessment_status*/
         /* UPDATE isanteplus.health_qual_patient_visit hqpv, (
            SELECT pv.encounter_id, o.concept_id
            FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
            WHERE o.person_id = pv.patient_id
              AND pv.visit_id = e.visit_id
              AND e.encounter_id= o.encounter_id
              AND e.encounter_id = pv.encounter_id
            ) AS visits
          SET hqpv.nutritional_assessment_completed = true
          WHERE
            visits.encounter_id = hqpv.encounter_id
            AND (
              (visits.concept_id = 5089 AND 5090)
              OR visits.concept_id = 5314
              OR visits.concept_id = 1343
            );*/

			UPDATE isanteplus.health_qual_patient_visit hqpv, (
            SELECT pv.encounter_id, o.concept_id
            FROM isanteplus.health_qual_patient_visit pv, openmrs.obs o, openmrs.encounter e
            WHERE o.person_id = pv.patient_id
              AND pv.visit_id = e.visit_id
              AND e.encounter_id= o.encounter_id
              AND e.encounter_id = pv.encounter_id
			  AND (
					  (o.concept_id = 5089 AND o.concept_id = 5090)
					  OR o.concept_id = 5314
					  OR o.concept_id = 1343
				)
			 AND o.voided = 0
            ) AS visits
          SET hqpv.nutritional_assessment_completed = true
          WHERE
            visits.encounter_id = hqpv.encounter_id;

          /*update for is_active_tb*/
			UPDATE isanteplus.health_qual_patient_visit hqpv, (
			SELECT pv.encounter_id FROM isanteplus.health_qual_patient_visit pv,
			openmrs.obs o, openmrs.encounter e
			WHERE o.person_id = pv.patient_id AND pv.visit_id = e.visit_id
			AND e.encounter_id= o.encounter_id AND e.encounter_id = pv.encounter_id AND
			((o.concept_id=160592 AND o.value_coded=113489) OR (o.concept_id=160749 AND o.value_coded=1065))
			AND o.voided = 0) v
			SET hqpv.is_active_tb = true
			WHERE v.encounter_id = hqpv.encounter_id;

		/*Update health_qual_patient_visit table for age patient at the visit.*/
		UPDATE isanteplus.health_qual_patient_visit pv, openmrs.person pe
		  SET pv.age_in_years = TIMESTAMPDIFF(YEAR, pe.birthdate, pv.visit_date)
          WHERE pe.person_id = pv.patient_id;

		/*---------------------------------------------------*/
/*Queries for filling the patient_tb_diagnosis table*/
/*Insert when Tuberculose [A15.0] remplir la section Tuberculose ci-dessous
 AND MDR TB remplir la section Tuberculose ci-dessous [Z16.24] areas are checked*/
insert into patient_tb_diagnosis
					(
					 patient_id,
					 encounter_id,
					 location_id
					)
					select distinct ob.person_id,
						   ob.encounter_id,ob.location_id
					from openmrs.obs ob, openmrs.obs ob1
					where ob.person_id=ob1.person_id
					AND ob.encounter_id=ob1.encounter_id
					AND ob.obs_group_id=ob1.obs_id
                    AND ob1.concept_id=159947
					AND ((ob.concept_id=1284 AND ob.value_coded=112141)
						OR
						(ob.concept_id=1284 AND ob.value_coded=159345))
					AND ob.voided = 0
						on duplicate key update
						encounter_id = ob.encounter_id;
/*Insert when Nouveau diagnostic Or suivi in the tuberculose menu are checked*/
insert into patient_tb_diagnosis
					(
						patient_id,
						encounter_id,
						location_id
					)
			select distinct ob.person_id,ob.encounter_id,ob.location_id
			FROM openmrs.obs ob
			where ob.concept_id=1659
			AND (ob.value_coded=160567 OR ob.value_coded=1662)
			AND ob.voided = 0
			on duplicate key update
			encounter_id = ob.encounter_id;
/*Insert when the area Toux >= 2 semaines is checked*/
insert into patient_tb_diagnosis
					(
						patient_id,
						encounter_id,
						location_id
					)
			select distinct ob.person_id,ob.encounter_id,ob.location_id
			FROM openmrs.obs ob
			where ob.concept_id=159614
			AND ob.value_coded=159799
			AND ob.voided = 0
			on duplicate key update
			encounter_id = ob.encounter_id;
/*Insert when one of the status tb is checked on the resultat du traitement(tb) menu*/
insert into patient_tb_diagnosis
					(
						patient_id,
						encounter_id,
						location_id
					)
			select distinct ob.person_id,ob.encounter_id,ob.location_id
			FROM openmrs.obs ob
			where ob.concept_id=159786
			AND (ob.value_coded=159791 OR ob.value_coded=160035
				OR ob.value_coded=159874 OR ob.value_coded=160031
				OR ob.value_coded=160034)
			AND ob.voided = 0
			on duplicate key update
			encounter_id = ob.encounter_id;
/*Insert when the HIV patient has a TB diagnosis
(we will find these concepts particularly in the first and follow-up visits HIV forms)*/
insert into patient_tb_diagnosis
					(
						patient_id,
						encounter_id,
						location_id
					)
			select distinct ob.person_id,ob.encounter_id,ob.location_id
			FROM openmrs.obs ob
			where (ob.concept_id = 6042 OR ob.concept_id = 6097)
			AND (ob.value_coded = 159355 OR ob.value_coded = 42
					OR ob.value_coded = 118890 OR ob.value_coded = 5042)
			AND ob.voided = 0
			on duplicate key update
			encounter_id = ob.encounter_id;
/*update for visit_id AND visit_date*/
update patient_tb_diagnosis pat, openmrs.visit vi, openmrs.encounter en
   set pat.visit_id=vi.visit_id, pat.visit_date=vi.date_started
	where pat.encounter_id=en.encounter_id
	AND en.visit_id=vi.visit_id
	AND vi.voided = 0;
/*update provider ???*/
update patient_tb_diagnosis pat, openmrs.encounter_provider enp
	set pat.provider_id=enp.provider_id
	WHERE pat.encounter_id=enp.encounter_id
	AND enp.voided = 0;
/*Update tb_diag and mdr_tb_diag*/
update patient_tb_diagnosis pat, openmrs.obs ob,openmrs.obs ob1
	set pat.tb_diag=1
	where ob.obs_group_id=ob1.obs_id
    AND ob1.concept_id=159947
	AND (ob.concept_id=1284 AND ob.value_coded=112141)
	AND pat.encounter_id=ob.encounter_id
	AND ob.voided = 0;

	update patient_tb_diagnosis pat, openmrs.obs ob,openmrs.obs ob1
	set pat.mdr_tb_diag=1
	where ob.obs_group_id=ob1.obs_id
    AND ob1.concept_id=159947
	AND (ob.concept_id=1284 AND ob.value_coded=159345)
	AND pat.encounter_id=ob.encounter_id
	AND ob.voided = 0;
/*update for M. tuberculosis(TB) pulmonaire*/
	update patient_tb_diagnosis pat, openmrs.obs ob
	set pat.tb_pulmonaire = 1
	where ob.concept_id IN (6042,6097)
	AND ob.value_coded = 42
	AND pat.encounter_id = ob.encounter_id
	AND ob.voided = 0;
/*update for Tuberculose multirésistante*/
	update patient_tb_diagnosis pat, openmrs.obs ob
	set pat.tb_multiresistante = 1
	where ob.concept_id IN (6042,6097)
	AND ob.value_coded = 159355
	AND pat.encounter_id = ob.encounter_id
	AND ob.voided = 0;
/*update for M. tuberculosis (TB) extrapulmonaire ou disséminée*/
	update patient_tb_diagnosis pat, openmrs.obs ob
	set pat.tb_extrapul_ou_diss = 1
	where ob.concept_id IN (6042,6097)
	AND ob.value_coded IN (118890,5042)
	AND pat.encounter_id = ob.encounter_id
	AND ob.voided = 0;
/*update tb_new_diag AND tb_follow_up_diag*/
	update patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.tb_new_diag=1
	WHERE pat.encounter_id=ob.encounter_id
	AND (ob.concept_id=1659 AND ob.value_coded=160567)
	AND ob.voided = 0;

	update patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.tb_follow_up_diag=1
	WHERE pat.encounter_id=ob.encounter_id
	AND (ob.concept_id=1659 AND ob.value_coded=1662)
	AND ob.voided = 0;
/*update cough_for_2wks_or_more*/
	update patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.cough_for_2wks_or_more=1
	WHERE pat.encounter_id=ob.encounter_id
	AND (ob.concept_id=159614 AND ob.value_coded=159799)
	AND ob.voided = 0;
/*update tb_treatment_start_date*/
	update patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.tb_treatment_start_date=ob.value_datetime
	WHERE pat.encounter_id=ob.encounter_id
	AND ob.concept_id=1113
	AND ob.voided = 0;
/*update for status_tb_treatment*/
/*
	statuts_tb_treatment = Gueri(1),traitement termine(2),
		Abandon(3),tranfere(4),decede(5), actuellement sous traitement(6)
<obs conceptId="CIEL:159786"
answerConceptIds="CIEL:159791,CIEL:160035,CIEL:159874,CIEL:160031,CIEL:160034"
answerLabels="Guéri,Traitement Terminé,Abandon,Transféré,Décédé" style="radio"/>
*/
update patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.status_tb_treatment=
	CASE WHEN ob.value_coded=159791 then 1
	when ob.value_coded=160035 then 2
	when ob.value_coded=159874 then 3
	when ob.value_coded=160031 then 4
	when ob.value_coded=160034 then 5
	END
	WHERE pat.encounter_id=ob.encounter_id
	AND ob.concept_id=159786
	AND ob.voided = 0;
/*Update for Actif and Gueri for TB diagnosis for HIV patient*/
update patient_tb_diagnosis pat, openmrs.obs ob,
	(SELECT o.person_id, o.encounter_id, count(o.encounter_id) as nb
	FROM openmrs.obs o WHERE o.concept_id=6042 AND o.value_coded IN (42,159355,118890) GROUP BY 1) a
	SET pat.status_tb_treatment =
	CASE WHEN (ob.concept_id = 6097 AND a.nb = 0)  then 1
	WHEN (ob.concept_id = 6042 AND a.nb > 0)  then 6
	END
	WHERE pat.encounter_id = ob.encounter_id
	AND ob.encounter_id = a.encounter_id
	AND ob.person_id = a.person_id
	AND ob.value_coded IN (42,159355,118890,5042)
	AND ob.voided = 0;

	/*Guéri*/

	 update isanteplus.patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.status_tb_treatment = 1
	WHERE pat.encounter_id = ob.encounter_id
    AND pat.patient_id = ob.person_id
	AND ob.concept_id = 6097
	AND ob.value_coded IN (42,159355,118890,5042)
	AND ob.voided = 0;

    /*Actif*/
    update isanteplus.patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.status_tb_treatment = 6
	WHERE pat.encounter_id = ob.encounter_id
    AND pat.patient_id = ob.person_id
	AND ob.concept_id = 6042
	AND ob.value_coded IN (42,159355,118890)
	AND ob.voided = 0;


/*Update for traitement TB COMPLETE AND Actuellement sous traitement
(Area in the HIV first and follow-up visit forms)*/
update patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.status_tb_treatment=
	CASE WHEN ob.value_coded=1663 then 2
	when ob.value_coded=1662 then 6
	ELSE null
	END
	WHERE pat.encounter_id=ob.encounter_id
	AND ob.concept_id=1659
	AND ob.voided = 0;
/*update tb_treatment_stop_date*/
   update patient_tb_diagnosis pat, openmrs.obs ob
	SET pat.tb_treatment_stop_date=ob.value_datetime
	WHERE pat.encounter_id=ob.encounter_id
	AND ob.concept_id=159431
	AND ob.voided = 0;
/*Insert for patient_id,encounter_id, drug_id areas*/
  INSERT into patient_dispensing
					(
					 patient_id,
					 encounter_id,
					 location_id,
					 drug_id,
					 dispensation_date
					)
					select distinct ob.person_id,
					ob.encounter_id,ob.location_id,ob.value_coded,ob2.obs_datetime
					from openmrs.obs ob, openmrs.obs ob1,openmrs.obs ob2
					where ob.person_id=ob1.person_id
					AND ob.encounter_id=ob1.encounter_id
					AND ob.obs_group_id=ob1.obs_id
					AND ob1.obs_id = ob2.obs_group_id
                    AND ob1.concept_id=163711
					AND ob.concept_id=1282
					AND ob2.concept_id=1276
					AND ob.voided = 0
					ON DUPLICATE KEY UPDATE
					dispensation_date = ob2.obs_datetime;

	/*update provider for patient_dispensing???*/
	update patient_dispensing padisp, openmrs.encounter_provider enp
	set padisp.provider_id=enp.provider_id
	WHERE padisp.encounter_id=enp.encounter_id
	AND enp.voided = 0;
	/*Update dose_day, pill_amount for patient_dispensing*/
	update isanteplus.patient_dispensing patdisp, openmrs.obs ob, openmrs.obs ob1
	SET patdisp.dose_day=ob.value_numeric
	WHERE patdisp.encounter_id=ob.encounter_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob.obs_group_id=ob1.obs_id
    AND ob1.concept_id=163711
	AND ob.concept_id=159368
	AND ob.voided = 0;
	/*Update pill_amount for patient_dispensing*/
	update isanteplus.patient_dispensing patdisp, openmrs.obs ob, openmrs.obs ob1
	SET patdisp.pills_amount=ob.value_numeric
	WHERE patdisp.encounter_id=ob.encounter_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob.obs_group_id=ob1.obs_id
    AND ob1.concept_id=163711
	AND ob.concept_id=1443
	AND ob.voided = 0;
	/*update next_dispensation_date for table patient_dispensing*/
	update patient_dispensing patdisp, openmrs.obs ob
	set patdisp.next_dispensation_date=ob.value_datetime
	WHERE patdisp.encounter_id=ob.encounter_id
	AND ob.concept_id=162549
	AND ob.voided = 0;
   /*update visit_id, visit_date for table patient_dispensing*/
	update patient_dispensing patdisp, openmrs.visit vi, openmrs.encounter en
   set patdisp.visit_id=vi.visit_id, patdisp.visit_date=vi.date_started
	where patdisp.encounter_id=en.encounter_id
	AND en.visit_id=vi.visit_id;
    /*update dispensation_location Dispensation communautaire=1755 for table patient_dispensing*/
	update patient_dispensing patdisp, openmrs.obs ob
	set patdisp.dispensation_location=1755
	WHERE patdisp.encounter_id=ob.encounter_id
	AND ob.concept_id=1755
	AND ob.value_coded=1065
	AND ob.voided = 0;
	/*update rx_or_prophy for table patient_dispensing*/
	update isanteplus.patient_dispensing pdisp, openmrs.obs ob1, openmrs.obs ob2, openmrs.obs ob3
		   set pdisp.rx_or_prophy=ob2.value_coded
		   WHERE pdisp.encounter_id=ob2.encounter_id
		   AND ob1.obs_id=ob2.obs_group_id
           AND ob1.obs_id=ob3.obs_group_id
		   AND pdisp.patient_id = ob2.person_id
		   AND pdisp.location_id = ob2.location_id
		   AND (ob1.concept_id=1442 OR ob1.concept_id=160741)
		   AND ob2.concept_id=160742
           AND ob3.concept_id=1282
           AND pdisp.drug_id=ob3.value_coded
           AND ob1.voided=ob2.voided=ob3.voided=0;
		/*Insertion for patient_id, visit_id,encounter_id,visit_date for table patient_imagerie */
insert into patient_imagerie (patient_id,location_id,visit_id,encounter_id,visit_date)
	select distinct ob.person_id,ob.location_id,vi.visit_id, ob.encounter_id,vi.date_started
	from openmrs.obs ob, openmrs.encounter en,
	openmrs.encounter_type enctype, openmrs.visit vi
	WHERE ob.encounter_id=en.encounter_id
	AND en.encounter_type=enctype.encounter_type_id
	AND en.visit_id=vi.visit_id
	AND(ob.concept_id=12 or ob.concept_id=309 or ob.concept_id=307)
	AND enctype.uuid='a4cab59f-f0ce-46c3-bd76-416db36ec719'
	on duplicate key update
	visit_date = vi.date_started;
/*update radiographie_pul of table patient_imagerie*/
update isanteplus.patient_imagerie patim, openmrs.obs ob
set patim.radiographie_pul=ob.value_coded
WHERE patim.encounter_id=ob.encounter_id
AND ob.concept_id=12
AND ob.voided = 0;
/*update radiographie_autre of table patient_imagerie*/
update isanteplus.patient_imagerie patim, openmrs.obs ob
set patim.radiographie_autre=ob.value_coded
WHERE patim.encounter_id=ob.encounter_id
AND ob.concept_id=309
AND ob.voided = 0;
/*update crachat_barr of table patient_imagerie*/
update isanteplus.patient_imagerie patim, openmrs.obs ob
set patim.crachat_barr=ob.value_coded
WHERE patim.encounter_id=ob.encounter_id
AND ob.concept_id=307
AND ob.voided = 0;

/*Part of patient Status*/

 TRUNCATE TABLE patient_on_arv;
	INSERT INTO patient_on_arv(patient_id,visit_id,visit_date)
	SELECT DISTINCT v.patient_id,v.visit_id,MAX(v.date_started)
	FROM openmrs.visit v, openmrs.encounter enc, openmrs.obs ob,
	openmrs.obs ob1, openmrs.obs ob2, isanteplus.arv_drugs darv
	WHERE v.visit_id=enc.visit_id
	AND enc.encounter_id=ob.encounter_id
	AND ob.person_id=ob1.person_id
	AND ob.encounter_id=ob1.encounter_id
	AND ob.obs_group_id=ob1.obs_id
	AND ob1.obs_id = ob2.obs_group_id
	AND ob1.concept_id=163711
	AND ob.concept_id=1282
	AND ob2.concept_id=1276
	AND ob.value_coded = darv.drug_id
	GROUP BY v.patient_id;


	TRUNCATE TABLE discontinuation_reason;
INSERT INTO
 discontinuation_reason(patient_id,visit_id,visit_date,reason,reason_name)
SELECT v.patient_id,v.visit_id,
			MAX(v.date_started),ob.value_coded,
		CASE WHEN(ob.value_coded=5240) THEN 'Perdu de vue'
		    WHEN (ob.value_coded=159492) THEN 'Transfert'
			WHEN (ob.value_coded=159) THEN 'Décès'
			WHEN (ob.value_coded=1667) THEN 'Discontinuations'
			WHEN (ob.value_coded=1067) THEN 'Inconnue'
		END
	FROM openmrs.visit v, openmrs.encounter enc,
	openmrs.encounter_type etype,openmrs.obs ob
	WHERE v.visit_id=enc.visit_id
	AND enc.encounter_type=etype.encounter_type_id
	AND enc.encounter_id=ob.encounter_id
	AND etype.uuid='9d0113c6-f23a-4461-8428-7e9a7344f2ba'
	AND ob.concept_id=161555
	AND ob.voided = 0
	Group BY v.patient_id, ob.value_coded;

	/*INSERT for stopping_reason*/

	TRUNCATE TABLE stopping_reason;
INSERT INTO
 stopping_reason(patient_id,visit_id,visit_date,reason,reason_name,other_reason)
SELECT v.patient_id,v.visit_id,
			MAX(v.date_started),ob.value_coded,
		CASE WHEN(ob.value_coded=1754) THEN 'ARVs non-disponibles'
		    WHEN (ob.value_coded=160415) THEN 'Patient a déménagé'
			WHEN (ob.value_coded=115198) THEN 'Adhérence inadéquate'
			WHEN (ob.value_coded=159737) THEN 'Préférence du patient'
			WHEN (ob.value_coded=5622) THEN 'Autre raison, préciser'
		END, ob.comments
	FROM openmrs.visit v, openmrs.encounter enc,
	openmrs.encounter_type etype,openmrs.obs ob
	WHERE v.visit_id=enc.visit_id
	AND enc.encounter_type=etype.encounter_type_id
	AND enc.encounter_id=ob.encounter_id
	AND etype.uuid='9d0113c6-f23a-4461-8428-7e9a7344f2ba'
	AND ob.concept_id=1667
	AND ob.value_coded IN(1754,160415,115198,159737,5622)
	AND ob.voided = 0
	GROUP BY v.patient_id, ob.value_coded;
/*Delete FROM discontinuation_reason WHERE visit_id NOT IN Adhérence inadéquate=115198
OR Préférence du patient=159737*/
DELETE FROM discontinuation_reason
	WHERE visit_id NOT IN(SELECT str.visit_id FROM stopping_reason str
	WHERE str.reason = 115198 OR str.reason = 159737)
	AND reason = 1667;
/*Starting patient_prescription*/
	/*Insert for patient_id,encounter_id, drug_id areas*/
  INSERT into patient_prescription
					(
					 patient_id,
					 encounter_id,
					 location_id,
					 drug_id
					)
					select distinct ob.person_id,
					ob.encounter_id,ob.location_id,ob.value_coded
					from openmrs.obs ob, openmrs.obs ob1
					where ob.person_id=ob1.person_id
					AND ob.encounter_id=ob1.encounter_id
					AND ob.obs_group_id=ob1.obs_id
                    AND (ob1.concept_id=1442 OR ob1.concept_id=160741)
					AND ob.concept_id=1282
					on duplicate key update
					encounter_id = ob.encounter_id;
	/*update provider for patient_prescription*/
	update patient_prescription pp, openmrs.encounter_provider enp
	set pp.provider_id=enp.provider_id
	WHERE pp.encounter_id=enp.encounter_id;
	  /*update visit_id, visit_date for table patient_prescription*/
	update patient_prescription patp, openmrs.visit vi, openmrs.encounter en
   set patp.visit_id=vi.visit_id, patp.visit_date=vi.date_started
	where patp.encounter_id=en.encounter_id
	AND en.visit_id=vi.visit_id;
	/*update rx_or_prophy for table patient_prescription*/
	update isanteplus.patient_prescription pp, openmrs.obs ob1, openmrs.obs ob2, openmrs.obs ob3
		   set pp.rx_or_prophy=ob2.value_coded
		   WHERE pp.encounter_id=ob2.encounter_id
		   AND ob1.obs_id=ob2.obs_group_id
           AND ob1.obs_id=ob3.obs_group_id
		   AND (ob1.concept_id=1442 OR ob1.concept_id=160741)
		   AND ob2.concept_id=160742
           AND ob3.concept_id=1282
           AND pp.drug_id=ob3.value_coded
           AND ob1.voided=ob2.voided=ob3.voided=0;
    /*update posology_day for table patient_prescription*/
	update isanteplus.patient_prescription pp, openmrs.obs ob1, openmrs.obs ob2, openmrs.obs ob3
		   set pp.posology=ob2.value_text
		   WHERE pp.encounter_id=ob2.encounter_id
		   AND ob1.obs_id=ob2.obs_group_id
           AND ob1.obs_id=ob3.obs_group_id
		   AND (ob1.concept_id=1442 OR ob1.concept_id=160741)
		   AND ob2.concept_id=1444
           AND ob3.concept_id=1282
           AND pp.drug_id=ob3.value_coded
           AND ob1.voided=ob2.voided=ob3.voided=0;
	/*update number_day for table patient_prescription*/
	update isanteplus.patient_prescription pp, openmrs.obs ob1, openmrs.obs ob2, openmrs.obs ob3
		   set pp.number_day=ob2.value_numeric
		   WHERE pp.encounter_id=ob2.encounter_id
		   AND ob1.obs_id=ob2.obs_group_id
           AND ob1.obs_id=ob3.obs_group_id
		   AND (ob1.concept_id=1442 OR ob1.concept_id=160741)
		   AND ob2.concept_id=159368
           AND ob3.concept_id=1282
           AND pp.drug_id=ob3.value_coded
           AND ob1.voided=ob2.voided=ob3.voided=0;
/*End of patient_prescription*/
/*Starting patient_laboratory */
/*Insertion for patient_laboratory*/
	INSERT into patient_laboratory
					(
					 patient_id,
					 encounter_id,
					 location_id,
					 test_id
					)
					select distinct ob.person_id,
					ob.encounter_id,ob.location_id,ob.value_coded
					from openmrs.obs ob, openmrs.encounter enc,
					openmrs.encounter_type entype
					where ob.encounter_id=enc.encounter_id
					AND enc.encounter_type=entype.encounter_type_id
                    AND ob.concept_id=1271
					AND ob.voided = 0
					AND entype.uuid='f037e97b-471e-4898-a07c-b8e169e0ddc4'
					on duplicate key update
					encounter_id = ob.encounter_id;
    /*update provider for patient_laboratory*/
	update patient_laboratory lab, openmrs.encounter_provider enp
	set lab.provider_id=enp.provider_id
	WHERE lab.encounter_id=enp.encounter_id
	AND enp.voided = 0;
	/*update visit_id, visit_date for table patient_laboratory*/
	update patient_laboratory lab, openmrs.visit vi, openmrs.encounter en
    set lab.visit_id=vi.visit_id, lab.visit_date=vi.date_started
	where lab.encounter_id=en.encounter_id
	AND en.visit_id=vi.visit_id
	AND vi.voided = 0;
	/*update test_done,date_test_done,comment_test_done for patient_laboratory*/
	update patient_laboratory plab,openmrs.obs ob
	SET plab.test_done=1,plab.test_result=CASE WHEN ob.value_coded<>''
	   THEN ob.value_coded
	   WHEN ob.value_numeric<>'' THEN ob.value_numeric
	   WHEN ob.value_text<>'' THEN ob.value_text
	   END,
	plab.date_test_done=ob.obs_datetime,
	plab.comment_test_done=ob.comments
	WHERE plab.test_id=ob.concept_id
	AND plab.encounter_id=ob.encounter_id
	AND ob.voided = 0;

	/*update order_destination for patient_laboratory*/
	update patient_laboratory plab,openmrs.obs ob
	SET plab.order_destination = ob.value_text
	WHERE ob.concept_id = 160632
	AND plab.encounter_id = ob.encounter_id
	AND ob.voided = 0;

	/*update test_name for patient_laboratory*/
	update patient_laboratory plab, openmrs.concept_name cn
	SET plab.test_name=cn.name
	WHERE plab.test_id = cn.concept_id
	AND cn.locale="fr"
	AND cn.voided = 0;

/*End of patient_laboratory*/
/*Starting insertion for patient_prenancy table*/
/*Patient_pregnancy insertion*/
	INSERT INTO patient_pregnancy (patient_id,encounter_id,start_date)
	SELECT DISTINCT ob.person_id,ob.encounter_id,DATE(ob.obs_datetime) AS start_date
	FROM openmrs.obs ob, openmrs.obs ob1
	WHERE ob.obs_group_id=ob1.obs_id
	AND ob.concept_id=1284
	AND ob.value_coded IN (46,129251,132678,47,163751,1449,118245,129211,141631)
	AND ob1.concept_id=159947
	AND ob.voided = 0
	on duplicate key update
	start_date = start_date;
	/*AND ob.person_id NOT IN
	(SELECT ppr.patient_id FROM isanteplus.patient_pregnancy ppr
	WHERE ppr.end_date is null
	AND ppr.end_date < DATE(ob.obs_datetime))*/
	/*Patient_pregnancy insertion for area Femme enceinte (Grossesse)*/
	INSERT INTO patient_pregnancy (patient_id,encounter_id,start_date)
	SELECT ob.person_id,ob.encounter_id,DATE(ob.obs_datetime) AS start_date
	FROM openmrs.obs ob
	WHERE ob.concept_id=162225
	AND ob.value_coded=1434
	AND ob.voided = 0
	on duplicate key update
	start_date = start_date;
	/*Insertion in patient_pregnancy table where prenatale is checked in the OBGYN form*/
	INSERT into patient_pregnancy(patient_id,encounter_id,start_date)
					select distinct ob.person_id,ob.encounter_id,DATE(enc.encounter_datetime) AS start_date
					from openmrs.obs ob, openmrs.encounter enc,
					openmrs.encounter_type ent
					WHERE ob.encounter_id = enc.encounter_id
					AND enc.encounter_type = ent.encounter_type_id
                    AND ob.concept_id = 160288
					AND ob.value_coded = 1622
					AND ent.uuid IN("5c312603-25c1-4dbe-be18-1a167eb85f97","49592bec-dd22-4b6c-a97f-4dd2af6f2171")
					AND ob.voided = 0
					on duplicate key update
					start_date = start_date;
	/*Insertion in patient_pregnancy table where DPA is filled*/
	INSERT into patient_pregnancy(patient_id,encounter_id,start_date)
					select distinct ob.person_id,ob.encounter_id,DATE(enc.encounter_datetime) AS start_date
					from openmrs.obs ob, openmrs.encounter enc,
					openmrs.encounter_type ent
					WHERE ob.encounter_id = enc.encounter_id
					AND enc.encounter_type = ent.encounter_type_id
                    AND ob.concept_id = 5596
					AND ob.value_datetime <> ""
					AND ent.uuid IN("5c312603-25c1-4dbe-be18-1a167eb85f97","49592bec-dd22-4b6c-a97f-4dd2af6f2171")
					AND ob.voided = 0
					on duplicate key update
					start_date = start_date;
	/*Patient_pregnancy insertion for areas B-HCG(positif),Test de Grossesse(positif) */
	INSERT INTO patient_pregnancy(patient_id,encounter_id,start_date)
	SELECT ob.person_id,ob.encounter_id,DATE(ob.obs_datetime) AS start_date
	FROM openmrs.obs ob
	WHERE (ob.concept_id=1945 OR ob.concept_id=45)
	AND ob.value_coded=703
	AND ob.voided = 0
	on duplicate key update
	start_date = start_date;
	/*Insertion in patient_pregnancy table where a form travail et accouchement is filled*/
	INSERT into patient_pregnancy(patient_id,encounter_id,start_date, end_date)
					select distinct ob.person_id,ob.encounter_id,(DATE(enc.encounter_datetime)- INTERVAL 9 MONTH) AS start_date,
					DATE(enc.encounter_datetime) AS end_date
					from openmrs.obs ob, openmrs.encounter enc,
					openmrs.encounter_type ent
					WHERE ob.encounter_id = enc.encounter_id
					AND enc.encounter_type = ent.encounter_type_id
					AND ent.uuid = "d95b3540-a39f-4d1e-a301-8ee0e03d5eab"
					AND ob.voided = 0
					on duplicate key update
					start_date = start_date,
					end_date = end_date;
	/* Patient_pregnancy updated date_stop for area DPA: <obs conceptId="CIEL:5596"/>*/
	UPDATE patient_pregnancy ppr,openmrs.obs ob
	SET end_date=DATE(ob.value_datetime)
	WHERE ppr.patient_id=ob.person_id
	AND ob.concept_id=5596
	AND ob.voided = 0
	AND ppr.start_date < DATE(ob.value_datetime)
	AND ppr.end_date is null;
	/*Patient_pregnancy updated end_date for La date d’une fiche de travail et d’accouchement > a la date de début*/
	UPDATE patient_pregnancy ppr,openmrs.encounter enc,
	openmrs.encounter_type etype
	SET end_date=DATE(enc.encounter_datetime)
	WHERE ppr.patient_id=enc.patient_id
	AND ppr.start_date < DATE(enc.encounter_datetime)
	AND ppr.end_date is null
	AND enc.encounter_type=etype.encounter_type_id
	AND enc.voided = 0
	AND etype.uuid='d95b3540-a39f-4d1e-a301-8ee0e03d5eab';
	/*Patient_pregnancy updated for DDR – 3 mois + 7 jours=1427 */
	UPDATE patient_pregnancy ppr,openmrs.obs ob, openmrs.encounter enc
	SET end_date=DATE(ob.value_datetime) - INTERVAL 3 MONTH + INTERVAL 7 DAY + INTERVAL 1 YEAR
	WHERE ppr.patient_id=ob.person_id
	AND ob.person_id=enc.patient_id
	AND ob.concept_id=1427
	AND ob.voided = 0
	AND ppr.start_date <= DATE(enc.encounter_datetime)
	AND ppr.end_date is null;
	/*update patient_pregnancy (Add 9 Months on the start_date
	    for finding the end_date) */
    UPDATE patient_pregnancy ppr
	SET ppr.end_date=ppr.start_date + INTERVAL 9 MONTH
	WHERE (TIMESTAMPDIFF(MONTH,ppr.start_date,DATE(now()))>=9)
	AND ppr.end_date is null;
/*Ending insertion for patient_prenancy table*/
/*Starting insertion for alert (charge viral)*/
/*Insertion for Nombre de patient sous ARV depuis 6 mois sans un résultat de charge virale*/
	TRUNCATE TABLE alert;
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert)
	SELECT pdis.patient_id,1,pdis.encounter_id,MAX(pdis.dispensation_date)
	FROM patient_dispensing pdis, (SELECT arv.drug_id FROM arv_drugs arv) B
	WHERE pdis.drug_id = B.drug_id
	AND(TIMESTAMPDIFF(MONTH,pdis.dispensation_date,DATE(now()))>=6)
	AND pdis.patient_id NOT IN (SELECT pl.patient_id FROM patient_laboratory pl
			WHERE pl.test_id=856 AND pl.test_done=1 AND pl.test_result <> "")
            GROUP BY pdis.patient_id;
	/*Insertion for Nombre de femmes enceintes, sous ARV depuis 4 mois sans un résultat de charge virale*/
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert)
	SELECT pdis.patient_id,2,pdis.encounter_id,MAX(pdis.dispensation_date)
	FROM patient_dispensing pdis, patient_pregnancy pp, (SELECT arv.drug_id FROM arv_drugs arv) B
	WHERE pdis.patient_id=pp.patient_id
	AND pdis.drug_id = B.drug_id
	AND(TIMESTAMPDIFF(MONTH,pdis.dispensation_date,DATE(now()))>=4)
	AND pdis.patient_id NOT IN (SELECT pl.patient_id FROM patient_laboratory pl
			WHERE pl.test_id=856 AND pl.test_done=1 AND pl.test_result <> "")
            GROUP BY pdis.patient_id;
	/*Insertion for Nombre de patients ayant leur dernière charge virale remontant à au moins 12 mois*/
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert)
            SELECT pl.patient_id,3,pl.encounter_id,MAX(pl.visit_date)
			FROM patient_laboratory pl INNER JOIN patient p
			ON p.patient_id=pl.patient_id
			WHERE pl.test_id=856 AND pl.test_done=1 AND pl.test_result <> ""
			AND(TIMESTAMPDIFF(MONTH,DATE(pl.visit_date),DATE(now()))>=12)
			AND p.vih_status=1
			AND p.patient_id NOT IN (SELECT plab.patient_id FROM patient_laboratory plab,
			             patient pa WHERE plab.patient_id=pa.patient_id
						 AND plab.test_id=844 AND plab.test_result=1302
						 AND (TIMESTAMPDIFF(YEAR,DATE(p.birthdate),DATE(now()))<=14))
			GROUP BY pl.patient_id;
	/*Insertion for Nombre de patients ayant leur dernière charge virale remontant à au moins 3 mois et dont le résultat était > 1000 copies/ml*/
	INSERT INTO alert(patient_id,id_alert,encounter_id,date_alert)
            SELECT pl.patient_id,4,pl.encounter_id,MAX(pl.visit_date)
			FROM patient_laboratory pl INNER JOIN patient p
			ON p.patient_id=pl.patient_id
			WHERE pl.test_id=856 AND pl.test_done=1
			AND(TIMESTAMPDIFF(MONTH,DATE(pl.visit_date),DATE(now()))>=3)
			AND pl.test_result > 1000
			AND p.vih_status=1
			AND p.patient_id NOT IN (SELECT plab.patient_id FROM patient_laboratory plab,
			             patient pa WHERE plab.patient_id=pa.patient_id
						 AND plab.test_id=844 AND plab.test_result=1302
						 AND (TIMESTAMPDIFF(YEAR,DATE(p.birthdate),DATE(now()))<=14))
			GROUP BY pl.patient_id;
/*Ending insertion for alert*/
/*Part of patient_diagnosis*/
	/*insertion of all diagnosis in the table patient_diagnosis*/
INSERT into patient_diagnosis
					(
					 patient_id,
					 encounter_id,
					 location_id,
					 concept_group,
					 obs_group_id,
					 concept_id,
					 answer_concept_id
					)
					select distinct ob.person_id,ob.encounter_id,
					ob.location_id,ob1.concept_id,ob.obs_group_id,ob.concept_id, ob.value_coded
					from openmrs.obs ob, openmrs.obs ob1
					where ob.person_id=ob1.person_id
					AND ob.encounter_id=ob1.encounter_id
					AND ob.obs_group_id=ob1.obs_id
                    AND ob1.concept_id=159947
					AND ob.concept_id=1284
					AND ob.voided = 0
					on duplicate key update
					encounter_id = ob.encounter_id;
	/*update patient diagnosis for suspected_confirmed area*/
	update patient_diagnosis pdiag, openmrs.obs ob,
	openmrs.obs ob1
	 SET pdiag.suspected_confirmed=ob.value_coded
	 WHERE ob.obs_group_id=ob1.obs_id
           AND ob1.concept_id=159947
		   AND ob.concept_id=159394
		   AND ob.voided = 0
		   AND pdiag.obs_group_id=ob.obs_group_id
		   and pdiag.encounter_id=ob.encounter_id;
	/*update patient diagnosis for primary_secondary area*/
     update patient_diagnosis pdiag, openmrs.obs ob,
	openmrs.obs ob1
	 SET pdiag.primary_secondary=ob.value_coded
	 WHERE ob.obs_group_id=ob1.obs_id
           AND ob1.concept_id=159947
		   AND ob.concept_id=159946
		   AND pdiag.obs_group_id=ob.obs_group_id
		   and pdiag.encounter_id=ob.encounter_id
		   AND ob.voided = 0;
	/*Update encounter date for patient_diagnosis*/
	update patient_diagnosis pdiag, openmrs.encounter enc
    SET pdiag.encounter_date=DATE(enc.encounter_datetime)
    WHERE pdiag.location_id=enc.location_id
          AND pdiag.encounter_id=enc.encounter_id
		  AND enc.voided = 0;
/*Ending patient_diagnosis*/
/*Part of visit_type*/
	/*Insertion for the type of the visit_type
Gynécologique=160456,Prénatale=1622,Postnatale=1623,Planification familiale=5483
*/
INSERT INTO visit_type(patient_id,encounter_id,location_id,
visit_id,concept_id,v_type,encounter_date)
SELECT ob.person_id, ob.encounter_id,ob.location_id, enc.visit_id,
 ob.concept_id,ob.value_coded, DATE(enc.encounter_datetime)
 FROM openmrs.obs ob, openmrs.encounter enc
 WHERE ob.encounter_id=enc.encounter_id
 AND ob.concept_id=160288
 AND ob.value_coded IN (160456,1622,1623,5483)
 AND ob.voided = 0
 on duplicate key update
 encounter_id = ob.encounter_id;
/*End part of visit_type*/
/*Part of patient_delivery table*/
/* Insertion for table patient_delivery */
	INSERT into patient_delivery
					(
					 patient_id,
					 encounter_id,
					 location_id,
					 delivery_location,
					 encounter_date
					)
					select distinct ob.person_id,ob.encounter_id,
					ob.location_id,ob.value_coded, DATE(enc.encounter_datetime)
					from openmrs.obs ob, openmrs.encounter enc,
					openmrs.encounter_type ent
					WHERE ob.encounter_id=enc.encounter_id
					AND enc.encounter_type=ent.encounter_type_id
                    AND ob.concept_id=1572
					AND ob.value_coded IN(163266,1501,1502,5622)
					AND ent.uuid="d95b3540-a39f-4d1e-a301-8ee0e03d5eab"
					AND ob.voided = 0
					on duplicate key update
					delivery_location = ob.value_coded;

	update patient_delivery pdel, openmrs.obs ob
	 SET pdel.delivery_date=ob.value_datetime
	 WHERE ob.concept_id=5599
		   and pdel.encounter_id=ob.encounter_id
		   AND pdel.location_id=ob.location_id
		   AND ob.voided = 0;

/*END of Insertion for table patient_delivery*/
/*Part of virological_tests table*/
/*insertion of virological tests (PCR) in the table virological_tests*/
INSERT into virological_tests
					(
					 patient_id,
					 encounter_id,
					 location_id,
					 concept_group,
					 obs_group_id,
					 test_id,
					 answer_concept_id
					)
					select distinct ob.person_id,ob.encounter_id,
					ob.location_id,ob1.concept_id,ob.obs_group_id,ob.concept_id, ob.value_coded
					from openmrs.obs ob, openmrs.obs ob1
					where ob.person_id=ob1.person_id
					AND ob.encounter_id=ob1.encounter_id
					AND ob.obs_group_id=ob1.obs_id
                    AND ob1.concept_id=1361
					AND ob.concept_id=162087
					AND ob.value_coded=1030
					AND ob.voided = 0
					on duplicate key update
					encounter_id = ob.encounter_id;

	/*Update for area test_result for PCR*/
	update virological_tests vtests, openmrs.obs ob
	 SET vtests.test_result=ob.value_coded
	 WHERE ob.concept_id=1030
		   AND vtests.obs_group_id=ob.obs_group_id
		   and vtests.encounter_id=ob.encounter_id
		   AND vtests.location_id=ob.location_id
		   AND ob.voided = 0;
	/*Update for area age for PCR*/
	update virological_tests vtests, openmrs.obs ob
	 SET vtests.age=ob.value_numeric
	 WHERE ob.concept_id=163540
		   AND vtests.obs_group_id=ob.obs_group_id
		   and vtests.encounter_id=ob.encounter_id
		   AND vtests.location_id=ob.location_id
		   AND ob.voided = 0;
	/*Update for age_unit for PCR*/
	update virological_tests vtests, openmrs.obs ob
	 SET vtests.age_unit=ob.value_coded
	 WHERE ob.concept_id=163541
		   AND vtests.obs_group_id=ob.obs_group_id
		   and vtests.encounter_id=ob.encounter_id
		   AND vtests.location_id=ob.location_id
		   AND ob.voided = 0;
	/*Update encounter date for virological_tests*/
	update virological_tests vtests, openmrs.encounter enc
    SET vtests.encounter_date=DATE(enc.encounter_datetime)
    WHERE vtests.location_id=enc.location_id
          AND vtests.encounter_id=enc.encounter_id
		  AND enc.voided = 0;
	/*Update to fill test_date area*/
	update virological_tests vtests, patient p
	SET vtests.test_date =
	CASE WHEN(vtests.age_unit=1072 AND (ADDDATE(DATE(p.birthdate), INTERVAL vtests.age DAY) < DATE(now())))
	THEN ADDDATE(DATE(p.birthdate), INTERVAL vtests.age DAY)
	WHEN(vtests.age_unit=1074
	AND (ADDDATE(DATE(p.birthdate), INTERVAL vtests.age MONTH) < DATE(now()))) THEN ADDDATE(DATE(p.birthdate), INTERVAL vtests.age MONTH)
	ELSE
		vtests.encounter_date
	END
	WHERE vtests.patient_id = p.patient_id
	AND vtests.test_id = 162087
	AND answer_concept_id = 1030;
/*END of virological_tests table*/
/*Part of pediatric_hiv_visit table*/
	/*Insertion for pediatric_hiv_visit */
	INSERT into pediatric_hiv_visit
					(
					 patient_id,
					 encounter_id,
					 location_id,
					 encounter_date
					)
					select distinct ob.person_id,ob.encounter_id,
					ob.location_id,DATE(enc.encounter_datetime)
					from openmrs.obs ob, openmrs.encounter enc,
					openmrs.encounter_type ent
					WHERE ob.encounter_id=enc.encounter_id
					AND enc.encounter_type=ent.encounter_type_id
                    AND ob.concept_id IN(163776,5665,1401)
					AND (ent.uuid="349ae0b4-65c1-4122-aa06-480f186c8350"
						OR ent.uuid="33491314-c352-42d0-bd5d-a9d0bffc9bf1")
						AND ob.voided = 0
						on duplicate key update
						encounter_id = ob.encounter_id;
/*update for ptme*/
	update pediatric_hiv_visit pv, openmrs.obs ob
	 SET pv.ptme=ob.value_coded
	 WHERE ob.concept_id=163776
		   and pv.encounter_id=ob.encounter_id
		   AND pv.location_id=ob.location_id
		   AND ob.voided = 0;
	/*update for prophylaxie72h*/
	update pediatric_hiv_visit pv, openmrs.obs ob
	 SET pv.prophylaxie72h=ob.value_coded
	 WHERE ob.concept_id=5665
		   and pv.encounter_id=ob.encounter_id
		   AND pv.location_id=ob.location_id
		   AND ob.voided = 0;
	/*update for actual_vih_status*/
	update pediatric_hiv_visit pv, openmrs.obs ob
	 SET pv.actual_vih_status=ob.value_coded
	 WHERE ob.concept_id=1401
		   and pv.encounter_id=ob.encounter_id
		   AND pv.location_id=ob.location_id
		   AND ob.voided = 0;

/*End of pediatric_hiv_visit table*/
/*Starting Insertion for table patient_menstruation*/
	/*Insertion for patient_menstruation*/
	insert into patient_menstruation
					(
					 patient_id,
					 encounter_id,
					 location_id,
					 encounter_date
					)
					select distinct ob.person_id,ob.encounter_id,
					ob.location_id,DATE(enc.encounter_datetime)
					from openmrs.obs ob, openmrs.encounter enc,
					openmrs.encounter_type ent
					WHERE ob.encounter_id=enc.encounter_id
					AND enc.encounter_type=ent.encounter_type_id
                    AND ob.concept_id IN(163732,160597,1427)
					AND (ent.uuid="5c312603-25c1-4dbe-be18-1a167eb85f97"
						OR ent.uuid="49592bec-dd22-4b6c-a97f-4dd2af6f2171")
					AND ob.voided = 0
						on duplicate key update
						encounter_id = ob.encounter_id;
	/*Update table patient_menstruation for having the
	DDR (DATE de Derniere Regle) value date*/
	update patient_menstruation pm, openmrs.obs ob
	 SET pm.ddr=DATE(ob.value_datetime)
	 WHERE ob.concept_id=1427
		   and pm.encounter_id=ob.encounter_id
		   AND pm.location_id=ob.location_id
		   AND ob.voided = 0;

	/*Starting insertion for table vih_risk_factor*/

	/*Insertion for risks factor*/
	insert into vih_risk_factor
					(
					 patient_id,
					 encounter_id,
					 location_id,
					 risk_factor,
					 encounter_date
					)
					select distinct ob.person_id,ob.encounter_id,
					ob.location_id,ob.value_coded,
					DATE(enc.encounter_datetime)
					from openmrs.obs ob, openmrs.encounter enc,
					openmrs.encounter_type ent
					WHERE ob.encounter_id=enc.encounter_id
					AND enc.encounter_type=ent.encounter_type_id
                    AND ob.concept_id IN(1061,160581)
					AND ob.value_coded IN (163290,163291,105,1063,163273,163274,163289,163275,5567,159218)
					AND ob.voided = 0
					AND ent.uuid IN('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
						'349ae0b4-65c1-4122-aa06-480f186c8350')
						on duplicate key update
						encounter_id = ob.encounter_id;

	/*Insertion for risks factor for other risks*/
	insert into vih_risk_factor
					(
					 patient_id,
					 encounter_id,
					 location_id,
					 risk_factor,
					 encounter_date
					)
					select distinct ob.person_id,ob.encounter_id,
					ob.location_id,ob.concept_id,
					DATE(enc.encounter_datetime)
					from openmrs.obs ob, openmrs.encounter enc,
					openmrs.encounter_type ent
					WHERE ob.encounter_id=enc.encounter_id
					AND enc.encounter_type=ent.encounter_type_id
                    AND ob.concept_id IN(123160,156660,163276,163278,160579,160580)
					AND ob.value_coded = 1065
					AND ob.voided = 0
					AND ent.uuid IN('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
						'349ae0b4-65c1-4122-aa06-480f186c8350')
					on duplicate key update
					encounter_id = ob.encounter_id;

		/*End of insertion for vih_risk_factor*/

	/*End of Insertion for table patient_menstruation*/

    START TRANSACTION;
      /*Starting insertion for table vaccination*/
      INSERT INTO vaccination(
        patient_id,
        encounter_id,
        encounter_date,
        location_id
      )
      SELECT DISTINCT ob.person_id, ob.encounter_id, enc.encounter_datetime, ob.location_id
      FROM openmrs.obs ob, openmrs.encounter enc, openmrs.encounter_type ent
      WHERE ob.encounter_id=enc.encounter_id
        AND enc.encounter_type=ent.encounter_type_id
        AND ob.concept_id=984
		AND ob.voided = 0
		on duplicate key update
		encounter_id = ob.encounter_id;

      /*Create temporary table for query vaccination dates*/
      CREATE TABLE temp_vaccination (
        person_id int(11),
        value_coded int(11),
        dose int(11),
        obs_group_id int(11),
        obs_datetime datetime,
        encounter_id int(11)
      );

      /*Set age range (day)*/
      UPDATE isanteplus.vaccination v, isanteplus.patient p
      SET v.age_range=
        CASE
          WHEN (
          TIMESTAMPDIFF(DAY, p.birthdate, v.encounter_date) BETWEEN 0 AND 45
          ) THEN 45
          WHEN TIMESTAMPDIFF(DAY, p.birthdate, v.encounter_date) BETWEEN 46 AND 75
            THEN 75
          WHEN TIMESTAMPDIFF(DAY, p.birthdate, v.encounter_date) BETWEEN 76 AND 105
            THEN 105
          WHEN TIMESTAMPDIFF(DAY, p.birthdate, v.encounter_date) BETWEEN 106 AND 270
            THEN 270
          ELSE null
        END
      WHERE v.patient_id = p.patient_id;

      /*Query for receive vaccination dates*/
      INSERT INTO temp_vaccination (person_id, value_coded, dose, obs_group_id, obs_datetime, encounter_id)
      SELECT ob.person_id, ob.value_coded, ob2.value_numeric, ob.obs_group_id, ob.obs_datetime, ob.encounter_id
      FROM openmrs.obs ob, openmrs.obs ob2
      WHERE ob2.obs_group_id = ob.obs_group_id
        AND ob2.concept_id=1418
        AND ob.concept_id=984
		AND ob.voided = 0;

      /*Update vaccination table for children 0-45 days old*/
      UPDATE isanteplus.vaccination v
      SET v.vaccination_done = true
      WHERE v.age_range=45
        AND (
          ( -- Scenario A 0-45
            3 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (783, 1423, 83531))
          )
          OR ( -- Scenario B 0-45
            5 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
          )
        );

      /*Update vaccination table for children 46-75 days old*/
      UPDATE isanteplus.vaccination v
      SET v.vaccination_done = true
      WHERE v.age_range=75
        AND (
          ( -- Scenario A 46-75
            -- Dose 1
            3 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (783, 1423, 83531))
            -- Dose 2
            AND 3 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (783, 1423, 83531))
          )
          OR ( -- Scenario B 46-75
            -- Dose 1
            5 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
            -- Dose 2
            AND 5 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
          )
        );

      /*Update vaccination table for children 76-105 days old*/
      UPDATE isanteplus.vaccination v
      SET v.vaccination_done = true
      WHERE v.age_range=105
        AND (
          ( -- Scenario A 76-105
            -- Dose 1
            3 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (783, 1423, 83531))
            -- Dose 2
            AND 3 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (783, 1423, 83531))
            -- Dose 3
            AND 2 = (SELECT COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (783, 1423))
          )
          OR ( -- Scenario B 76-105
            -- Dose 1
            5 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
            -- Dose 2
            AND 5 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
            -- Dose 3
            AND 4 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=3 AND tv.value_coded IN (781, 782, 783, 5261))
          )
        );

      /*Update vaccination table for children 106-270 days old*/
      UPDATE isanteplus.vaccination v
      SET v.vaccination_done = true
      WHERE v.age_range=270
      AND (
        ( -- Scenario A 106-270
          -- Dose 1
          3 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (783, 1423, 83531))
          AND (
            159701 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
            OR 162586 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
          )
          -- Dose 2
          AND 3 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (783, 1423, 83531))
          AND ((
              159701 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2)
              AND 159701 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
            ) OR (
              162586 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
            )
          )
          -- Dose 3
          AND 2 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=3 AND tv.value_coded IN (783, 1423))
        )
        OR ( -- Scenario B 106-270
          -- Dose 1
          5 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
          AND (
            159701 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
            OR 162586 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
          )
          -- Dose 2
          AND 5 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2 AND tv.value_coded IN (781, 782, 783, 5261, 83531))
          AND ((
              159701 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=2)
              AND 159701 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
            ) OR (
              162586 IN (SELECT tv.value_coded FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=1)
            )
          )
          -- Dose 3
          AND 4 = (SELECT  COUNT(tv.person_id) FROM temp_vaccination tv WHERE tv.encounter_id=v.encounter_id AND tv.dose=3 AND tv.value_coded IN (781, 782, 783, 5261))
        )
        );
      DROP TABLE if exists `temp_vaccination`;
    COMMIT;


	/*Part of serological tests*/
		INSERT into serological_tests
					(
					 patient_id,
					 encounter_id,
					 location_id,
					 concept_group,
					 obs_group_id,
					 test_id,
					 answer_concept_id
					)
					select distinct ob.person_id,ob.encounter_id,
					ob.location_id,ob1.concept_id,ob.obs_group_id,ob.concept_id, ob.value_coded
					from openmrs.obs ob, openmrs.obs ob1
					where ob.person_id=ob1.person_id
					AND ob.encounter_id=ob1.encounter_id
					AND ob.obs_group_id=ob1.obs_id
                    AND ob1.concept_id=1361
					AND ob.concept_id=162087
					AND ob.value_coded IN(163722,1042)
					AND ob.voided = 0
					on duplicate key update
					encounter_id = ob.encounter_id;

	/*Update for area test_result for tests serologiques*/
	update serological_tests stests, openmrs.obs ob
	 SET stests.test_result=ob.value_coded
	 WHERE ob.concept_id=163722
		   AND stests.obs_group_id=ob.obs_group_id
		   and stests.encounter_id=ob.encounter_id
		   AND stests.location_id=ob.location_id
		   AND ob.voided = 0;
	/*Update for area age for tests serologiques*/
	update serological_tests stests, openmrs.obs ob
	 SET stests.age=ob.value_numeric
	 WHERE ob.concept_id=163540
		   AND stests.obs_group_id=ob.obs_group_id
		   and stests.encounter_id=ob.encounter_id
		   AND stests.location_id=ob.location_id
		   AND ob.voided = 0;
	/*Update for age_unit for tests serologiques*/
	update serological_tests stests, openmrs.obs ob
	 SET stests.age_unit=ob.value_coded
	 WHERE ob.concept_id=163541
		   AND stests.obs_group_id=ob.obs_group_id
		   and stests.encounter_id=ob.encounter_id
		   AND stests.location_id=ob.location_id
		   AND ob.voided = 0;
	/*Update encounter date for serological_tests*/
	update serological_tests stests, openmrs.encounter enc
    SET stests.encounter_date=DATE(enc.encounter_datetime)
    WHERE stests.location_id=enc.location_id
          AND stests.encounter_id=enc.encounter_id;
	/*End serological tests*/

	/*Update to fill test_date area*/
	update serological_tests stests, patient p
	SET stests.test_date =
	CASE WHEN(stests.age_unit=1072 AND (ADDDATE(DATE(p.birthdate), INTERVAL stests.age DAY) < DATE(now())))
	THEN ADDDATE(DATE(p.birthdate), INTERVAL stests.age DAY)
	WHEN(stests.age_unit=1074
	AND (ADDDATE(DATE(p.birthdate), INTERVAL stests.age MONTH) < DATE(now()))) THEN ADDDATE(DATE(p.birthdate), INTERVAL stests.age MONTH)
	ELSE
		stests.encounter_date
	END
	WHERE stests.patient_id = p.patient_id
	AND stests.test_id = 162087
	AND answer_concept_id IN(163722,1042);
/*END of virological_tests table*/
	/*Insert pcr on patient_pcr*/
	truncate table patient_pcr;
	INSERT INTO patient_pcr(patient_id,encounter_id,location_id,visit_date,pcr_result, test_date)
	SELECT distinct pl.patient_id,pl.encounter_id,pl.location_id,pl.visit_date,pl.test_result,pl.date_test_done
	FROM isanteplus.patient_laboratory pl
	WHERE pl.test_id = 844
	AND pl.test_done = 1
	AND pl.test_result IN(1301,1302,1300,1304);

	INSERT INTO patient_pcr(patient_id,encounter_id,location_id,visit_date,pcr_result, test_date)
	SELECT distinct vt.patient_id,vt.encounter_id, vt.location_id,
	vt.encounter_date,vt.test_result,vt.test_date
	FROM isanteplus.virological_tests vt
	WHERE vt.test_id = 162087
	AND vt.answer_concept_id = 1030
	AND vt.test_result IN (664,703,1138);

	/*Update for date_started_arv area in patient table */
	UPDATE patient p, patient_dispensing pdis,
	(SELECT pdi.patient_id, MIN(pdi.visit_date) as visit_date
	FROM patient_dispensing pdi WHERE pdi.drug_id IN (SELECT darv.drug_id
	FROM isanteplus.arv_drugs darv) GROUP BY 1) B
	SET p.date_started_arv = pdis.visit_date
	WHERE p.patient_id = pdis.patient_id
	AND pdis.patient_id = B.patient_id
	AND pdis.visit_date = B.visit_date;

	/* Update on patient_dispensing where the drug is a ARV drug */
	UPDATE patient_dispensing pdis, (SELECT ad.drug_id FROM arv_drugs ad) B
		   SET pdis.arv_drug = 1065
		   WHERE pdis.drug_id = B.drug_id;

	/*Update next_visit_date on table patient, find the last next_visit_date for all patients*/
	DROP TABLE IF EXISTS next_visit_date_table;
	CREATE TEMPORARY TABLE next_visit_date_table
	SELECT pdi.patient_id, MAX(pdi.next_dispensation_date) as next_visit_date
	FROM patient_dispensing pdi GROUP BY 1;

	INSERT INTO next_visit_date_table
	SELECT pv.patient_id, MAX(pv.next_visit_date) as next_visit_date
	FROM patient_visit pv GROUP BY 1;

	 UPDATE patient p,
	 (SELECT patient_id, MAX(next_visit_date) as next_visit_date from next_visit_date_table GROUP BY 1) B
	SET p.next_visit_date = B.next_visit_date
	WHERE p.patient_id = B.patient_id;

	DROP TABLE next_visit_date_table;



    SET FOREIGN_KEY_CHECKS=1;
    SET SQL_SAFE_UPDATES = 1;
    /*End of DML queries*/
    END$$
DELIMITER ;

	--
  --   DROP EVENT if exists isanteplusreports_dml_event;
	-- CREATE EVENT if not exists isanteplusreports_dml_event
	-- ON SCHEDULE EVERY 3 HOUR
	--  STARTS now()
	-- 	DO
		call isanteplusreports_dml();
