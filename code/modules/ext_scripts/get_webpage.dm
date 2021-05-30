//in case if we want https page
/proc/get_webpage(address)
	address = shelleo_url_scrub(address)

	if(!address)
		return

	return world.ext_python("get.py", address)
