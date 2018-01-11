#define STATE_UNDOCKED		0
#define STATE_DOCKING		1
#define STATE_UNDOCKING		2
#define STATE_DOCKED		3

/obj/machinery/embedded_controller/radio/simple_docking_controller/multi_slave
	var/master_tag //for mapping
	progtype = /datum/computer/file/embedded_program/docking/simple/multi


/datum/computer/file/embedded_program/docking/simple/multi
	var/master_tag
	var/master_status = "undocked"
	var/master_state = STATE_UNDOCKED

/datum/computer/file/embedded_program/docking/simple/multi/New(obj/machinery/embedded_controller/M)
	..()

	if (istype(M, /obj/machinery/embedded_controller/radio/simple_docking_controller/multi_slave))	//if our parent controller is the right type, then we can auto-init stuff at construction
		var/obj/machinery/embedded_controller/radio/simple_docking_controller/multi_slave/controller = M
		master_tag = controller.master_tag

/datum/computer/file/embedded_program/docking/simple/multi/receive_signal(datum/signal/signal, receive_method, receive_param)
	var/receive_tag = signal.data["tag"]		//for docking signals, this is the sender id
	var/command = signal.data["command"]
	var/recipient = signal.data["recipient"]	//the intended recipient of the docking signal

	if (receive_tag == master_tag)
		if (signal.data["dock_status"])
			master_status = signal.data["dock_status"]

		if (recipient == id_tag)
			switch (command)
				if ("prepare_for_docking")
					if(!override_enabled)
						response_sent = FALSE
						master_state = STATE_DOCKING
						prepare_for_docking()

				if ("prepare_for_undocking")
					if(!override_enabled)
						response_sent = FALSE
						master_state = STATE_UNDOCKING
						prepare_for_undocking()

				if ("finish_docking")
					if(!override_enabled)
						master_state = STATE_DOCKED
						finish_docking()

				if ("finish_undocking")
					if(!override_enabled)
						master_state = STATE_UNDOCKED
						finish_undocking()

	..(signal, receive_method, receive_param)

/datum/computer/file/embedded_program/docking/simple/multi/process()
	if(master_state && !response_sent)
		switch(master_state)
			if(STATE_DOCKING)
				if (ready_for_docking())
					send_signal_to_master("ready_for_docking")
					response_sent = TRUE
			if(STATE_UNDOCKING)
				if (ready_for_undocking())
					send_signal_to_master("ready_for_undocking")
					response_sent = TRUE

	..()

/datum/computer/file/embedded_program/docking/simple/multi/get_docking_status()
	return master_state? master_status : ..()

/datum/computer/file/embedded_program/docking/simple/multi/enable_override()
	..()
	broadcast_override_status()

/datum/computer/file/embedded_program/docking/simple/multi/disable_override()
	..()
	broadcast_override_status()

/datum/computer/file/embedded_program/docking/simple/multi/proc/send_signal_to_master(command)
	var/datum/signal/signal = new
	signal.data["tag"] = id_tag
	signal.data["command"] = command
	signal.data["recipient"] = master_tag
	post_signal(signal)

/datum/computer/file/embedded_program/docking/simple/multi/proc/broadcast_override_status()
	var/datum/signal/signal = new
	signal.data["tag"] = id_tag
	signal.data["override_status"] = override_enabled? "enabled" : "disabled"
	post_signal(signal)

#undef STATE_UNDOCKED
#undef STATE_DOCKING
#undef STATE_UNDOCKING
#undef STATE_DOCKED
