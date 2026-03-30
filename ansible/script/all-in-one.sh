#!/bin/bash
LOG_FILE="/var/log/sysadmin_script.log"
BACKUP_DIR="/backup/config_$(date +%F)"
SERVICES=("ssh" "docker" "nginx")
CPU_A=80
MEM_A=80

echo "=====$(date)=====" >> $LOG_FILE

#1 Kiem tra trang thai dich vu
echo "[INFO] Checking services...." >> $LOG_FILE
for service in "${SERVICES[@]}"; do
	systemclt is-active --quite $service
	if [ $? -q 0 ]; then
		echo "[OK] $service is running well" >>	$LOG_FILE
	else 
		echo "[ERROR] $service is not active" >> $LOG_FILE
		systemctl start $service
		echo "[ACTIVE] restart $service" >> $LOG_FILE
	fi
done
#2 Don dep he thong
echo "[INFO] Clearning system...." >> $LOG_FILE
apt-get clean -y
apt-get autoremove -y
journalctl --vacuum-time=7d
echo "[OK System cleaned]" >> $LOG_FILE
#3 Backup cau hinh
echo "[INFO] Backup configs..." >> $LOG_FILE
mkdir -p $BACKUP_DIR
cp -r /etc/nginx $BACKUP_DIR 2>/dev/null
cp -r /etc/ssh $BACKUP_DIR 2>/dev/null
cp -r /etc/passwd $BACKUP_DIR 2>/dev/null
cp -r /etc/group $BACKUP_DIR 2>/dev/null
echo "[OK] Backup done at $BACKUP_DIR"	>> $LOG_FILE
#4.Chan ip la
echo "[INFO] Checking IP ..." >> $LOG_FILE
lastb | awk '{print $3}' | sort | uniq -c | sort -nr | while read count ip; do
	if ["$count" -gt 5]; then
		iptables -A INPUT -s $ip -j DROP
		echo "[Blocked] $ip blocked (falied login: $count)" >> $LOG_FILE
	fi
done
#5.Giam sat tien trinh tai nguyen














