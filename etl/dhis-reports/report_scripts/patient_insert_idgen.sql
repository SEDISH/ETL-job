DROP PROCEDURE IF EXISTS patient_insert_idgen;
DELIMITER $$
CREATE PROCEDURE patient_insert_idgen(IN program CHAR(11))
BEGIN

  CREATE TABLE IF NOT EXISTS tmp_idgen (
  id INT AUTO_INCREMENT PRIMARY KEY,
  identifier VARCHAR(32) NOT NULL,
  program_id CHAR(11) NOT NULL,
  program_patient_id CHAR(11),
  UNIQUE KEY program_patient_constraint (program_id, identifier));

  INSERT IGNORE INTO tmp_idgen(identifier, program_id)
  SELECT pat.identifier, program
  FROM isanteplus.patient pat;

  SET SQL_SAFE_UPDATES = 0;
  UPDATE tmp_idgen SET program_patient_id = idgen(identifier, program)
    WHERE program_id = program AND program_patient_id IS NULL;
  SET SQL_SAFE_UPDATES = 1;

END $$
DELIMITER ;
