# ACS UPB Mobile
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE.txt)
[![Linter](https://github.com/acs-upb-mobile/acs-upb-mobile/workflows/Linter/badge.svg)](https://github.com/acs-upb-mobile/acs-upb-mobile/actions?query=workflow%3ALinter)
[![Tests](https://github.com/acs-upb-mobile/acs-upb-mobile/workflows/Tests/badge.svg)](https://github.com/acs-upb-mobile/acs-upb-mobile/actions?query=workflow%3ATests)
[![codecov](https://codecov.io/gh/acs-upb-mobile/acs-upb-mobile/branch/master/graph/badge.svg)](https://codecov.io/gh/acs-upb-mobile/acs-upb-mobile)
[![extra_pedantic on pub.dev](https://img.shields.io/badge/style-extra__pedantic-blue)](https://pub.dev/packages/extra_pedantic)

[![Facebook](https://img.shields.io/badge/Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white)](https://www.facebook.com/acsupbmobile)
[![Instagram](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/acs_upb_mobile/)

A mobile application for students at [ACS UPB](https://acs.pub.ro/). For now, you can try it out by accessing [https://acs-upb-mobile.web.app/](https://acs-upb-mobile.web.app/) or download it from Google Play by pressing the button below. Android users can also download the apk from the latest [release](https://github.com/acs-upb-mobile/acs-upb-mobile/releases).

<a href="https://play.google.com/store/apps/details?id=ro.pub.acs.acs_upb_mobile"><img width=200 src=https://raw.githubusercontent.com/steverichey/google-play-badge-svg/266d2b2df26f10d3c00b8129a0bd9f6da6b19f00/img/en_get.svg></a>

Please note that some features may not work perfectly in the web version, as the app is designed to work better natively. However, please feel free to [create an issue](https://github.com/acs-upb-mobile/acs-upb-mobile/issues/new?&template=bug_report.md) if you encounter any problem.

If you would like to contribute and don't know where to start, or you have any questions about this project, feel free to send an e-mail at acs.upb.mobile@gmail.com.

## Demo

https://user-images.githubusercontent.com/25504811/120929790-1bc24080-c6f3-11eb-9360-9994110da946.mp4

<a href="https://www.youtube.com/watch?v=-IRL35WIeGc"><img width=200 src="https://user-images.githubusercontent.com/25504811/120929979-fa158900-c6f3-11eb-8ef3-237591001b44.png"></a>


## Contributors
* [Ioana Alexandru](https://github.com/IoanaAlexandru)
* [Andrei-Constantin Mirciu](https://github.com/andreicmirciu)
* [Adrian Mărgineanu](https://github.com/AdrianMargineanu)
* [Alex Conțiu](https://github.com/AlexContiu)
* [Eric Postolache](https://github.com/ericpostolache)
* [Gabriel Gavriluță](https://github.com/gabrielGavriluta)
* [Crăciun Octavian ](https://github.com/craciunoctavian)
* [Răzvan Rădoi ](https://github.com/razvanra2)
* [George Diaconu](https://github.com/GeorgeMD)
* [Maria Stoichițescu](https://github.com/stoichitescumaria)
* [Anghel Andrei](https://github.com/AnghelAndrei28)
* [Bogdan Piele](https://github.com/bogpie)
* [Bogdan Iuga](https://github.com/iugabogdan98)
* [Alexandra Pavel](https://github.com/AlexandraPavel)

## Building from source with Android Studio

### Prerequisites

* Install Flutter as per the instructions [here](https://flutter.dev/docs/get-started/install).
* Open Android Studio.
* Make sure you have the [Flutter plugin](https://plugins.jetbrains.com/plugin/9212-flutter) installed, as well as the [Dart plugin](https://plugins.jetbrains.com/plugin/6351-dart) dependency. Restart the IDE if necessary.
* Use the *Check out project from Version Control* option (or *File > New > Project from Version
Control*) to clone the repository from https://github.com/acs-upb-mobile/acs-upb-mobile.
* If the plugins are installed, Android Studio should automatically recognise it as being a Flutter project, so you should be able to just click *Next* on everything and create a new project.
* When prompted, set up the Flutter SDK (the location is the `flutter/` folder you downloaded when you installed it) and Dart SDK (it comes bundled with Flutter at `flutter/bin/cache/dart-sdk/`).
* Open a terminal in the Flutter SDK directory and switch to the version we are currently using for the project:
```
git pull
git checkout 1.24.0-10.2.pre
```
* Open the project terminal in Android Studio and install all of the required packages by running:
```
flutter pub get
```
* You may need to restart the IDE for the changes to take effect.

### Building for Android

* Install and run an emulator in Android Studio (using AVD Manager), or connect a physical Android device (make sure USB debugging is enabled, and your cable supports data transfer).
* Select your device from the dropdown list and hit the play button (*Shift+F10* or *^R*). Note that Android Studio runs the app in debug mode by default.

| :exclamation: | On Android, ACS UPB Mobile uses **a separate (development) environment in debug mode**. That means a completely different Firebase project - separate data, including user info.|
|---------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     :bulb:    | In order to try the release (production) version, the recommended approach is to download an APK from the [Releases](https://github.com/acs-upb-mobile/acs-upb-mobile/releases) page. If you really need to test the release version from AS (make sure you know what you're doing), you need to change the `signingConfig signingConfigs.release` line to `signingConfig signingConfigs.debug` in [android/app/build.gradle](android/app/build.gradle), and then run `flutter run --release`. Do note that the release version *cannot* be ran on an emulator.|

### Building for iOS (MacOS only)

* Make sure you have Xcode installed and up to date (it is free on the App Store).
* Connect a physical iOS device or select *Open iOS Simulator* from the device drop-down menu to power on Xcode's simulator.
* Select your device from the dropdown list and hit the play button (*^R*).

### Building for Web

* You need to have *Chrome* installed in order to be able to run the web version of the app.
* Select *Chrome* from the dropdown list and hit the play button (*Shift+F10* or *^R*).

### Not working?

Possible fixes could be:
* Run `flutter doctor` and fix any issues that may come up (make sure you're using the right Flutter version for the project, see [Prerequisites](#prerequisites)).
* Run `flutter clean` to delete the `build` directory and then build again.
* Restart Android Studio using *File > Invalidate Caches / Restart*.

Test your setup by creating and running a new Flutter project (Android Studio provides a sample). If that works but this project doesn't, feel free to [open an issue](https://github.com/IoanaAlexandru/acs_upb_mobile/issues/new) and describe the problem.

## License  

This project is under the [MIT License](LICENSE.txt), which means that you can do whatever you want with it, as long as you add a copy of the original MIT license and copyright notice to your work.
