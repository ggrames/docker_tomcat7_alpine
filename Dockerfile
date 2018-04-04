FROM alpine:3.7

ARG TOMCAT_VERSION=7.0.57
ARG JAVA_PACKAGE=openjdk
ARG JAVA_PACKAGE_VERSION=7
ARG ORACLE_CLIENT_VERSION=12.1.0.2.0
ARG SAPJCO_VERSION=2.1.10

RUN apk add ${JAVA_PACKAGE}${JAVA_PACKAGE_VERSION} --no-cache --repository=http://nl.alpinelinux.org/alpine/edge/main && \
    apk add --no-cache curl=7.59.0-r0 && \
    apk add --no-cache bash && \
    curl -LO https://archive.apache.org/dist/tomcat/tomcat-7/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    mkdir -p /opt2/local/tomcat/ && \
    tar -zxf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt2/local/tomcat/ && \
    mv /opt2/local/tomcat/apache-tomcat-${TOMCAT_VERSION} /opt2/local/tomcat/${TOMCAT_VERSION} && \
    rm -f apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Create needed dirs
RUN mkdir -p /usr/lib/oracle/12.1/client64/network/admin && \
    mkdir -p /usr/lib/oracle/12.1/client64/bin/ && \
    mkdir -p /usr/lib/oracle/12.1/client64/lib/ && \
    mkdir -p /opt2/local/sapjco/${SAPJCO_VERSION}_64

#########################
# Oracle Instant Client #
#########################

COPY ./files/instantclient-basic-linux.x64-${ORACLE_CLIENT_VERSION}.zip ./
RUN unzip instantclient-basic-linux.x64-${ORACLE_CLIENT_VERSION}.zip && \
    mv instantclient_12_1/*.* /usr/lib/oracle/12.1/client64/lib/ && \
    mv instantclient_12_1/* /usr/lib/oracle/12.1/client64/bin/ && \
    rm -rf instantclient_12_1 && \
    rm instantclient-basic-linux.x64-${ORACLE_CLIENT_VERSION}.zip 

COPY ./files/instantclient-tools-linux.x64-${ORACLE_CLIENT_VERSION}.zip ./
RUN unzip instantclient-tools-linux.x64-${ORACLE_CLIENT_VERSION}.zip && \
    mv instantclient_12_1/* /usr/lib/oracle/12.1/client64/bin/ && \
    rm -rf instantclient_12_1 && \
    rm instantclient-tools-linux.x64-${ORACLE_CLIENT_VERSION}.zip

COPY ./files/instantclient-sqlplus-linux.x64-${ORACLE_CLIENT_VERSION}.zip ./
RUN unzip instantclient-sqlplus-linux.x64-${ORACLE_CLIENT_VERSION}.zip && \
    mv instantclient_12_1/*.* /usr/lib/oracle/12.1/client64/lib/ && \
    mv instantclient_12_1/* /usr/lib/oracle/12.1/client64/bin/ && \
    rm -rf instantclient_12_1 && \
    rm instantclient-sqlplus-linux.x64-${ORACLE_CLIENT_VERSION}.zip

ENV ORACLE_BASE /usr/lib/oracle/12.1/client64/
ENV LD_LIBRARY_PATH /usr/lib/oracle/12.1/client64/lib/
ENV ORACLE_HOME /usr/lib/oracle/12.1/client64/
ENV JAVA_HOME /usr/lib/jvm/java-1.${JAVA_PACKAGE_VERSION}-openjdk/

##########
# SAPJCO #
##########

COPY ./files/sapjco-linuxx86_64-${SAPJCO_VERSION}.tgz ./
RUN tar -zxf sapjco-linuxx86_64-${SAPJCO_VERSION}.tgz -C /opt2/local/sapjco/2.1.10_64/ && \
    rm sapjco-linuxx86_64-${SAPJCO_VERSION}.tgz

ENTRYPOINT ["/bin/bash"]
