## 一、安装`Homebrew`

[Homebrew官方文档](https://brew.sh/index_zh-cn.html)

[^1]: `Failed to connect to raw.githubusercontent.com port 443: Connection refused`，经常会被墙，请打开终端代理，翻墙下载。

## 二、Jenkins安装

通过`homebrew`安装`jdk8`：`brew cask install homebrew/cask-versions/adoptopenjdk8`

安装稳定版：`brew install jenkins-lts`

## 三、启动Jenkins

1. `brew services start jenkins-lts`启动`jenkins-lts`

2. 打开浏览器，输入`localhost:8080`，若能正常打开网页说明启动服务成功
3. 按照提示从`/Users/xxx/.jenkins/secrets/initialAdminPassword`复制初始密码：`sudo cat /Users/zjm/.jenkins/secrets/initialAdminPassword/`
4. 安装插件阶段：若对jenkins不熟悉，尽量选择安装所有推荐插件，要不然在后续的流程中可能会找不到部分功能。此阶段会需要一定时间，多重试几次全部变绿色再进入下个阶段。

![截屏2020-03-11下午10.51.56](https://tva1.sinaimg.cn/large/00831rSTly1gcridff1bqj30n60c0q43.jpg)

5. 初始化完成后更改一个简易密码
6. 更改httpListenAddress地址。

```shell
# jenkins默认的httpListenAddress地址是127.0.0.1，如果需要局域网内访问的话需要改成0.0.0.0
sudo vim /usr/local/opt/jenkins-lts/homebrew.mxcl.jenkins.plist
```

7. 更改后需重新启动：`brew services restart jenkins`

## 四、构建项目

选择一个自由分格的项目。

### 4.1新增参数

![截屏2020-03-12下午10.29.19](https://tva1.sinaimg.cn/large/00831rSTly1gcrim6aaflj30yw0u07a5.jpg)

### 4.2源码管理

- 创建公私钥对

```shell
# 创建sshkey,xxx@xxx.com请替换为自己的邮箱
ssh-keygen -t rsa -C "xxx@xxx.com"
# 查看公钥，公钥上传到gitee中
cat ~/.ssh/id_rsa.pub
# 查看私钥，私钥用于到jenkins中的凭据
car ~/.ssh/id_rsa
```

- 设置git仓库

<img src="https://tva1.sinaimg.cn/large/00831rSTly1gcride4jxoj31gi0tu77u.jpg" alt="截屏2020-03-10下午2.34.45" style="zoom:50%;" />

- 类型设置为`SSH Username with private key`；`Username`最好填写申请`ssh-key`时对应的名称；`private Key`填写私钥。

<img src="https://tva1.sinaimg.cn/large/00831rSTly1gcridcer0pj31kx0u0jxh.jpg" alt="截屏2020-03-10下午2.37.00" style="zoom:50%;" />

## 五、构建

选择Execute Shell

![截屏2020-03-12下午10.35.21](https://tva1.sinaimg.cn/large/00831rSTly1gcrir9s9qbj31h60kcjth.jpg)

## jenkins 命令行

```shell
# 启动jenkins
brew services start jenkins-lts
# 停止jenkins
brew services stop jenkins-lts
# 重启jenkins
brew services restart jenkins-lts
# 卸载jenkins
brew uninstall jenkins-lts
# 如果找不到brew安装的东西在哪儿，可以使用
brew list jenkins
```

## 报错信息

```shell
报错
xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance
解决
sudo xcode-select --switch /Applications/Xcode.app
```

## 脚本部分shell语法解释

```shell
# 返回该文件当前的上一层路径，通过cd到该路径，通过pwd获得当前路径。其中"$(cmd)"表示命令组，括号中的命令cmd将会新开一个shell顺序执行，其中的分号将两个命令分开。
"$(cd "$(dirname "$0")"; pwd)"
```

```shell
# 检测两个数是否相等，不相等返回true
-ne
```

```shell
# 通过jq脚本获得json中的code字段对应的值
`echo $result | $JQ_PATH '.code'
```

```shell
# 返回上一层目录
cd ..
```

```shell
# 检测文件是否是目录，如果是，则返回true
-d file
```

```shell
# 当前工作目录
pwd
```

```shell
# 赋予执行权限
chmod +x
```

```shell
# 建立名称为dirName的子目录，-p确保目录名称存在，不存在的就新建一个。若不加-p，且原来的目录不存在，则产生错误
mkdir -p dirName
```

## 安装关联工具

```shell
# 安装rvm
curl -L get.rvm.io | bash -s stable 

source ~/.bashrc

source ~/.bash_profile
```

```shell
# 查看当前ruby版本
ruby -v
# 查看rvm版本
rvm -v
# 列出ruby可安装的版本信息
rvm list known
# 安装一个ruby版本
rvm install x.x
```

```shell
brew install jq
```

