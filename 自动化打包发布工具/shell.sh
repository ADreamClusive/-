#使用方法

# 创建目录
#if [ ! -d ./IPADir ];
#then
#mkdir -p IPADir;
#fi

#!/bin/sh

# sudo xcode-select -s "/Applications/Xcode.app"
#
## ------- 参数获取 ----------
TARGET_NAME=$1
SCHEME=$2
SOURCEPATH=$3
cEXPORTPATH=$4
number=2
EXPORTOPTIONSPLIST=$5
COMMENTS=$6


# ------- 变量配置 ------------
#TARGET_NAME=ADreamClusiveModel                    ## 项目名
#SCHEME=ADreamClusiveModel                         ## Scheme名
BUILD_TYPE=Debug                            ## 编译类型
#SOURCEPATH=$PWD                            ##当前目录
WORKSPACE=$SOURCEPATH/${TARGET_NAME}.xcworkspace ## workspace名
#ARCHIVEPATH=$SOURCEPATH/$TARGET_NAME.xcarchive      ##xcarchive文件的存放路径
# 格式化时间获取
DATE=`date +%Y-%m-%d-%H-%M-%S`
#EXPORTPATH=$SOURCEPATH/IPADir/$DATE                      ## ipa文件的存放路径
EXPORTPATH=$cEXPORTPATH/$DATE
ARCHIVEPATH=$EXPORTPATH/$TARGET_NAME.xcarchive
IPAFILE=${EXPORTPATH}/${TARGET_NAME}-$DATE.ipa        ## ipa文件
#EXPORTOPTIONSPLIST=$SOURCEPATH/ExportOptions.plist  ## ExportOptions.plist文件的存放路径

#echo "Place enter the number you want to export ? [ 1:app-store 2:development] "
#
#read number
#while([[ $number != 1 ]] && [[ $number != 2 ]])
#do
#echo "Error! Should enter 1 or 2"
#echo "Place enter the number you want to export ? [ 1:app-store 2:development] "
#read number
#done

#if [ $number == 1 ];then
#    BUILD_TYPE=Release                            ## 编译类型
#    EXPORTOPTIONSPLIST=${SOURCEPATH}/exportAppstore.plist
#else
#    BUILD_TYPE=Debug                            ## 编译类型
#    EXPORTOPTIONSPLIST=${SOURCEPATH}/ExportOptions.plist
#fi

# ------- 正式打包任务开始 ------------
echo '/// 正在清理工程'

# 清理缓存
xcodebuild clean -workspace $WORKSPACE -scheme ${SCHEME} -configuration ${BUILD_TYPE} -quiet  || exit

echo '/// 清理完成'
# 输出关键信息 echo -e : 处理特殊字符
echo -e "  TARGET_NAME   : ${TARGET_NAME}"
echo -e "  BUILD_TYPE    : ${BUILD_TYPE}"
echo -e "  SOURCEPATH    : ${SOURCEPATH}"
echo -e "  ARCHIVEPATH    : ${ARCHIVEPATH}"
echo -e "  EXPORTPATH    : ${EXPORTPATH}"
echo -e "  EXPORTOPTIONSPLIST    : ${EXPORTOPTIONSPLIST}"
echo '/// 正在编译工程:'${BUILD_TYPE}

# 导出archive包
xcodebuild \
archive -workspace ${WORKSPACE} \
-scheme ${SCHEME} \
-configuration ${BUILD_TYPE} \
-archivePath $ARCHIVEPATH \
-quiet  || exit

echo '/// 编译完成'
echo '/// 开始ipa打包'

#导出IPA包
xcodebuild -exportArchive -archivePath $ARCHIVEPATH \
-configuration ${BUILD_TYPE} \
-exportPath ${EXPORTPATH} \
-exportOptionsPlist ${EXPORTOPTIONSPLIST} \
-quiet || exit


if [ -e $EXPORTPATH ]; then
    echo '/// ipa包已导出'
    mv $EXPORTPATH/${TARGET_NAME}.ipa $IPAFILE
#    open $EXPORTPATH
else
    echo '/// ipa包导出失败 '
fi

echo '/// 打包ipa完成  '
echo '/// 开始发布ipa包 '

# ------- 上传蒲公英并发送邮件开始 ------------

#if [ $number == 1 ];then
#
##验证并上传到App Store
## 将-u 后面的XXX替换成自己的AppleID的账号，-p后面的XXX替换成自己的密码
#altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
#"$altoolPath" --validate-app -f ${IPAFILE} -u 2506513065@qq.com -p mmgz-kxmd-ogwg-bful -t ios --output-format xml
#"$altoolPath" --upload-app -f ${IPAFILE} -u  2506513065@qq.com -p mmgz-kxmd-ogwg-bful -t ios --output-format normal
#else
#
#
##上传到Fir
## 将XXX替换成自己的Fir平台的token
#fir login -T XXX
#fir publish $exportIpaPath/$scheme_name.ipa

# 如果只上传，可以用这个
#TARGET_NAME=ADreamClusiveModel                    ## 项目名
#SOURCEPATH=$PWD                                   ##当前目录
#EXPORTPATH=$SOURCEPATH/../IPADir                  ## ipa文件的存放路径
#IPAFILE=${EXPORTPATH}/${TARGET_NAME}.ipa        ## ipa文件
#
## ------ 蒲公英API 2.0版本 ------
##蒲公英上的User Key
#uKey="e3a5af5c2dba1487c4859114ea465b32"
##蒲公英上的API Key
apiKey="387f4cba1e23e922bb27a4dbe1a2bcaa"
##要上传的ipa文件路径
##执行上传至蒲公英的命令，这句不需要修改
##curl -F "file=@${IPAFILE}" -F "uKey=${uKey}" -F "_api_key=${apiKey}"  https://www.pgyer.com/apiv1/app/upload
#
## 设置为密码安装： 密码：111111
##curl -F "file=@${IPAFILE}" -F "_api_key=${apiKey}" -F "buildInstallType=2" -F " buildPassword=111111"  https://www.pgyer.com/apiv2/app/upload
#
# -o : 完成后将返回的response数据输出到这个文件
# -# : 显示上传进度
# -OLv : 显示详情
# -s : 静默状态完成任务，不会输出任何信息到控制台
curl https://www.pgyer.com/apiv2/app/upload \
    -X POST \
    -F "file=@${IPAFILE}" \
    -F "_api_key=${apiKey}" \
    -F "buildInstallType=2" \
    -F "buildPassword=111111" \
    -F "buildUpdateDescription=${COMMENTS}" \
    -o ./response.json \
    -s

#fi

exit 0
