CREATE ROLE erke_student NOLOGIN PASSWORD 'Nop@ssw0rd';
CREATE ROLE erke_organizer NOLOGIN PASSWORD 'Nop@ssw0rd';
CREATE ROLE erke_auditor NOLOGIN PASSWORD 'Nop@ssw0rd';

GRANT CONNECT ON DATABASE erke TO erke_student, erke_organizer, erke_auditor;
GRANT USAGE ON SCHEMA public TO erke_student, erke_organizer, erke_auditor;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO erke_student, erke_organizer, erke_auditor;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM erke_student, erke_organizer, erke_auditor;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM erke_student, erke_organizer, erke_auditor;

GRANT SELECT ON TABLE Activity TO erke_student, erke_organizer, erke_auditor;
GRANT SELECT ON TABLE ActivityTag TO erke_student, erke_organizer, erke_auditor;
GRANT SELECT ON TABLE "Audit" TO erke_organizer, erke_auditor;
GRANT SELECT ON TABLE Auditor TO erke_student, erke_organizer, erke_auditor;
GRANT SELECT ON TABLE BeOpenTo TO erke_student, erke_organizer, erke_auditor;
GRANT SELECT ON TABLE BeTagged TO erke_student, erke_organizer, erke_auditor;
GRANT SELECT ON TABLE DoCheckIn TO erke_student, erke_organizer;
GRANT SELECT ON TABLE DoCheckOut TO erke_student, erke_organizer;
GRANT SELECT ON TABLE Grade TO erke_student, erke_organizer, erke_auditor;
GRANT SELECT ON TABLE InitiateCheckIn TO erke_student, erke_organizer;
GRANT SELECT ON TABLE InitiateCheckOut TO erke_student, erke_organizer;
GRANT SELECT ON TABLE Organizer TO erke_student, erke_organizer, erke_auditor;
GRANT SELECT ON TABLE Rate TO erke_student, erke_organizer, erke_auditor;
GRANT SELECT ON TABLE SignUp TO erke_student, erke_organizer;
GRANT SELECT ON TABLE Student TO erke_student, erke_organizer;
GRANT SELECT ON v_StudentSelfSignUp TO erke_student;
GRANT SELECT ON v_StudentSelfRate TO erke_student;
GRANT SELECT ON v_OrganizerSelfActivity TO erke_organizer;
GRANT SELECT ON v_RatingAgg TO erke_student, erke_organizer, erke_auditor;
GRANT SELECT ON v_ActivitySignUpCount TO erke_student, erke_organizer, erke_auditor;
GRANT SELECT ON v_StudentAvailActivity TO erke_student;
GRANT SELECT ON v_StudentNonParticipActivity TO erke_student;
GRANT SELECT ON v_OrganizerSelfAudit TO erke_organizer;
GRANT EXECUTE ON PROCEDURE p_signup(student_id_ VARCHAR, activity_id_ INTEGER, OUT okay_ BOOLEAN, OUT msg_ VARCHAR) TO erke_student;
GRANT EXECUTE ON PROCEDURE p_initiate_checkin(organizer_id_ VARCHAR, activity_id_ INTEGER, valid_duration_ TIME, OUT okay_ BOOLEAN, OUT msg_ VARCHAR, OUT code_ VARCHAR) TO erke_organizer;
GRANT EXECUTE ON PROCEDURE p_initiate_checkout(organizer_id_ VARCHAR, activity_id_ INTEGER, valid_duration_ TIME, OUT okay_ BOOLEAN, OUT msg_ VARCHAR, OUT code_ VARCHAR) TO erke_organizer;
GRANT EXECUTE ON PROCEDURE p_do_checkin(student_id_ VARCHAR, code_ VARCHAR, OUT okay_ BOOLEAN, OUT msg_ VARCHAR) TO erke_student;
GRANT EXECUTE ON PROCEDURE p_do_checkout(student_id_ VARCHAR, code_ VARCHAR, OUT okay_ BOOLEAN, OUT msg_ VARCHAR) TO erke_student;
GRANT EXECUTE ON PROCEDURE p_audit(auditor_id_ VARCHAR, activity_id_ INTEGER, audition_comment_ VARCHAR, audition_passed_ BOOLEAN, OUT okay_ BOOLEAN, OUT msg_ VARCHAR) TO erke_auditor;
GRANT EXECUTE ON PROCEDURE p_rate(student_id_ VARCHAR, activity_id_ INTEGER, rate_value_ DECIMAL, OUT okay_ BOOLEAN, OUT msg_ VARCHAR) TO erke_student;
GRANT EXECUTE ON FUNCTION f_gen_random_checkinout_code() TO erke_organizer;
GRANT EXECUTE ON FUNCTION f_check_session_user_is(type_ VARCHAR, uid_ VARCHAR) TO erke_student, erke_organizer, erke_auditor;

GRANT INSERT ON TABLE Activity TO erke_organizer;
-- No INSERT specified for ActivityTag
GRANT INSERT ON TABLE "Audit" TO erke_auditor;
-- No INSERT specified for Auditor
GRANT INSERT ON TABLE BeOpenTo TO erke_organizer;
GRANT INSERT ON TABLE BeTagged TO erke_organizer;
GRANT INSERT ON TABLE DoCheckIn TO erke_student;
GRANT INSERT ON TABLE DoCheckOut TO erke_student;
-- No INSERT specified for Grade
GRANT INSERT ON TABLE InitiateCheckIn TO erke_organizer;
GRANT INSERT ON TABLE InitiateCheckOut TO erke_organizer;
-- No INSERT specified for Organizer
GRANT INSERT ON TABLE Rate TO erke_student;
GRANT INSERT ON TABLE SignUp TO erke_student;
-- No INSERT specified for Student

GRANT UPDATE ON TABLE Activity TO erke_organizer, erke_auditor;
-- No UPDATE specified for ActivityTag
-- No UPDATE specified for "Audit"
-- No UPDATE specified for Auditor
GRANT UPDATE ON TABLE BeOpenTo TO erke_organizer;
GRANT UPDATE ON TABLE BeTagged TO erke_organizer;
-- No UPDATE specified for DoCheckIn
-- No UPDATE specified for DoCheckOut
-- No UPDATE specified for Grade
-- No UPDATE specified for InitiateCheckIn
-- No UPDATE specified for InitiateCheckOut
-- No UPDATE specified for Organizer
-- No UPDATE specified for Rate
-- No UPDATE specified for SignUp
-- No UPDATE specified for Student
