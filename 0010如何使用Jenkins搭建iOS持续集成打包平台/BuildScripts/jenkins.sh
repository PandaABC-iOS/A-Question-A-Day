#!/bin/bash
# author: JM<jimmy.zhang@pdabc.com>
# lastUpdate: 2020.3.10

function initialEnv() {
    #Shell基本信息
    echo 🤖==================== Shell基本信息 ====================
    
    APP_NAME="iPadN"
    echo 🤖app名称:$APP_NAME
    
    PROJECT_SCHEME="iPadN"
    echo 🤖scheme:$PROJECT_SCHEME
    
    PROJECT_XCCONFIG=$xcconfig
    echo 🤖xcconfig:$PROJECT_XCCONFIG

    SHELL_BUNDLE_PATH=$( cd "$( dirname "$0"  )" && pwd )
    echo 🤖shell路径：$SHELL_BUNDLE_PATH
    
    JQ_PATH="$SHELL_BUNDLE_PATH/jq"
    chmod +x $JQ_PATH
    echo 🤖JQ路径：$JQ_PATH

    echo 🤖==================== Repo基本信息 ====================
    cd ..
    LOCAL_REPO_PATH=`pwd`
    echo 🤖本地Repo路径：$LOCAL_REPO_PATH

    PODFILE_PATH=`pwd`
    echo 🤖podfile路径：$PODFILE_PATH

    WORKSPACE_ABSOLUTE_PATH="$LOCAL_REPO_PATH/$PROJECT_SCHEME.xcworkspace"
    echo 🤖workSpace绝对路径：$WORKSPACE_ABSOLUTE_PATH

    EXPORT_OPTIONS_PLIST="$LOCAL_REPO_PATH/ExportOptions/$PROJECT_XCCONFIG.plist"
    echo 🤖开发环境包Archive导出配置地址：$EXPORT_OPTIONS_PLIST

    echo 🤖==================== 打包参数信息 ====================
    cd ~
    ARCHIVE_OUTPUT_FOLDER_PATH=`pwd`
    echo 🤖打包输出目录：$ARCHIVE_OUTPUT_FOLDER_PATH

    ARCHIVE_FOLDER_PATH="$ARCHIVE_OUTPUT_FOLDER_PATH/$APP_NAME/$PROJECT_XCCONFIG/"`date "+%F-%T"`
    echo 🤖此次打包输出目录：$ARCHIVE_FOLDER_PATH
    mkdir -p $ARCHIVE_FOLDER_PATH

    ARCHIVE_PATH="$ARCHIVE_FOLDER_PATH/$PROJECT_SCHEME.xcarchive"
    echo 🤖archive文件目标路径：$ARCHIVE_PATH

    IPA_FOLDER_PATH="$ARCHIVE_FOLDER_PATH/ipa"
    echo 🤖ipa文件夹目标路径：$IPA_FOLDER_PATH
    
    IPA_PATH="$IPA_FOLDER_PATH/$PROJECT_SCHEME.ipa"
    echo 🤖.ipa文件路径：$IPA_PATH

    echo 🤖==================== 钉钉 ====================
    DINGDING_PATH="$SHELL_BUNDLE_PATH/dingding.sh"
    echo 🤖钉钉路径：$DINGDING_PATH
}

function clean() {
    echo 🤖Cleanning...

    xcodebuild clean \
    -workspace $WORKSPACE_ABSOLUTE_PATH \
    -scheme $PROJECT_SCHEME \
    -configuration $PROJECT_XCCONFIG

    local result=$?
    echo 😳结果：$result
    return $result
}

function build() {
    echo 🤖Building...

    xcodebuild archive \
    -workspace $WORKSPACE_ABSOLUTE_PATH \
    -scheme $PROJECT_SCHEME \
    -configuration $PROJECT_XCCONFIG \
    -archivePath $ARCHIVE_PATH

    local result=$?
    echo 😳结果：$result
    return $result
}

function archive() {
    # $1:exportOptionsPlist path
    echo 🤖Achiving...
    
    echo 第一个参数的值为 $1

    xcodebuild -exportArchive \
    -archivePath $ARCHIVE_PATH \
    -exportPath $IPA_FOLDER_PATH \
    -exportOptionsPlist $1

    local result=$?
    echo 😳结果：$result
    return $result
}

function uploadIPA() {

    echo 🤖uploading IPA...
    
    #蒲公英上的User Key
    uKey="f2f18dbfcd54617609cf5acaeb3d1bea"

    #蒲公英上的API Key
    apiKey="08d5cd829657242849432916de5d9077"
    
    PASSWORD=123456
    
    local result=`curl -F "file=@${IPA_PATH}" -F "uKey=${uKey}" -F "_api_key=${apiKey}" -F "installType=2" -F "password=${PASSWORD}"  http://www.pgyer.com/apiv1/app/upload`

    echo 😳结果：$result
    local resultCode=`echo $result | $JQ_PATH '.code'`
    
    echo 😳retcode:$resultCode
    
    return $resultCode
}

function generateResultReport() {
    local PLISTPATH="$LOCAL_REPO_PATH/iPadN/main/iPadN.plist"
    echo 🤖plist的位置：$PLISTPATH

    local APP_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${PLISTPATH}")
    echo 🤖App版本号 $APP_VERSION

    local APP_BUILD_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${PLISTPATH}")
    echo 🤖App Build Version: $APP_BUILD_VERSION

    local APP_FINAL_NAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDisplayName" "${PLISTPATH}")
    echo 🤖app名称：$APP_FINAL_NAME

    cd $SHELL_BUNDLE_PATH
    ./dingding.sh $branch
}

function reportFailed() {
    cd $SHELL_BUNDLE_PATH
    ./dingding_failed.sh
}

#======= 正文 =======

initialEnv

clean
if [ $? -ne 0 ]; then
    reportFailed
    echo ❌clean失败！
    exit -1
fi

build
if [ $? -ne 0 ]; then
    reportFailed
    echo ❌build失败！
    exit -1
fi

archive $EXPORT_OPTIONS_PLIST
if [ $? -ne 0 ]; then
    reportFailed
    echo ❌archive失败！
    exit -1
fi

uploadIPA
if [ $? -ne 0 ]; then
    reportFailed
    echo ❌upload失败，请手动上传IPA包！
    exit -1
fi

generateResultReport

