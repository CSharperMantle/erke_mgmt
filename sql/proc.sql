CREATE OR REPLACE PROCEDURE p_signup(
  student_id_ INTEGER,
  activity_id_ INTEGER,
  OUT okay_ BOOLEAN,
  OUT msg_ VARCHAR) AS
DECLARE
  current_count INTEGER;
  max_count INTEGER;
BEGIN
  okay_ := FALSE;
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
    WHERE activity_id=NEW.activity_id
    AND CURRENT_TIMESTAMP BETWEEN activity_sign_up_start_time AND activity_sign_up_end_time
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

  IF EXISTS (
    SELECT 1 FROM SignUp s 
    JOIN Activity a ON s.activity_id=activity_id_
    WHERE s.student_id=student_id_ AND (
      (a.activity_start_time, a.activity_end_time) OVERLAPS (
        SELECT activity_start_time, activity_end_time FROM Activity
        WHERE activity_id=activity_id_
      )
    )
  ) THEN
    msg_ := 'time conflict with other activities';
    RETURN;
  END IF;
  INSERT INTO SignUp(student_id, activity_id, signup_time) VALUES(student_id_, activity_id_ ,CURRENT_TIMESTAMP);
  okay_ := TRUE;
  msg_ := '';
  RETURN; 
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
BEGIN
  RAISE EXCEPTION 'not implemented';
END;
$$ LANGUAGE plpgsql;
