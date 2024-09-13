class ApiException implements Exception{
  final msg;
  ApiException(this.msg);

  @override
  String toString() {
    return msg;
  }
}