FROM debian:stretch

ARG HADOOP=hadoop-2.9.1
ARG HADOOP_URL=https://archive.apache.org/dist/hadoop/core/${HADOOP}/${HADOOP}.tar.gz

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_PREFIX=/opt/${HADOOP}
ENV HADOOP_LOG_DIR=/var/log/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV HADOOP_DATA_DIR=/data/hadoop
ENV PATH $HADOOP_PREFIX/bin:$PATH

RUN apt-get clean \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    ca-certificates-java \
    curl \
    dirmngr \
    gnupg \
    openssh-server \
    openssh-client \
    rsync \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fSL ${HADOOP_URL} -o /tmp/${HADOOP}.tar.gz \
  && curl -fSL ${HADOOP_URL}.asc -o /tmp/${HADOOP}.tar.gz.asc \
  && gpg --keyserver hkp://pgpkeys.mit.edu:80 --recv-key 8A256EF198AAD349 \
  && gpg --verify /tmp/${HADOOP}.tar.gz.asc /tmp/${HADOOP}.tar.gz \
  && tar -xzf /tmp/${HADOOP}.tar.gz -C /opt/ \
  && rm /tmp/${HADOOP}* \
  && ln -s ${HADOOP_PREFIX}/etc/hadoop ${HADOOP_CONF_DIR}

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
  && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
  && chmod 0600 ~/.ssh/authorized_keys \
  && service ssh restart \
  && ssh-keyscan -H localhost >> ~/.ssh/known_hosts \
  && ssh-keyscan -H 0.0.0.0 >> ~/.ssh/known_hosts

RUN sed -i "s|^#\?export JAVA_HOME=.*|export JAVA_HOME=$JAVA_HOME|" $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh \
  && sed -i "s|^#\?export HADOOP_CONF_DIR=.*|export HADOOP_CONF_DIR=$HADOOP_CONF_DIR|" $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh \
  && sed -i "s|^#\?export HADOOP_LOG_DIR=.*|export HADOOP_LOG_DIR=$HADOOP_LOG_DIR|" $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

ADD ./pseudo-distributed/config/* ${HADOOP_CONF_DIR}/
ADD ./pseudo-distributed/start-hadoop-pseudo-distributed.sh /sbin/start-hadoop-pseudo-distributed.sh

RUN hdfs namenode -format

VOLUME ["${HADOOP_CONF_DIR}", "${HADOOP_LOG_DIR}", "${HADOOP_DATA_DIR}"]

# HDFS
EXPOSE 50010 50020 50070 50075 50090
# MAPRED
EXPOSE 19888
#YARN
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other
EXPOSE 49707 2122

CMD ["/sbin/start-hadoop-pseudo-distributed.sh"]
