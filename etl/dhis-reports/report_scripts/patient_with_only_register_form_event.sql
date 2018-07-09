-- Patient with only a register form
DROP PROCEDURE IF EXISTS patient_with_only_register_form_event;
DELIMITER $$
CREATE PROCEDURE patient_with_only_register_form_event()
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INT UNSIGNED DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'Lh9TkmcZf4a';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
  FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
    FROM (SELECT GROUP_CONCAT(entities_list.tracked_entity SEPARATOR ',') AS array
      FROM (
        SELECT DISTINCT JSON_OBJECT (
          "program", program,
          "programStage", "SSe717ZwYzp",
          "orgUnit", distinct_entity.organisation_uid,
          "eventDate", DATE_FORMAT(distinct_entity.last_date, date_format),
          "status", "COMPLETED",
          "storedBy", "admin",
          "trackedEntityInstance", distinct_entity.program_patient_id,
          "dataValues", JSON_ARRAY(
            JSON_OBJECT(
              "dataElement", "BruXV0FD2XS", -- No. de patient attribué par le site
              "value", distinct_entity.st_id
            ),
            JSON_OBJECT(
              "dataElement", "bzpXF1yVV74", -- No. dentité nationale
              "value", distinct_entity.national_id
            ),
            JSON_OBJECT(
              "dataElement", "ofp7LiAyMsW", -- Dernière date
              "value", DATE_FORMAT(distinct_entity.last_date, date_format)
            )
          )
        ) AS tracked_entity
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
