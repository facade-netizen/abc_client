List<String> inPlayTabs(bool isLoggedIn) {
  return ['In-Play', 'Today', 'Tomorrow', if (isLoggedIn) 'Results'];
}

List<String> resultsTabs = ['Today', 'Yesterday'];
