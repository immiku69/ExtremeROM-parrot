echo "Patch Vendor fstab for Erofs"

sed -i \
    -e "s/vendor\t\/vendor\tf2fs/vendor\t\/vendor\terofs/g" \
    -e "s/system_ext\t\/system_ext\tf2fs/system_ext\t\/system_ext\terofs/g" \
    -e "s/product\t\/product\tf2fs/product\t\/product\terofs/g" \
    -e "s/vendor_dlkm\t\/vendor_dlkm\tf2fs/vendor_dlkm\t\/vendor_dlkm\terofs/g" \
    -e "s/odm\t\/odm\tf2fs/odm\t\/odm\terofs/g" \
    "$WORK_DIR/vendor/etc/fstab.qcom"

echo "Patch Vendor_boot fstab for Erofs"

declare -a MKBOOTIMG_ARGS_ARRAY=()
while IFS= read -r -d '' ARG; do
    MKBOOTIMG_ARGS_ARRAY+=("${ARG}")
done < <(unpack_bootimg --boot_img "$WORK_DIR/kernel/vendor_boot.img" --out "$WORK_DIR/vendor_boot" --format=mkbootimg -0)

mkdir -p "$WORK_DIR/vendor_boot/ramdisk"
lz4 -dc "$WORK_DIR/vendor_boot/vendor_ramdisk00" | (cd "$WORK_DIR/vendor_boot/ramdisk" && cpio -i -m -d)

sed -i \
    -e "s/vendor\t\/vendor\tf2fs/vendor\t\/vendor\terofs/g" \
    -e "s/system_ext\t\/system_ext\tf2fs/system_ext\t\/system_ext\terofs/g" \
    -e "s/product\t\/product\tf2fs/product\t\/product\terofs/g" \
    -e "s/vendor_dlkm\t\/vendor_dlkm\tf2fs/vendor_dlkm\t\/vendor_dlkm\terofs/g" \
    -e "s/odm\t\/odm\tf2fs/odm\t\/odm\terofs/g" \
    "$WORK_DIR/vendor_boot/ramdisk/first_stage_ramdisk/fstab.qcom"

(cd "$WORK_DIR/vendor_boot/ramdisk" && find . | cpio -o -H newc | lz4) > "$WORK_DIR/vendor_boot/vendor_ramdisk00"
mkbootimg "${MKBOOTIMG_ARGS_ARRAY[@]}" --vendor_boot "$WORK_DIR/kernel/vendor_boot.img"
rm -rf "$WORK_DIR/vendor_boot"