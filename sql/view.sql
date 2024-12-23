DROP VIEW IF EXISTS v_RateAgg;
CREATE VIEW v_RateAgg AS
  SELECT
    r.activity_id AS activity_id, COUNT(r.rate_value) AS rate_cnt, AVG(r.rate_value) AS rate_avg, MAX(r.rate_value) AS rate_max, MIN(r.rate_value) AS rate_min
  FROM Rate r
  GROUP BY r.activity_id;

DROP VIEW IF EXISTS v_ActivitySignUpCount;
CREATE VIEW v_ActivitySignUpCount AS
  SELECT
    NULL::INT4 AS activity_id,
    NULL::INT4 AS cnt;

DROP VIEW IF EXISTS v_AvailActivity;
CREATE VIEW v_AvailActivity AS
  SELECT
    NULL::INT4 AS activity_id;

DROP VIEW IF EXISTS v_NonParticipActivity;
CREATE VIEW v_NonParticipActivity AS
  SELECT s.activity_id AS activity_id FROM SignUp s
  INNER JOIN Activity a ON s.activity_id=a.activity_id
  WHERE (
    s.activity_state=2
    AND f_check_session_user_is('student', s.student_id)
    AND NOT EXISTS (
      SELECT 1 FROM DoCheckIn d
      WHERE d.activity_id=s.activity_id AND d.student_id=s.student_id
    )
  );
