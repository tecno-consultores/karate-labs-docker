FROM ubuntu:24.04
LABEL maintainer="sinfallas@gmail.com"
LABEL build_date="2024-09-26"
WORKDIR /app
RUN apt update && apt -y install --no-install-recommends --no-install-suggests nginx libnginx-mod-stream nano wget curl unzip ssh git openjdk-17-jre openjdk-17-jdk maven gradle && rm -rf /var/lib/{apt,dpkg,cache,log} && apt clean
RUN git clone https://github.com/karatelabs/karate-template.git .
COPY COPYING ./
RUN rm -rf /app/src/test/java/examples/users
RUN mkdir -p /app/src/test/java/examples/test
RUN mvn clean test
EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
