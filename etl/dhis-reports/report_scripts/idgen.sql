DROP FUNCTION IF EXISTS idgen;
DELIMITER $$
CREATE FUNCTION idgen(isante_id VARCHAR(32), program CHAR(11)) RETURNS CHAR(11)
BEGIN
  DECLARE tmp_id INTEGER;
  DECLARE length INTEGER;
  DECLARE to_add INTEGER;
  DECLARE result VARCHAR(11);

SET tmp_id = (SELECT id
            FROM tmp_idgen
            WHERE identifier = isante_id
            AND program_id = program);

SET result = CONCAT('', tmp_id);
SET length = (SELECT LENGTH(result));

SET to_add = 10 - length;

WHILE to_add > 0 DO
  SET result = CONCAT('0', result);
  SET to_add = to_add - 1;
END WHILE;

SET result = CONCAT('R', result);

RETURN result;

END $$
DELIMITER ;
