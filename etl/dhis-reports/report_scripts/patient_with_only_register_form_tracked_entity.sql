-- Patient with only a register form
DROP PROCEDURE IF EXISTS patient_with_only_register_form_tracked_entity;
DELIMITER $$
CREATE PROCEDURE patient_with_only_register_form_tracked_entity()
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INT UNSIGNED DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'Lh9TkmcZf4a';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  CALL patient_insert_idgen(program);

  SELECT (SELECT CONCAT( "{\"trackedEntityInstances\": ", instances.entity_instance, "}")
  FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
    FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
      FROM (
        SELECT JSON_OBJECT (
          "trackedEntity", "MCPQUTHX1Ze",
          "trackedEntityInstance", distinct_entity.program_patient_id,
          "orgUnit", distinct_entity.organisation_uid,
          "attributes", JSON_ARRAY(
            JSON_OBJECT(
              "attribute", "py0TvSTBlrr",
              "value", distinct_entity.family_name
              ),
            JSON_OBJECT(
              "attribute", "uWUIkGpSMa6",
              "value", distinct_entity.given_name
              ),
            JSON_OBJECT(
              "attribute", "Cn9LcaW7Orr",
              "value", distinct_entity.identifier
              )
            ),
          "enrollments", JSON_ARRAY(
            JSON_OBJECT(
              "orgUnit", distinct_entity.organisation_uid,
              "program", program,
              "enrollmentDate", DATE_FORMAT(DATE(NOW()), date_format),
              "incidentDate", DATE_FORMAT(DATE(NOW()), date_format)
              )
            )
          ) AS track_entity
        FROM (
              SELECT DISTINCT p.st_id, p.national_id, p.family_name, p.identifier,
                p.given_name, DATE(enc.encounter_datetime) AS last_date,
                tmp.program_patient_id, p.organisation_uid
              FROM isanteplus.patient p, openmrs.encounter enc,
                openmrs.encounter_type entype, isanteplus.tmp_idgen tmp
              WHERE p.patient_id=enc.patient_id
              AND enc.encounter_type=entype.encounter_type_id
              AND entype.uuid='873f968a-73a8-4f9c-ac78-9f4778b751b6'
              AND enc.encounter_id=(SELECT MAX(en.encounter_id) FROM openmrs.encounter en)
              AND tmp.identifier = p.identifier
              AND tmp.program_id = program
            ) AS distinct_entity
      ) AS entities_list
    ) AS instance
  ) AS instances) AS result;

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
