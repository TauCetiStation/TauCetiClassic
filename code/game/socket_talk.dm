// Module used for fast interprocess communication between BYOND and other processes

/datum/socket_talk
	var/enabled = 0

/datum/socket_talk/New()
	..()
	src.enabled = config.socket_talk

	if(enabled)
		call("DLLSocket.so","establish_connection")("127.0.0.1","8019")

/datum/socket_talk/proc/send_raw(message)
	if(enabled)
		return call("DLLSocket.so","send_message")(message)

/datum/socket_talk/proc/receive_raw()
	if(enabled)
		return call("DLLSocket.so","recv_message")()

/datum/socket_talk/proc/send_log(var/log, var/message)
	return send_raw("type=log&log=[log]&message=[message]")

/datum/socket_talk/proc/send_keepalive()
	return send_raw("type=keepalive")


var/global/datum/socket_talk/socket_talk
