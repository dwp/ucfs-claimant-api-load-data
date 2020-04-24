CREATE TABLE IF NOT EXISTS claimant (
  id INT NOT NULL AUTO_INCREMENT,
  data json NOT NULL,
  nino varchar(200) GENERATED ALWAYS AS (json_unquote(json_extract(data,'$.nino'))) VIRTUAL,
  citizen_id varchar(100) GENERATED ALWAYS AS (json_unquote(json_extract(data,'$._id.citizenId'))) VIRTUAL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS claimant_old;
DROP TABLE IF EXISTS claimant_stage;

CREATE TABLE IF NOT EXISTS contract (
  id INT NOT NULL AUTO_INCREMENT,
  data json NOT NULL,
  contract_id varchar(100) GENERATED ALWAYS AS (json_unquote(json_extract(data,'$._id.contractId'))) VIRTUAL,
  citizen_a varchar(100) GENERATED ALWAYS AS (json_unquote(json_extract(data,'$.people[0]'))) VIRTUAL,
  citizen_b varchar(100) GENERATED ALWAYS AS (json_unquote(json_extract(data,'$.people[1]'))) VIRTUAL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS contract_old;
DROP TABLE IF EXISTS contract_stage;

CREATE TABLE IF NOT EXISTS statement (
  id INT NOT NULL AUTO_INCREMENT,
  data json NOT NULL,
  contract_id varchar(100) GENERATED ALWAYS AS (json_unquote(json_extract(data,'$.assessmentPeriod.contractId'))) VIRTUAL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS statement_old;
DROP TABLE IF EXISTS statement_stage;

CREATE TABLE claimant_stage (
  id INT NOT NULL AUTO_INCREMENT,
  data json NOT NULL,
  nino varchar(200) GENERATED ALWAYS AS (json_unquote(json_extract(data,'$.nino'))) VIRTUAL,
  citizen_id varchar(100) GENERATED ALWAYS AS (json_unquote(json_extract(data,'$._id.citizenId'))) VIRTUAL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE contract_stage (
  id INT NOT NULL AUTO_INCREMENT,
  data json NOT NULL,
  contract_id varchar(100) GENERATED ALWAYS AS (json_unquote(json_extract(data,'$._id.contractId'))) VIRTUAL,
  citizen_a varchar(100) GENERATED ALWAYS AS (json_unquote(json_extract(data,'$.people[0]'))) VIRTUAL,
  citizen_b varchar(100) GENERATED ALWAYS AS (json_unquote(json_extract(data,'$.people[1]'))) VIRTUAL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE statement_stage (
  id INT NOT NULL AUTO_INCREMENT,
  data json NOT NULL,
  contract_id varchar(100) GENERATED ALWAYS AS (json_unquote(json_extract(data,'$.assessmentPeriod.contractId'))) VIRTUAL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
