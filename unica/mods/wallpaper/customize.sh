TARGET_FIRMWARE_PATH="$FW_DIR/$(echo -n "$TARGET_FIRMWARE" | sed 's./._.g' | rev | cut -d "_" -f2- | rev)"

echo "Replacing wallpaper-res.apk with target's stock wallpaper-res.apk..."

# Delete existing wallpaper-res.apk if exists
DELETE_FROM_WORK_DIR "system" "system/priv-app/wallpaper-res/wallpaper-res.apk"

# Add wallpaper-res.apk from target firmware
ADD_TO_WORK_DIR "$TARGET_FIRMWARE_PATH" "system" "system/priv-app/wallpaper-res/wallpaper-res.apk" 0 0 644 "u:object_r:system_file:s0"

sed -i "/system\/system\/priv-app\/wallpaper-res/d" "$WORK_DIR/configs/fs_config-system" \
    && sed -i "/system\/system\/priv-app\/wallpaper-res/d" "$WORK_DIR/configs/file_context-system"

while read -r i; do
    FILE="$(echo -n "$i"| sed "s.$WORK_DIR/system/..")"
    [ -d "$i" ] && echo "$FILE 0 0 755 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-system"
    [ -f "$i" ] && echo "$FILE 0 0 644 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-system"
    FILE="$(echo -n "$FILE" | sed 's/\./\\./g')"
    echo "/$FILE u:object_r:system_file:s0" >> "$WORK_DIR/configs/file_context-system"
done <<< "$(find "$WORK_DIR/system/system/priv-app/wallpaper-res")"

rm -f "$WORK_DIR/system/system/etc/vpl_apks_count_list.txt"
while read -r i; do
    FILE="$(echo "$i" | sed "s.$WORK_DIR/system..")"
    echo "$FILE" >> "$WORK_DIR/system/system/etc/vpl_apks_count_list.txt"
done <<< "$(find "$WORK_DIR/system/system/priv-app/wallpaper-res" -name "*.apk" | sort)"
