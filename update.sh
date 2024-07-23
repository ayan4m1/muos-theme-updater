#!/bin/sh

if [ ! -f /opt/muos/script/var/func.sh ]; then
  echo "Anbernic scripts were not found! Looks like you're running on your desktop... Exiting!"
  exit 1
fi

if [ ! -d /mnt/mmc/MUOS/theme ]; then
  echo "Theme directory was not found! Looks like you're running on your desktop... Exiting!"
  exit 1
fi

. /opt/muos/script/var/func.sh

WIFI_CONNECTED=$(ping -n 1 8.8.8.8 | grep Reply | wc -l)

if [ "$WIFI_CONNECTED" = "0" ]; then
  echo "You do not appear to be connected to the internet. Exiting!"
  exit 1
fi

for FILE in /mnt/mmc/MUOS/theme/*.zip; do
  THEME_FILENAME=$(basename -s ".zip" "$FILE")
  THEME_NAME=$(echo "$THEME_FILENAME" | sed -r 's/\./ /g')

  echo "Processing theme ${THEME_NAME}"

  THEME_INDEX=$(curl -o /dev/null -s -w "%{http_code}\n" "https://github.com/MustardOS/theme/tree/main/${THEME_NAME}")

  if [ "$THEME_INDEX" = "404" ]; then
    echo "Skipping theme ${THEME_NAME} because it was not found in the theme repository. Check the filename."
    continue
  fi

  echo "Updating ${THEME_NAME} to latest version..."
  curl -o "/mnt/mmc/MUOS/theme/${FILE}" "https://github.com/MustardOS/theme/releases/latest/download/${FILE}"

  # todo: run theme install (how?)
done