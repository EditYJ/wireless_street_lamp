import 'package:wireless_street_lamp/config/config_info.dart';
import 'package:wireless_street_lamp/utils/toast_util.dart';

class NumberConvert {
  static String handleReturnString(context, String msg) {
    List<String> msgs = <String>[];
    String result = '';
    String temp = '';
    String item = '';
    String itemEr = '';

//    String buwei = ''; //补零用

    if (msg.startsWith(LIGHT_STATE_CODE) && msg.length == 22) {
      temp = msg.substring(6);

      for (int i = 0; i < temp.length; i++) {
        item = temp[i].codeUnitAt(0).toRadixString(2);
        item = addToEight(item);
        itemEr = item.split('').reversed.join('');
        print(itemEr);
        result += itemEr;
      }

//
//      for (int i = 0; i < temp.length; i++) {
//        item += temp[i];
//        if (item.length == 2) {
//          item = '0x' + item;
//          msgs.add(item);
//          item = '';
//        }
//      }
//
//      for (int j = 0; j < msgs.length; j++) {
//        itemEr = int.parse(msgs[j]).toRadixString(2);
//        itemEr = addToEight(itemEr);
//        itemEr = itemEr.split('').reversed.join('');
//        result += itemEr;
//        print(itemEr);
//      }

      print(result);

//      for (int i = 0; i < temp.length; i++) {
//        item = temp[i].codeUnitAt(0).toRadixString(2);
//        if (item.length < 8) {
//          int j = 8 - item.length;
//          for (int k = 0; k < j; k++) {
//            buwei += '0';
//          }
//          item = buwei + item;
////          print(item+'=');
//          result+=item;
//          item = '';
//          buwei = '';
//        }
//
//      }
//      print('处理结果===>>>' +
//          handleBitStringToList(msg.substring(6, 14)).join(''));
//      msgs.add('0x' + handleBitStringToList(msg.substring(6, 14)).join(''));
//      msgs.add('0x' + handleBitStringToList(msg.substring(14, 22)).join(''));
//      msgs.add('0x' + handleBitStringToList(msg.substring(22, 30)).join(''));
//      msgs.add('0x' + handleBitStringToList(msg.substring(30, 38)).join(''));
//      msgs.add('0x' + msg.substring(6, 14));
//      msgs.add('0x' + msg.substring(14, 22));
//      msgs.add('0x' + msg.substring(22, 30));
//      msgs.add('0x' + msg.substring(30, 38));
    } else {
      Toast.show(context, '得到的数据格式错误!正确的格式应该为STATE:加上128位二进制状态值！');
      print('得到的数据格式错误!正确的格式应该为STATE:加上128位二进制状态值！');
    }

//    print(msgs[0]);
//    print(msgs[1]);
//    print(msgs[2]);
//    print(msgs[3]);
//
//    print('尝试==' + result.codeUnitAt(0).toRadixString(2));
//
//    result += int.tryParse(msgs[0]).toRadixString(2) + '-';
//    result += int.tryParse(msgs[1]).toRadixString(2) + '-';
//    result += int.tryParse(msgs[2]).toRadixString(2) + '-';
//    result += int.tryParse(msgs[3]).toRadixString(2) + '-';

    return result;
  }

  static List<String> handleBitStringToList(String bitString) {
//    List<String> bitStringList = bitString.split('');
//    for (int i = 0; i < 8; i++) {
//      if (i % 2 == 0) {
//        String temp = bitStringList[i];
//        bitStringList[i] = bitStringList[i + 1];
//        bitStringList[i + 1] = temp;
//      }
//    }
////    bitStringList.join('');
//    return bitStringList;
  }

  /// 不足八位前面补零
  static String addToEight(String bitString) {
    String buwei = '';
    for (int i = 0; i < bitString.length; i++) {
      if (bitString.length < 8) {
        int j = 8 - bitString.length;
        for (int k = 0; k < j; k++) {
          buwei += '0';
        }
        bitString = buwei + bitString;
        buwei = '';
      }
    }
    return bitString;
  }
}
