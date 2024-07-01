Future<void> fakeNetworkOperation({required bool fail}) async {
  return Future.delayed(Duration.zero, () {
    return fail ? throw Exception('Network error') : null;
  });
}
