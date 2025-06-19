# Batch Analytics

## Sumber Data: 
- [Plain text Wikipedia (SimpleEnglish)](https://www.kaggle.com/datasets/ffatty/plain-text-wikipedia-simpleenglish)
- [Web Server Access Logs](https://www.kaggle.com/datasets/eliasdabbas/web-server-access-logs)

## Copy Data From Local
- `docker cp path/to/batch-analytics/data/sample_text.txt namenode:/tmp/sample_text.txt`
- `docker cp path/to/batch-analytics/data/access.log hive-server:/tmp/access_logs/access.log`

## Word Count MapReduce
Perintah: 
- `hdfs dfs -put /opt/hadoop/data/sample_text.txt /user/root/input/`
- `hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.4.jar wordcount \`
  `/user/root/input/sample_text.txt /user/root/output_wc`
- `hdfs dfs -cat /user/root/output_wc/part-r-00000 | head -n 20`

Waktu eksekusi: 44 detik

## Word Count Spark RDD
Perintah:
- `sc = spark.sparkContext`
- `text = sc.textFile("hdfs://namenode:8020/user/root/input/sample_text.txt")`
- `counts = text.flatMap(lambda line: line.split()) \`
             `.map(lambda word: (word, 1)) \`
             `.reduceByKey(lambda a, b: a + b)`
- `counts.take(20)`
- `counts.saveAsTextFile("hdfs://namenode:8020/user/root/output_spark_wc")`

Waktu eksekusi: 34 detik

## Hive
Perintah:
- Buat schema Hive ke PostgreSQL (`/opt/hive/bin/schematool -dbType postgres -initSchema`) kemudian restart hive-metastore
- `hdfs dfs -put /tmp/access_logs/access.log /data/access_logs/`
- CREATE EXTERNAL TABLE IF NOT EXISTS logs_raw (
  line STRING
)
ROW FORMAT DELIMITED
LINES TERMINATED BY '\n'
LOCATION '/data/access_logs';
- CREATE TABLE IF NOT EXISTS logs_parsed (
  ip STRING,
  identity STRING,
  `user` STRING,
  `timestamp` STRING,
  method STRING,
  endpoint STRING,
  protocol STRING,
  status INT,
  size INT,
  referer STRING,
  user_agent STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
  "input.regex" = "^(\\S+) (\\S+) (\\S+) \\[([^\\]]+)\\] \\\"(\\S+) (.*?) (HTTP/\\d\\.\\d)\\\" (\\d{3}) (\\S+) \\\"(.*?)\\\" \\\"(.*?)\\\"$"
)
STORED AS TEXTFILE
LOCATION '/data/access_logs';
- INSERT INTO TABLE logs_parsed
SELECT
  regexp_extract(line, '^(\\S+)', 1)         AS ip,
  regexp_extract(line, '^(?:\\S+\\s+)(\\S+)', 1) AS identity,
  regexp_extract(line, '^(?:\\S+\\s+\\S+\\s+)(\\S+)', 1) AS `user`,
  regexp_extract(line, '\\[([^\\]]+)\\]', 1) AS `timestamp`,
  regexp_extract(line, '\\"(\\S+)', 1)       AS method,
  regexp_extract(line, '\\"\\S+\\s(.*?)\\s', 1) AS endpoint,
  regexp_extract(line, '(HTTP/\\d\\.\\d)"', 1) AS protocol,
  CAST(regexp_extract(line, '\\s(\\d{3})\\s', 1) AS INT)  AS status,
  CAST(regexp_extract(line, '\\s(\\d+)$', 1) AS INT)      AS size,
  regexp_extract(line, '\\"\\s\\"(.*?)\\"', 1) AS referer,
  regexp_extract(line, '\\"(Mozilla.*)\\"$', 1) AS user_agent
FROM logs_raw;

## Spark SQL
- Install pyspark==2.4.0, pandas, seaborn
- Execution Time jauh lebih cepat dibandingkan Hive