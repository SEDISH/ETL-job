DROP PROCEDURE IF EXISTS hivPatientWithoutFirstVisit_tracked_entity;
DELIMITER $$
CREATE PROCEDURE hivPatientWithoutFirstVisit_tracked_entity()
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INT UNSIGNED DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'lV4LM75LrPt';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  CALL patient_insert_idgen(program);

  SELECT (SELECT CONCAT( "{\"trackedEntityInstances\": ", instances.entity_instance, "}")
  FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
    FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
      FROM (
        SELECT DISTINCT JSON_OBJECT (
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
