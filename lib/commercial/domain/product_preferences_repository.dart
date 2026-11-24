abstract interface class ProductPreferencesRepository {
  Future<List<String>> getMyPreferences();
  Future<List<String>> getAvailableCategories();
  Future<void> subscribe(String category);
  Future<void> unsubscribe(String category);
}
