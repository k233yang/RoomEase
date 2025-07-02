enum ChoreStatus {
  toDo("choresToDo"),
  inProgress("choresInProgress"),
  completed("choresCompleted"),
  archived("choresArchived");

  const ChoreStatus(this.value);

  final String value;
}
