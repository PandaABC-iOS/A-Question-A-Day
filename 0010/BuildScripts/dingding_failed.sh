time=$(date "+%Y-%m-%d %H:%M:%S")
curl 'https://oapi.dingtalk.com/robot/send?access_token=13170c3925dcd0a1eebe6c511e36dc03daab4b4c130495fcc6e28a2ce0cf21ac' \
    -H 'Content-Type: application/json' \
    -d '
{
    "msgtype": "markdown",
    "markdown": {
    "text":"iPadN打包失败了，大兄弟",
    },
    "at": {
        "atMobiles": [],
        "isAtAll": false
          }
}'


