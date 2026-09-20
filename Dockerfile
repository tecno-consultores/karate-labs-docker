FROM ubuntu:26.04
LABEL org.opencontainers.image.authors="sinfallas@gmail.com"
ENV LANG=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app
RUN apt update -qq && apt -y dist-upgrade && apt -y install --no-install-recommends --no-install-suggests nginx libnginx-mod-stream nano wget curl zip unzip ssh git openjdk-26-jre openjdk-26-jdk maven gradle locales && apt clean && rm -rf /var/lib/{apt,dpkg,cache,log} && rm -rf /var/cache/* && rm -rf /var/log/apt/* && rm -rf /tmp/* && locale-gen en_US.UTF-8 && dpkg-reconfigure --frontend noninteractive locales && update-locale LANG=en_US.UTF-8
RUN git clone https://github.com/karatelabs/karate-template.git .
RUN rm -rf /app/src/test/java/examples/users
RUN mkdir -p /app/src/test/java/examples/test
RUN mvn clean test
EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
ARG BUILD_DATE
LABEL org.opencontainers.image.created=$BUILD_DATE
