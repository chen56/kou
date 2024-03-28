import 'package:flutter/material.dart';

/// 本包的类提供属性和子组件分离的代码形式
/// 比较激进，实验更好的组件树代码视觉

final Debug debug=Debug();

class Debug {
  final Measurement measurement = Measurement();
}

class Measurement {
  LayoutBuilder constraints() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Text("$constraints");
      },
    );
  }
}

class Drawer$ {
  final Key? key;
  final Color? backgroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final ShapeBorder? shape;
  final double? width;
  final Widget? child;
  final String? semanticLabel;
  final Clip? clipBehavior;

  const Drawer$({
    this.key,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.shape,
    this.width,
    this.child,
    this.semanticLabel,
    this.clipBehavior,
  });

  Drawer call(Widget child) {
    return Drawer(
      key: key,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      width: width,
      semanticLabel: semanticLabel,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
