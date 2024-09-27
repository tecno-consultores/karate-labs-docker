FROM ubuntu:22.04
LABEL maintainer="sinfallas@gmail.com"

WORKDIR /app
RUN apt update && apt -y install --no-install-recommends --no-install-suggests nano wget curl unzip git openjdk-17-jre openjdk-17-jdk maven gradle && rm -rf /var/lib/{apt,dpkg,cache,log} && apt-get clean
RUN git clone git@github.com:karatelabs/karate-template.git
