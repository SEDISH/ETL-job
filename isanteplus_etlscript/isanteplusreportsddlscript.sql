DROP DATABASE if exists isanteplus;
create database if not exists isanteplus;
SET GLOBAL event_scheduler = 1 ;
use isanteplus;
CREATE TABLE if not exists `patient` (
  `identifier` varchar(50) DEFAULT NULL,
  `st_id` varchar(50) DEFAULT NULL,
  `national_id` varchar(50) DEFAULT NULL,
  `patient_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `given_name` longtext,
  `family_name` longtext,
  `gender` varchar(10) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `telephone` varchar(50) DEFAULT NULL,
  `last_address` longtext,
  `degree` longtext,
  `vih_status` int(11) DEFAULT 0,
  `arv_status` int(11),
  `mother_name` longtext,
  `occupation` int(11),
  `maritalStatus` int(11),
  `place_of_birth` longtext,
  `creator` varchar(20) DEFAULT NULL,
  `date_created` date DEFAULT NULL,
  `death_date` date DEFAULT NULL,
  `cause_of_death` longtext,
  `first_visit_date` DATETIME,
  `last_visit_date` DATETIME,
  `date_started_arv` DATETIME,
  `next_visit_date` DATE,
  `last_inserted_date` datetime DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  PRIMARY KEY (`patient_id`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `patient_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES openmrs.`location`(`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE  if not exists `patient_visit` (
  `visit_date` date DEFAULT NULL,
  `visit_id` int(11),
  `encounter_id` int(11),
  `location_id` int(11),
  `patient_id` int(11),
  `start_date` date DEFAULT NULL,
  `stop_date` date DEFAULT NULL,
  `creator` varchar(20) DEFAULT NULL,
  `encounter_type` int(11) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `next_visit_date` date DEFAULT NULL,
  `last_insert_date` date DEFAULT NULL,
  KEY `location_id` (`location_id`),
  KEY `form_id` (`form_id`),
  KEY `patient_id` (`patient_id`),
  KEY `visit_id` (`visit_id`),
  KEY `patient_visit_ibfk_3_idx` (`patient_id`),
  CONSTRAINT `pk_visit` PRIMARY KEY(patient_id, encounter_id, location_id),
  CONSTRAINT `patient_visit_ibfk_3` FOREIGN KEY (`patient_id`) REFERENCES openmrs.`patient`(`patient_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `patient_visit_ibfk_2` FOREIGN KEY (`form_id`) REFERENCES openmrs.`form`(`form_id`),
  CONSTRAINT `patient_visit_ibfk_4` FOREIGN KEY (`location_id`) REFERENCES openmrs.`location`(`location_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Debut etl for tb reports*/

CREATE TABLE IF NOT EXISTS patient_tb_diagnosis (
	patient_id int(11) not null,
	provider_id int(11),
	location_id int(11),
	visit_id int(11),
	visit_date Datetime,
	encounter_id INT(11) not null,
	tb_diag int(11),
	mdr_tb_diag int(11),
	tb_new_diag int(11),
	tb_follow_up_diag int(11),
	cough_for_2wks_or_more INT(11),
	tb_treatment_start_date DATE,
	status_tb_treatment INT(11) default 0,
	/*statuts_tb_treatment = Gueri(1),traitement_termine(2),
		Abandon(3),tranfere(4),decede(5)
	*/
	tb_treatment_stop_date DATE,
	PRIMARY KEY (`encounter_id`,location_id),
	CONSTRAINT FOREIGN KEY (patient_id) REFERENCES isanteplus.patient(patient_id),
	INDEX(visit_date),
	INDEX(encounter_id),
	INDEX(patient_id)
);
/*Table patient_dispensing for all drugs from the form ordonance medical*/

CREATE TABLE IF NOT EXISTS patient_dispensing (
	patient_id int(11) not null,
	visit_id int(11),
	location_id int(11),
	visit_date Datetime,
	encounter_id int(11) not null,
	provider_id int(11),
	drug_id int(11) not null,
	dose_day int(11),
	pills_amount int(11),
	dispensation_date date,
	next_dispensation_date Date,
	dispensation_location int(11) default 0,
	arv_drug int(11) default 1066, /*1066=No, 1065=YES*/
	CONSTRAINT pk_patient_dispensing PRIMARY KEY(encounter_id,location_id,drug_id),
    /*CONSTRAINT FOREIGN KEY (patient_id) REFERENCES isanteplus.patient(patient_id),*/
	INDEX(visit_date),
	INDEX(encounter_id),
	INDEX(patient_id)
);
/*Table patient_imagerie*/

CREATE TABLE IF NOT EXISTS patient_imagerie (
	patient_id int(11) not null,
	location_id int(11),
	visit_id int(11) not null,
	encounter_id int(11) not null,
	visit_date Datetime,
	radiographie_pul int(11) default 0,
	radiographie_autre int(11),
	crachat_barr int(11),
	PRIMARY KEY (`location_id`,`encounter_id`),
	CONSTRAINT FOREIGN KEY (patient_id) REFERENCES isanteplus.patient(patient_id),
	INDEX(visit_date),
	INDEX(encounter_id),
	INDEX(patient_id)
);
/*Table that contains all the arv drugs*/
DROP TABLE if exists `arv_drugs`;
CREATE TABLE IF NOT EXISTS arv_drugs(
	id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
	drug_id INT(11) NOT NULL UNIQUE,
	drug_name longtext NOT NULL,
	date_inserted DATE NOT NULL
);
TRUNCATE TABLE arv_drugs;
INSERT INTO arv_drugs(drug_id,drug_name,date_inserted)
VALUES(70056,'Abacavir(ABC)', DATE(now())),
	  (630,'Combivir(AZT+3TC)', DATE(now())),
	  (74807,'Didanosine(ddI)', DATE(now())),
	  (75628,'Emtricitabine(FTC)', DATE(now())),
	  (78643,'Lamivudine(3TC)', DATE(now())),
	  (84309,'Stavudine(d4T)', DATE(now())),
	  (84795,'Tenofovir(TDF)', DATE(now())),
	  (817,'Trizivir(ABC+AZT+3TC)', DATE(now())),
	  (86663,'Zidovudine(AZT)', DATE(now())),
	  (75523,'Efavirenz(EFV)', DATE(now())),
	  (80586,'Nevirapine(NVP)', DATE(now())),
	  (71647,'Atazanavir(ATV)', DATE(now())),
	  (159809,'Atazanavir+BostRTV', DATE(now())),
	  (77995,'Indinavir(IDV)', DATE(now())),
	  (794,'Lopinavir + BostRTV(Kaletra)', DATE(now())),
	  (74258,'Darunavir', DATE(now())),
	  (154378,'Raltegravir', DATE(now()));

/*Table that contains the labels of ARV status*/
DROP TABLE IF EXISTS arv_status_loockup;
	CREATE TABLE IF NOT EXISTS arv_status_loockup(
	id int primary key auto_increment,
	name_en varchar(50),
	name_fr varchar(50),
	definition longtext,
	insertDate date);

	insert into arv_status_loockup values
	(1,'Death on ART','Décédés','Tout patient mis sous ARV et ayant un rapport d’arrêt rempli pour motif de décès',date(now())),
	(2,'Stopped','Arrêtés','Tout patient mis sous ARV et ayant un rapport d’arrêt rempli pour motif d’arrêt de traitement',date(now())),
	(3,'Transfert','Transférés','Tout patient mis sous ARV et ayant un rapport d’arrêt rempli pour motif de transfert',date(now())),
	(4,'Death on PRE-ART','Décédés en Pré-ARV',' Tout patient VIH+ non encore mis sous ARV ayant un rapport d’arrêt rempli pour cause de décès',date(now())),
	(5,'Transferred on PRE-ART','Transférés en Pré-ARV','Tout patient VIH+ non encore mis sous ARV ayant un rapport d’arrêt rempli pour cause de transfert',date(now())),
	(6,'Regular','Réguliers (actifs sous ARV)','Tout patient mis sous ARV et n’ayant aucun rapport d’arrêt rempli pour motifs de décès, de transfert, ni d’arrêt de traitement. La date de prochain rendez-vous clinique ou de prochaine collecte de médicaments est située dans le futur de la période d’analyse. (Fiches à ne pas considérer, labo et counseling)',date(now())),
	(7,'Recent on PRE-ART','Récents en Pré-ARV','Tout patient VIH+ non encore mis sous ARV ayant eu sa première visite (clinique « 1re visite VIH» ) au cours des 12 derniers mois tout en excluant tout patient ayant un rapport d’arrêt avec motifs décédé ou transféré',date(now())),
	(8,'Missing appointment','Rendez-vous ratés','Tout patient mis sous ARV et n’ayant aucun rapport d’arrêt rempli pour motifs de décès, de transfert, ni d’arrêt de traitement. La date de la période d’analyse est supérieure à la date de rendez-vous clinique ou de collecte de médicaments la plus récente sans excéder 90 jours',date(now())),
	(9,'Lost to follow-up','Perdus de vue','Tout patient mis sous ARV et n’ayant aucun rapport d’arrêt rempli pour motifs de décès, de transfert, ni d’arrêt de traitement. La date de la période d’analyse est supérieure à la date de rendez-vous clinique ou de collecte de médicaments la plus récente de plus de 90 jours',date(now())),
	(10,'Lost to follow-up on PRE-ART','Perdus de vue en Pré-ARV','Tout patient VIH+ non encore mis sous ARV n’ayant eu aucune visite (clinique « 1re visite VIH et suivi VIH uniquement », pharmacie, labo) au cours des 12 derniers mois et n’étant ni décédé ni transféré',date(now())),
	(11,'Actif on Pre-ART','Actifs en Pré-ARV','Tout patient VIH+ non encore mis sous ARV et ayant eu une visite (clinique de suivi VIH uniquement, ou de pharmacie ou de labo) au cours des 12 derniers mois et n’étant ni décédé ni transféré',date(now())),
	(12,'ongoing','En cours','La somme des patients sous ARV réguliers et ceux ayant raté leurs rendez-vous',date(now()));
 /*Table that contains all patients on ARV*/
	DROP TABLE IF EXISTS patient_on_arv;
	create table if not exists patient_on_arv(
	id int primary key auto_increment,
	patient_id int(11),
	visit_id int(11),
	visit_date date);
	/*Create a index for patient_id on patient_on_arv table*/
	create index patient_id_on_arv_index on patient_on_arv (patient_id);
/*Table for all patients with reason of discontinuation
Perte de contact avec le patient depuis plus de trois mois = 5240
Transfert vers un autre établissement=159492
Décès=159
Discontinuations=1667
Raison d'arrêt inconnue=1067
*/
 DROP TABLE IF EXISTS discontinuation_reason;
	create table if not exists discontinuation_reason(
	patient_id int(11),
	visit_id int(11),
	visit_date date,
	reason int(11),
	reason_name longtext,
	CONSTRAINT pk_dreason PRIMARY KEY (patient_id,visit_id,reason)
	);
/*Create a table for raison arretés concept_id = 1667,
		answer_concept_id IN (1754,160415,115198,159737,5622)
		That table allow us to delete from the table discontinuation_reason
		WHERE the discontinuation_raison (arretés raison) not in Adhérence inadéquate=115198
		AND Préférence du patient=159737
		*/
	DROP TABLE IF EXISTS stopping_reason;
	create table if not exists stopping_reason(
	patient_id int(11),
	visit_id int(11),
	visit_date date,
	reason int(11),
	reason_name longtext,
	other_reason longtext,
	CONSTRAINT pk_stop_reason PRIMARY KEY (patient_id,visit_id,reason)
	);
/*Table patient_status_ARV contains all patients and their status*/
	DROP TABLE IF EXISTS patient_status_arv;
	create table if not exists patient_status_arv(
	patient_id int(11),
	id_status int,
	start_date date,
	end_date date,
	dis_reason int(11)
	);

/*Create table for medicaments prescrits*/
DROP TABLE IF EXISTS patient_prescription;
CREATE TABLE IF NOT EXISTS patient_prescription (
	patient_id int(11) not null,
	visit_id int(11),
	location_id int(11),
	visit_date Datetime,
	encounter_id int(11) not null,
	provider_id int(11),
	drug_id int(11) not null,
	rx_or_prophy int(11),
    posology text,
    number_day int(11),
	CONSTRAINT pk_patient_dispensing PRIMARY KEY(encounter_id,location_id,drug_id),
    /*CONSTRAINT FOREIGN KEY (patient_id) REFERENCES isanteplus.patient(patient_id),*/
	INDEX(visit_date),
	INDEX(encounter_id),
	INDEX(patient_id)
);

 /*Create table for lab*/
	DROP TABLE IF EXISTS patient_laboratory;
	CREATE TABLE IF NOT EXISTS patient_laboratory(
		patient_id int(11) not null,
		visit_id int(11),
		location_id int(11),
		visit_date Datetime,
		encounter_id int(11) not null,
		provider_id int(11),
		test_id int(11) not null,
		test_done int(11) default 0,
		test_result text,
		date_test_done DATE,
		comment_test_done text,
		order_destination  varchar(50),
    		test_name text,
		CONSTRAINT pk_patient_laboratory PRIMARY KEY (patient_id,encounter_id,test_id),
		INDEX(visit_date),
		INDEX(encounter_id),
		INDEX(patient_id)
	);

	DROP TABLE IF EXISTS patient_pregnancy;
	CREATE TABLE IF NOT EXISTS patient_pregnancy(
	patient_id int(11),
	encounter_id int(11),
	start_date date,
	end_date date,
	CONSTRAINT pk_patient_preg PRIMARY KEY (patient_id,encounter_id));

	/*Create table alert_lookup*/
	DROP TABLE IF EXISTS alert_lookup;
	CREATE TABLE IF NOT EXISTS alert_lookup(
		id int primary key auto_increment,
		libelle text,
		insert_date date
	);
	/*table alert_lookup insertion*/
	INSERT INTO alert_lookup(id,libelle,insert_date) VALUES
	(1,'Nombre de patient sous ARV depuis 6 mois sans un résultat de charge virale',DATE(now())),
	(2,'Nombre de femmes enceintes, sous ARV depuis 4 mois sans un résultat de charge virale',DATE(now())),
	(3,'Nombre de patients ayant leur dernière charge virale remontant à au moins 12 mois',DATE(now())),
	(4,'Nombre de patients ayant leur dernière charge virale remontant à au moins 3 mois et dont le résultat était > 1000 copies/ml',DATE(now()));
	/*Create table alert*/
	DROP TABLE IF EXISTS alert;
	CREATE TABLE IF NOT EXISTS alert(
	id int primary key auto_increment,
	patient_id int(11),
	id_alert int(11),
	encounter_id int(11),
	date_alert date);

	/*TABLE patient_diagnosis, this table contains all patient diagnosis*/
DROP TABLE IF EXISTS patient_diagnosis;
CREATE TABLE IF NOT EXISTS patient_diagnosis(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	encounter_date date,
	concept_group int(11),
	obs_group_id int(11),
	concept_id int(11),
	answer_concept_id int(11),
	suspected_confirmed int(11),
	primary_secondary int(11),
	constraint pk_patient_diagnosis
	PRIMARY KEY (encounter_id,location_id,concept_group,concept_id,answer_concept_id)
);

/*Table visit_type for visit_type like : Gynécologique=160456,Prénatale=1622,
Postnatale=1623,Planification familiale=5483 (ex: OBGYN FORM) */
DROP TABLE IF EXISTS visit_type;
	CREATE TABLE IF NOT EXISTS visit_type(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	visit_id int(11),
	obs_group int(11),
	concept_id int(11),
	v_type int(11),
	encounter_date date,
	CONSTRAINT pk_isanteplus_visit_type
	PRIMARY KEY (encounter_id,location_id,obs_group,concept_id,v_type));

/*Create table virological_tests */
DROP TABLE IF EXISTS virological_tests;
 CREATE TABLE IF NOT EXISTS virological_tests(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	encounter_date date,
	concept_group int(11),
	obs_group_id int(11),
    test_id int(11),
	answer_concept_id int(11),
	test_result int(11),
	age int(11),
	age_unit int(11),
	test_date date,
	constraint pk_virological_tests PRIMARY KEY (encounter_id,location_id,obs_group_id,test_id));

/* Create patient_delivery table */
DROP TABLE IF EXISTS patient_delivery;
CREATE TABLE IF NOT EXISTS patient_delivery(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	delivery_date datetime,
	delivery_location int(11),
	vaginal int(11),
	forceps int(11),
	vacuum int(11),
	delivrance int(11),
	encounter_date date,
	constraint pk_patient_delivery PRIMARY KEY (encounter_id,location_id));
/*Create table pediatric_first_visit*/
	DROP TABLE IF EXISTS pediatric_hiv_visit;
	CREATE TABLE IF NOT EXISTS pediatric_hiv_visit(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	ptme int(11),
	prophylaxie72h int(11),
	actual_vih_status int(11),
	encounter_date date,
	constraint pk_pediatric_hiv_visit PRIMARY KEY (patient_id,encounter_id,location_id));

	/*Create table patient_menstruation*/
	DROP TABLE IF EXISTS patient_menstruation;
	CREATE TABLE IF NOT EXISTS patient_menstruation(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	duree_regle int(11),
	duree_cycle int(11),
	ddr date,
	encounter_date date,
	constraint pk_patient_menstruation PRIMARY KEY (patient_id,encounter_id,location_id));

	/*Create table for vih_risk_factor*/
	DROP TABLE IF EXISTS vih_risk_factor;
	CREATE TABLE IF NOT EXISTS vih_risk_factor(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	risk_factor int(11),
	encounter_date date,
	constraint pk_vih_risk_factor PRIMARY KEY (patient_id,encounter_id,location_id,risk_factor));

	/*Create table for vaccinations*/
	DROP TABLE IF EXISTS vaccination;
	CREATE TABLE IF NOT EXISTS vaccination(
	patient_id int(11),
	encounter_id int(11),
	encounter_date date,
	location_id int(11),
	age_range int(11),
	vaccination_done boolean DEFAULT false,
	constraint pk_vaccination PRIMARY KEY (patient_id,encounter_id,location_id));

	/*Create table for health qual visits*/
	DROP TABLE IF EXISTS health_qual_patient_visit;
	CREATE TABLE IF NOT EXISTS health_qual_patient_visit(
	patient_id int(11),
	encounter_id int(11),
	visit_date date,
	visit_id int(11),
	location_id int(11),
	encounter_type int(11) DEFAULT NULL,
	patient_bmi double DEFAULT NULL,
	adherence_evaluation int(11) DEFAULT NULL,
	family_planning_method_used boolean DEFAULT false,
	evaluated_of_tb boolean DEFAULT false,
	nutritional_assessment_completed boolean DEFAULT false,
	is_active_tb boolean DEFAULT false,
	age_in_years int(11),
	last_insert_date date DEFAULT NULL,
	constraint pk_health_qual_patient_visit PRIMARY KEY (patient_id, encounter_id, location_id));
	/*Eposed infants table

	*/
	DROP TABLE IF EXISTS exposed_infants;
	CREATE table IF NOT EXISTS exposed_infants(
		patient_id int(11),
		location_id int(11),
		encounter_id int(11),
		visit_date date,
		condition_exposee int(11)
	);
	/*serological_tests table*/
	DROP TABLE IF EXISTS serological_tests;
 CREATE TABLE IF NOT EXISTS serological_tests(
	patient_id int(11),
	encounter_id int(11),
	location_id int(11),
	encounter_date date,
	concept_group int(11),
	obs_group_id int(11),
    test_id int(11),
	answer_concept_id int(11),
	test_result int(11),
	age int(11),
	age_unit int(11),
	test_date date,
	constraint pk_serological_tests PRIMARY KEY (encounter_id,location_id,obs_group_id,test_id));

	/*Create table patient_pcr*/
	DROP TABLE IF EXISTS patient_pcr;
	CREATE TABLE IF NOT EXISTS patient_pcr(
		patient_id int(11),
		encounter_id int(11),
		location_id int(11),
		visit_date date,
		pcr_result int(11),
		test_date date
	);

GRANT SELECT ON isanteplus.* TO 'root'@'localhost';
