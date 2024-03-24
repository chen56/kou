import 'package:flutter/widgets.dart';

/*
 * 更好的flutter ui编程实践，代码尽力做到美观:
 *  - 代码缩进只应体现组件的父子关系，属性会干扰层级视觉，需要独立开尽量不换行，最少也要隔离开。
 *  - 扁平化不必要的组件层级，比如Padding、Decoration、Aglin等只是外观属性，不用一层包一层。
 * */
class StyledWidget extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;
  final Widget? child;

  const StyledWidget({
    super.key,
    this.padding,
    this.decoration,
    this.alignment,
    this.child,
  });

  StyledWidget call(Widget child) {
    return StyledWidget(
      key: key,
      padding: padding,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: child,
    );
  }
}
