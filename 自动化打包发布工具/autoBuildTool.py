#!/usr/bin/env python3
# coding=utf-8

import io
import json
import time
import os

def newPath(projectPath):
    # 获取路径的上级目录
    parentPath = os.path.abspath(os.path.dirname(projectPath))
    # 获取路径的最后一部分
    projectCurPath = os.path.basename(projectPath)
    # 工程新路径
    newPath = parentPath + "/" + projectCurPath + cDateTime
    # 测试
    newPath = projectPath
    return newPath

def copyToNewPath(oriPath, newPath):
    # 拷贝一份新工程 注意cp的参数
    commandStr = "cp -Rfi {} {}".format(oriPath, newPath)
    os.system(commandStr)
    
def archiveIPA(archiveConfig):
    projectName=archiveConfig["project_name"]
    schemaName = archiveConfig["scheme_name"]
    exportIPAPath = archiveConfig["export_ipa_path"]
    # 获取当前目录
    curPath = os.getcwd()
    exportOptionsPath = (curPath+"/ExportOptions.plist")
    
    # comments
    comments = archiveConfig["comments"]
    
    # 拼接命令
    commandStr = "./shell.sh {} {} {} {} {} {}".format(projectName, schemaName, newPath, exportIPAPath, exportOptionsPath, comments.encode('utf-8'))
    #    commandStr = commandStr.decode('utf-8').encode('gbk')
    print(commandStr)
    os.system(commandStr)

def subPullUpdate(projectPath, branchName):
    # 本地所有修改的。没有的提交的，都返回到原来的状态: [git checkout .]
    os.system("git -C {} checkout .".format(projectPath))
    # 切换分支
    os.system("git -C {} checkout {}".format(projectPath, branchName))
    # 拉取新内容
    os.system("git -C {} checkout .".format(projectPath))
    os.system("git -C {} pull origin {}".format(projectPath, branchName))

def pullUpadteContent(newPath, branchName):
    #    os.system("git checkout -b {} {}".format(git_project_branch_name, git_project_branch_name))
    # 每次保证master最新 -- 这一步不是必须的
#    subPullUpdate(newPath, "master")
    # 切换到branchname分支，拉取最新内容
    subPullUpdate(newPath, branchName)
    
# ---- 获取最近3条提交日志
def getPushLog(projectPath):
    logs = os.popen("git -C {} log --pretty=format:\"%ad : %s\" -3 --date=format:\"%Y-%m-%d %H:%M:%S\"".format(projectPath))
    return logs.read()
    
# ------ SendEmail ----------
import sys
import smtplib
from email.mime.text import MIMEText
from email.header import Header

def sendEmail(emailConfig):
    sender = emailConfig["mail_user_name"]
    password = emailConfig["password"]
    smtpserver = emailConfig["host"]
    receiver = emailConfig["to_user"]
    subject = emailConfig["subject"]
    content = emailConfig["body"] + "\n\n" + logs.decode('utf-8') + u"\n\n下载地址：https://www.pgyer.com/69nX"
    
    # ---- 使用QQ邮箱发送 ----
    #sender = '2472780140@qq.com'
    #smtpserver = 'smtp.qq.com'
    # 配置SMTP开启服务的账号和授权密码密码
    username = sender
    #password = 'kzwvjasknbouecbb'

    # ---- 使用163邮箱发送 ----
    #sender = '18833052506@163.com'
    #smtpserver = 'smtp.163.com'
    ## 配置SMTP开启服务的账号和授权密码密码
    #username = sender
    #password = 'IKXUWLANJVCMGLOX'

    # ---- 配置接收的邮箱 ----
    #receiver = ['jiaozenglian@xiangha.com', '2506513065@qq.com', '18231081115@163.com']
    
    # 发送邮件 -- to：
    toStr = ";".join(receiver)

    print('正在发送邮件......')
    
    # subject代表标题 content代表邮件内容
    try:
       msg = MIMEText(content,'plain','utf-8')
       if not isinstance(subject,unicode):
           subject = unicode(subject, 'utf-8')
       msg['Subject'] = subject
       msg['From'] = sender
       msg['To'] = toStr
       msg["Accept-Language"]="zh-CN"
       msg["Accept-Charset"]="ISO-8859-1,utf-8"

       smtp = smtplib.SMTP_SSL(smtpserver,465)
       smtp.login(username, password)
       smtp.sendmail(sender, receiver, msg.as_string())
       smtp.quit()
       return True
    except Exception, e:
       print str(e)
       return False
           
           
# -------------------- 主函数入口 -----------------------

if __name__ == '__main__':
    # 当前日期时间的格式化输出 time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime())
    cDateTime = time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime())

    # 读取json文件内容,返回字典格式
    print('正在读取打包配置：')
    with io.open('./config.json', 'r', encoding='utf-8') as fp:
        json_data = json.load(fp)
        
    # ---- 拷贝新工程 ----
    project_path = json_data["project_path"]
    # 工程拷贝到新路径
    newPath = newPath(project_path)
    
    # 拷贝一份新工程 注意cp的参数
#    copyToNewPath(project_path, newPath)

    # ----- 切换打包分支 ------
    git_project_branch_name = json_data["git_project_branch_name"]
    pullUpadteContent(newPath, git_project_branch_name)

    # ------ 获取提交日志 ------
    logs = getPushLog(newPath)
    print("提交日志：")
    print(logs)
    
    # ---- 执行打包脚本 -----
    archiveIPA(json_data)

    # ----- 读取邮件配置 - 发送邮件 -----
    email_config = json_data["email_config"]
    #if send_mail(sys.argv[1], sys.argv[2]):
    if sendEmail(email_config):
        print("邮件发送成功！")
    else:
        print("邮件发送失败！")


#################################################
##  命令行： python 路径/autoBuildTool.py。
##  1. 读取config.json中的配置
##  2. 进行自动打包，并上传到蒲公英；
##  3. 发送邮件给测试人员                   
###############################################
