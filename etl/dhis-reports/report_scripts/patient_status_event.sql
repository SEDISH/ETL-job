DROP PROCEDURE IF EXISTS patient_status_event;
DELIMITER $$
CREATE PROCEDURE patient_status_event()
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INT UNSIGNED DEFAULT 4294967295;
  DECLARE date_format VARCHAR(60) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'x2NBbIpHohD';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
  FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
    FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
      FROM (
        SELECT JSON_OBJECT (
          "program", program,
          "programStage", "ROWwGepZ2yb",
          "orgUnit", distinct_entity.organisation_uid,
          "eventDate", distinct_entity.last_date,
          "status", "COMPLETED",
          "storedBy", "admin",
          "trackedEntityInstance", distinct_entity.program_patient_id,
          "dataValues", JSON_ARRAY(
            JSON_OBJECT(
              "dataElement", "EhQ157ZZMny", -- Contact
              "value", distinct_entity.mother_name
              ),
            JSON_OBJECT(
              "dataElement", "uSSFtn7oU2n", -- Age
              "value", distinct_entity.age
              ),
            JSON_OBJECT(
              "dataElement", "ofp7LiAyMsW", -- Dernière date
              "value", distinct_entity.last_date
              ),
            JSON_OBJECT(
              "dataElement", "vHkw3Habii4", -- Gender
              "value", distinct_entity.gender
              ),
            JSON_OBJECT(
              "dataElement", "BruXV0FD2XS", -- No. de patient attribué par le site
              "value", distinct_entity.st_id
              ),
            JSON_OBJECT(
              "dataElement", "bzpXF1yVV74", -- No. dentité nationale
              "value", distinct_entity.national_id
              ),
            JSON_OBJECT(
              "dataElement", "BaofPATSdwD", -- Raison de discontinuation
              "value",  CASE
                          WHEN (distinct_entity.dis_reason=5240) THEN 'Perdu de vue'
                          WHEN (distinct_entity.dis_reason=159492) THEN 'Transfert'
                          WHEN (distinct_entity.dis_reason=159) THEN 'Décès'
                          WHEN (distinct_entity.dis_reason=1667) THEN 'Discontinuations'
                          WHEN (distinct_entity.dis_reason=1067) THEN 'Inconnue'
                        END
              ),
            JSON_OBJECT(
              "dataElement", "uliVoL9otho", -- Telephone
              "value", distinct_entity.telephone
              ),
            JSON_OBJECT(
              "dataElement", "ZffT4ZES0dI", -- Status de patient
              "value", distinct_entity.name_fr
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
