CREATE OR REPLACE PROCEDURE p_signup(
  student_id_ VARCHAR,
  activity_id_ INTEGER,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR) AS
DECLARE
  current_count INTEGER;
  max_count INTEGER;
  new_activity_start TIMESTAMP WITH TIME ZONE;
  new_activity_end TIMESTAMP WITH TIME ZONE;
  t TIMESTAMP WITH TIME ZONE;
BEGIN
  okay_ := FALSE;
  t := CURRENT_TIMESTAMP;

  IF NOT f_check_session_user_is('student', student_id_) THEN
    msg_ := 'cross-user operation';
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM BeOpenTo b
    JOIN Student s ON b.grade_value=s.grade_value
    WHERE b.activity_id=activity_id AND s.student_id=student_id_
  ) THEN 
    msg_ := 'not open to this grade.';
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=activity_id_
    AND t BETWEEN activity_signup_start_time AND activity_signup_end_time
  ) THEN
    msg_ := 'activity is not in the sign-up phase.';
    RETURN;
  END IF;

  IF EXISTS (
    SELECT 1 FROM SignUp
    WHERE student_id=student_id_ AND activity_id=activity_id_
  ) THEN
    msg_ := 'already sign up for this activity';
    RETURN;
  END IF;
  
  SELECT cnt INTO current_count FROM v_ActivitySignUpCount WHERE activity_id=activity_id_;
  SELECT activity_max_particp_count INTO max_count FROM Activity WHERE activity_id=activity_id_;
  IF (current_count>=max_count) THEN
    msg_ := 'activity is alread full';
    RETURN;
  END IF;

  SELECT activity_start_time, activity_end_time INTO new_activity_start, new_activity_end FROM Activity
  WHERE activity_id=activity_id_;
  IF EXISTS (
    SELECT 1 FROM SignUp s
    INNER JOIN Activity a ON s.activity_id=a.activity_id
    WHERE s.student_id=student_id_ AND ((a.activity_start_time, a.activity_end_time) OVERLAPS (new_activity_start, new_activity_end))
  ) THEN
    msg_ := 'time conflict with other activities';
    RETURN;
  END IF;
  INSERT INTO SignUp(student_id, activity_id, signup_time) VALUES (student_id_, activity_id_, t);
  okay_ := TRUE;
  msg_ := '';
END;

CREATE OR REPLACE PROCEDURE p_initiate_checkin(
  organizer_id_ VARCHAR,
  activity_id_ INTEGER,
  valid_duration_ TIME,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR,
  OUT code_ VARCHAR) AS
DECLARE
  t TIMESTAMP WITH TIME ZONE;
BEGIN
  t := CURRENT_TIMESTAMP;
  okay_ := FALSE;

  IF NOT f_check_session_user_is('organizer', organizer_id_) THEN
    msg_ := 'cross-user operation';
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM Activity a
    WHERE a.organizer_id=organizer_id_ AND a.activity_id=activity_id_
  ) THEN
    msg_ := 'not the same organizer';
    RETURN;
  END IF;

  IF EXISTS (
    SELECT 1 FROM Activity a
    WHERE a.activity_id=activity_id_ AND t<activity_start_time
  ) THEN
    msg_ := 'the activity is not started yet';
    RETURN;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM Activity a
    WHERE a.activity_id=activity_id_ AND a.activity_state IN (0, 1)
  ) THEN
    msg_ := 'the activity is not in the check-in period';
    RETURN;
  END IF;
  code_ := f_gen_random_checkinout_code();
  INSERT INTO InitiateCheckIn (
    organizer_id, activity_id, initiatecheckin_time, initiatecheckin_secret, initiatecheckin_valid_duration
  ) VALUES (
    organizer_id_, activity_id_, t, code_, valid_duration_
  );
  okay_ := TRUE;
  msg_ := '';
END;

CREATE OR REPLACE PROCEDURE p_initiate_checkout(
  organizer_id_ VARCHAR,
  activity_id_ INTEGER,
  valid_duration_ TIME,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR,
  OUT code_ VARCHAR) AS
DECLARE
  t TIMESTAMP WITH TIME ZONE;
BEGIN
  t := CURRENT_TIMESTAMP;
  okay_ := FALSE;

  IF NOT f_check_session_user_is('organizer', organizer_id_) THEN
    msg_ := 'cross-user operation';
    RETURN;
  END IF;

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
  student_id_ VARCHAR,
  code_ VARCHAR,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR) AS
DECLARE
  v RECORD;
  t TIMESTAMP WITH TIME ZONE;
BEGIN
  t := CURRENT_TIMESTAMP;
  okay_ := FALSE;
  IF NOT f_check_session_user_is('student', student_id_) THEN
    msg_ := 'cross-user operation';
    RETURN;
  END IF;
  FOR v IN (
    SELECT s.student_id AS student_id, s.activity_id AS activity_id FROM SignUp s
    INNER JOIN Activity a ON s.activity_id=a.activity_id
    WHERE (
      a.activity_state=1
      AND s.student_id=student_id_
      AND EXISTS (
        SELECT 1 FROM InitiateCheckIn i
        WHERE (
          (i.activity_id=s.activity_id)
          AND (i.initiatecheckin_secret=code_)
          AND (t BETWEEN i.initiatecheckin_time AND (i.initiatecheckin_time+i.initiatecheckin_valid_duration))
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
  student_id_ VARCHAR,
  code_ VARCHAR,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR) AS
DECLARE
  v RECORD;
  t TIMESTAMP WITH TIME ZONE;
BEGIN
  t := CURRENT_TIMESTAMP;
  okay_ := FALSE;
  IF NOT f_check_session_user_is('student', student_id_) THEN
    msg_ := 'cross-user operation';
    RETURN;
  END IF;
  FOR v IN (
    SELECT s.student_id AS student_id, s.activity_id AS activity_id FROM SignUp s
    INNER JOIN Activity a ON s.activity_id=a.activity_id
    WHERE (
      a.activity_state=2
      AND s.student_id=student_id_
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
  auditor_id_ VARCHAR,
  activity_id_ INTEGER,
  audition_comment_ VARCHAR,
  audition_passed_ BOOLEAN,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR) AS
DECLARE
BEGIN
  okay_ := FALSE;
  IF NOT f_check_session_user_is('auditor', auditor_id_) THEN
    msg_ := 'cross-user operation';
    RETURN;
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=activity_id_ AND activity_state=2
  ) THEN
    msg_ := 'activity state is invalid';
    RETURN;
  END IF;
  INSERT INTO "Audit"(auditor_id, activity_id, audit_comment, audit_passed) VALUES (auditor_id_, activity_id_, audition_comment_, audition_passed_);
  okay_ := TRUE;
  msg_ := '';
END;

CREATE OR REPLACE PROCEDURE p_rate(
  student_id_ VARCHAR,
  activity_id_ INTEGER,
  rate_value_ DECIMAL,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR) AS
DECLARE
BEGIN
  okay_ := FALSE;
  IF NOT f_check_session_user_is('student', student_id_) THEN
    msg_ := 'cross-user operation';
    RETURN;
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM DoCheckOut
    WHERE student_id=student_id_ AND activity_id=activity_id_
  ) THEN
    msg_ := 'you must check out before rating';
    RETURN;
  END IF;
  INSERT INTO Rate(student_id, activity_id, rate_value) VALUES (student_id_, activity_id_, rate_value_);
  okay_ := TRUE;
  msg_ := '';
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
