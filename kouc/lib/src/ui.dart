import 'package:flutter/widgets.dart';

/// https://stackoverflow.com/questions/50429660/is-there-a-constant-for-max-min-int-double-value-in-dart

/// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum WindowClass {
  // phone
  s(widthFrom:0,widthTo:600),
  // pad
  m(widthFrom:600,widthTo:840),
  // full screen pc
  l(widthFrom:840 ,widthTo:1240),
  // our extends
  xl(widthFrom:1240,widthTo:double.maxFinite);

  const WindowClass({required this.widthFrom,required this.widthTo});

  final double widthFrom;
  final double widthTo;

  factory WindowClass.of(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    for (var window in  WindowClass.values){
      if(width>=window.widthFrom && width< window.widthTo) return window;
    }
    return WindowClass.s;
  }
}
