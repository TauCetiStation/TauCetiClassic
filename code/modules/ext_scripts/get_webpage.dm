//in case if we want https page
/proc/get_webpage(address)
	address = shell_url_scrub(address)

	if(!address)
		return

	var/list/output = ext_python("get.py", address)
	if(!output)
		return
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	//var/stderr = output[SHELLEO_STDERR]
	if(!errorlevel)
		return stdout
