variable "mirror" {
  default = "https://mirrors.aliyun.com/alpine"
}
variable "version" {
  default = "3.12.0"
}
variable "flavor" {
  default = "virt"
}

variable "size" {
  default = "40G"
}
variable "format" {
  default = "qcow2"
  description = "qcow2, raw"
}

variable "accel" {
  default = "hvf"
  description = "hvf for macOS"
}
variable "boot_wait" {
  default = "10s"
  description = "if no accel, should set at least 30s"
}
variable "dist" {
  default = ""
}

locals {
  ver = regex_replace(var.version, "[.][0-9]+$", "")
  checksums = {
    "alpine-virt-3.12.0-x86_64.iso": "sha256:fe694a34c0e2d30b9e5dea7e2c1a3892c1f14cb474b69cc5c557a52970071da5"
  }
}

source "qemu" "alpine" {
  iso_url = "${var.mirror}/v${local.ver}/releases/x86_64/alpine-virt-${var.version}-x86_64.iso"
  iso_checksum = local.checksums["alpine-virt-${var.version}-x86_64.iso"]
  // display = "cocoa"
  headless = true
  accelerator = var.accel
  ssh_username = "root"
  ssh_password = "root"
  ssh_timeout = "2m"

  boot_key_interval = "10ms"
  boot_wait = var.boot_wait
  boot_command = [
    "root<enter>",
    "setup-interfaces -a<enter>",
    "service networking restart<enter>",
    "echo root:root | chpasswd<enter><wait5>",
    "setup-sshd -c openssh<enter>",
    "echo PermitRootLogin yes >> /etc/ssh/sshd_config<enter>",
    "service sshd restart<enter>",
  ]

  disk_size = var.size
  format = var.format

  output_directory = var.dist
}

build {
  source "qemu.alpine" {}

  provisioner "shell" {

    inline = [
<<-EOF
: $${ALPINE_MIRROR:=https://mirrors.aliyun.com/alpine}
: $${ALPINE_FLAVOR:=virt}
: $${ALPINE_VER:=$(egrep -o 'VERSION_ID=[0-9]+[.]+[0-9]+' /etc/os-release | egrep -o '[0-9]+[.]+[0-9]+')}
echo Building $${ALPINE_VER} using $${ALPINE_MIRROR}
echo $${ALPINE_MIRROR}/v$${ALPINE_VER}/main > /etc/apk/repositories
echo $${ALPINE_MIRROR}/v$${ALPINE_VER}/community >> /etc/apk/repositories
rc-update add networking
ERASE_DISKS=/dev/vda setup-disk -m sys -s 0 -k $${ALPINE_FLAVOR} /dev/vda
EOF
    ]
    environment_vars = [
      "ALPINE_MIRROR=${var.mirror}",
      "ALPINE_FLAVOR=${var.flavor}",
    ]
  }
}
