DROP PROCEDURE IF EXISTS consultationByDay_event;
DELIMITER $$
CREATE PROCEDURE consultationByDay_event()
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INT UNSIGNED DEFAULT 4294967295;
  DECLARE date_format VARCHAR(60) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'Rnvvg6utP5O';

SET SESSION group_concat_max_len = max_group_concat_max_len;

SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
    FROM (
      SELECT DISTINCT JSON_OBJECT (
        "program", program,
        "programStage", "ev25AqGJkAk",
        "orgUnit", distinct_entity.organisation_uid,
        "eventDate", distinct_entity.event_date,
        "status", "COMPLETED",
        "storedBy", "admin",
        "trackedEntityInstance", distinct_entity.program_patient_id,
        "dataValues", JSON_ARRAY(
          JSON_OBJECT(
            "dataElement", "IlvC79PC18X", -- Form
            "value", distinct_entity.name
          ),
          JSON_OBJECT(
            "dataElement", "qji8c53o8ST", -- Patient VIH
            "value",  CASE
                        WHEN distinct_entity.vih_status=1 THEN 'true'
                        WHEN distinct_entity.vih_status=0 THEN 'false'
                      END
          )
        )
      ) AS track_entity
      FROM (SELECT DISTINCT pat.identifier, pat.st_id, pat.national_id, pat.family_name, pat.given_name,
              enct.name, pat.vih_status,  DATE_FORMAT(DATE(patvi.date_started), date_format) AS event_date,
              tmp.program_patient_id, pat.organisation_uid
            FROM isanteplus.patient pat, openmrs.visit patvi, openmrs.location loc,
              openmrs.encounter enc, isanteplus.tmp_idgen tmp, openmrs.encounter_type enct
            WHERE pat.patient_id=patvi.patient_id
            AND patvi.visit_id=enc.visit_id
            AND enc.location_id=loc.location_id
            AND enc.encounter_type=enct.encounter_type_id
            AND tmp.identifier = pat.identifier
            AND tmp.program_id = program) AS distinct_entity
    ) AS entities_list
  ) AS instance
) AS instances) AS result;

SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
