DROP PROCEDURE IF EXISTS dashboard_etl_extension;
DELIMITER $$
CREATE PROCEDURE dashboard_etl_extension()
BEGIN

  CREATE TABLE IF NOT EXISTS p_on_haart (
    patient_id INT(11) NOT NULL,
    id_status INT(11) NOT NULL,
    ac CHAR(1)
  );

  INSERT IGNORE INTO p_on_haart (patient_id, id_status, ac)
    SELECT p.patient_id, psa.id_status,
      CASE WHEN (YEAR(NOW()) - YEAR(p.birthdate) < 14)
        THEN 'C' -- child
          ELSE 'A' -- adult
      END
    FROM patient p
    LEFT JOIN patient_status_arv psa
    ON p.patient_id = psa.patient_id
    WHERE psa.patient_id IN (
      SELECT pd.patient_id
      FROM patient_dispensing pd
      GROUP BY pd.patient_id
      HAVING count(*) >= 3);

  CREATE TABLE IF NOT EXISTS p_on_palliative_care (
    patient_id INT(11) NOT NULL,
    id_status INT(11) NOT NULL,
    ac CHAR(1)
  );

  INSERT IGNORE INTO p_on_palliative_care (patient_id, id_status, ac)
    SELECT p.patient_id, psa.id_status,
      CASE WHEN (YEAR(NOW()) - YEAR(p.birthdate) < 14)
        THEN 'C' -- child
          ELSE 'A' -- adult
      END
    FROM patient p
    LEFT JOIN patient_status_arv psa
    ON p.patient_id = psa.patient_id
    WHERE psa.patient_id IN (
      SELECT pd.patient_id
      FROM patient_dispensing pd
      GROUP BY pd.patient_id
      HAVING count(*) < 3
    );

END $$
DELIMITER ;
