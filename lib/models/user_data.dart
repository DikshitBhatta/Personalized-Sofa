class UserData {
  String name;
  String email;
  String? profilePictureUrl;
  bool newArrivalsNotification;
  bool deliveryStatusNotification;
  bool salesNotification;
  
  UserData(
      {this.name = "",
      this.email = "",
      this.profilePictureUrl,
      this.newArrivalsNotification = false,
      this.deliveryStatusNotification = true,
      this.salesNotification = true});
      
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePictureUrl: json['profile_picture_url'],
      newArrivalsNotification: json['new_arrivals_notification'] ?? false,
      salesNotification: json['sales_notification'] ?? true,
      deliveryStatusNotification: json['delivery_status_notification'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profile_picture_url': profilePictureUrl,
      'new_arrivals_notification': newArrivalsNotification,
      'sales_notification': salesNotification,
      'delivery_status_notification': deliveryStatusNotification,
    };
  }
}
