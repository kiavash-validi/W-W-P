#!/bin/bash

# به‌روزرسانی و ارتقاء سیستم
echo "در حال به‌روزرسانی و ارتقاء سیستم..."
sudo apt-get update && sudo apt-get upgrade -y

# نصب impacket
echo "در حال نصب impacket..."
sudo apt-get install impacket-scripts -y

# نصب ابزارهای مورد نیاز برای chromepass
echo "در حال نصب ابزارهای مورد نیاز برای chromepass..."
sudo apt-get install libnss3-tools sqlite3 -y

# نصب firefox_decrypt
echo "در حال نصب firefox_decrypt..."
sudo apt-get install git python3-setuptools -y
git clone https://github.com/unode/firefox_decrypt
cd firefox_decrypt
sudo python3 setup.py install
cd ..
rm -rf firefox_decrypt

echo "نصب پیش‌نیازها با موفقیت انجام شد."
