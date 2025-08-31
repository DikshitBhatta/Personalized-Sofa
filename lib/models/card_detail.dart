class CardDetail {
  late String id;
  String cardNumber;
  String expiryDate;
  String cardHolderName;
  String cvvCode;
  CardDetail({
    required this.id,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
  });
  factory CardDetail.fromJson(Map<String, dynamic> json) {
    return CardDetail(
      id: json['id'],
      cardNumber: json['cardNumber'],
      expiryDate: json['expiryDate'],
      cardHolderName: json['cardHolderName'],
      cvvCode: json['cvvCode'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cardHolderName': cardHolderName,
      'cvvCode': cvvCode,
    };
  }
}
