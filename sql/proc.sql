CREATE OR REPLACE PROCEDURE p_signup(
  student_id_ INTEGER,
  activity_id_ INTEGER,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR) AS
DECLARE
BEGIN
  RAISE EXCEPTION 'not implemented';
END;

CREATE OR REPLACE PROCEDURE p_initiate_checkin(
  organizer_id_ INTEGER,
  activity_id_ INTEGER,
  valid_duration_ TIME,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR,
  OUT code_ VARCHAR) AS
DECLARE
BEGIN
  RAISE EXCEPTION 'not implemented';
END;

CREATE OR REPLACE PROCEDURE p_initiate_checkout(
  organizer_id_ INTEGER,
  activity_id_ INTEGER,
  valid_duration_ TIME,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR,
  OUT code_ VARCHAR) AS
DECLARE
BEGIN
  RAISE EXCEPTION 'not implemented';
END;

CREATE OR REPLACE PROCEDURE p_do_checkin(
  code_ VARCHAR,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR) AS
DECLARE
BEGIN
  RAISE EXCEPTION 'not implemented';
END;

CREATE OR REPLACE PROCEDURE p_do_checkout(
  code_ VARCHAR,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR) AS
DECLARE
BEGIN
  RAISE EXCEPTION 'not implemented';
END;

CREATE OR REPLACE PROCEDURE p_audit(
  auditor_id_ INTEGER,
  activity_id_ INTEGER,
  audition_comment_ VARCHAR,
  audition_passed_ BOOLEAN,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR) AS
DECLARE
BEGIN
  RAISE EXCEPTION 'not implemented';
END;

CREATE OR REPLACE PROCEDURE p_rate(
  student_id_ INTEGER,
  activity_id_ INTEGER,
  rate_value_ DECIMAL,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR) AS
DECLARE
BEGIN
  RAISE EXCEPTION 'not implemented';
END;

CREATE OR REPLACE FUNCTION f_gen_random_checkinout_code()
RETURNS VARCHAR AS $$
DECLARE
  salt CONSTANT VARCHAR := 'erke_';
BEGIN
  RETURN LPAD(ABS((('x' || LEFT(MD5(salt || CURRENT_TIMESTAMP), 8))::BIT(32)::INT4 % 100000000)::TEXT), 8, '0');
END;
$$ LANGUAGE plpgsql;
