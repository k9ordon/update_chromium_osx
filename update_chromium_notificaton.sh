LATEST=`curl -s http://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac/LAST_CHANGE`
CURRENT=`(defaults read /Applications/Chromium.app/Contents/Info.plist SCMRevision 2>/dev/null) | cut -d'#' -f 2 | grep -Eo "[[:digit:]]+" `
PROCESSID=`ps ux | awk '/Chromium/ && !/awk/ {print $2}'`

#osascript -e 'display notification "current: '$CURRENT' latest: '$LATEST'" with title "Chromium Update"'

if [ $LATEST -lt 1 ]; then
  osascript -e 'display notification "Cannot find repository" with title "Chromium Update"'
  exit 0
fi

if [[ $LATEST -eq $CURRENT ]]; then
  osascript -e 'display notification "Already up to date - '$LATEST'" with title "Chromium Update"'
  exit 0
fi

osascript -e 'display notification "Downloading '$LATEST' ..." with title "Chromium Update"'
curl -s -L "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac/$LATEST/chrome-mac.zip" -o /tmp/chrome-mac.zip
wait

osascript -e 'display notification "Installing '$LATEST' ..." with title "Chromium Update"'
unzip -o -qq /tmp/chrome-mac.zip -d /tmp
wait
for x in $PROCESSID; do
  kill -9 $x
done
rm -Rf /Applications/Chromium.app
wait
cp -R /tmp/chrome-mac/Chromium.app /Applications
wait
rm -rf /tmp/chrome-*

osascript -e 'display notification "Updated to '$LATEST'" with title "Chromium Update"'
open -Rf /Applications/Chromium.app
exit 0
