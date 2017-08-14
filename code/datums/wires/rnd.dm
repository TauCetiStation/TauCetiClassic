var/const/RND_WIRE_HACK    = 1
var/const/RND_WIRE_DISABLE = 2
var/const/RND_WIRE_SHOCK   = 4

/datum/wires/rnd
	holder_type = /obj/machinery/r_n_d
	wire_count = 6

/datum/wires/rnd/can_use()
	var/obj/machinery/r_n_d/R = holder
	return R.panel_open

/datum/wires/rnd/get_interact_window()
	var/obj/machinery/r_n_d/R = holder
	. += ..()
	. += "<br>The red light is [R.disabled ? "off" : "on"]."
	. += "<br>The green light is [R.shocked ? "off" : "on"]."
	. += "<br>The blue light is [R.hacked ? "off" : "on"]."

/datum/wires/rnd/update_cut(index, mended)
	var/obj/machinery/r_n_d/R = holder

	switch(index)
		if(RND_WIRE_HACK)
			R.hacked = !mended

		if(RND_WIRE_DISABLE)
			R.disabled = !mended
			R.shock(usr, 50)

		if (RND_WIRE_SHOCK)
			R.shocked = !mended
			R.shock(usr, 50)

/datum/wires/rnd/update_pulsed(index)
	var/obj/machinery/r_n_d/R = holder

	switch(index)
		if(RND_WIRE_HACK)
			R.hacked = !R.hacked
			addtimer(CALLBACK(src, .proc/pulse_reaction, index), 100)

		if(RND_WIRE_DISABLE)
			R.disabled = !R.disabled
			R.shock(usr, 50)
			addtimer(CALLBACK(src, .proc/pulse_reaction, index), 100)

		if(RND_WIRE_SHOCK)
			R.shocked = !R.shocked
			addtimer(CALLBACK(src, .proc/pulse_reaction, index), 100)

/datum/wires/rnd/proc/pulse_reaction(index)
	var/obj/machinery/r_n_d/R = holder

	switch(index)
		if(RND_WIRE_HACK)
			R.hacked = !R.hacked

		if(RND_WIRE_DISABLE)
			R.disabled = !R.disabled

		if(RND_WIRE_SHOCK)
			R.shocked = !R.shocked