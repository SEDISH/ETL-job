DROP PROCEDURE IF EXISTS org_unit_etl_extension;
DELIMITER $$
CREATE PROCEDURE org_unit_etl_extension()
BEGIN
  DECLARE attr_type TEXT;

  IF NOT EXISTS ( SELECT NULL
                  FROM INFORMATION_SCHEMA.COLUMNS
                  WHERE table_name = 'patient'
                  AND table_schema = DATABASE()
                  AND column_name = 'organisation_code')  THEN
    ALTER TABLE patient
    ADD COLUMN organisation_code TEXT DEFAULT NULL
    AFTER last_updated_date;
  END IF;

  IF NOT EXISTS ( SELECT NULL
                  FROM INFORMATION_SCHEMA.COLUMNS
                  WHERE table_name = 'patient'
                  AND table_schema = DATABASE()
                  AND column_name = 'organisation_uid')  THEN
    ALTER TABLE patient
    ADD COLUMN organisation_uid VARCHAR(32) DEFAULT NULL
    AFTER last_updated_date;
  END IF;

  SET attr_type = (SELECT location_attribute_type_id
                    FROM `openmrs`.location_attribute_type
                    WHERE uuid = '6242bf19-207e-4076-9d28-9290525b8ed9');

  SET SQL_SAFE_UPDATES = 0;

  UPDATE patient p, `openmrs`.location_attribute loc_attr
  SET organisation_code = loc_attr.value_reference, last_updated_date = NOW()
  WHERE p.location_id = loc_attr.location_id
  AND loc_attr.attribute_type_id = attr_type
  AND organisation_code IS NULL;

  UPDATE patient p, org_code_uid org
  SET p.organisation_uid = org.uid, p.last_updated_date = NOW()
  WHERE org.code IS NOT NULL
  AND organisation_uid IS NULL
  AND p.organisation_code = org.code;

  SET SQL_SAFE_UPDATES = 1;

END $$
DELIMITER ;
