# app devtools extension

试了一下，暂时没啥用处，发现只能搞一个web页面以iframe的模式挂在devtools下，无法调用操作系统api

> ref:
> https://docs.flutter.dev/tools/devtools/extensions
> https://github.com/flutter/devtools/blob/master/packages/devtoo
> ls_extensions/README.md
>

## 使用

1. 先编译本项目

```bash
# 会在./extension/devtools/build目录下生成web静态文件
dart run devtools_extensions build_and_copy --source=. --dest="./extension/devtools"
```

2. 在app项目pubspec.yaml中指定：

```yaml
dev_dependencies:
    app_devtools:
      path: ./packages/app_devtools
```

3. app项目根目录增加文件devtools_options.yaml，添加内容：

```yaml
extensions:
  - app_devtools: true  # 打开app_devtools,默认为关闭状态
```

`flutter run -d macos` debug模式运行app程序，打开flutter devtools,就可以看到一个新的tab栏：app_devtools

## app_devtools自身的开发

```bash
# use_simulated_environment： 开启仿真环境，模仿devtools的工作，便于调试
flutter run -d Chrome --dart-define=use_simulated_environment=true
```