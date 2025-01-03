CREATE OR REPLACE FUNCTION tf_activity_update_check() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=NEW.activity_id AND CURRENT_TIMESTAMP<activity_signup_start_time
  ) AND OLD.activity_state=NEW.activity_state THEN
    RAISE EXCEPTION '活动已开放报名，无法修改';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_activity_update_check ON Activity;
CREATE TRIGGER t_activity_update_check BEFORE UPDATE
ON Activity FOR EACH ROW
EXECUTE PROCEDURE tf_activity_update_check();

CREATE OR REPLACE FUNCTION tf_signup_insert_check() RETURNS TRIGGER AS $$
DECLARE
  current_count INTEGER;
  new_activity_start TIMESTAMP WITH TIME ZONE;
  new_activity_end TIMESTAMP WITH TIME ZONE;
  max_count INTEGER;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM BeOpenTo b
    JOIN Student s ON b.grade_value=s.grade_value
    WHERE b.activity_id=NEW.activity_id AND s.student_id=NEW.student_id
  ) THEN 
    RAISE EXCEPTION '活动未对该年级开放';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=NEW.activity_id
    AND CURRENT_TIMESTAMP BETWEEN activity_signup_start_time AND activity_signup_end_time
  ) THEN
    RAISE EXCEPTION '活动未开放报名';
  END IF;

  IF EXISTS (
    SELECT 1 FROM SignUp
    WHERE student_id=NEW.student_id AND activity_id=NEW.activity_id
  ) THEN
    RAISE EXCEPTION '已报名该活动';
  END IF;
  
  SELECT cnt INTO current_count FROM v_ActivitySignUpCount WHERE activity_id=NEW.activity_id;
  SELECT activity_max_particp_count INTO max_count FROM Activity WHERE activity_id=NEW.activity_id;
  IF (current_count>=max_count) THEN
    RAISE EXCEPTION '活动报名人数已满';
  END IF;
  
  SELECT activity_start_time, activity_end_time INTO new_activity_start, new_activity_end FROM Activity
  WHERE activity_id=NEW.activity_id;
  IF EXISTS (
    SELECT 1 FROM SignUp s
    INNER JOIN Activity a ON s.activity_id=a.activity_id
    WHERE s.student_id=NEW.student_id AND ((a.activity_start_time, a.activity_end_time) OVERLAPS (new_activity_start, new_activity_end))
  ) THEN
    RAISE EXCEPTION '活动时间冲突';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_signup_insert_check ON SignUp;
CREATE TRIGGER t_signup_insert_check BEFORE INSERT
ON SignUp FOR EACH ROW
EXECUTE PROCEDURE tf_signup_insert_check();

CREATE OR REPLACE FUNCTION tf_initiatecheckin_insert_check_activity_state() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=NEW.activity_id AND CURRENT_TIMESTAMP>=activity_start_time AND (activity_state IN (0, 1))
  ) THEN
    RAISE EXCEPTION '当前活动状态下不可发起签到';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_initiatecheckin_insert_check_activity_state ON InitiateCheckIn;
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
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_initiatecheckin_insert_update_activity_state ON InitiateCheckIn;
CREATE TRIGGER t_initiatecheckin_insert_update_activity_state AFTER INSERT
ON InitiateCheckIn FOR EACH ROW
EXECUTE PROCEDURE tf_initiatecheckin_insert_update_activity_state();

CREATE OR REPLACE FUNCTION tf_initiatecheckout_insert_check_activity_state() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=NEW.activity_id AND (activity_state IN (1, 2))
  ) THEN
    RAISE EXCEPTION '当前活动状态下不可发起签退';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_initiatecheckout_insert_check_activity_state ON InitiateCheckOut;
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

DROP TRIGGER IF EXISTS t_initiatecheckout_insert_update_activity_state ON InitiateCheckOut;
CREATE TRIGGER t_initiatecheckout_insert_update_activity_state AFTER INSERT
ON InitiateCheckOut FOR EACH ROW
EXECUTE PROCEDURE tf_initiatecheckout_insert_update_activity_state();

CREATE OR REPLACE FUNCTION tf_audit_insert_check_activity_state() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Activity
    WHERE activity_id=NEW.activity_id AND activity_state=2
  ) THEN
    RAISE EXCEPTION '当前活动状态下不可审核';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_audit_insert_check_activity_state ON "Audit";
CREATE TRIGGER t_audit_insert_check_activity_state BEFORE INSERT
ON "Audit" FOR EACH ROW
EXECUTE PROCEDURE tf_audit_insert_check_activity_state();

CREATE OR REPLACE FUNCTION tf_audit_insert_update_activity_state() RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.audit_passed=TRUE) THEN
    UPDATE Activity SET activity_state=3
    WHERE activity_id=NEW.activity_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_audit_insert_update_activity_state ON "Audit";
CREATE TRIGGER t_audit_insert_update_activity_state AFTER INSERT
ON "Audit" FOR EACH ROW
EXECUTE PROCEDURE tf_audit_insert_update_activity_state();

CREATE OR REPLACE FUNCTION tf_rate_insert_check() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM DoCheckOut
    WHERE student_id=NEW.student_id AND activity_id=NEW.activity_id
  ) THEN
    RAISE EXCEPTION '未在该活动中签退';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS t_rate_insert_check ON Rate;
CREATE TRIGGER t_rate_insert_check BEFORE INSERT
ON Rate FOR EACH ROW
EXECUTE PROCEDURE tf_rate_insert_check();
