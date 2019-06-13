import 'package:flutter/material.dart';

class Light {
  int id;
  bool isSelect;  //是否被选中
  int lightNum; //亮度
  Color stateColor;

  Light({this.id, this.isSelect, this.lightNum, this.stateColor});
}
