CREATE ROLE erke_student NOLOGIN PASSWORD 'Nop@ssw0rd';

GRANT CONNECT ON DATABASE erke TO erke_student;
GRANT USAGE ON SCHEMA public TO erke_student;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO erke_student;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO erke_student;

CREATE ROLE erke_organizer NOLOGIN PASSWORD 'Nop@ssw0rd';

GRANT CONNECT ON DATABASE erke TO erke_organizer;
GRANT USAGE ON SCHEMA public TO erke_organizer;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO erke_organizer;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO erke_organizer;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO erke_organizer;

CREATE ROLE erke_auditor NOLOGIN PASSWORD 'Nop@ssw0rd';

GRANT CONNECT ON DATABASE erke TO erke_auditor;
GRANT USAGE ON SCHEMA public TO erke_auditor;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO erke_auditor;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO erke_auditor;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO erke_auditor;