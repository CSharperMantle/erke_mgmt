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
  t TIMESTAMP;
BEGIN
  t := CURRENT_TIMESTAMP;
  okay_ := FALSE;
  IF NOT EXISTS (
    SELECT 1 FROM Activity a
    WHERE a.organizer_id=organizer_id_ AND a.activity_id=activity_id_
  ) THEN
    msg_ := 'not the same organizer';
    RETURN;
  END IF;

  IF EXISTS (
    SELECT 1 FROM Activity a
    WHERE a.activity_id=activity_id_ AND t<a.activity_start_time
  ) THEN
    msg_ := 'the activity is not started yet';
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM Activity a
    WHERE a.activity_id=activity_id_ AND a.activity_state IN (1, 2)
  ) THEN
    msg_ := 'the activity is not in the check-out period';
    RETURN;
  END IF;

  code_ := f_gen_random_checkinout_code();

  INSERT INTO InitiateCheckOut (
    organizer_id, activity_id, initiatecheckout_time, initiatecheckout_secret, initiatecheckout_valid_duration
  ) VALUES (
    organizer_id_, activity_id_, t, code_, valid_duration_
  );

  okay_ := TRUE;
  msg_ := '';
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
  v RECORD;
  t TIMESTAMP;
BEGIN
  t := CURRENT_TIMESTAMP;
  okay_ := FALSE;
  FOR v IN (
    SELECT s.student_id AS student_id, s.activity_id AS activity_id FROM SignUp s
    INNER JOIN Activity a ON s.activity_id=a.activity_id
    WHERE (
      a.activity_state=2
      AND f_check_session_user_is('student', s.student_id)
      AND EXISTS (
        SELECT 1 FROM DoCheckIn dci
        WHERE dci.student_id=s.student_id AND dci.activity_id=s.activity_id
      )
      AND EXISTS (
        SELECT 1 FROM InitiateCheckOut ico
        WHERE (
          (ico.activity_id=s.activity_id)
          AND (ico.initiatecheckout_secret=code_)
          AND (t BETWEEN ico.initiatecheckout_time AND (ico.initiatecheckout_time+ico.initiatecheckout_valid_duration))
        )
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
