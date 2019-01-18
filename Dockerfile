FROM jboss/base:latest
MAINTAINER Tero Ahonen <tero@gamerefinery.com>

# Enables signals getting passed from startup script to JVM
# ensuring clean shutdown when container is stopped.
ENV LAUNCH_JBOSS_IN_BACKGROUND 1

ENV KEYCLOAK_VERSION 4.8.0.Final

# This can be specified as build argument, e.g. docker build  --build-arg OPERATING_MODE=clustered --tag IMAGE_NAME .
ARG OPERATING_MODE=clustered
ENV OPERATING_MODE ${OPERATING_MODE}

USER root


RUN yum install -y java-1.8.0-openjdk-devel openssl epel-release wget jq git gettext && yum update -y && yum clean all

ENV KEYCLOAK_HOME /opt/jboss/keycloak
ENV JAVA_HOME /usr/lib/jvm/java

RUN curl -o keycloak-$KEYCLOAK_VERSION.tar.gz https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz && \
    tar -xzvf keycloak-$KEYCLOAK_VERSION.tar.gz && \
    mv keycloak-$KEYCLOAK_VERSION $KEYCLOAK_HOME

#ADD keycloak-$KEYCLOAK_VERSION.tar.gz /opt/jboss/
#RUN mv /opt/jboss/keycloak-$KEYCLOAK_VERSION $KEYCLOAK_HOME

WORKDIR $KEYCLOAK_HOME

ADD standalone-ha.xml $KEYCLOAK_HOME/standalone/configuration
COPY themes/ $KEYCLOAK_HOME/themes/

RUN curl https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem > /tmp/rds-combined-ca-bundle.pem && \
    openssl x509 -outform der -in /tmp/rds-combined-ca-bundle.pem -out /tmp/rds-combined-ca-bundle.der && \
    keytool -importcert -keystore /usr/lib/jvm/java/jre/lib/security/cacerts -storepass changeit -file /tmp/rds-combined-ca-bundle.der -alias rds -noprompt


RUN chown -R 1000:0 ${KEYCLOAK_HOME} && chmod -R ug+rw ${KEYCLOAK_HOME}

USER jboss

ADD docker-entrypoint.sh /opt/jboss/

ENV PSQL_JDBC_VERSION 42.2.5

RUN mkdir -p $KEYCLOAK_HOME/modules/system/layers/base/org/postgresql/jdbc/main
ADD module-postgres-jdbc.xml $KEYCLOAK_HOME/modules/system/layers/base/org/postgresql/jdbc/main/
RUN cd $KEYCLOAK_HOME/modules/system/layers/base/org/postgresql/jdbc/main && \
  curl -O http://central.maven.org/maven2/org/postgresql/postgresql/$PSQL_JDBC_VERSION/postgresql-$PSQL_JDBC_VERSION.jar && \
  envsubst < $KEYCLOAK_HOME/modules/system/layers/base/org/postgresql/jdbc/main/module-postgres-jdbc.xml > $KEYCLOAK_HOME/modules/system/layers/base/org/postgresql/jdbc/main/module.xml && \
  rm $KEYCLOAK_HOME/modules/system/layers/base/org/postgresql/jdbc/main/module-postgres-jdbc.xml

EXPOSE 8080
EXPOSE 8443
ENTRYPOINT [ "/opt/jboss/docker-entrypoint.sh" ]

CMD ["--debug", "-b", "0.0.0.0"]
