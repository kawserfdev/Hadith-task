class CacheService {
  static final Map<String, dynamic> _cache = {};
  
  static void setWithExpiry(String key, dynamic value, Duration expiry) {
    final expiryTime = DateTime.now().add(expiry);
    _cache[key] = {
      'value': value,
      'expiry': expiryTime,
    };
  }
  
  static dynamic get(String key) {
    if (!_cache.containsKey(key)) return null;
    
    final cacheItem = _cache[key];
    final expiryTime = cacheItem['expiry'] as DateTime;
    
    if (DateTime.now().isAfter(expiryTime)) {
      _cache.remove(key);
      return null;
    }
    
    return cacheItem['value'];
  }
  
  static void clearCache() {
    _cache.clear();
  }
}