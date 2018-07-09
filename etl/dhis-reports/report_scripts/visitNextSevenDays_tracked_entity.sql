DROP PROCEDURE IF EXISTS visitNextSevenDays_tracked_entity;
DELIMITER $$
CREATE PROCEDURE visitNextSevenDays_tracked_entity()
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INT UNSIGNED DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'iTlI6sz0KWM';

SET SESSION group_concat_max_len = max_group_concat_max_len;

CALL patient_insert_idgen(program);

SELECT (SELECT CONCAT( "{\"trackedEntityInstances\": ", instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
    FROM (
      SELECT DISTINCT JSON_OBJECT (
        "trackedEntity", "MCPQUTHX1Ze",
        "trackedEntityInstance", pat.program_patient_id,
        "orgUnit", pat.organisation_uid,
        "attributes", JSON_ARRAY(
        JSON_OBJECT(
          "attribute", "py0TvSTBlrr",
          "value", pat.family_name
        ),
        JSON_OBJECT(
          "attribute", "uWUIkGpSMa6",
          "value", pat.given_name
        ),
        JSON_OBJECT(
          "attribute", "Cn9LcaW7Orr",
          "value", pat.identifier
        )
        ),
        "enrollments", JSON_ARRAY(
          JSON_OBJECT(
            "orgUnit", pat.organisation_uid,
            "program", program,
            "enrollmentDate", DATE_FORMAT(DATE(NOW()), date_format),
            "incidentDate", DATE_FORMAT(DATE(NOW()), date_format)
          )
        )
      ) AS track_entity
      FROM (
        select DISTINCT pa.st_id, pa.national_id, pa.identifier, pa.given_name, pa.family_name, tmp.program_patient_id,
          pa.gender, TIMESTAMPDIFF(YEAR, pa.birthdate,DATE(now())) as age, pa.telephone, f.name,
          asl.name_fr, DATE_FORMAT(pv.next_visit_date, "%d-%m-%Y") as nextVisit, pa.organisation_uid
        from isanteplus.patient pa, isanteplus.patient_visit pv, openmrs.form f,
          isanteplus.arv_status_loockup asl, isanteplus.tmp_idgen tmp
        where pa.patient_id=pv.patient_id AND pv.form_id=f.form_id and pa.arv_status = asl.id
        and pv.next_visit_date between date(now()) and date_add(date(now()),interval 7 day)
        AND tmp.identifier = pa.identifier
        AND tmp.program_id = program

        UNION

        select DISTINCT pa.st_id, pa.national_id, pa.identifier, pa.given_name, pa.family_name, tmp.program_patient_id,
          pa.gender, TIMESTAMPDIFF(YEAR, pa.birthdate,DATE(now())) as age, pa.telephone, f.name,
          asl.name_fr, DATE_FORMAT(pd.next_dispensation_date, "%d-%m-%Y") as nextVisit, pa.organisation_uid
        from isanteplus.patient pa, isanteplus.patient_dispensing pd, openmrs.encounter enc,
          openmrs.form f, isanteplus.arv_status_loockup asl, isanteplus.tmp_idgen tmp
        where pa.patient_id=pd.patient_id
        AND pd.encounter_id=enc.encounter_id
        AND enc.form_id=f.form_id
        AND pa.arv_status = asl.id
        and pd.next_dispensation_date between date(now()) and date_add(date(now()),interval 7 day)
        AND tmp.identifier = pa.identifier
        AND tmp.program_id = program
      ) pat
    ) AS entities_list
  ) AS instance
) AS instances) AS result;

SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
