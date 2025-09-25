class HttpResponse<T> {
  final T? data;
  final int? statusCode;
  final String? message;

  HttpResponse({this.data, this.statusCode, this.message});

  bool get isSuccess => (statusCode != null && statusCode! >= 200 && statusCode! < 300);
}
