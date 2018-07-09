DROP PROCEDURE IF EXISTS hivPatientWithoutFirstVisit_event;
DELIMITER $$
CREATE PROCEDURE hivPatientWithoutFirstVisit_event()
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INT UNSIGNED DEFAULT 4294967295;
  DECLARE date_format VARCHAR(60) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'lV4LM75LrPt';

SET SESSION group_concat_max_len = max_group_concat_max_len;

SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
    FROM (
      SELECT DISTINCT JSON_OBJECT (
        "program", program,
        "programStage", "DKSmlrXzuUX",
        "orgUnit", distinct_entity.organisation_uid,
        "eventDate", distinct_entity.last_date,
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
            "value", distinct_entity.last_date
          )
        )
      ) AS track_entity
      FROM (SELECT p.identifier, p.st_id, p.national_id, p.given_name, p.family_name,
              MAX(DATE(enc.encounter_datetime)) AS last_date, p.organisation_uid, tmp.program_patient_id
            FROM isanteplus.patient p, openmrs.encounter enc, openmrs.encounter_type entype, isanteplus.tmp_idgen tmp
            WHERE p.patient_id=enc.patient_id
            AND enc.encounter_type=entype.encounter_type_id
            AND p.vih_status=1
            AND p.patient_id NOT IN (
              SELECT enco.patient_id
              FROM openmrs.encounter enco, openmrs.encounter_type enct
              WHERE enco.encounter_type=enct.encounter_type_id
              AND enct.uuid IN ('17536ba6-dd7c-4f58-8014-08c7cb798ac7',
                '349ae0b4-65c1-4122-aa06-480f186c8350')
              )
            AND tmp.identifier = p.identifier
            AND tmp.program_id = program
            GROUP BY p.patient_id) AS distinct_entity
    ) AS entities_list
  ) AS instance
) AS instances) AS result;

SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
