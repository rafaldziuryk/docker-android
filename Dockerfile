FROM ubuntu:16.04
MAINTAINER Piotr Ciastko <ciaasteczkowy@gmail.com>

ENV ANDROID_SDK_FILENAME android-sdk_r24.4.1-linux.tgz
ENV ANDROID_BUILD_TOOLS build-tools-24.0.2
ENV ANDROID_SDK android-25
ENV ANDROID_ADDITIONAL extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services

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

# Install Android SDK
RUN cd /opt && wget -q https://dl.google.com/android/${ANDROID_SDK_FILENAME} && \
    tar xzf ${ANDROID_SDK_FILENAME} && \
    rm -f ${ANDROID_SDK_FILENAME} && \
    chown -R root.root android-sdk-linux && \
    echo y | android-sdk-linux/tools/android update sdk --all --no-ui --filter platform-tools,tools && \
    echo y | android-sdk-linux/tools/android update sdk --all --no-ui --filter platform-tools,tools && \
    echo y | android-sdk-linux/tools/android update sdk --all --no-ui --filter ${ANDROID_BUILD_TOOLS},${ANDROID_SDK},${ANDROID_ADDITIONAL} && \
    yes | sdkmanager --licenses

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Copy license
COPY licenses ${ANDROID_HOME}/licenses
RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

# Cleaning
RUN apt clean

# GO to workspace
RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace
