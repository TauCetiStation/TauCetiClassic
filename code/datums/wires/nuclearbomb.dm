var/const/NUKE_WIRE_LIGHT  = 1
var/const/NUKE_WIRE_TIMING = 2
var/const/NUKE_WIRE_SAFETY = 4

/datum/wires/nuclearbomb
	random = TRUE
	holder_type = /obj/machinery/nuclearbomb
	wire_count = 7

/datum/wires/nuclearbomb/can_use()
	var/obj/machinery/nuclearbomb/N = holder
	return N.opened

/datum/wires/nuclearbomb/additional_checks_and_effects(mob/living/user)
	return isdrone(user)

/datum/wires/nuclearbomb/get_interact_window()
	var/obj/machinery/nuclearbomb/N = holder
	. = ..()
	. += "<br>The device is [N.timing ? "shaking!" : "still."]"
	. += "<br>The device is [N.safety ? "quiet" : "whirring"]."
	. += "<br>The lights are [N.lighthack ? "static" : "functional"]."

/datum/wires/nuclearbomb/update_cut(index, mended)
	var/obj/machinery/nuclearbomb/N = holder

	switch(index)
		if(NUKE_WIRE_LIGHT)
			N.lighthack = mended

		if(NUKE_WIRE_TIMING)
			if(!N.lighthack && !mended)
				if(N.icon_state == "nuclearbomb2")
					N.icon_state = "nuclearbomb1"
				N.timing = 0
				bomb_set = 0
				if(get_security_level() == "delta")
					set_security_level("red")

		if(NUKE_WIRE_SAFETY)
			if(N.timing > 0)
				N.explode()

/datum/wires/nuclearbomb/update_pulsed(index)
	var/obj/machinery/nuclearbomb/N = holder

	switch(index)
		if(NUKE_WIRE_LIGHT)
			N.lighthack = !N.lighthack
			addtimer(CALLBACK(src, .proc/pulse_reaction, index), 100)

		if(NUKE_WIRE_TIMING)
			if(N.timing > 0)
				N.explode()

		if(NUKE_WIRE_SAFETY)
			N.safety = !N.safety
			addtimer(CALLBACK(src, .proc/pulse_reaction, index), 100)
			if(N.safety)
				N.visible_message("<span class='notice'>The [N] quiets down.</span>")
				if(N.icon_state == "nuclearbomb2")
					N.icon_state = "nuclearbomb1"
			else
				N.visible_message("<span class='notice'>The [N] emits a quiet whirling noise!</span>")

/datum/wires/nuclearbomb/proc/pulse_reaction(index)
	var/obj/machinery/nuclearbomb/N = holder

	switch(index)
		if(NUKE_WIRE_LIGHT)
			N.lighthack = !N.lighthack

		if(NUKE_WIRE_SAFETY)
			N.safety = !N.safety
