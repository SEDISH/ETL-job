-- Dasboar report
DROP PROCEDURE IF EXISTS dashboard_event;
DELIMITER $$
CREATE PROCEDURE dashboard_event()
BEGIN
  DECLARE default_group_concat_max_len INTEGER DEFAULT 1024;
  DECLARE max_group_concat_max_len INT UNSIGNED DEFAULT 4294967295;
  DECLARE date_format VARCHAR(255) DEFAULT '%Y-%m-%d';
  DECLARE program CHAR(11) DEFAULT 'Q7pD6QSyVwF';

  SET SESSION group_concat_max_len = max_group_concat_max_len;

  SELECT (SELECT CONCAT( "{\"events\": ", instances.entity_instance, "}")
  FROM (SELECT CONCAT('[', instance.array, ']') as entity_instance
    FROM (SELECT GROUP_CONCAT(entities_list.tracked_entity SEPARATOR ',') AS array
      FROM (
        SELECT DISTINCT JSON_OBJECT (
          "program", program,
          "programStage", "zqbLP5kJWAf",
          "orgUnit", distinct_entity.organisation_uid,
          "eventDate", DATE_FORMAT(NOW(), date_format),
          "status", "COMPLETED",
          "storedBy", "admin",
          "trackedEntityInstance", distinct_entity.program_patient_id,
          "dataValues", JSON_ARRAY(
            JSON_OBJECT(
              "dataElement", "ND6F3M2VfBW", -- Date de premiere utilisation
              "value", distinct_entity.oldestDate
            ),
            JSON_OBJECT(
              "dataElement", "VWKw28B6LDB", -- Date de saisie la plus récente
              "value", distinct_entity.latestDate
            ),
            JSON_OBJECT(
              "dataElement", "ziEdMTsddYv", -- Sous TAR- Régulier (A)
              "value", distinct_entity.onHaart_regular_adult
            ),
            JSON_OBJECT(
              "dataElement", "n0wrx5yvjhz", -- Sous TAR- Régulier (E)
              "value", distinct_entity.onHaart_regular_child
            ),
            JSON_OBJECT(
              "dataElement", "QFjqA8SSmDG", -- Sous TAR- Rendez-vous ratés (A)
              "value", distinct_entity.onHaart_missingAppointment_adult
            ),
            JSON_OBJECT(
              "dataElement", "tUWg18xVIJw", -- Sous TAR- Rendez-vous ratés (E)
              "value", distinct_entity.onHaart_missingAppointment_child
            ),
            JSON_OBJECT(
              "dataElement", "YxfC3gJjEKL", -- Sous TAR- Perdus de vue (A)
              "value", distinct_entity.onHaart_lostToFollowUp_adult
            ),
            JSON_OBJECT(
              "dataElement", "NE4xBXQnJFL", -- Sous TAR- Perdus de vue (E)
              "value", distinct_entity.onHaart_lostToFollowUp_child
            ),
            JSON_OBJECT(
              "dataElement", "Dp95xn5tNRJ", -- Sous TAR- Arrêtés (A)
              "value", distinct_entity.onHaart_stopped_adult
            ),
            JSON_OBJECT(
              "dataElement", "fDkWpV6cChZ", -- Sous TAR- Arrêtés (E)
              "value", distinct_entity.onHaart_stopped_child
            ),
            JSON_OBJECT(
              "dataElement", "hGzxULO6mJF", -- Sous TAR- Transférés (A)
              "value", distinct_entity.onHaart_transfert_adult
            ),
            JSON_OBJECT(
              "dataElement", "IGke2nIqdLh", -- Sous TAR- Transférés (E)
              "value", distinct_entity.onHaart_transfert_child
            ),
            JSON_OBJECT(
              "dataElement", "oRwcSJlTsKN", -- Sous TAR- Décédés (A)
              "value", distinct_entity.onHaart_deathOnART_adult
            ),
            JSON_OBJECT(
              "dataElement", "T9PnBDmDZX7", -- Sous TAR- Décédés (E)
              "value", distinct_entity.onHaart_deathOnART_child
            ),
            JSON_OBJECT(
              "dataElement", "LfAIOup2d53", -- Sous TAR- Total (A)
              "value", distinct_entity.onHaart_total_adult
            ),
            JSON_OBJECT(
              "dataElement", "E8ik2ULn2TG", -- Sous TAR- Total (E)
              "value", distinct_entity.onHaart_total_child
            ),
            JSON_OBJECT(
              "dataElement", "RdYT0Nwql3b", -- Soins palliatifs- Récent (A)
              "value", distinct_entity.palliativeCare_recentOnPreART_adult
            ),
            JSON_OBJECT(
              "dataElement", "SW4OEVnqfI2", -- Soins palliatifs- Récent (E)
              "value", distinct_entity.palliativeCare_recentOnPreART_child
            ),
            JSON_OBJECT(
              "dataElement", "d6ja5ppe3Oi", -- Soins palliatifs- Aclifs (A)
              "value", distinct_entity.palliativeCare_actifOnPreART_adult
            ),
            JSON_OBJECT(
              "dataElement", "EypHsUYAnjp", -- Soins palliatifs- Aclifs (E)
              "value", distinct_entity.palliativeCare_actifOnPreART_child
            ),
            JSON_OBJECT(
              "dataElement", "EXAbB6XEx1Q", -- Soins palliatifs- Perdus de vue (A)
              "value", distinct_entity.palliativeCare_lostToFollowUpOnPreART_adult
            ),
            JSON_OBJECT(
              "dataElement", "Pwi8q3LyPWX", -- Soins palliatifs- Perdus de vue (E)
              "value", distinct_entity.palliativeCare_lostToFollowUpOnPreART_child
            ),
            JSON_OBJECT(
              "dataElement", "JyskwHdAeza", -- Soins palliatifs- Transférés (A)
              "value", distinct_entity.palliativeCare_transferredOnPreART_adult
            ),
            JSON_OBJECT(
              "dataElement", "muOn5QhPaes", -- Soins palliatifs- Transférés (E)
              "value", distinct_entity.palliativeCare_transferredOnPreART_child
            ),
            JSON_OBJECT(
              "dataElement", "LTBzoetD0B3", -- Soins palliatifs- Décédés (A)
              "value", distinct_entity.palliativeCare_deathOnPreART_adult
            ),
            JSON_OBJECT(
              "dataElement", "XqqwIa5Nb3Q", -- Soins palliatifs- Décédés (E)
              "value", distinct_entity.palliativeCare_deathOnPreART_child
            ),
            JSON_OBJECT(
              "dataElement", "ezQKAXSK7tH", -- Soins palliatifs- Total (A)
              "value", distinct_entity.palliativeCare_total_adult
            ),
            JSON_OBJECT(
              "dataElement", "VkgUH1XFJho", -- Soins palliatifs- Total (E)
              "value", distinct_entity.palliativeCare_total_child
            ),
            JSON_OBJECT(
              "dataElement", "l4aryW8O1kR", -- Totaux généraux
              "value", distinct_entity.grandTotal
            ),
            JSON_OBJECT(
              "dataElement", "VfSDy2CH6kX", -- Version
              "value", distinct_entity.value_reference
            )
          )
        ) AS tracked_entity
        FROM (SELECT p.location_id, tmp.program_patient_id, dates.oldestDate, dates.latestDate, p.organisation_uid,
            COUNT(
            DISTINCT CASE WHEN ( -- Réguliers (actifs sous ARV)
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE id_status = 6 AND AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_regular_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Réguliers (actifs sous ARV)
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE id_status = 6 AND AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_regular_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Rendez-vous ratés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE id_status = 8 AND AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_missingAppointment_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Rendez-vous ratés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE id_status = 8 AND AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_missingAppointment_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Perdus de vue
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE id_status = 9 AND AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_lostToFollowUp_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Perdus de vue
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE id_status = 9 AND AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_lostToFollowUp_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Arrêtés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE id_status = 2 AND AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_stopped_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Arrêtés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE id_status = 2 AND AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_stopped_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Transférés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE id_status = 3 AND AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_transfert_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Transférés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE id_status = 3 AND AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_transfert_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Décédés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE id_status = 1 AND AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_deathOnART_adult,
             COUNT(
            DISTINCT CASE WHEN ( -- Décédés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE id_status = 1 AND AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_deathOnART_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Sous TAR- Total (A)
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart WHERE AC = 'A'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_total_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Sous TAR- Total (E)
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_haart
                        WHERE AC = 'C'
              )
                ) THEN p.patient_id ELSE null END
            ) AS onHaart_total_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Récents Pré-ARV
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 7 AND AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_recentOnPreART_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Récents Pré-ARV
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 7 AND AC = 'C'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_recentOnPreART_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Actifs en Pré-ARV
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 11 AND AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_actifOnPreART_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Actifs en Pré-ARV
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 11 AND AC = 'C'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_actifOnPreART_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Perdus de vue
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 9 AND AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_lostToFollowUpOnPreART_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Perdus de vue
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 9 AND AC = 'C'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_lostToFollowUpOnPreART_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Transférés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 3 AND AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_transferredOnPreART_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Transférés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 3 AND AC = 'C'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_transferredOnPreART_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Décédés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 1 AND AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_deathOnPreART_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Décédés
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE id_status = 1 AND AC = 'C'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_deathOnPreART_child,
            COUNT(
            DISTINCT CASE WHEN ( -- Soins palliatifs- Total (A)
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_total_adult,
            COUNT(
            DISTINCT CASE WHEN ( -- Soins palliatifs- Total (E)
              p.patient_id IN (
                SELECT patient_id
                        FROM p_on_palliative_care
                        WHERE AC = 'A'
                    )
                ) THEN p.patient_id ELSE null END
            ) AS palliativeCare_total_child,
            COUNT(p.patient_id) AS grandTotal, -- Totaux généraux
            version.value_reference -- Version
          FROM isanteplus.tmp_idgen tmp,
            ( SELECT location_id, 
				CASE
					WHEN MIN(date_created) < DATE('2005-04-08') OR MIN(date_created) > CURDATE() THEN DATE('2005-04-08')
					ELSE MIN(date_created)
				END AS oldestDate, 
				MAX(date_created) latestDate
              FROM `openmrs`.encounter
              GROUP BY location_id ) AS dates,
            patient p
            LEFT OUTER JOIN ( SELECT l.location_id, l.value_reference
                              FROM `openmrs`.location_attribute l, `openmrs`.location_attribute_type a
                              WHERE l.attribute_type_id = a.location_attribute_type_id
                              AND a.uuid = '26dd75b4-31cb-44af-96e9-76844a31ab32' ) AS version
            ON version.location_id = p.location_id
          WHERE tmp.identifier = p.identifier
          AND tmp.program_id = program
          AND dates.location_id = p.location_id
          GROUP BY p.location_id
        ) AS distinct_entity
      ) AS entities_list
    ) AS instance
  ) AS instances) AS result;

  SET SESSION group_concat_max_len = default_group_concat_max_len;

END $$
DELIMITER ;
