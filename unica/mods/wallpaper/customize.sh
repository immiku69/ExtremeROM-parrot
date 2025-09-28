SOURCE_MODEL=$(echo -n "$SOURCE_FIRMWARE" | cut -d "/" -f 1)
TARGET_MODEL=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 1)

DELETE_FROM_WORK_DIR "system" "system/priv-app/wallpaper-res/wallpaper-res.apk"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/priv-app/wallpaper-res/wallpaper-res.apk" 0 0 644 "u:object_r:system_file:s0"
