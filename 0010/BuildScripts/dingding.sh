time=$(date "+%Y-%m-%d %H:%M:%S")

JSON_FMT='{
    "msgtype": "markdown",
    "markdown": {
    "title":"1VN iPad 学生端 内测版 已打包上传到蒲公英",
    "text":"1VN **iPad** 学生端 **%s包** 已打包上传到蒲公英  \n  > **下载链接**： https://www.pgyer.com/ACiPadQA  \n > **密码**：123456 \n > **打包时间**： '"$time"'  \n  > **注意事项**：App默认使用正式服，测试时请根据需要自行切换相应的服务器 "
    },
    "at": {
        "atMobiles": [],
        "isAtAll": false
          }
}'

json=$(printf "$JSON_FMT" "$1")

echo $json

curl 'https://oapi.dingtalk.com/robot/send?access_token=13170c3925dcd0a1eebe6c511e36dc03daab4b4c130495fcc6e28a2ce0cf21ac' \
    -H 'Content-Type: application/json' \
    -d "$json"




