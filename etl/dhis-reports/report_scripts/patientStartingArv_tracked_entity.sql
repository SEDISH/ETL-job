# List of patients who started an HAART regimen
DROP PROCEDURE IF EXISTS patientStartingArv_tracked_entity;
DELIMITER $$
CREATE PROCEDURE patientStartingArv_tracked_entity()
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INT UNSIGNED DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'ewmeREcqCmN';

SET SESSION group_concat_max_len = max_group_concat_max_len;

CALL patient_insert_idgen(program);

SELECT (SELECT CONCAT( '{\"trackedEntityInstances\": ', instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.tracked_entity SEPARATOR ',') AS array
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
      ) AS tracked_entity
      FROM (SELECT DISTINCT MIN(DATE(pdis.visit_date)) as visit_date, p.national_id, p.given_name,
            p.family_name, p.birthdate, tmp.program_patient_id, p.identifier, p.organisation_uid
            FROM isanteplus.patient p,isanteplus.patient_dispensing pdis, isanteplus.tmp_idgen tmp
            WHERE p.patient_id=pdis.patient_id
            AND pdis.drug_id IN (select arvd.drug_id from isanteplus.arv_drugs arvd)
            AND pdis.visit_date=(SELECT MIN(pdp.visit_date) FROM isanteplus.patient_dispensing pdp WHERE pdp.patient_id=p.patient_id)
            AND tmp.identifier = p.identifier
            AND tmp.program_id = program
            GROUP BY p.patient_id) AS distinct_entity
    ) AS entities_list
  ) AS instance
) AS instances) AS result;

SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
