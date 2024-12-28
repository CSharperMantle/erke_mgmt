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

CREATE OR REPLACE FUNCTION gen_random_string(length_ INTEGER)
RETURNS VARCHAR AS $$
DECLARE
    digits VARCHAR(10) := '0123456789';
    random_string VARCHAR(4) := '';
    i INTEGER;
BEGIN
    FOR i IN 1..length_ LOOP
        random_string := random_string || SUBSTRING(digits, 1 + FLOOR(RANDOM() * length(digits)), 1);
    END LOOP;
    RETURN random_string;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE PROCEDURE p_initiate_checkout(
    organizer_id_ INTEGER,
    activity_id_ INTEGER,
    valid_duration_ TIME,
    OUT okay_ BOOLEAN,
    OUT msg_ VARCHAR,
    OUT code_ VARCHAR
) AS $$
DECLARE
    current_time TIMESTAMP := CURRENT_TIMESTAMP;
    activity_state INTEGER;
BEGIN
    SELECT activity_state INTO activity_state
    FROM Activity
    WHERE activity_id = activity_id_ AND organizer_id = organizer_id_ AND activity_start_time <= current_time AND activity_state = 1;
    IF NOT FOUND THEN
        okay_ := FALSE;
        msg_ := 'The conditions for signing out haven't met.';
    ELSE
        code_ := gen_random_string(8);
        INSERT INTO InitiateCheckOut (activity_id, organizer_id, initiatecheckout_time, initiatecheckout_secret, initiatecheckout_valid_duration)
        VALUES (activity_id_, organizer_id_, current_time, code_, valid_duration_);
        okay_ := TRUE;
        msg_ := 'The sign-out is successful.';
    END IF;
END;
$$ LANGUAGE plpgsql;

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
  v RECORD;
  t TIMESTAMP;
BEGIN
  t := CURRENT_TIMESTAMP;
  okay_ := FALSE;
  FOR v IN (
    SELECT s.student_id AS student_id, s.activity_id AS activity_id FROM SignUp s
    INNER JOIN Activity a ON s.activity_id = a.activity_id
    WHERE (
      a.activity_state = 2 
      AND f_check_session_user_is('student', s.student_id)
      AND EXISTS (
        SELECT 1 FROM InitiateCheckOut i
        WHERE (
          (i.activity_id = s.activity_id)
          AND (i.initiatecheckout_secret = code_)
          AND (t BETWEEN i.initiatecheckout_time AND (i.initiatecheckout_time + i.initiatecheckout_valid_duration))
        )
      )
      AND EXISTS (
        SELECT 1 FROM DoCheckIn dci
        WHERE (dci.student_id = s.student_id) AND (dci.activity_id = s.activity_id)
      )
    )
  ) LOOP
    okay_ := TRUE;
    INSERT INTO DoCheckOut(student_id, activity_id, docheckout_time) VALUES (v.student_id, v.activity_id, t);
  END LOOP;
  IF (okay_) THEN
    msg_ := '';
  ELSE
    msg_ := 'invalid checkout code';
  END IF;
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
BEGIN
  RAISE EXCEPTION 'not implemented';
END;
$$ LANGUAGE plpgsql;
