import 'dart:async';
import 'package:flutter/services.dart';
//import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:wireless_street_lamp/models/message.dart';
//import 'package:mqtt_client_example/dialogs/send_message.dart';
import 'package:wireless_street_lamp/config/config_info.dart';

import 'package:provide/provide.dart';
import 'package:wireless_street_lamp/provide/config_provide.dart';
import 'package:wireless_street_lamp/models/light.dart';
import 'package:wireless_street_lamp/utils/toast_util.dart';
import 'package:wireless_street_lamp/utils/number_convert.dart';
import 'package:shared_preferences/shared_preferences.dart';
//二维码扫描
//import 'package:qrscan/qrscan.dart' as scanner;
//import 'package:flutter_qrscaner/flutter_qrscaner.dart';
//import 'package:barcode_scan/barcode_scan.dart';
import 'package:qr_reader/qr_reader.dart';

class ConfigConnectPage extends StatelessWidget {
  final TextEditingController imeiInputControl = TextEditingController();
  BuildContext context;
  mqtt.MqttClient client;
  mqtt.MqttConnectionState connectionState;
  StreamSubscription subscription;
  List<Message> messages = <Message>[];
  Set<String> topics = Set<String>();
  String imei;
  String imeiHis;
//  String barcode = "";


  @override
  Widget build(BuildContext context) {
    this.context = context;
    _readShared();
    _initLightList();
//    _initLightList();
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: _titleContent(),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.0),
        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _editRowContent(),
            _enterButton(),
            _configLightNumContent(),
            _gridViewUI()
          ],
        ),
      ),
    );
  }

  /*
   * SharedPreferences存储数据
   */
  Future _saveShared(String data) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('imei', data);
    print('========>存储imei为:$data');
  }

  /*
   * SharedPreferences读取数据
   */
  Future _readShared() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    imeiHis = preferences.get('imei');
    imeiInputControl.text = imeiHis;
    print('========>读取到imei为:$imeiHis');
  }

  //初始化网格列表数据
  _initLightList() {
    List<Light> lightList = <Light>[];
    for (int i = 0; i < 128; i++) {
      lightList.add(Light(
          id: i, isSelect: false, lightNum: 0, stateColor: Colors.redAccent));
    }
    Provide.value<ConfigProvide>(context).changeLightList(lightList);
  }

  //根据传入状态值改变网格列表数据
  _changeLightList(String states){
    List<Light> lightList = <Light>[];
    bool isOpen = false;
    for(int i=0; i<states.length;i++){
      if(states[i] =='1'){
        isOpen = true;
      }else{
        isOpen = false;
      }
      lightList.add(Light( id: i, isSelect: false, lightNum: 0, stateColor: isOpen?Colors.greenAccent:Colors.redAccent));
    }
    Provide.value<ConfigProvide>(context).changeLightList(lightList);
  }

  //标题
  Widget _titleContent() {
    return Provide<ConfigProvide>(builder: (builder, child, scope) {
      return Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: Text('连接配置'),
          ),
          Icon(scope.connectionStateIcon),
          Expanded(
            child: Container(),
          ),
          RaisedButton(
            onPressed: () {
//              print('按下表天牛');
              if (scope.client?.connectionState ==
                  mqtt.MqttConnectionState.connected) {
                _disconnect();
                FocusScope.of(context).requestFocus(FocusNode());
              } else {
                _connect();
                FocusScope.of(context).requestFocus(FocusNode());
              }
            },
            child: Text(scope.client?.connectionState ==
                    mqtt.MqttConnectionState.connected
                ? 'Disconnect'
                : 'Connect'),
          )
        ],
      );
    });
  }

  //编辑框与扫码按钮
  Widget _editRowContent() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(

            keyboardType: TextInputType.number,
            controller: imeiInputControl,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.subject),
                helperText: '请手动输入IMEI码或者点击右侧按钮扫描输入',
                labelText: 'IMEI码'),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 2.0),
          child: IconButton(
            onPressed: () {
              //调用扫码
              Future<String> futureString = new QRCodeReader()
                  .setAutoFocusIntervalInMs(200) // default 5000
                  .setForceAutoFocus(true) // default false
                  .setTorchEnabled(true) // default false
                  .setHandlePermissions(true) // default true
                  .setExecuteAfterPermissionGranted(true) // default true
                  .scan().then((value){
                imeiInputControl.text = value;
              });
            },
            icon: Icon(Icons.filter_center_focus),
          ),
        ),
      ],
    );
  }

  //确认按钮
  Widget _enterButton() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Provide<ConfigProvide>(builder: (builder, child, scope) {
            return RaisedButton(
//              padding: EdgeInsets.all(15.0),
              child: Text(scope.isConnect ? '确认' : '未连接'),
              textColor: Colors.white,
              color: Theme.of(context).primaryColor,
              onPressed: scope.isConnect
                  ? () {
                      imei = imeiInputControl.value.text;
                      _saveShared(imei);
                      print('订阅中。。。。。。。。。');
                      _subscribeToTopic(getPhoneTheme(imei));
                      FocusScope.of(context).requestFocus(FocusNode());
                    }
                  : null,
            );
          }))
        ],
      ),
    );
  }

  //生产下拉框数据
  List<DropdownMenuItem> _getListData() {
    List<DropdownMenuItem> items = new List();
    for (int i = 0; i < 10; i++) {
      DropdownMenuItem dropdownMenuItem = new DropdownMenuItem(
        child: Text((i+1).toString()),
        value: i.toString(),
      );
      items.add(dropdownMenuItem);
    }
    return items;
  }

  //下拉框
  Widget _configLightNumContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(right: 8.0),
            child: Provide<ConfigProvide>(builder: (builder, child, scope) {
              return DropdownButton(
                items: _getListData(),
                hint: new Text('下拉选择你想要的数据'), //当没有默认值的时候可以设置的提示
                value: scope.lightValue.toString(), //下拉菜单选择完之后显示给用户的值
                onChanged: (T) {
                  //下拉菜单item点击之后的回调
                  scope.changeLightValue(int.parse(T));
                },
                elevation: 24, //设置阴影的高度
                style: new TextStyle(
                  //设置文本框里面文字的样式
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              );
            })),
        Container(
            width: 50,
            child: Provide<ConfigProvide>(builder: (builder, child, scope) {
              return RaisedButton(
                padding: EdgeInsets.all(0.0),
                child: scope.isConnect ? Text('开') : Icon(Icons.cloud_off),
                textColor: Colors.white,
                color: Theme.of(context).primaryColor,
                onPressed: scope.isSub ? () {
                  _sendMessage(CHANGE_LIGHT_CODE+(scope.lightValue+1).toString());
                  Toast.show(context, '调整亮度为 '+(scope.lightValue+1).toString()+' 请求中...');
                  FocusScope.of(context).requestFocus(FocusNode());
                } : null,
              );
            })),
        Container(
            width: 50,
            child: Provide<ConfigProvide>(builder: (builder, child, scope) {
              return RaisedButton(
                padding: EdgeInsets.all(0.0),
                child: scope.isConnect ? Text('关') : Icon(Icons.cloud_off),
                textColor: Colors.white,
                color: Theme.of(context).primaryColor,
                onPressed: scope.isSub ? () {
                  _sendMessage(CHANGE_LIGHT_CODE+'0');
                  Toast.show(context, '调整亮度为 '+'0'+' 请求中...');
                  FocusScope.of(context).requestFocus(FocusNode());
                } : null,
              );
            })),
        Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Provide<ConfigProvide>(builder: (builder, child, scope) {
              return RaisedButton(
                child: Text(scope.isConnect ? '刷新列表' : '未连接'),
                textColor: Colors.white,
                color: Theme.of(context).primaryColor,
                onPressed:
                scope.isSub
                    ? () {
////                        _initLightList();
                        _sendMessage(FLASH_LIGHT_STATE);
                        Toast.show(context, '刷新中...');
                        FocusScope.of(context).requestFocus(FocusNode());
////                        String msg = LIGHT_STATE_CODE + 'abcd1568abcd1568';
////                        print(msg);
////                        print(NumberConvert.handleReturnString(msg));
////                        _changeLightList(NumberConvert.handleReturnString(msg));
                      }
                    : null,
              ////////////////////////////////////////
//                  (){
////                    print(int.tryParse('0xFFFFFFFF').toRadixString(2));
////                    String msg = LIGHT_STATE_CODE + 'FF070000000000000000000000000000';
//                    String msg = LIGHT_STATE_CODE + '0000FE07000000000000000000000000';
//                    NumberConvert.handleReturnString(context,msg);
////                    _changeLightList('10001100100011001000110010001100100011001000110010001100100011001000110010001100100011001000110010001100100011001000110010001100');
//                    Toast.show(context, '刷新中...');
//                  }
              );
            })),
      ],
    );
  }

  //网格每一项布局
  Widget _gridViewItemUI(Light item) {
    return InkWell(
        onTap: () {
          print('点击了导航');
        },
        child: Card(
          elevation: 4.0,
          color: item.stateColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.lightbulb_outline,
//                size: 35,
              ),
              Text(
                item.id.toString(),
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ));
  }

  Widget _gridViewUI() {
    return Expanded(
        child: Provide<ConfigProvide>(builder: (builder, child, scope) {
      return GridView.count(
//        padding: const EdgeInsets.all(20.0),
          crossAxisSpacing: 1.0,
          mainAxisSpacing: 1.0,
          crossAxisCount: 8,
          children:
              scope.lightList.map((item) => _gridViewItemUI(item)).toList());
    }));
  }

  void _connect() async {
    /// First create a client, the client is constructed with a broker name, client identifier
    /// and port if needed.
    client = mqtt.MqttClient(serviceUrl, '');

    /// A websocket URL must start with ws:// or wss:// or Dart will throw an exception,
    /// consult your websocket MQTT broker
    /// for details.
    /// To use websockets add the following lines -:
    // client.useWebSocket = true;

    /// This flag causes the mqtt client to use an alternate method to perform the WebSocket handshake. This is needed for certain
    /// matt clients (Particularly Amazon Web Services IOT) that will not tolerate additional message headers in their get request
    // client.useAlternateWebSocketImplementation = true;
    client.port = servicePort; // ( or whatever your WS port is)
    /// Note do not set the secure flag if you are using wss, the secure flags is for TCP sockets only.

    /// Set logging on if needed, defaults to off
    client.logging(on: true);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = 30;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = _onDisconnected;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId2')
        // Must agree with the keep alive set above or not set
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        // If you set this you must set a will message
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .withWillQos(mqtt.MqttQos.atLeastOnce);
    print('MQTT client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await client.connect();
    } catch (e) {
      print(e);
      _disconnect();
    }

    /// Check if we are connected
    if (client.connectionState == mqtt.MqttConnectionState.connected) {
      print('MQTT client connected');
      Provide.value<ConfigProvide>(context)
          .changeConnectState(client.connectionState);
      Provide.value<ConfigProvide>(context)
          .changeConnectionStateIcon(Icons.cloud_done);
      Provide.value<ConfigProvide>(context).changeIsConnect(true);
      Toast.show(context, "建立连接成功！");
    } else {
      print('ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionState}');
      _disconnect();
    }

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    subscription = client.updates.listen(_onMessage);
    Provide.value<ConfigProvide>(context).changeClient(client);
  }

  //关闭连接
  void _disconnect() {
    client.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
//    topics.clear();
    Provide.value<ConfigProvide>(context)
        .changeConnectState(client.connectionState);
    Provide.value<ConfigProvide>(context).changeClient(null);
    Provide.value<ConfigProvide>(context)
        .changeConnectionStateIcon(Icons.cloud_off);
    Provide.value<ConfigProvide>(context).changeIsClose(false);
    Provide.value<ConfigProvide>(context).changeIsOpen(false);
    Provide.value<ConfigProvide>(context).changeIsConnect(false);

    _unsubscribeFromTopic(getPhoneTheme(imeiInputControl.value.text));
    topics.remove(getPhoneTheme(imeiInputControl.value.text));
    subscription.cancel();
    subscription = null;
    Provide.value<ConfigProvide>(context).changeIsSub(false);
    print('MQTT client disconnected');
    Toast.show(context, "连接已断开！");
  }

  //消息监听器
  void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    print(event.length);
    final mqtt.MqttPublishMessage recMess =
        event[0].payload as mqtt.MqttPublishMessage;
    final String message =
        mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print('MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    print(client.connectionState);

//    messages.add(Message(
//      topic: event[0].topic,
//      message: message,
//      qos: recMess.payload.header.qos,
//    ));
    Provide.value<ConfigProvide>(context).addMessage(Message(
      topic: event[0].topic,
      message: message,
      qos: recMess.payload.header.qos,
    ));
    if(message == SUCCESS_FLAG){
      Toast.show(context, 'Success!');
    }else if(message.startsWith(LIGHT_STATE_CODE) && message.length == 22){
      _changeLightList(NumberConvert.handleReturnString(context, message));
      Toast.show(context, '刷新成功');
    }else{
      Toast.show(context, message.length.toString()+message+'服务器返回的数据格式有误，请检查！');
    }
    Provide.value<ConfigProvide>(context).changeLightItemState();
  }

  //订阅
  void _subscribeToTopic(String topic) {
    if (client.connectionState == mqtt.MqttConnectionState.connected) {
      if (topics.add(topic.trim())) {
        print('Subscribing to ${topic.trim()}');
        client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
//        Provide.value<ConfigProvide>(context).changeClient(client);
        Provide.value<ConfigProvide>(context).changeIsSub(true);
        Toast.show(context, "已订阅该设备状态！");
      }
    }
  }

  void _unsubscribeFromTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
          print('Unsubscribing from ${topic.trim()}');
          client.unsubscribe(topic);
        }
  }

  ///发送消息
  void _sendMessage(String msg) {
    final mqtt.MqttClientPayloadBuilder builder =
        mqtt.MqttClientPayloadBuilder();
    builder.addString(msg);
    client.publishMessage(
      getLightTheme(imei),
      mqtt.MqttQos.values[0],
      builder.payload,
      retain: false,
    );
  }
}
