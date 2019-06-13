import 'package:flutter/material.dart';
import 'package:wireless_street_lamp/models/message.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:wireless_street_lamp/models/light.dart';

class ConfigProvide with ChangeNotifier{
  //接收的订阅消息
  List<Message> messages = [];
  mqtt.MqttClient client;
  mqtt.MqttConnectionState connectionState;
  IconData connectionStateIcon = Icons.cloud_off;
  List<Light> lightList = <Light>[];

  bool isOpen=false; //是否置灰设置亮度按钮
  bool isClose=false; //是否置灰关灯按钮
  bool isConnect = false; //是否为连接状态
  bool isSub = false; //是否为订阅状态

  int lightValue = 0;

  addMessage(Message msg){
    this.messages.add(msg);
    notifyListeners();
  }

  changeMessages(List<Message> msgs){
    this.messages = msgs;
    notifyListeners();
  }

  changeClient(mqtt.MqttClient client){
    this.client = client;
    notifyListeners();
  }

  changeConnectState(mqtt.MqttConnectionState connectionState){
    this.connectionState = connectionState;
    notifyListeners();
  }

  changeConnectionStateIcon(IconData connectionStateIcon){
    this.connectionStateIcon = connectionStateIcon;
    notifyListeners();
  }

  changeLightValue(int lightValue){
    this.lightValue = lightValue;
    notifyListeners();
  }

  changeLightList(List<Light> lightList){
    this.lightList=lightList;
    notifyListeners();
  }

  changeLightItemState(){
    this.lightList[0].lightNum = 5;
    notifyListeners();
  }

  changeIsOpen(bool state){
    this.isOpen = state;
    notifyListeners();
  }

  changeIsClose(bool state){
    this.isClose = state;
    notifyListeners();
  }

  changeIsConnect(bool state){
    this.isConnect = state;
    notifyListeners();
  }

  changeIsSub(bool state){
    this.isSub = state;
    notifyListeners();
  }
}