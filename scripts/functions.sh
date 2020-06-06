everbose() {
	if [ "$verbose" = "0" ]; then
		return
	fi

	echo $*
}

ewarn() {
	echo "WARNING:" $@ >&2
}

eerror() {
	echo "ERROR:" $@ >&2
	return 1
}

iscmd() {
    local n=0;
    if [[ "$1" = "-n" ]]; then
        n=1;
        shift;
    fi;
    command -v $1 > /dev/null;
    return $(( $n ^ $? ))
}
