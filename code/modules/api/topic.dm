/world/Topic(T, addr, master, key)
	var/list/packet_data = params2list(T)

	var/route = packet_data["route"]
	if(!route)
		return ..()

	var/datum/callback/router = global.routes[route]
	if(router)
		return router.Invoke(packet_data)

	return ..()
