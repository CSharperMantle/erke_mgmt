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
    NULL::INT4 AS activity_id,
    NULL::INT4 AS cnt;

DROP VIEW IF EXISTS v_AvailActivity;
CREATE VIEW v_AvailActivity AS
  SELECT
    NULL::INT4 AS activity_id;

DROP VIEW IF EXISTS v_NonParticipActivity;
CREATE VIEW v_NonParticipActivity AS
  SELECT
    NULL::INT4 AS activity_id;
