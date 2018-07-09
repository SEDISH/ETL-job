-- HIV patient with activity after discontinuation
DROP PROCEDURE IF EXISTS hiv_patient_with_activity_after_disc_event;
DELIMITER $$
CREATE PROCEDURE hiv_patient_with_activity_after_disc_event()
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INT UNSIGNED DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'mfyC6GCw1IH';
  DECLARE default_uuid CHAR(36) DEFAULT '9d0113c6-f23a-4461-8428-7e9a7344f2ba';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
  FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
    FROM (SELECT GROUP_CONCAT(entities_list.tracked_entity SEPARATOR ',') AS array
      FROM (
        SELECT DISTINCT JSON_OBJECT (
          "program", program,
          "programStage", "rN1j8bJNlev",
          "orgUnit", distinct_entity.organisation_uid,
          "eventDate", DATE_FORMAT(distinct_entity.discontinuation_date, date_format),
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
              "dataElement", "FVRCqcG8gZs", -- Date de discontinuation
              "value", DATE_FORMAT(distinct_entity.discontinuation_date, date_format)
            ),
            JSON_OBJECT(
              "dataElement", "ofp7LiAyMsW", -- Dernière date
              "value", DATE_FORMAT(distinct_entity.last_date, date_format)
            ),
            JSON_OBJECT(
              "dataElement", "LxhqdExyea0", -- Name
              "value", distinct_entity.name
            )
          )
        ) AS tracked_entity
        FROM (SELECT DISTINCT p.identifier, p.st_id, p.national_id, p.family_name, p.given_name,
                MAX(DATE(en.encounter_datetime)) as discontinuation_date, entype.name,
                MAX(DATE(enc.encounter_datetime)) as last_date, tmp.program_patient_id, p.organisation_uid
              FROM isanteplus.patient p, openmrs.encounter enc, openmrs.encounter_type entype, openmrs.encounter en,
                  isanteplus.tmp_idgen tmp
              WHERE p.patient_id = enc.patient_id
              AND enc.encounter_type = entype.encounter_type_id
              AND enc.patient_id = en.patient_id
              AND p.vih_status = 1
              AND en.encounter_type = (SELECT enct.encounter_type_id FROM openmrs.encounter_type enct
                                        WHERE uuid = default_uuid)
              AND DATE(enc.encounter_datetime) > DATE(en.encounter_datetime)
              AND tmp.identifier = p.identifier
              AND tmp.program_id = program
              GROUP BY p.patient_id) AS distinct_entity
      ) AS entities_list
    ) AS instance
  ) AS instances) AS result;

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
