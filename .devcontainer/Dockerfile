# Use a parameterized Flutter version
ARG FLUTTER_VERSION
FROM ghcr.io/cirruslabs/flutter:$FLUTTER_VERSION

# Set up Android NDK
ARG ANDROID_NDK_VERSION
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV ANDROID_NDK_HOME=$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION

# Define the SHA256 checksum for the NDK version
ARG ANDROID_NDK_SHA256

# Download and install the NDK with checksum verification
RUN mkdir -p $ANDROID_HOME/ndk && \
    wget https://dl.google.com/android/repository/android-ndk-r$ANDROID_NDK_VERSION-linux-x86_64.zip -O /tmp/ndk.zip && \
    echo "$ANDROID_NDK_SHA256  /tmp/ndk.zip" | sha256sum -c - && \
    unzip /tmp/ndk.zip -d $ANDROID_HOME/ndk && \
    mv $ANDROID_HOME/ndk/android-ndk-r$ANDROID_NDK_VERSION $ANDROID_NDK_HOME && \
    rm /tmp/ndk.zip

# Ensure the NDK is in the PATH
ENV PATH="$ANDROID_NDK_HOME:/usr/local/bin:$PATH"

# Set the working directory for Flutter builds
WORKDIR /workspace/build