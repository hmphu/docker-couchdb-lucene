FROM maven:3-jdk-11-slim as build

ARG COUCHDB_LUCENE_VERSION=2.1.0

RUN apt-get update && apt-get install -y unzip
RUN mkdir -p /usr/src; cd /usr/src \
    && curl -L https://github.com/rnewson/couchdb-lucene/archive/v$COUCHDB_LUCENE_VERSION.tar.gz | tar -xz \
    && cd couchdb-lucene-$COUCHDB_LUCENE_VERSION \
    && mvn
RUN cd /usr/src/couchdb-lucene-$COUCHDB_LUCENE_VERSION/target \
    && unzip couchdb-lucene-$COUCHDB_LUCENE_VERSION-dist.zip \
    && mv couchdb-lucene-$COUCHDB_LUCENE_VERSION /opt/couchdb-lucene \
    && rm -rf /usr/src/couchdb-lucene-*

FROM openjdk:11-slim
WORKDIR /opt/couchdb-lucene
COPY --from=build /opt/couchdb-lucene /opt/couchdb-lucene

ENV COUCHDB_PORT 5984
ENV COUCHDB_SERVER couchdb

COPY entrypoint.sh /opt/couchdb-lucene/entrypoint.sh
RUN chmod +x /opt/couchdb-lucene/entrypoint.sh
RUN ln -sf $JAVA_HOME/bin/java /usr/local/bin/java

RUN groupadd -r couchdb && useradd -d /opt/couchdb-lucene -g couchdb couchdb

WORKDIR /opt/couchdb-lucene
EXPOSE 5985
VOLUME ["/opt/couchdb-lucene/indexes"]

ENTRYPOINT ["./entrypoint.sh"]
