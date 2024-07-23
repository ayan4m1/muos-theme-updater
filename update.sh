#!/bin/sh

if [ ! -f /opt/muos/script/var/func.sh ]; then
  echo "Anbernic scripts were not found! Looks like you're running on your desktop... Exiting!"
  exit 1
fi

. /opt/muos/script/var/func.sh

. /opt/muos/script/var/device/storage.sh

if [ ! -d "${DC_STO_ROM_MOUNT}/theme" ]; then
  echo "Theme directory was not found! Looks like you're running on your desktop... Exiting!"
  exit 1
fi

pkill -STOP muxtask

WIFI_CONNECTED=$(ping -n 1 github.com | grep Reply | wc -l)

if [ "$WIFI_CONNECTED" = "0" ]; then
  echo "You do not appear to be connected to the internet. Exiting!"
  exit 1
fi

for FILE in "${DC_STO_ROM_MOUNT}/theme/*.zip"; do
  THEME_FILENAME=$(basename -s ".zip" "$FILE")
  THEME_NAME=$(echo "$THEME_FILENAME" | sed -r 's/\./ /g')

  echo "Processing theme ${THEME_NAME}"

  THEME_INDEX=$(curl -o /dev/null -s -w "%{http_code}" "https://github.com/MustardOS/theme/tree/main/${THEME_NAME}")

  if [ "$THEME_INDEX" = "404" ]; then
    echo "Skipping theme ${THEME_NAME} because it was not found in the theme repository. Check the filename: ${THEME_FILENAME}"
    continue
  fi

  echo "Updating ${THEME_NAME} to latest version..."
  curl -o "/tmp/${FILE}" "https://github.com/MustardOS/theme/releases/latest/download/${FILE}"

  echo "Running extract script on newly downloaded theme..."
  /bin/sh "${DC_STO_ROM_MOUNT}/script/mux/extract.sh" "/tmp/${FILE}"

  rm "/tmp/${FILE}"
done

echo "Completed updating themes!"
sleep 2
pkill -CONT muxtask
exit 0