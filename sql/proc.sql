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
  v RECORD;
  t TIMESTAMP;
BEGIN
  t := CURRENT_TIMESTAMP;
  okay_ := FALSE;
  FOR v IN (
    SELECT s.student_id AS student_id, s.activity_id AS activity_id FROM SignUp s
    INNER JOIN Activity a ON s.activity_id=a.activity_id
    WHERE (
      a.activity_state=1
      AND f_check_session_user_is('student', s.student_id)
      AND EXISTS (
        SELECT 1 FROM InitiateCheckIn i
        WHERE (
          (i.activity_id=s.activity_id)
          AND (i.initiatecheckin_secret=code_)
          AND (t BETWEEN i.initiatecheckin_time AND (i.initiatecheckin_time + i.initiatecheckin_valid_duration))
        )
      )
    )
  ) LOOP
    okay_ := TRUE;
    INSERT INTO DoCheckIn(student_id, activity_id, docheckin_time) VALUES (v.student_id, v.activity_id, t);
  END LOOP;
  IF (okay_) THEN
    msg_ := '';
  ELSE
    msg_ := 'invalid check-in code';
  END IF;
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

CREATE OR REPLACE FUNCTION f_check_session_user_is(type_ VARCHAR, uid_ VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
  matches VARCHAR[];
BEGIN
  IF (SESSION_USER='erke_admin') THEN
    RETURN TRUE;
  END IF;
  matches := regexp_matches(SESSION_USER, '^erke_(auditor|student|organizer)_([0-9]+)$');
  RETURN ((matches IS NOT NULL) AND (array_length(matches, 1)=2) AND (matches[1]=type_) AND (matches[2]=uid_));
END;
$$ LANGUAGE plpgsql;
