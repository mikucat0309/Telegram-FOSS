FROM gradle:7.6.4-jdk17

ARG ANDROID_SDK_URL=https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip
ARG ANDROID_NDK_URL=https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip
ARG ANDROID_VERSION=33
ARG ANDROID_BUILD_TOOLS_VERSION=33.0.0
ARG ANDROID_NDK_VERSION=21.4.7075529
ARG DEBIAN_FRONTEND=noninteractive

ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_NDK_HOME ${ANDROID_HOME}/ndk/${ANDROID_NDK_VERSION}

RUN --mount=type=cache,target=/var/cache <<EOF
if [ ! -f /var/cache/sdk.zip ]; then
curl -o /var/cache/sdk.zip "$ANDROID_SDK_URL"
fi
mkdir "$ANDROID_HOME" .android
cd "$ANDROID_HOME"
unzip /var/cache/sdk.zip
EOF

RUN --mount=type=cache,target=/var/cache <<EOF
if [ ! -f /var/cache/ndk.zip ]; then
curl -o /var/cache/ndk.zip "$ANDROID_NDK_URL"
fi
unzip /var/cache/ndk.zip
mkdir "$ANDROID_HOME/ndk"
mv android-ndk-*/ "$ANDROID_NDK_HOME"
EOF

ENV PATH $PATH:$ANDROID_HOME/cmdline-tools/bin

RUN yes | sdkmanager --sdk_root=$ANDROID_HOME --licenses
RUN sdkmanager --sdk_root=$ANDROID_HOME --update
RUN sdkmanager --sdk_root=$ANDROID_HOME \
    "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
    "platforms;android-$ANDROID_VERSION" \
    "platform-tools"

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    <<EOF
apt update
apt install -y cmake golang-go libuv1 make ninja-build yasm patch
EOF

ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools

ENV NDK=$ANDROID_NDK_HOME
ENV NINJA_PATH=/usr/bin/ninja

CMD [ "/src/build.sh" ]
