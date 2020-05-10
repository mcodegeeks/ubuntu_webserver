function readConfig() {
    local file=$1
    local key=$2

    grep ".*${key}[ \t][ \t]*.*" $file | cut -d ' ' -f2
}

function writeConfig() {
    local file=$1
    local key=$2
    local val=$3

    grep ".*${key}[ \t][ \t]*.*" $file > /dev/null
    if [ ! "$?" -eq 0 ]; then
        echo "${key} ${val}" | tee -a $file > /dev/null
    else
       sed -ie "s/.*${key}[ \t][ \t]*.*/${key} ${val}/g" $file
    fi
}

function updateConfig() {
    local file=$1
    local key=$2
    local newVal=$3
    local oldVal=$(readConfig $file $key)
    if [ ! $newVal -eq $oldVal ]; then
        writeConfig $file $key $newVal
        newVal=$(readConfig $file $key)
        echo "ClientAliveInterval: ${newVal} (was ${oldVal})"
    else
        echo "ClientAliveInterval: ${oldVal}"
    fi
}
