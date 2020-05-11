function is_sudo_exec() {
    local ROOT_UID=0
    if [ ! $UID -eq $ROOT_UID ]; then
        echo "Please, execute this shell script with SUDO privilege!"
        exit 0
    fi
}

function upsert_line() {
    local file=$1
    local key=$2
    local val=$3
    local delim=$4
    local line=$(grep ".*${key}[[:space:]]*${delim}" $file)

    if [[ -z $line ]]; then
        echo "(+) ${key}${delim}${val}"
        echo "${key}${delim}${val}" | tee -a $file > /dev/null
    else
        echo "(-) $line"
        echo "(+) ${key}${delim}${val}"
        sed -ie "s|.*${key}[[:space:]]*${delim}.*|${key}${delim}${val}|" $file
    fi
}
