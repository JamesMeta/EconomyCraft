import time
from typing import Any

from cachetools import TTLCache

class LocalCacheManager:

    def __init__(self) -> None:
        self.cache : TTLCache = TTLCache(maxsize=10_000, ttl=300)

    def set(self, key, value, ttl = 300):
        expire_at = time.time() + ttl
        self.cache[key] = (value, expire_at)

    def get(self, key) -> Any:
        val = self.cache.get(key)
        if val is None:
            return None
        value, expire_at = val
        if time.time() > expire_at:
            del self.cache[key]
            return None
        return value
