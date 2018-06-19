## 游戏玩法
 - 小白兔目的是吃闪烁的小星星，小白兔只是**鼻子嘴巴部分**![rabbit](https://github.com/11lin/PlaygroundOSS/blob/master/DemoRabbit/rabbit.png)是`有效碰撞`，开始之前可以勾选上显示碰撞点，这样更清楚碰撞范围。不要让移动的子弹碰到了小白兔鼻子，而且小白兔的生命只有一条
 - 子弹有两种类型：
   - 1. 连发子弹 
   - 2. 发射的时候朝小白兔方向飞行
 - [国外Youtube视频](https://youtu.be/kdawbOblTCU)
 - [国内Youku视频](https://v.youku.com/v_show/id_XMzY3Mjg0MDI0NA==.html?spm=a2h3j.8428770.3416059.1)


## Windows工具：
Toboggan 1.17.3.4 用户界面、打包资源等

## Android开发环境
* MacOS 10.13.4
* Android Studio 3.1.3
* Gradle 4.4
* 真机红米4

### Android工程升级过程中遇到问题：

 - com.android.tools.build:gradle:0.6 => 3.1.3
 - gradle.build需要把instrumentTest类改成androidTest
 - 32位so=>支持64位手机:
  - 在Gradle中的sourceSets结构里添加jniLibs.srcDirs = ['libs']
  - 在Gradle中添加代码
```javascript
  defaultConfig {
        targetSdkVersion 17
        ndk {
            moduleName "native"
            abiFilters "armeabi", "armeabi-v7a", "x86", "mips"
        }}
```

## iOS开发环境
 * MacOS 10.13.4
 * Xcode 9.3
 * 模拟器 IPhone 5S
 * 真机测试设备IPhone 8P、IPhone 5S

### 编译iOS遇到的问题:
 * 在iOS11中苹果已经禁用函数接口system()，目前PlaygroundOSS引擎引入的lua库在ioslib.c:81行方法os_execute中有使用。

 解决办法：注释掉方法内容，并且在lua代码中不要使用os.execute方法
 * 真机调试的时候会报bitcode错误。
 
 解决办法：设置Build Settings => 选择All(默认Combined) => 设置 Enable Bitcode为No
 * 目前引擎PlaygroundOSS中的curl库不支持64位。

 解决办法：重新下载curl源码编译支持64位
  * lipo -info Engine/porting/iOS/curl/ios-dev/lib/libcurl.a
  * 升级之前支持：Architectures i386 armv7 armv7s
  * 升级之后支持：Architectures i386 x86_64 armv7 armv7s arm64

## 游戏开发相关：
 * 添加Tutoral/27.ActivityIndicator实例代码
 * 游戏设计分辨率640x1136
 * 游戏层级 -10到0是背景层 500是主角层 600到650是道具层 700到800子弹层 1000到1500是UI层 1500到2000是对话框层
 * 场景之间切换的资源管理
 * 游戏中子弹道具对象使用了对象池来管理

## 项目工程目录
  * `iOS` Engine\porting\iOS\Project\SampleProject
  * `Android` Engine\porting\Android\GameEngine-android 
  * Toboggan工程目录DemoTobogganResources

## 游戏工程目录结构
 * `start.lua`
 * `app/main.lua` 游戏入口、常量、class类库
 * `app/views/Entry.lua` 首页逻辑
 * `app/views/Entry.xml` 首页UI界面
 * `app/views/Battle.lua` 战斗逻辑 -- 主要结构 MainGame -> BulletManger -> BulletGenerator -> Bullet
 * `app/views/Battle.xml` 战斗界面
 * `app/assets/Entry` 首页资源
 * `app/assets/Battle` 游戏战斗资源
 * `app/assets/Sounds` 游戏声音mp3资源

## 游戏开发注意问题：
 * 游戏字体需要手动加载
 * lua中设置order显示优先级参数必须是uint 否则报Order Problem错误
 * 在编辑里如果图片已经打包进Texture里，在修改图片属性的话，这时候Publish会提示图片在Texture找不到，重启Toboggan编辑即可
 * 在Mac下编辑器Toboggan发布的资源目录.publish都是隐藏的，Tutorial里的.publish也是隐藏的
  
# 总结
 * 开发主要在Mac下，Window负责打包资源之后同步到Mac来，主要以640x1136设计分辨率。可能Android部分机型会有适配问题，IPhone大部分机型可以完美适配。
 * 平常要上班的话，正常开发demo的时间基本上在只有2-3天左右，有1天时间熟悉引擎。想做完整一点时间肯定不够，目前个人觉得还算比较可以有玩法也有难度,核心代码其实600行，开发的时候还算比较顺利没遇到什么大问题。

# 最后感谢klab提供的游戏引擎

![screenshoot1](https://raw.githubusercontent.com/11lin/PlaygroundOSS/master/DemoRabbit/screenshoot1.jpg)
![screenshoot2](https://raw.githubusercontent.com/11lin/PlaygroundOSS/master/DemoRabbit/screenshoot2.jpg)
![screenshoot3](https://raw.githubusercontent.com/11lin/PlaygroundOSS/master/DemoRabbit/screenshoot3.jpg)