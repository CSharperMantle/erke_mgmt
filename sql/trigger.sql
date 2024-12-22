CREATE OR REPLACE FUNCTION tf_activity_update_check() RETURNS TRIGGER AS $$
BEGIN
  RAISE WARNING 'not implemented';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_activity_update_check BEFORE UPDATE
ON Activity FOR EACH ROW
EXECUTE PROCEDURE tf_activity_update_check();

CREATE OR REPLACE FUNCTION tf_signup_insert_check() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS(
    SELECT 1 FROM BeOpenTO b JOIN Student s ON b.grade_value=s.grade_value
    WHERE b.activity_id=NEW.activity_id AND s.student_id=NEW.student_id
  )THEN 
    RAISE EXCEPTION 'not open to this grade.';
  END IF;

  IF EXISTS (
    SELECT 1 FROM Activity WHERE activity_id = NEW.activity_id AND activity_state = 1
    ) THEN
  ELSE
    RAISE EXCEPTION 'activity is not in the sign-up phase.';
  END IF;

  IF EXISTS (
    SELECT 1 FROM SignUp WHERE student_id=NEW.student_id AND activity_id=NEW.activity_id
  )THEN
    RAISE EXCEPTION 'already sign up for this activity';
  END IF;
  
  IF EXIST(
    SELECT 1 FROM SignUp s JOIN Activity a ON s.activity_id=a.activity_id
    WHERE a.activity_id=NEW.activity_id GROUP BY a.activity_id
    HAVING COUNT(s.student_id)>=a.activity_max_particp_count
  )THEN
    RASIE EXCEPTION 'activity is alread full';
  
  IF EXISTS (
    SELECT 1 FROM SignUp s JOIN Activity a ON s.activity_id=a.activity_id
    WHERE  s.student_id=NEW.student_id AND (a.activity_start_time,a.activity_end_time)
    OVERLAPS(SELECT activity_start_time,activity_end_time FROM Activity WHERE activity_id=NEW.activity_id)
  )THEN
    RAISE EXCEPTION 'time conflict with other activities';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_signup_insert_check BEFORE INSERT
ON SignUp FOR EACH ROW
EXECUTE PROCEDURE tf_signup_insert_check();

CREATE OR REPLACE FUNCTION tf_initiatecheckin_insert_check_activity_state() RETURNS TRIGGER AS $$
BEGIN
  RAISE WARNING 'not implemented';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_initiatecheckin_insert_check_activity_state BEFORE INSERT
ON InitiateCheckIn FOR EACH ROW
EXECUTE PROCEDURE tf_initiatecheckin_insert_check_activity_state();

CREATE OR REPLACE FUNCTION tf_initiatecheckin_insert_update_activity_state() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS(
    SELECT 1 FROM Activity WHERE activity_id=NEW.activity_id AND activity_state=1
  )THEN
    UPDATE Activity SET activity_state=2
    WHERE activity_id=NEW.activity_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_initiatecheckin_insert_update_activity_state AFTER INSERT
ON InitiateCheckIn FOR EACH ROW
EXECUTE PROCEDURE tf_initiatecheckin_insert_update_activity_state();

CREATE OR REPLACE FUNCTION tf_initiatecheckout_insert_check_activity_state() RETURNS TRIGGER AS $$
BEGIN
  RAISE WARNING 'not implemented';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_initiatecheckout_insert_check_activity_state BEFORE INSERT
ON InitiateCheckOut FOR EACH ROW
EXECUTE PROCEDURE tf_initiatecheckout_insert_check_activity_state();

CREATE OR REPLACE FUNCTION tf_initiatecheckout_insert_update_activity_state() RETURNS TRIGGER AS $$
BEGIN
  RAISE WARNING 'not implemented';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_initiatecheckout_insert_update_activity_state AFTER INSERT
ON InitiateCheckOut FOR EACH ROW
EXECUTE PROCEDURE tf_initiatecheckout_insert_update_activity_state();

CREATE OR REPLACE FUNCTION tf_audit_insert_check_activity_state() RETURNS TRIGGER AS $$
BEGIN
  RAISE WARNING 'not implemented';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_audit_insert_check_activity_state BEFORE INSERT
ON "Audit" FOR EACH ROW
EXECUTE PROCEDURE tf_audit_insert_check_activity_state();

CREATE OR REPLACE FUNCTION tf_audit_insert_update_activity_state() RETURNS TRIGGER AS $$
BEGIN
  RAISE WARNING 'not implemented';
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
