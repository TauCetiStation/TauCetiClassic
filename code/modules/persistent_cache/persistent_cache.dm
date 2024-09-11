// cache we can keep between rounds for generated files
// cache is saved with the hash of the source key files, so it will always be actual:
// if source .dmi has been changed, then it hash was changed too, so we will generate and use new cache file
// 
// usage:
// var/icon/I = try_access_persistent_cache("filename.dmi", "icons/source.dmi", "icons/source2.dmi")
// if(!I)
// 	I = do_generation()
// 	save_persistent_cache(I, "filename.dmi", "icons/source.dmi", "icons/source2.dmi")

// use wrapper try_access_persistent_cache()
/proc/_try_access_persistent_cache(filename_key, list/key_files)
	var/key_files_hash = key_files_hash(key_files)

	if(!key_files_hash)
		return

	var/cache_file_path = "[PERSISTENT_CACHE_FOLDER]/[key_files_hash]/[filename_key]"

	if(!fexists(cache_file_path))
		return FALSE

	return file(cache_file_path)

// use wrapper save_persistent_cache()
/proc/_save_persistent_cache(file, filename_key, list/key_files)
	var/key_files_hash = key_files_hash(key_files)

	if(!key_files_hash)
		return

	var/cache_file_path = "[PERSISTENT_CACHE_FOLDER]/[key_files_hash]/[filename_key]"

	fcopy(file, cache_file_path)

var/global/list/md5_files_cache = list()

/proc/key_files_hash(list/key_files)
	. = ""
	for(var/path in key_files)
		if(isfile(path))
			stack_trace("Need path, not file!")
			return FALSE
		if(!fexists(path))
			stack_trace("Non-existing key file: [path]")
			return FALSE

		if(!md5_files_cache[path])
			md5_files_cache[path] = md5(file(path))

		. += md5_files_cache[path]

	. = md5(.) // just for short nice name
