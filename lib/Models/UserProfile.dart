class UserProfile {
  String id;
  String role;
  String firstName;
  String lastName;
  String email;
  String address;
  String phoneNumber;
  int receiveNotifications;

  UserProfile(
      {this.id,
      this.email,
      this.role,
      this.firstName,
      this.lastName,
      this.address,
      this.phoneNumber,
      this.receiveNotifications,
      });

  bool isNotificationEnabled() {
    if (receiveNotifications == 1) return true;
    return false;
  }
}