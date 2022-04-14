#!/bin/bash

rps=$1
trigger_duration=$2 # in ms
experiment_duration=$3 # in second
maxheapsize=$4 #e.g., 256m

sudo docker create -it --tag=exp /bin/bash #TODO: figure out --tag
sudo docker start exp #TODO: make sure the syntax work
sudo docker cp GCMetastability.java exp:/gc_artifacts/GCMetastability.java

sudo docker exec exp /bin/bash -c "
javac GCMetastability.java && java -XX:MaxHeapSize=${maxheapsize} -XX:+CrashOnOutOfMemoryError -XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCApplicationStoppedTime -Xloggc:gc.log GCMetastability ${rps} ${trigger_duration} ${experiment_duration} &;

sleep 2;
vmid=$(jps | grep GCMetastability | awk '{print $1}');
echo 'vmid is: $vmid';
jstat -gcutil -t ${vmid} 100 > gc.csv;

exit
"

sudo docker cp exp:/gc_artifacts/job.csv .
sudo docker cp exp:/gc_artifacts/gc.log .
sudo docker cp exp:/gc_artifacts/gc.csv .
sudo docker cp exp:/gc_artifacts/exp_record.csv .

sudo docker stop exp
sudo docker rm exp
