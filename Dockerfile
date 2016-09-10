FROM segment/base:v4

RUN apt-get install -y vim default-jre

# Download and place Heka binaries
ENV KAFKA_FILE_NAME kafka_2.11-0.10.0.1
ENV KAFKA_VERSION 0.10.0.1
ENV KAFKA_DOWNLOAD_URL http://apache.claz.org/kafka/$KAFKA_VERSION/$KAFKA_FILE_NAME.tgz
ENV KAFKA_HOME /usr/local/kafka

RUN cd /usr/local && \
    curl -LO $KAFKA_DOWNLOAD_URL && \
    echo "$KAFKA_FILE_NAME.tgz" | xargs tar -zxf && \
    mv $KAFKA_FILE_NAME kafka && \
    rm -rf $KAFKA_FILE_NAME.tar.gz

# Place the config file required for startup
RUN mkdir /usr/local/etc/kafka
COPY include/etc/kafka/server.properties /usr/local/etc/kafka
COPY include/etc/kafka/log4j.properties /usr/local/etc/kafka

RUN mkdir /usr/local/etc/init.d
COPY include/kafka-start-all.sh /usr/local/etc/init.d/kafka-start-all.sh
COPY include/kafka-start.sh /usr/local/etc/init.d/kafka-start.sh

# Replace broker id
ENV BROKER_ID 0
ENV KAFKA_CONFIGS_HOME /usr/local/etc/kafka
ENV IP 192.168.131.197
ENV ZK_PORT 2181
ENV KAFKA_PORT 9092

RUN sed -ie "s/\(broker\.id=\).*/\1$BROKER_ID/" $KAFKA_CONFIGS_HOME/server.properties
RUN sed -ie "s/\(zookeeper\.connect=\).*/\1$IP\:$ZK_PORT/" $KAFKA_CONFIGS_HOME/server.properties
RUN sed -ie "s/\(#\)\(advertised\.listeners=PLAINTEXT\:\/\/\).*/\2$IP\:$KAFKA_PORT/" $KAFKA_CONFIGS_HOME/server.properties

# Fix permissions for the Kafka startup scripts
RUN chmod +x /usr/local/etc/init.d/kafka-start-all.sh
RUN chmod +x /usr/local/etc/init.d/kafka-start.sh


CMD ["bash", "-C", "/usr/local/etc/init.d/kafka-start.sh"]

