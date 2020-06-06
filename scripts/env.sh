

# when using as --rcfile
[ -f $HOME/.bashrc ] && . $HOME/.bashrc 

[ -f "$conf" ] && . "$conf"

: ${profile:=${FLAVOR}}
[ -f "scripts/${profile}-pre.sh" ] && . "scripts/${profile}pre.sh"

. scripts/functions.sh
. scripts/utils.sh
. scripts/preset.sh

. scripts/images.sh
. scripts/setups.sh
. scripts/confs.sh
. scripts/users.sh

[ -f "scripts/${profile}-post.sh" ] && . "scripts/${profile}-post.sh"

env-load(){
  . scripts/env.sh
}


