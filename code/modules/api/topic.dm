/world/Topic(T, addr, master, key)
	var/list/packet_data = params2list(T)

	for(var/route in global.routes)
		if(packet_data[route])
			return global.routes[route].Invoke(packed_data)

	return ..()
