-- The list of patients whose ARV refill date is expected within the next 30 days.
DROP PROCEDURE IF EXISTS patientNextArvInThirtyDay_event;
DELIMITER $$
CREATE PROCEDURE patientNextArvInThirtyDay_event()
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INT UNSIGNED DEFAULT 4294967295;
  DECLARE date_format VARCHAR(60) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'cBI32y2KeC9';

SET SESSION group_concat_max_len = max_group_concat_max_len;

SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
  FROM (SELECT GROUP_CONCAT(entities_list.track_entity SEPARATOR ',') AS array
    FROM (
      SELECT DISTINCT JSON_OBJECT (
        "program", program,
        "programStage", "yzcSkGEI4qe",
        "orgUnit", distinct_entity.organisation_uid,
        "eventDate", distinct_entity.dispensation_date,
        "status", "COMPLETED",
        "storedBy", "admin",
        "trackedEntityInstance", distinct_entity.program_patient_id,
        "dataValues", JSON_ARRAY(
          JSON_OBJECT(
            "dataElement", "bzpXF1yVV74", -- No. dentité nationale
            "value", distinct_entity.national_id
          ),
          JSON_OBJECT(
            "dataElement", "XY1yClztxCG", -- Date de naissance
            "value", distinct_entity.birthdate
          ),
          JSON_OBJECT(
            "dataElement", "wyq5jC0iOBR", -- Date de dispensation
            "value", distinct_entity.dispensation_date
          ),
          JSON_OBJECT(
            "dataElement", "VT5fvNKFHr7", -- Date Visite
            "value", distinct_entity.visit_date
          )
        )
      ) AS track_entity
      FROM (SELECT p.identifier, p.st_id, p.national_id, p.given_name, p.family_name,
              DATE_FORMAT(p.birthdate, date_format) AS birthdate,
              DATE_FORMAT(pdisp.next_dispensation_date, date_format) AS dispensation_date,
              DATE_FORMAT(pdisp.visit_date, date_format) AS visit_date, p.organisation_uid, tmp.program_patient_id
            FROM isanteplus.patient p, isanteplus.patient_dispensing pdisp,
                (SELECT pad.patient_id, MAX(pad.next_dispensation_date) as next_dispensation_date
                 FROM isanteplus.patient_dispensing pad
                 GROUP BY 1) B,
              isanteplus.tmp_idgen tmp
            WHERE p.patient_id=pdisp.patient_id
            AND pdisp.patient_id = B.patient_id
            AND pdisp.next_dispensation_date = B.next_dispensation_date
            AND p.patient_id NOT IN(SELECT dreason.patient_id
              FROM isanteplus.discontinuation_reason dreason WHERE dreason.reason IN(159,1667,159492))
            AND pdisp.arv_drug = 1065
            AND tmp.identifier = p.identifier
            AND tmp.program_id = program
            AND p.patient_id NOT IN (SELECT ei.patient_id FROM isanteplus.exposed_infants ei)
            AND pdisp.drug_id NOT IN (SELECT pp.drug_id
                                      FROM isanteplus.patient_prescription pp
                                      WHERE pp.patient_id = pdisp.patient_id
                                      AND pp.encounter_id = pdisp.encounter_id
                                      AND pp.drug_id = pdisp.drug_id
                                      AND pp.rx_or_prophy = 163768)
            AND DATEDIFF(pdisp.next_dispensation_date,now()) between 0 and 30
            ) AS distinct_entity
    ) AS entities_list
  ) AS instance
) AS instances) AS result;

SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
