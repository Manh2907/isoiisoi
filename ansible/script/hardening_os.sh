#!/bin/bash
# Đồ án Giám sát & Bảo mật hệ thống - Nhóm 27
# Người thực hiện: Nguyễn Vũ Quang Minh & Team

# 1. Kiểm tra quyền Root
if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy với quyền root (sudo)"
  exit 1
fi

# 2. Cài đặt các gói bổ trợ bảo mật cần thiết
echo "--- Đang cài đặt các gói bảo mật (ntp, rsyslog, logrotate...) ---"
packages=("ntp" "libpam-cracklib" "rsyslog" "logrotate" "libpam-modules")
apt-get update -y
for pkg in "${packages[@]}"; do
    apt-get install -y "$pkg"
done

# 3. Vô hiệu hóa các dịch vụ không an toàn (Bluetooth, CUPS)
echo "--- Vô hiệu hóa Bluetooth và CUPS (In ấn) để giảm bề mặt tấn công ---"
systemctl stop bluetooth cups 2>/dev/null
systemctl disable bluetooth cups 2>/dev/null

# 4. Thắt chặt chính sách mật khẩu (/etc/login.defs)
echo "--- Cấu hình thời hạn mật khẩu (90 ngày) ---"
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs

# 5. Cấu hình PAM (Độ phức tạp mật khẩu & Chống Brute Force)
PAM_FILE="/etc/pam.d/common-password"
echo "--- Cấu hình độ phức tạp mật khẩu (minlen=8, u/l/d/o credits) ---"
# Sao lưu trước khi sửa
cp $PAM_FILE $PAM_FILE.bak-$(date +%Y%m%d)
# Cấu hình: tối thiểu 8 ký tự, ít nhất 1 chữ hoa, 1 chữ thường, 1 số, 1 ký tự đặc biệt
if ! grep -q "pam_cracklib.so" $PAM_FILE; then
    echo "password requisite pam_cracklib.so minlen=8 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1" >> $PAM_FILE
fi

# 6. Thắt chặt cấu hình SSH (/etc/ssh/sshd_config)
SSHD_CONFIG="/etc/ssh/sshd_config"
echo "--- Thắt chặt bảo mật SSH (Tắt Root login, đổi Protocol 2) ---"
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' $SSHD_CONFIG
sed -i 's/^#Protocol.*/Protocol 2/' $SSHD_CONFIG
sed -i 's/^#ClientAliveInterval.*/ClientAliveInterval 100/' $SSHD_CONFIG
sed -i 's/^#ClientAliveCountMax.*/ClientAliveCountMax 3/' $SSHD_CONFIG
systemctl restart sshd

# 7. Thiết lập Timeout cho người dùng (Tự động logout sau 5 phút idle)
echo "--- Thiết lập TMOUT=300 (5 phút) cho hệ thống ---"
if ! grep -q "TMOUT=300" /etc/profile; then
    echo "TMOUT=300" >> /etc/profile
    echo "readonly TMOUT" >> /etc/profile
    echo "export TMOUT" >> /etc/profile
fi

# 8. Cấu hình Ghi nhật ký lệnh (Command Logging - Rất quan trọng cho Loki)
echo "--- Cấu hình CMDLOG để ghi lại mọi lệnh user đã gõ ---"
BASHRC="/etc/bash.bashrc"
CMDLOG_STR="export PROMPT_COMMAND='RETRN_VAL=\$?;logger -p local6.debug \"[cmdlog] \$(whoami) [\$\$]: \$(history 1 | sed \"s/^[ ]*[0-9]\\+[ ]*//\" ) [\$RETRN_VAL] [\$(echo \$SSH_CLIENT | cut -d\" \" -f1)]\"'"

if ! grep -q "cmdlog" $BASHRC; then
    echo "$CMDLOG_STR" >> $BASHRC
fi

# 9. Phân quyền cho file hệ thống nhạy cảm
echo "--- Phân quyền an toàn cho crontab ---"
chown root:root /etc/crontab
chmod 600 /etc/crontab

# 10. Hoàn tất
echo "--- Hardening OS hoàn tất lúc: $(date) ---"
