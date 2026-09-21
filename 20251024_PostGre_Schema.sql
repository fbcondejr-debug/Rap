-- Step 1: Create database (optional - run separately if needed)
-- CREATE DATABASE dicom_metadata
--   WITH OWNER = postgres
--   ENCODING = 'UTF8'
--   LC_COLLATE = 'en_US.UTF-8'
--   LC_CTYPE = 'en_US.UTF-8'
--   TEMPLATE = template0
--   CONNECTION LIMIT = -1;

-- Step 2: Create schema
CREATE SCHEMA IF NOT EXISTS dbo AUTHORIZATION postgres;
SET search_path TO dbo, public;

-- Step 3: Create tables

-- =======================
-- Study-level metadata
-- =======================
CREATE SEQUENCE IF NOT EXISTS dbo.study_study_id_seq;

CREATE TABLE IF NOT EXISTS dbo.study (
    study_id INTEGER NOT NULL DEFAULT nextval('dbo.study_study_id_seq'),
    study_instance_uid VARCHAR(128) NOT NULL,
    institution_name VARCHAR(256),
    manufacturer VARCHAR(128),
    manufacturer_model_name VARCHAR(128),
    study_time TIME,
    accession_number VARCHAR(64),
    protocol_name VARCHAR(256),
    body_part_examined VARCHAR(128),
    software_versions VARCHAR(128),
    device_serial_number VARCHAR(128),
    CONSTRAINT study_pkey PRIMARY KEY (study_id),
    CONSTRAINT study_study_instance_uid_key UNIQUE (study_instance_uid)
);

ALTER TABLE dbo.study OWNER TO dbadmin;

CREATE INDEX IF NOT EXISTS idx_study_accession_number
    ON dbo.study(accession_number);

-- =======================
-- Series-level metadata
-- =======================
CREATE SEQUENCE IF NOT EXISTS dbo.series_series_id_seq;

CREATE TABLE IF NOT EXISTS dbo.series (
    series_id INTEGER NOT NULL DEFAULT nextval('dbo.series_series_id_seq'),
    study_id INTEGER NOT NULL,
    series_instance_uid VARCHAR(128) NOT NULL,
    series_time TIME,
    acquisition_time TIME,
    scanning_sequence VARCHAR(64),
    repetition_time NUMERIC(10,4),
    echo_time NUMERIC(10,4),
    flip_angle NUMERIC(10,2),
    series_description VARCHAR(256),
    series_protocol VARCHAR(256),
    content_date DATE,
    content_time TIME,
    CONSTRAINT series_pkey PRIMARY KEY (series_id),
    CONSTRAINT series_series_instance_uid_key UNIQUE (series_instance_uid),
    CONSTRAINT series_study_id_fkey FOREIGN KEY (study_id)
        REFERENCES dbo.study (study_id)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

ALTER TABLE dbo.series OWNER TO dbadmin;

CREATE INDEX IF NOT EXISTS idx_series_study_id
    ON dbo.series(study_id);

-- =======================
-- Image-level metadata
-- =======================
CREATE SEQUENCE IF NOT EXISTS dbo.image_image_id_seq;

CREATE TABLE IF NOT EXISTS dbo.image (
    image_id INTEGER NOT NULL DEFAULT nextval('dbo.image_image_id_seq'),
    series_id INTEGER NOT NULL,
    sop_instance_uid VARCHAR(128) NOT NULL,
    acquisition_number INTEGER,
    CONSTRAINT image_pkey PRIMARY KEY (image_id),
    CONSTRAINT image_sop_instance_uid_key UNIQUE (sop_instance_uid),
    CONSTRAINT image_series_id_fkey FOREIGN KEY (series_id)
        REFERENCES dbo.series (series_id)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

ALTER TABLE dbo.image OWNER TO dbadmin;

CREATE INDEX IF NOT EXISTS idx_image_series_id
    ON dbo.image(series_id);

-- =======================
-- End of Schema
-- =======================
