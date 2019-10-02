
<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![MIT License][license-shield]][license-url]
<!-- [![LinkedIn][linkedin-shield]][linkedin-url] -->



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/zoujiemeng/twosnakes-by-flutter">
    <img src="./assets/icon/icon2.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">twosnakes-by-flutter</h3>

  <p align="center">
    包含单人模式和双人模式的贪吃蛇游戏
    <br />
    <a href="https://play.google.com/store/apps/details?id=com.jaytown.twosnakes"><strong>前往谷歌应用商店 »</strong></a>
    <br />
    <br />
    <a href="https://github.com/zoujiemeng/twosnakes-by-flutter">View Demo</a>
    ·
    <a href="https://github.com/zoujiemeng/twosnakes-by-flutter/issues">report Bug</a>
    ·
    <a href="https://github.com/zoujiemeng/twosnakes-by-flutter/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
## 目录

* [项目简介](#项目简介)
  * [单人模式](#单人模式)
  * [双人模式](#双人模式)
  * [更改颜色](#更改颜色)
  * [软件框架](#软件框架)
* [开发指南](#开发指南)
  * [安装Flutter](#安装Flutter)
  * [选一个编辑器](#选一个编辑器)
  * [运行程序](#运行程序)
  * [代码结构](#代码结构)
* [Contributing](#contributing)
* [License](#license)
* [联系方式](#联系方式)
* [致谢](#致谢)



<!-- 项目简介 -->
## 项目简介
这是一个用Flutter写的贪吃蛇游戏，单人模式基本和传统的贪吃蛇一致，双人模式是两个玩家分别用左右两个控制器控制一条蛇去争抢一个食物，先撞墙或者撞上另一条蛇的玩家败北。头碰头算平局，追尾的算后车输。根据实测，双人模式绝对是“撑死胆大的，饿死胆小的”这句话的完美诠释。这个app的另一大特点是随时可以暂停更改各UI组件的颜色，尤其是在游戏中更改的时候，确认后能看到像蛇蜕皮一样的谜之场景。
+ 本项目适合新手入门Flutter，代码量约1500，核心源码文件两个(500+1000)。
+ 本项目所有界面元素皆使用代码生成，没有使用任何图片资源。

### 单人模式
单人模式就是传统的贪吃蛇游戏，可以选择地图大小和难度（难度越高蛇的速度越快），具体界面可以参考下面的gif图，不过gif图失真比较厉害，建议有条件的去[Google Play Store](https://play.google.com/store/apps/details?id=com.jaytown.twosnakes)下载APP体验或者在[youtube](https://youtu.be/fRPARjtkeR8)上观看高清视频。
![one player mode preview](./assets/demo/1player.gif)

### 双人模式
本地双人模式应该是一个创新模式（至少我没见过，好吧我就玩过一款贪吃蛇游戏，好像是GBC上的）。两条蛇抢同一个食物，走对手的路，让对手无路可走是这模式获胜的秘诀。
![two player mode preview](./assets/demo/2player.gif)

### 更改颜色
游戏中可安右下角的暂停按键随时暂停，暂停后的菜单可以设置UI各个部分的颜色。设置完确认后，颜色更改可即时显示，游戏中更改蛇的颜色会有谜之现象(lll￢ω￢)。
![change color preview1](./assets/demo/color1.gif)
![change color preview2](./assets/demo/color2.gif)

### 软件框架

* [Flutter](https://flutter.dev/)

<!-- GETTING STARTED -->
## 开发指南

### 安装Flutter

如果从没使用过Flutter的话，请按照[官方指南](https://flutter.dev/docs/get-started/install)安装Flutter。如果无法翻墙的话，请参考[Using Flutter in China](https://flutter.dev/community/china)。

### 选一个编辑器

官方推荐Android Studio或者VS code. Android Studio内容全面不过稍显臃肿，VS code相对轻量级。

### 运行程序

1. Clone文件夹到本地
```sh
git clone https://github.com/zoujiemeng/twosnakes-by-flutter.git
```

2. 用喜欢的编辑器打开clone的文件夹，参照[官方指南](https://flutter.dev/docs/get-started/test-drive)运行app。

3. 随意修改，保存文件之后无需重启APP即可在设备上看到更改内容.

### 代码结构

本项目代码结构及其简单，适合新手入门Flutter，一个main.dart文件负责画UI，另一个game_state.dart文件负责保存和管理游戏状态。

<!-- CONTRIBUTING -->
## Contributing

如果有想增加的功能或者bug，欢迎到[issue](https://github.com/zoujiemeng/twosnakes-by-flutter/issues)提出。
欢迎任何形式的issue和pull request（希望加上简单说明）.

<!-- LICENSE -->
## License
本项目在MIT License下发布，大家可以随便改。

<!-- 联系方式 -->
## 联系方式

Zou Jiemeng - [@jiemengzou](https://twitter.com/jiemengzou) - jiemengzou@gmail.com

Project Link: [https://github.com/zoujiemeng/twosnakes-by-flutter](https://github.com/zoujiemeng/twosnakes-by-flutter)



<!-- 致谢 -->
## 致谢

* [Flutter](https://github.com/flutter/flutter)
* [flutter-tetris](https://github.com/boyan01/flutter-tetris)
* [Package:orientation](https://pub.dev/packages/orientation)
* [Package:provider](https://pub.dev/packages/provider)
* [Package:vibration](https://pub.dev/packages/vibration)
* [Package:flutter_speed_dial](https://pub.dev/packages/flutter_speed_dial)
* [Package:flutter_colorpicker](https://pub.dev/packages/flutter_colorpicker)
* [Package:shared_preferences](https://pub.dev/packages/shared_preferences)
* [Readme template](https://github.com/othneildrew/Best-README-Template)


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=flat-square
[license-url]: https://github.com/zoujiemeng/twosnakes-by-flutter/blob/master/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=flat-square&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
