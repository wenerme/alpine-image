
setup-user-admin(){
cat <<SH | chmnt /bin/sh
  apk add shadow sudo

  adduser -D admin
  # sudo NOPASSWORD
  echo 'admin ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
  echo admin:${ADMIN_PASSWORD:-admin} | chpasswd

  adduser admin adm
SH
}
