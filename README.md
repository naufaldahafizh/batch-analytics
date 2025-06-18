# Batch Analytics

## Sumber Data: 
- [Plain text Wikipedia (SimpleEnglish)](https://www.kaggle.com/datasets/ffatty/plain-text-wikipedia-simpleenglish)
- [Web Server Access Logs](https://www.kaggle.com/datasets/eliasdabbas/web-server-access-logs)


## Word Count MapReduce
Perintah: 
- hdfs dfs -put /opt/hadoop/data/sample_text.txt /user/root/input/
- hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.4.jar wordcount \
  /user/root/input/sample_text.txt /user/root/output_wc
- hdfs dfs -cat /user/root/output_wc/part-r-00000 | head -n 20
Waktu eksekusi: 44 detik

## Word Count Spark RDD
Perintah:
- sc = spark.sparkContext
- text = sc.textFile("hdfs://namenode:8020/user/root/input/sample_text.txt")
- counts = text.flatMap(lambda line: line.split()) \
             .map(lambda word: (word, 1)) \
             .reduceByKey(lambda a, b: a + b)
- counts.take(20)
- counts.saveAsTextFile("hdfs://namenode:8020/user/root/output_spark_wc")
Waktu eksekusi: 34 detik

## Hive (Soon)