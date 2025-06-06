if [ -z "$DEVPOD_NAME" ]; then
  if [ $(uname -s) = "Darwin" ]; then
    unset JAVA_HOME
    export JDK_11="$(/usr/libexec/java_home -v11)"
    export JDK_17="$(/usr/libexec/java_home -v17)"
    export JDK_21="$(/usr/libexec/java_home -v21)"
    export JAVA_HOME=$JDK_21
  else
    export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
  fi
  export ANDROID_HOME=~/android-sdk
  export ANDROID_NDK=~/android-ndk
  export ANDROID_NDK_HOME=~/android-ndk

  # Add env variables to PATH
  export PATH=$JAVA_HOME/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:~/.local/bin:$ANDROID_HOME/platform-tools:$PATH
fi

# Mount the Android file image
function mountAndroid { hdiutil attach ~/android.dmg.sparseimage -mountpoint /Volumes/android; }

# Unmount the Android file image
function umountAndroid() { hdiutil detach /Volumes/android; }

function heapdump(){
  jmap -dump:live,format=b,file=$1 $2
}