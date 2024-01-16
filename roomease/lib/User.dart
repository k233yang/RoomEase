class User {
  String name;
  String userId;
  String householdId;
  String userStatus;
  List<String> userStatusList;
  List<String> messageRoomList;

  User(this.name, this.userId, this.householdId, this.userStatus,
      this.userStatusList, this.messageRoomList);
}
