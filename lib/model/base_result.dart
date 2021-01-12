/**
 * Response result class
 */
class BaseResult<T> {
  BaseResult({this.code, this.msg, this.data}); //Constructor

  int code; //Response code
  String msg; //Message
  T data;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'data': data,
    };
  }
}
