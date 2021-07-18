FROM ghcr.io/graalvm/graalvm-ce:ol8-java11-21.1.0 AS builder

RUN microdnf update && \
    microdnf install git wget

# install maven to build SimpleLanguage
# https://maven.apache.org/install.html
ENV MAVEN_VERSION 3.8.1
RUN wget https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-3.8.1-bin.tar.gz && \
    tar xzvf apache-maven-${MAVEN_VERSION}-bin.tar.gz
ENV PATH $PATH:/apache-maven-${MAVEN_VERSION}/bin

# install native-image to build stand-alone SimpleLanguage binary
RUN gu install native-image

# download and build SimpleLanguage
# https://www.graalvm.org/graalvm-as-a-platform/implement-language/
WORKDIR /tmp
RUN git clone https://github.com/graalvm/simplelanguage
WORKDIR /tmp/simplelanguage
RUN export SL_BUILD_NATIVE=true
RUN mvn package

FROM oraclelinux:8-slim

WORKDIR /app

COPY --from=builder /tmp/simplelanguage/native/slnative /bin/sl
