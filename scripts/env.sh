

# when using as --rcfile
[ -f $HOME/.bashrc ] && . $HOME/.bashrc || true

[ -f "$conf" ] && . "$conf" || true

: ${profile:=${FLAVOR}}
[ -f "scripts/${profile}-pre.sh" ] && . "scripts/${profile}pre.sh" || true

. scripts/functions.sh
. scripts/utils.sh
. scripts/preset.sh

. scripts/images.sh
. scripts/setups.sh
. scripts/confs.sh
. scripts/users.sh

[ -f "scripts/${profile}-post.sh" ] && . "scripts/${profile}-post.sh" || true

env-load(){
  . scripts/env.sh
}


