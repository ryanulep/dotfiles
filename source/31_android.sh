# Mount the Android file image
function mountAndroid { hdiutil attach ~/android.dmg.sparseimage -mountpoint /Volumes/android; }

# Unmount the Android file image
function umountAndroid() { hdiutil detach /Volumes/android; }

function heapdump(){
  jmap -dump:live,format=b,file=$1 $2
}