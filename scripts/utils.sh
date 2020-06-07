
qemu-arch-detect(){
  case $$1 in
  armhf)
    echo -n arm
    ;;
  *)
    echo -n $1
    ;;
  esac
}
