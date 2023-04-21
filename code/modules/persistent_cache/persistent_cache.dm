#define PERSISTENT_CACHE_FOLDER "cache/persistent"

//try_access_persistent_cache(cache_string, smooth_icon_initial)
/proc/_try_access_persistent_cache(filename_key, list/key_files)
	world.log << "access"
	var/hash_key = ""
	for(var/path in key_files)
		if(isfile(path))
			stack_trace("Need path, not file!")
			return FALSE
		if(!fexists(path))
			stack_trace("Non-existing key file: [path]")
			return FALSE

		hash_key += md5(file(path))
		//world.log << "Path: [path], [hash_key]"

	hash_key = md5(hash_key) // just for short nice name

	var/cache_file_path = "[PERSISTENT_CACHE_FOLDER]/[hash_key]/[filename_key]"
	world.log << cache_file_path

	if(!fexists(cache_file_path))
		return FALSE

	return file(cache_file_path)

/proc/_save_persistent_cache(file, filename_key, list/key_files)
	world.log << "save"
	var/hash_key = ""
	for(var/path in key_files)
		if(isfile(path))
			stack_trace("Need path, not file!")
			return FALSE
		if(!fexists(path))
			stack_trace("Non-existing key file: [path]")
			return FALSE

		hash_key += md5(file(path))
		//world.log << "Path: [path], [hash_key]"

	hash_key = md5(hash_key) // just for short nice name

	var/cache_file_path = "[PERSISTENT_CACHE_FOLDER]/[hash_key]/[filename_key]"
	world.log << cache_file_path

	fcopy(file, cache_file_path)

#undef PERSISTENT_CACHE_FOLDER
