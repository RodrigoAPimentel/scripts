#! /bin/bash

PACKAGE_MANAGER=''

YUM_CMD=$(which yum 2> /dev/null)
APT_GET_CMD=$(which apt-get 2> /dev/null)

if [[ ! -z $YUM_CMD ]]; then
    PACKAGE_MANAGER='yum'
elif [[ ! -z $APT_GET_CMD ]]; then
    PACKAGE_MANAGER='apt-get'
else
    echo "error can't identify package manager"
    exit 1;
fi

os=`hostnamectl | grep "Operating System" | cut -d ':' -f 2 | xargs`

# echo "$os"
echo "$PACKAGE_MANAGER"