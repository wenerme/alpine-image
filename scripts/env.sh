

# when using as --rcfile
[ -f $HOME/.bashrc ] && . $HOME/.bashrc || true

[ -f "$conf" ] && . "$conf" || true

: ${profile:=${FLAVOR}}
# Arch hooks load before profile hooks, so a profile such as rpi can still override them.
[ -f "scripts/arch-${ARCH:-x86_64}-pre.sh" ] && . "scripts/arch-${ARCH:-x86_64}-pre.sh" || true
[ -f "scripts/${profile}-pre.sh" ] && . "scripts/${profile}-pre.sh" || true

. scripts/functions.sh
. scripts/utils.sh
. scripts/preset.sh

. scripts/images.sh
. scripts/setups.sh
. scripts/confs.sh
. scripts/users.sh

[ -f "scripts/arch-${ARCH:-x86_64}-post.sh" ] && . "scripts/arch-${ARCH:-x86_64}-post.sh" || true
[ -f "scripts/${profile}-post.sh" ] && . "scripts/${profile}-post.sh" || true

env-load(){
  . scripts/env.sh
}


