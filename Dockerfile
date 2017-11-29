FROM ubuntu:16.04
MAINTAINER Piotr Ciastko <ciaasteczkowy@gmail.com>

ENV ANDROID_SDK_FILENAME android-sdk_r24.4.1-linux.tgz
ENV ANDROID_BUILD_TOOLS build-tools-26.0.2
ENV ANDROID_SDK android-26
ENV ANDROID_ADDITIONAL extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services

#Instal Maven
RUN apt-get update
RUN apt-get install -y maven

ADD pom.xml /pom.xml
RUN ["mvn", "dependency:resolve"]
RUN ["mvn", "verify"]

ADD src /src
RUN ["mvn", "package"]

EXPOSE 4567
CMD ["/usr/lib/jvm/java-8-openjdk-amd64/bin/java", "-jar", "target/sample-1.0.jar"]

# Install java8
RUN apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y ppa:webupd8team/java && \
    (echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections) && \
    apt update && \
    apt install -y oracle-java8-installer && \
    apt clean && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Deps
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --force-yes expect git wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 python curl libqt5widgets5 && apt-get clean && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy install tools
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools

RUN chmod -R 777 /opt/tools/android-accept-licenses.sh

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin

# Install Android SDK
RUN cd /opt && wget -q https://dl.google.com/android/${ANDROID_SDK_FILENAME} && \
    tar xzf ${ANDROID_SDK_FILENAME} && \
    rm -f ${ANDROID_SDK_FILENAME} && \
    chown -R root.root android-sdk-linux

# Make licences Android SDK
RUN cd ${ANDROID_HOME} && \
    yes | tools/bin/sdkmanager --licences 

# Copy license
COPY licenses ${ANDROID_HOME}/licenses

# Cleaning
RUN apt clean

# GO to workspace
RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace
