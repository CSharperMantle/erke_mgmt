DROP VIEW IF EXISTS v_RateAgg;
CREATE VIEW v_RateAgg AS
  SELECT
    NULL::INT4 AS activity_id,
    NULL::INT4 AS rate_cnt,
    NULL::DECIMAL AS rate_avg,
    NULL::DECIMAL AS rate_max,
    NULL::DECIMAL AS rate_min;

DROP VIEW IF EXISTS v_ActivitySignUpCount;
CREATE VIEW v_ActivitySignUpCount AS
  SELECT
    s.activity_id AS activity_id, COUNT(s.student_id) AS cnt 
  FROM SignUp s
  GROUP BY activity_id;

DROP VIEW IF EXISTS v_AvailActivity;
CREATE VIEW v_AvailActivity AS
  SELECT
    a.activity_id AS activity_id
  FROM Activity a
  JOIN BeOpenTo b ON a.activity_id=b.activity_id
  JOIN Student s ON b.grade_value=s.grade_value
  WHERE s.student_id=SESSION_USER
  AND CURRENT_TIMESTAMP BETWEEN a.activity_signup_start_time AND a.activity_signup_end_time;


DROP VIEW IF EXISTS v_NonParticipActivity;
CREATE VIEW v_NonParticipActivity AS
  SELECT
    NULL::INT4 AS activity_id;
