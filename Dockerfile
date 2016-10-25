FROM centos:7
MAINTAINER "Yanbin" <yabqiu@gmail.com>

USER root

#RUN yum -y update
RUN yum -y install wget
RUN yum -y  java-1.8.0-openjdk-devel

RUN cd ~/
RUN wget http://mirror.stjschools.org/public/apache/kafka/0.10.1.0/kafka_2.11-0.10.1.0.tgz
RUN tag xzvf kafka_2.11-0.10.1.0.tgz
RUN cd kafka_2.11-0.10.1.0

RUN cp config/server.properties config/server-1.properties
RUN cp config/server.properties config/server-2.properties

RUN sed -i 's/^broker.id=0/broker.id=1/' config/server-1.properties
RUN sed -i 's/kafka-logs/kafka-logs-1/'  config/server-1.properties
RUN echo "listeners=PLAINTEXT://:9093" >> config/server-1.properties
RUN sed -i 's/^broker.id=0/broker.id=2/' config/server-2.properties
RUN sed -i 's/kafka-logs/kafka-logs-2/'  config/server-2.properties
RUN echo "listeners=PLAINTEXT://:9094" >> config/server-2.properties

RUN bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
RUN bin/kafka-server-start.sh -daemon  config/server.properties
RUN bin/kafka-server-start.sh -daemon config/server-1.properties
RUN bin/kafka-server-start.sh -daemon config/server-2.properties

RUN bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 3 --partitions 5 --topic replicated-topic
RUN bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic replicated-topic

RUN cd ~
RUN yum -y install git
RUN yum -y install sbt
RUN wget https://dl.bintray.com/sbt/native-packages/sbt/0.13.12/sbt-0.13.12.tgz
RUN tar xzvf sbt-0.13.12.tgz
RUN git clone https://github.com/yahoo/kafka-manager
RUN cd kafka-manager
RUN ../sbt/bin/sbt clean universal:packageZipTarball
RUN cd ..
RUN tar xzvf kafka-manager/target/universal/kafka-manager-*.tgz
RUN cd kafka-manager-*
RUN bin/kafka-manager -DZK_HOSTS=localhost:2181
