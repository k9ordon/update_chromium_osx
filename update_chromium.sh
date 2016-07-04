LATEST=`curl -s http://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac/LAST_CHANGE`
CURRENT=`(defaults read /Applications/Chromium.app/Contents/Info.plist SCMRevision 2>/dev/null) | cut -d'#' -f 2 | grep -Eo "[[:digit:]]+" `
PROCESSID=`ps ux | awk '/Chromium/ && !/awk/ {print $2}'`

echo 'current: '$CURRENT' latest: '$LATEST

if [ $LATEST -lt 1 ]; then
  echo 'Cannot find repository'
  exit 0
fi

if [[ $LATEST -eq $CURRENT ]]; then
  echo 'Already up to date - '$LATEST
  exit 0
fi

echo 'Downloading '$LATEST' ...'
curl -L "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac/$LATEST/chrome-mac.zip" -o /tmp/chrome-mac.zip
wait

echo 'Installing '$LATEST' ...'
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

echo 'Updated to '$LATEST
open -Rf /Applications/Chromium.app
exit 0
