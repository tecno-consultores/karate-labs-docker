# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Jesus Palencia <sinfallas@gmail.com> (Creado en Tecno Consultores)
# Imagen Base Oficial QA 11X para Karate Labs BDD (Ephemeral No-Root Runner)

FROM ubuntu:26.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    HOME=/home/appuser \
    MAVEN_HOME=/opt/maven

WORKDIR /app

RUN apt-get update -qq \
    && apt-get -y upgrade \
    && apt-get -y dist-upgrade \
    && apt-get -y install --no-install-recommends --no-install-suggests \
        ca-certificates curl wget git zip unzip nano locales tzdata python3 openjdk-26-jdk-headless \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && apt-get clean \
    && apt-get -y autoremove --purge \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/*

RUN MVN_VER="$(curl -fsSL https://repo1.maven.org/maven2/org/apache/maven/apache-maven/maven-metadata.xml | grep -o '<release>[^<]*</release>' | head -n1 | sed 's/<[^>]*>//g')" \
    && mkdir -p /opt/maven /opt/m2/repository \
    && curl -fsSL "https://repo1.maven.org/maven2/org/apache/maven/apache-maven/${MVN_VER}/apache-maven-${MVN_VER}-bin.tar.gz" \
       | tar -xz --strip-components=1 -C /opt/maven \
    && rm -f /opt/maven/lib/guava-*.jar \
    && curl -fsSL "https://repo1.maven.org/maven2/com/google/guava/guava/33.8.0-jre/guava-33.8.0-jre.jar" \
       -o /opt/maven/lib/guava-33.8.0-jre.jar \
    && printf '%s\n' \
        '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"' \
        '          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' \
        '          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">' \
        '</settings>' \
        > /opt/maven/conf/settings.xml

RUN groupadd -g 10001 appgroup \
    && useradd -u 10001 -g appgroup -m -d /home/appuser -s /usr/sbin/nologin appuser \
    && git clone --depth 1 https://github.com/karatelabs/karate-template.git /app \
    && rm -rf /app/.git /app/src/test/java/examples/users \
    && mkdir -p /app/src/test/java/examples/test \
    && python3 -c "import xml.etree.ElementTree as ET; \
p='/app/pom.xml'; ns='http://maven.apache.org/POM/4.0.0'; ET.register_namespace('', ns); \
tree=ET.parse(p); root=tree.getroot(); q=lambda t: f'{{{ns}}}{t}'; \
props=root.find(q('properties')); \
[setattr(props.find(q(k)), 'text', v) for k,v in [('maven.compiler.version','3.14.0'),('maven.surefire.version','3.5.3'),('karate.version','1.5.2')] if props.find(q(k)) is not None]; \
dm=ET.Element(q('dependencyManagement')); deps=ET.SubElement(dm, q('dependencies')); \
add_dep=lambda g,a,v,t=None,sc=None: [ET.SubElement(d,q('groupId')).__setattr__('text',g), ET.SubElement(d,q('artifactId')).__setattr__('text',a), ET.SubElement(d,q('version')).__setattr__('text',v), t and ET.SubElement(d,q('type')).__setattr__('text',t), sc and ET.SubElement(d,q('scope')).__setattr__('text',sc)] if (d:=ET.SubElement(deps,q('dependency'))) is not None else None; \
add_dep('com.fasterxml.jackson','jackson-bom','2.23.0','pom','import'); \
add_dep('io.netty','netty-bom','4.2.20.Final','pom','import'); \
add_dep('io.micrometer','micrometer-bom','1.17.2','pom','import'); \
add_dep('commons-io','commons-io','2.22.0'); \
add_dep('org.thymeleaf','thymeleaf','3.1.7.RELEASE'); \
add_dep('org.codehaus.plexus','plexus-utils','4.1.0'); \
root.insert(list(root).index(root.find(q('dependencies'))), dm); \
build=root.find(q('build')); plugins=build.find(q('plugins')); \
[ET.SubElement(ET.SubElement(ET.SubElement(plugins,q('plugin')),q('groupId')).__setattr__('text','org.apache.maven.plugins') or plugins[-1], q('artifactId')).__setattr__('text', art) or ET.SubElement(plugins[-1], q('version')).__setattr__('text', ver) for art,ver in [('maven-clean-plugin','3.5.0'),('maven-resources-plugin','3.3.1')]]; \
[ [ET.SubElement(pdeps,q('dependency')).__setattr__('text',None) or [ET.SubElement(pdeps[-1],q('groupId')).__setattr__('text',g), ET.SubElement(pdeps[-1],q('artifactId')).__setattr__('text',a), ET.SubElement(pdeps[-1],q('version')).__setattr__('text',v)] for g,a,v in [('commons-io','commons-io','2.22.0'),('org.codehaus.plexus','plexus-utils','4.1.0')]] for pl in plugins.findall(q('plugin')) if (pdeps:=ET.SubElement(pl,q('dependencies'))) is not None ]; \
tree.write(p, encoding='UTF-8', xml_declaration=True)" \
    && /opt/maven/bin/mvn -B -ntp -Dmaven.repo.local=/opt/m2/repository test-compile surefire:test clean \
    && rm -rf /app/target /root/.m2 /tmp/* \
    && find /opt/m2/repository -type d \( -path '*/commons-io/commons-io/2.11.*' -o -path '*/org/codehaus/plexus/plexus-utils/3.*' -o -path '*/org/codehaus/plexus/plexus-utils/4.0.1' -o -path '*/org/codehaus/plexus/plexus-utils/4.0.2' \) -exec rm -rf {} + \
    && printf '%s\n' \
        '#!/usr/bin/env sh' \
        'set -eu' \
        'HAS_REPO_LOCAL=0' \
        'HAS_BATCH=0' \
        'for arg in "$@"; do' \
        '  case "$arg" in' \
        '    -Dmaven.repo.local=*) HAS_REPO_LOCAL=1 ;;' \
        '    -B|--batch-mode) HAS_BATCH=1 ;;' \
        '  esac' \
        'done' \
        'EXTRA_ARGS=""' \
        'if [ "$HAS_REPO_LOCAL" -eq 0 ]; then' \
        '  USER_M2="${MAVEN_USER_REPO:-${HOME:-/tmp}/.m2/repository}"' \
        '  if [ ! -f "${USER_M2}/.qa11x_seeded" ]; then' \
        '    mkdir -p "${USER_M2}"' \
        '    cp -r --update=none /opt/m2/repository/. "${USER_M2}/"' \
        '    chmod -R u+w "${USER_M2}"' \
        '    touch "${USER_M2}/.qa11x_seeded"' \
        '  fi' \
        '  EXTRA_ARGS="-Dmaven.repo.local=${USER_M2}"' \
        'fi' \
        'if [ "$HAS_BATCH" -eq 0 ] && [ ! -t 0 ]; then' \
        '  EXTRA_ARGS="${EXTRA_ARGS} -B"' \
        'fi' \
        '# shellcheck disable=SC2086' \
        'exec /opt/maven/bin/mvn $EXTRA_ARGS "$@"' \
        > /usr/local/bin/mvn \
    && chmod 0755 /usr/local/bin/mvn \
    && chmod -R a+rX /opt/m2 /opt/maven /app/pom.xml /app/src \
    && chown -R 10001:10001 /app /home/appuser \
    && chmod 1777 /app

ARG BUILD_DATE
LABEL org.opencontainers.image.authors="Jesus Palencia <sinfallas@gmail.com> (Creado en Tecno Consultores)" \
      org.opencontainers.image.title="sinfallas/karatelabs" \
      org.opencontainers.image.description="Karate Labs BDD ephemeral non-root QA 11X v2 runner with pre-warmed Maven cache" \
      org.opencontainers.image.source="https://hub.docker.com/r/sinfallas/karatelabs" \
      org.opencontainers.image.licenses="GPL-2.0-only" \
      org.opencontainers.image.created="${BUILD_DATE}"

USER 10001:10001
CMD ["mvn", "-B", "clean", "test"]
