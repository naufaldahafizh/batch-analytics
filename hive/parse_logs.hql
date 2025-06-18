CREATE TABLE IF NOT EXISTS logs_parsed (
  ip STRING,
  timestamp STRING,
  method STRING,
  endpoint STRING,
  protocol STRING,
  status INT,
  size INT,
  user_agent STRING
);

INSERT INTO TABLE logs_parsed
SELECT
  regexp_extract(line, '^([^ ]*)', 1) AS ip,
  regexp_extract(line, '\\[(.*?)\\]', 1) AS timestamp,
  regexp_extract(line, '\"(\\S+)', 1) AS method,
  regexp_extract(line, '\"\\S+\\s(.*?)\\s', 1) AS endpoint,
  regexp_extract(line, 'HTTP/\\d\\.\\d\"', 0) AS protocol,
  CAST(regexp_extract(line, '\\s(\\d{3})\\s', 1) AS INT) AS status,
  CAST(regexp_extract(line, '\\s(\\d+)$', 1) AS INT) AS size,
  regexp_extract(line, '\"\\s\"(.*?)\"\\s\"', 1) AS user_agent
FROM logs_raw;