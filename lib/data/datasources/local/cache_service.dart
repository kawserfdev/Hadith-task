class CacheService {
  // In-memory cache for frequently accessed data
  static final Map<String, dynamic> _cache = {};
  
  // Set cache with expiration
  static void setWithExpiry(String key, dynamic value, Duration expiry) {
    final expiryTime = DateTime.now().add(expiry);
    _cache[key] = {
      'value': value,
      'expiry': expiryTime,
    };
  }
  
  // Get cached value if not expired
  static dynamic get(String key) {
    if (!_cache.containsKey(key)) return null;
    
    final cacheItem = _cache[key];
    final expiryTime = cacheItem['expiry'] as DateTime;
    
    if (DateTime.now().isAfter(expiryTime)) {
      // Cache expired, remove it
      _cache.remove(key);
      return null;
    }
    
    return cacheItem['value'];
  }
  
  // Clear all cache
  static void clearCache() {
    _cache.clear();
  }
}