#define try_access_persistent_cache(filename_key, arguments...) _try_access_persistent_cache(filename_key, list(##arguments))

#define save_persistent_cache(file, filename_key, arguments...) _save_persistent_cache(file, filename_key, list(##arguments))
