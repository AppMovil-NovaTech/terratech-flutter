/// US32: favorites belong to the currently authenticated backend user.
abstract interface class ProductFavoritesRepository {
  Future<bool> isFavorite(int productId);
  Future<void> addFavorite(int productId);
  Future<void> removeFavorite(int productId);
}
