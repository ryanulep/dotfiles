## Java and Android
export JAVA_HOME="$(/usr/libexec/java_home -v11)"
export ANDROID_HOME=~/android-sdk
export ANDROID_NDK=~/android-ndk
export ANDROID_NDK_HOME=~/android-ndk
# Add env vars to PATH
export PATH=$JAVA_HOME/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH