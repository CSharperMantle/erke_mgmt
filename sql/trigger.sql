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
  RAISE WARNING 'not implemented';
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
  RAISE WARNING 'not implemented';
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
        WHERE activity_id = NEW.activity_id AND activity_state IN (2, 3)
    ) THEN
        RAISE EXCEPTION 'The activity is not in the Started check-in or check-out state.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER t_initiatecheckout_insert_check_activity_state BEFORE INSERT
ON InitiateCheckOut FOR EACH ROW
EXECUTE PROCEDURE tf_initiatecheckout_insert_check_activity_state();

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
    IF NOT EXISTS (
        SELECT 1 FROM Activity
        WHERE activity_id = NEW.activity_id AND activity_state = 2
    ) THEN
        RAISE EXCEPTION 'The activity is not in the Started check-in state.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER t_audit_insert_check_activity_state BEFORE INSERT
ON "Audit" FOR EACH ROW
EXECUTE PROCEDURE tf_audit_insert_check_activity_state();

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
