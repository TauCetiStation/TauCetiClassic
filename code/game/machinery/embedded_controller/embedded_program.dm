/datum/computer/file/embedded_program
	var/list/memory = list()
	var/obj/machinery/embedded_controller/master

	var/id_tag


/datum/computer/file/embedded_program/New(obj/machinery/embedded_controller/M)
	master = M
	if(istype(M, /obj/machinery/embedded_controller/radio))
		var/obj/machinery/embedded_controller/radio/R = M
		var/datum/computer/file/embedded_program/P = locate(R.id_tag)
		if(istype(P))
			error("Duplicate program: '[R.id_tag]'")
		id_tag = R.id_tag

/datum/computer/file/embedded_program/Destroy()
	master = null
	return ..()

/datum/computer/file/embedded_program/proc/receive_user_command(command)
	return

/datum/computer/file/embedded_program/proc/receive_signal(datum/signal/signal, receive_method, receive_param)
	return

/datum/computer/file/embedded_program/process()
	return

/datum/computer/file/embedded_program/proc/post_signal(datum/signal/signal, comm_line)
	if(master)
		master.post_signal(signal, comm_line)
	else
		qdel(signal)
