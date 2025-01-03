DROP VIEW IF EXISTS v_StudentSelfSignUp;
CREATE VIEW v_StudentSelfSignUp AS
  SELECT * FROM SignUp
  WHERE f_check_session_user_is('student', student_id);

DROP VIEW IF EXISTS v_StudentSelfRate;
CREATE VIEW v_StudentSelfRate AS
  SELECT * FROM Rate
  WHERE f_check_session_user_is('student', student_id);

DROP VIEW IF EXISTS v_OrganizerSelfActivity;
CREATE VIEW v_OrganizerSelfActivity AS
  SELECT activity_id FROM Activity
  WHERE f_check_session_user_is('organizer', organizer_id);

DROP VIEW IF EXISTS v_AuditorSelfAudit;
CREATE VIEW v_AuditorSelfAudit AS
  SELECT * FROM "Audit"
  WHERE f_check_session_user_is('auditor', auditor_id);

DROP VIEW IF EXISTS v_RatingAgg;
CREATE VIEW v_RatingAgg AS
  SELECT
    a.activity_id AS activity_id, a.activity_name AS activity_name, COUNT(r.rate_value) AS rate_cnt, AVG(r.rate_value) AS rate_avg, MAX(r.rate_value) AS rate_max, MIN(r.rate_value) AS rate_min
  FROM Activity a
  LEFT JOIN Rate r ON a.activity_id=r.activity_id
  GROUP BY a.activity_id;

DROP VIEW IF EXISTS v_ActivitySignUpCount;
CREATE VIEW v_ActivitySignUpCount AS
  SELECT
    a.activity_id AS activity_id, COUNT(s.student_id) AS cnt
  FROM Activity a
  LEFT JOIN SignUp s ON a.activity_id=s.activity_id
  GROUP BY a.activity_id;

DROP VIEW IF EXISTS v_StudentAvailActivity;
CREATE VIEW v_StudentAvailActivity AS
  SELECT
    a.activity_id AS activity_id
  FROM Activity a
  JOIN BeOpenTo b ON a.activity_id=b.activity_id
  JOIN Student s ON b.grade_value=s.grade_value
  WHERE f_check_session_user_is('student', s.student_id)
  AND CURRENT_TIMESTAMP BETWEEN a.activity_signup_start_time AND a.activity_signup_end_time;

DROP VIEW IF EXISTS v_StudentNonParticipActivity;
CREATE VIEW v_StudentNonParticipActivity AS
  SELECT s.activity_id AS activity_id FROM v_StudentSelfSignUp s
  INNER JOIN Activity a ON s.activity_id=a.activity_id
  WHERE (
    a.activity_state=2
    AND NOT EXISTS (
      SELECT 1 FROM DoCheckIn d
      WHERE d.activity_id=s.activity_id AND d.student_id=s.student_id
    )
  );

DROP VIEW IF EXISTS v_OrganizerSelfAudit;
CREATE VIEW v_OrganizerSelfAudit AS
  SELECT
    au.audit_id AS audit_id,
    au.auditor_id AS auditor_id,
    aur.auditor_name AS auditor_name,
    au.activity_id AS activity_id,
    a.activity_name AS activity_name,
    au.audit_comment AS audit_comment,
    au.audit_passed AS audit_passed
  FROM "Audit" au
  INNER JOIN Auditor aur ON au.auditor_id=aur.auditor_id
  INNER JOIN Activity a ON au.activity_id=a.activity_id
  WHERE f_check_session_user_is('organizer', organizer_id);
