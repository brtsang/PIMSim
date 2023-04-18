#!/bin/bash

LONGOPTS=title,color,help
OPTIONS=t:c:h

PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS  --name "$0" -- "$@")

if [[ ${PIPESTATUS[0]} -ne 0  ]]; then
    exit 2
fi

eval set -- "$PARSED"

t="A Message From Bash" c=14090495

while true; do
    case "$1" in
        -t|--title)
            t="$2"
            shift 2
            ;;
        -c|--color)
            c=`bin/hextoint.sh $2`
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-t|--title? \"titletext\"] [-c|--color? \"SOME_HEX_CODE\"] \"Text To Display In Embed!!\""
            exit 1;
            ;;
        --)
            shift
            break
            ;;
        *)
            echo uh error idk $1
            echo "Usage: $0 [-t|--title? \"titletext\"] [-c|--color? \"SOME_HEX_CODE\"] \"Text To Display In Embed!!\""
            echo "t\`$t\` c\`$c\` 1\`$1\`"
            break
            ;;
    esac
done

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 [-t|--title? \"titletext\"] [-c|--color? \"SOME_HEX_CODE\"] \"Text To Display In Embed!!\""
    exit 4
fi

HOOKURL="https://discord.com/api/webhooks/1097986084262138109/5jN4bS9j03yDQSbJ2J24JxNCzYSqYA3qWfyMUmQRdwSqh5NmyVn7KlEpChqrzdVeVTOg"

AVATARURL="https://icon-library.com/images/terminal-icon-png/terminal-icon-png-6.jpg"

curl --location --request POST $HOOKURL \
    --header 'Content-Type: application/json' \
    --header 'Cookie: __cfruid=949b7e919cd23be12abdcdac5bf35ca6551eb9b5-1648524188; __dcfduid=8e0cbc1aaf0f11ec83634ad09f66caf5; __sdcfduid=8e0cbc1aaf0f11ec83634ad09f66caf5876e78c8bb8e60253431089238b1b6a61374228c4ef5e3d309bcc41d8eb5892c' \
    --data-raw "{
    \"content\": \"\",
    \"avatar_url\": \"$AVATARURL\",
    \"embeds\": [
    {
        \"title\": \"$t\",
        \"color\": $c,
        \"description\": \"$1\",
        \"footer\": {
        \"text\": \"Message sent by `whoami`@`hostname`\"
    }
}
]
}"
