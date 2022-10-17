//in case if we want https page
// use \" for escaping all ulr
/proc/get_webpage(address)
	address = shelleo_url_scrub(address)

	if(!address)
		return

	return world.ext_python("get.py", address)
