const serviceUrl = 'pjlk.china-hutec.com';
const servicePort = 2601;
const CHANGE_LIGHT_CODE = 'LIGHT:';
const LIGHT_STATE_CODE = 'STATE:';
const FLASH_LIGHT_STATE = 'CHECK';
const SUCCESS_FLAG = 'OK';

String getLightTheme(String imei){
  return '/LIGHT/'+imei+'/REQ';
}
String getPhoneTheme(String imei){
  return '/LIGHT/'+imei+'/RSP';
}