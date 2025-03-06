echo "First task"
awk '/session opened for user/ {split ($1, a, "T"); print a[1]}' /var/log/auth.log | sort | uniq -c
echo "\n Second Task"
wc -l /var/log/auth.log
echo "\n Third task"
ps -eu evanwoo | tee allProcesses.log
echo "\n Fourth Task"
sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}T//' /var/log/auth.log | tee auth_clean.log
sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2} //' /var/log/auth.log | tee cloud-init_clean.log
diff auth_clean.log cloud-init_clean.log
