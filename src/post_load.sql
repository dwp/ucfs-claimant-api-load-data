DELETE FROM claimant_stage WHERE citizen_id IS NULL;
DELETE FROM contract_stage WHERE contract_id IS NULL;
DELETE FROM statement_stage WHERE statement_id IS NULL;

ALTER TABLE claimant_stage ADD CONSTRAINT citizen_id UNIQUE KEY (citiezen_id);
ALTER TABLE contract_stage ADD CONSTRAINT contract_id UNIQUE KEY (contract_id);
ALTER TABLE statement_stage ADD CONSTRAINT statement_id UNIQUE KEY (statement_id);

CREATE INDEX idx_nino on claimant_stage (nino);
CREATE INDEX idx_citizen_id on claimant_stage (citizen_id);

CREATE INDEX idx_contract_id ON contract_stage (contract_id);
CREATE INDEX idx_citizen_a ON contract_stage (citizen_a);
CREATE INDEX idx_citizen_b ON contract_stage (citizen_b);
CREATE INDEX idx_citizens ON contract_stage (citizen_a,citizen_b);

CREATE INDEX idx_contract_id on statement_stage (contract_id);


RENAME TABLE
    claimant to claimant_old,
    contract to contract_old,
    statement to statement_old,
    claimant_stage to claimant,
    contract_stage to contract,
    statement_stage to statement
;

CREATE USER IF NOT EXISTS %(ro_username)s IDENTIFIED WITH AWSAuthenticationPlugin AS 'RDS';
ALTER USER IF EXISTS %(ro_username)s IDENTIFIED WITH AWSAuthenticationPlugin AS 'RDS';

GRANT SELECT ON claimant to %(ro_username)s;
GRANT SELECT ON contract to %(ro_username)s;
GRANT SELECT ON statement to %(ro_username)s;
