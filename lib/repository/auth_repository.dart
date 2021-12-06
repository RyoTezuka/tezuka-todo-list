class AuthRepository {
  Future<String> login({
    required String name,
    required String password,
  }) async {
    // TODO 認証APIへアクセス
    await Future.delayed(const Duration(seconds: 2));

    return "success";
  }
}
