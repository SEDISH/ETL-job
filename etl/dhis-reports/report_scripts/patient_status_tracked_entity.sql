DROP PROCEDURE IF EXISTS patient_status_tracked_entity;
DELIMITER $$
CREATE PROCEDURE patient_status_tracked_entity()
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INT UNSIGNED DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'x2NBbIpHohD';

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
        FROM (SELECT pat.identifier, pat.st_id, pat.national_id, pat.given_name, pat.family_name,
                pat.mother_name, pat.birthdate, pat.gender, DATE_FORMAT(MAX(patstatus.start_date), date_format) AS last_date,
                patstatus.dis_reason, pat.telephone, arv.name_fr, TIMESTAMPDIFF(YEAR, pat.birthdate, DATE(NOW())) AS age,
                pat.organisation_uid, tmp.program_patient_id
              FROM isanteplus.patient pat
              INNER JOIN isanteplus.patient_status_arv patstatus
              ON pat.patient_id=patstatus.patient_id
              INNER JOIN isanteplus.arv_status_loockup arv
              ON patstatus.id_status=arv.id
              INNER JOIN isanteplus.tmp_idgen tmp
              ON tmp.identifier = pat.identifier
              AND tmp.program_id = program
              GROUP BY pat.patient_id) AS distinct_entity
      ) AS entities_list
    ) AS instance
  ) AS instances) AS result;

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
