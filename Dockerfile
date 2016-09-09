FROM segment/base:v4

RUN apt-get install -y vim

# Download and place Heka binaries
ENV KAFKA_FILE_NAME kafka_2.11-0.10.0.1
ENV KAFKA_VERSION 0.10.0.1
ENV KAFKA_DOWNLOAD_URL http://apache.claz.org/kafka/$KAFKA_VERSION/$KAFKA_FILE_NAME.tgz
ENV KAFKA_HOME /usr/local/kafka

RUN cd /usr/local && \
    curl -LO $KAFKA_DOWNLOAD_URL && \
    echo "$KAFKA_FILE_NAME.tar.gz" | xargs tar -zxf && \
    mv $KAFKA_FILE_NAME kafka && \
    rm -rf $KAFKA_FILE_NAME.tar.gz

# Place the config file required for startup
RUN mkdir /usr/local/etc/kafka
COPY include/etc/kafka/server.properties /usr/local/etc/kafka
COPY include/etc/kafka/log4j.properties /usr/local/etc/kafka

RUN mkdir /usr/local/etc/init.d
COPY include/kafka-start-all.sh /usr/local/etc/init.d/kafka-start-all.sh
RUN chmod +x /usr/local/etc/init.d/kafka-start-all.sh

CMD ["bash", "-C", "/usr/local/etc/init.d/kafka-start-all.sh"]

