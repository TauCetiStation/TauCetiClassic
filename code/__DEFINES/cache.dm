#define PERSISTENT_CACHE_FOLDER "cache/persistent"

#define try_access_persistent_cache(filename_key, arguments...) config.use_persistent_cache && _try_access_persistent_cache(filename_key, list(##arguments))

#define save_persistent_cache(file, filename_key, arguments...) config.use_persistent_cache && _save_persistent_cache(file, filename_key, list(##arguments))
