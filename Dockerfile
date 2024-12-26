FROM ubuntu:24.04
LABEL maintainer="sinfallas@gmail.com"
LABEL build_date="2024-12-26"
ENV LANG=en_US.UTF-8
WORKDIR /app
RUN apt update -qq && apt -y install --no-install-recommends --no-install-suggests nginx libnginx-mod-stream nano wget curl zip unzip ssh git openjdk-17-jre openjdk-17-jdk maven gradle locales locales-all && apt clean && rm -rf /var/lib/{apt,dpkg,cache,log} && rm -rf /var/cache/* && rm -rf /var/log/apt/* && rm -rf /tmp/* && locale-gen en_US.UTF-8 && dpkg-reconfigure --frontend noninteractive locales && update-locale LANG=en_US.UTF-8
RUN git clone https://github.com/karatelabs/karate-template.git .
COPY COPYING ./
RUN rm -rf /app/src/test/java/examples/users
RUN mkdir -p /app/src/test/java/examples/test
RUN mvn clean test
EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
