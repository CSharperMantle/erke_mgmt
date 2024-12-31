CREATE OR REPLACE FUNCTION tf_activity_update_check() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=NEW.activity_id AND CURRENT_TIMESTAMP<activity_signup_start_time
  ) THEN
    RAISE EXCEPTION 'activity is already open for signing up';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_activity_update_check BEFORE UPDATE
ON Activity FOR EACH ROW
EXECUTE PROCEDURE tf_activity_update_check();

CREATE OR REPLACE FUNCTION tf_signup_insert_check() RETURNS TRIGGER AS $$
DECLARE
  current_count INTEGER;
  max_count INTEGER;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM BeOpenTo b
    JOIN Student s ON b.grade_value=s.grade_value
    WHERE b.activity_id=NEW.activity_id AND s.student_id=NEW.student_id
  ) THEN 
    RAISE EXCEPTION 'not open to this grade.';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=NEW.activity_id
    AND CURRENT_TIMESTAMP BETWEEN activity_sign_up_start_time AND activity_sign_up_end_time
  ) THEN
    RAISE EXCEPTION 'activity is not in the sign-up phase.';
  END IF;

  IF EXISTS (
    SELECT 1 FROM SignUp
    WHERE student_id=NEW.student_id AND activity_id=NEW.activity_id
  ) THEN
    RAISE EXCEPTION 'already sign up for this activity';
  END IF;
  
  SELECT cnt INTO current_count FROM v_ActivitySignUpCount WHERE activity_id=NEW.activity_id;
  SELECT activity_max_particp_count INTO max_count FROM Activity WHERE activity_id=NEW.activity_id;
  IF (current_count>=max_count) THEN
    RAISE EXCEPTION 'activity is alread full';
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM SignUp s1
    INNER JOIN Activity a1 ON s1.activity_id=a1.activity_id
    CROSS JOIN SignUp s2
    INNER JOIN Activity a2 ON s2.activity_id=a2.activity_id
    WHERE (
      (s1.student_id=NEW.student_id)
      AND (s1.student_id=s2.student_id)
      AND (a1.activity_id<>a2.activity_id)
      AND ((a1.activity_start_time, a1.activity_end_time) OVERLAPS (a2.activity_start_time, a2.activity_end_time))
    )
  ) THEN
    RAISE EXCEPTION 'time conflict with other activities';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_signup_insert_check BEFORE INSERT
ON SignUp FOR EACH ROW
EXECUTE PROCEDURE tf_signup_insert_check();

CREATE OR REPLACE FUNCTION tf_initiatecheckin_insert_check_activity_state() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=NEW.activity_id AND CURRENT_TIMESTAMP>=activity_start_time AND (activity_state IN (0, 1))
  ) THEN
    RAISE EXCEPTION 'activity state not valid for check-in';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_initiatecheckin_insert_check_activity_state BEFORE INSERT
ON InitiateCheckIn FOR EACH ROW
EXECUTE PROCEDURE tf_initiatecheckin_insert_check_activity_state();

CREATE OR REPLACE FUNCTION tf_initiatecheckin_insert_update_activity_state() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=NEW.activity_id AND activity_state=0
  ) THEN
    UPDATE Activity SET activity_state=1
    WHERE activity_id=NEW.activity_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_initiatecheckin_insert_update_activity_state AFTER INSERT
ON InitiateCheckIn FOR EACH ROW
EXECUTE PROCEDURE tf_initiatecheckin_insert_update_activity_state();

CREATE OR REPLACE FUNCTION tf_initiatecheckout_insert_check_activity_state() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=NEW.activity_id AND (activity_state IN (1, 2))
  ) THEN
    RAISE EXCEPTION 'activity state invalid for check-out';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_initiatecheckout_insert_check_activity_state BEFORE INSERT
ON InitiateCheckOut FOR EACH ROW
EXECUTE PROCEDURE tf_initiatecheckout_insert_check_activity_state();

CREATE OR REPLACE FUNCTION tf_initiatecheckout_insert_update_activity_state() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=NEW.activity_id AND activity_state=1
  ) THEN
    UPDATE Activity SET activity_state=2
    WHERE activity_id=NEW.activity_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_initiatecheckout_insert_update_activity_state AFTER INSERT
ON InitiateCheckOut FOR EACH ROW
EXECUTE PROCEDURE tf_initiatecheckout_insert_update_activity_state();

CREATE OR REPLACE FUNCTION tf_audit_insert_check_activity_state() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=NEW.activity_id AND activity_state=2
  ) THEN
    RAISE EXCEPTION 'activity state invalid for audit';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_audit_insert_check_activity_state BEFORE INSERT
ON "Audit" FOR EACH ROW
EXECUTE PROCEDURE tf_audit_insert_check_activity_state();

CREATE OR REPLACE FUNCTION tf_audit_insert_update_activity_state() RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.audit_passed==TRUE) THEN
    UPDATE Activity SET activity_state=3
    WHERE activity_id=NEW.activity_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_audit_insert_update_activity_state AFTER INSERT
ON "Audit" FOR EACH ROW
EXECUTE PROCEDURE tf_audit_insert_update_activity_state();

CREATE OR REPLACE FUNCTION tf_rate_insert_check() RETURNS TRIGGER AS $$
BEGIN
  RAISE WARNING 'not implemented';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_rate_insert_check BEFORE INSERT
ON Rate FOR EACH ROW
EXECUTE PROCEDURE tf_rate_insert_check();
