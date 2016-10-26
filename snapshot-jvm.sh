#!/bin/bash
# Created : 26-10-2016
# Author : Gabriel Prestes (helkmut@gmail.com)
# Description : Script to analysis JVMs, needed only JDK 1.7 or higher and know the ports you want to collect the data.

# Crontab entries example: 
# 10 * * * * /opt/resources/scripts/bin/snapshot-jvm.sh >> /opt/resources/logs/snapshot-jvm.out 2>&1

export TERM="xterm"

# -- VARS -- #
JAVA_PATH="/usr/java/jdk1.7.0_79/bin"
PATH_LOCATION="/opt/tomcat8/temp"
#SERVERNAME=""

PID=`ps -ef | grep catalina | grep tomcat | grep -v grep | awk '{ print $2}'` # -> Tomcat all versions 
#PID=`ps -ef | grep port-offset | egrep \"jboss|wildfly\" | grep -v grep | awk '{ print $2}'` # -> JBoss 7 or higher, if in domain mode set your server name
#PID=`ps -ef | grep "weblogic.Name=${SERVERNAME}" | grep oracle | grep -v grep | awk '{ print $2}'` # -> WLS - set your ManagedServer Name
#PID=`ps -ef | grep java | grep ${SERVERNAME}" | grep -v grep | awk '{ print $2}'` # -> Websphere - set your ManagedServer Name
#PID=`ps -ef | grep jetty | grep java | grep -v grep | awk '{ print $2}'` # -> Jetty

DATE=`date`
JVMWEBPORT="8080" # -> Port where your connector HTTP listen
JVMWEBSPORT="8443" # -> Port where your connector HTTPS listen
JVMAJPPORT="8009" # -> Port where your connector AJP listen (only to Jboss|Wildfly and Tomcat)
JVMDSPORT="1521" # -> Port where your DS established connections (default : PGSQL - 5432 | MySQL - 3306 | Oracle - 1521)  


echo "PID JVM -> ${PID}"
echo "Date execution -> ${DATE}"
echo " "

# --- #

echo " " >> ${PATH_LOCATION}/thread-dump-`date -I`.dmp
echo " " >> ${PATH_LOCATION}/thread-dump-`date -I`.dmp
echo "Take thread dump..."
echo "Thread dump time : ${DATE}" >> ${PATH_LOCATION}/thread-dump-`date -I`.dmp
echo "______________________________" >> ${PATH_LOCATION}/thread-dump-`date -I`.dmp
${JAVA_PATH}/jstack -l ${PID} >> ${PATH_LOCATION}/thread-dump-`date -I`.dmp

# --- #

echo " " >> ${PATH_LOCATION}/memory-snapshot-`date -I`.out
echo " " >> ${PATH_LOCATION}/memory-snapshot-`date -I`.out
echo "Take memory snapshot..."
echo "Memory snapshot time : ${DATE}" >> ${PATH_LOCATION}/memory-snapshot-`date -I`.out
echo "______________________________" >> ${PATH_LOCATION}/memory-snapshot-`date -I`.out
${JAVA_PATH}/jmap -heap ${PID} >> ${PATH_LOCATION}/memory-snapshot-`date -I`.out
echo " " >> ${PATH_LOCATION}/memory-snapshot-`date -I`.out
echo " " >> ${PATH_LOCATION}/memory-snapshot-`date -I`.out
${JAVA_PATH}/jmap -permstat ${PID} >> ${PATH_LOCATION}/memory-snapshot-`date -I`.out

# --- #

echo "Take memory dump..."
${JAVA_PATH}/jmap -dump:format=b,file=${PATH_LOCATION}/heapdump-${PID}-`date +%H-%F`.hprof ${PID}

# --- #

echo "Snapshot resources in use"
echo " " >> ${PATH_LOCATION}/hardresources-`date -I`.out
echo " " >> ${PATH_LOCATION}/hardresources-`date -I`.out
echo "Resources snapshot time : ${DATE}" >> ${PATH_LOCATION}/hardresources-`date -I`.out
echo "______________________________" >> ${PATH_LOCATION}/hardresources-`date -I`.out
top -b -n 1 >> ${PATH_LOCATION}/hardresources-`date -I`.out
echo " " >> ${PATH_LOCATION}/hardresources-`date -I`.out
echo " " >> ${PATH_LOCATION}/hardresources-`date -I`.out
iostat -n 2 -x 2 >> ${PATH_LOCATION}/hardresources-`date -I`.out

# --- #

echo "Check threads in use..."
echo " " >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
echo " " >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
echo "Threads collection time : ${DATE}" >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
echo "______________________________" >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
echo " " >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
echo " " >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
echo "Threads in HTTP Connector : " >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
netstat -na | grep ${JVMWEBPORT} | grep -v LISTEN | wc -l >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
echo "Threads in HTTPS Connector : " >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
netstat -na | grep ${JVMWEBSPORT} | grep -v LISTEN | wc -l >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
echo "Threads in AJP Connector -> ${AJP_THREADS}" >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
netstat -na | grep ${JVMAJPPORT} | grep -v LISTEN | wc -l >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
echo "Threads in DS -> ${DS_THREADS}" >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
netstat -na | grep ${JVMDSPORT} | grep -v LISTEN | wc -l >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
echo " " >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
echo "List connections full : " >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
netstat -na | grep ${JVMWEBPORT} | grep -v LISTEN >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
netstat -na | grep ${JVMWEBSPORT} | grep -v LISTEN >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
netstat -na | grep ${JVMAJPPORT} | grep -v LISTEN >> ${PATH_LOCATION}/threads-in-use-`date -I`.out
netstat -na | grep ${JVMDSPORT} | grep -v LISTEN >> ${PATH_LOCATION}/threads-in-use-`date -I`.out


echo "Finish."
echo " "

exit
