var/global/const/NUKE_WIRE_LIGHT  = 1
var/global/const/NUKE_WIRE_TIMING = 2
var/global/const/NUKE_WIRE_SAFETY = 4

/datum/wires/nuclearbomb
	random = TRUE
	holder_type = /obj/machinery/nuclearbomb
	wire_count = 7
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_PRO)

/datum/wires/nuclearbomb/can_use()
	var/obj/machinery/nuclearbomb/N = holder
	return N.opened

/datum/wires/nuclearbomb/additional_checks_and_effects(mob/living/user)
	return isdrone(user)

/datum/wires/nuclearbomb/get_status()
	var/obj/machinery/nuclearbomb/N = holder
	. = ..()
	. += "The device is [N.timing ? "shaking!" : "still."]"
	. += "The device is [N.safety ? "quiet" : "whirring"]."
	. += "The lights are [N.lighthack ? "static" : "functional"]."

/datum/wires/nuclearbomb/update_cut(index, mended, mob/user)
	var/obj/machinery/nuclearbomb/N = holder

	switch(index)
		if(NUKE_WIRE_LIGHT)
			N.lighthack = mended

		if(NUKE_WIRE_TIMING)
			if(!N.lighthack && !mended)
				N.timing = 0
				if(istype(N, /obj/machinery/nuclearbomb/fake))
					return
				if(get_security_level() == "delta")
					set_security_level("red")

		if(NUKE_WIRE_SAFETY)
			if(N.timing && !N.detonated)
				N.explode()
	N.update_icon()

/datum/wires/nuclearbomb/update_pulsed(index)
	var/obj/machinery/nuclearbomb/N = holder

	switch(index)
		if(NUKE_WIRE_LIGHT)
			N.lighthack = !N.lighthack
			addtimer(CALLBACK(src, PROC_REF(pulse_reaction), index), 100)

		if(NUKE_WIRE_TIMING)
			if(N.timing && !N.detonated)
				N.explode()

		if(NUKE_WIRE_SAFETY)
			N.safety = !N.safety
			addtimer(CALLBACK(src, PROC_REF(pulse_reaction), index), 100)
			if(N.safety)
				N.visible_message("<span class='notice'>The [N] quiets down.</span>")
			else
				N.visible_message("<span class='notice'>The [N] emits a quiet whirling noise!</span>")
	N.update_icon()

/datum/wires/nuclearbomb/proc/pulse_reaction(index)
	var/obj/machinery/nuclearbomb/N = holder

	switch(index)
		if(NUKE_WIRE_LIGHT)
			N.lighthack = !N.lighthack

		if(NUKE_WIRE_SAFETY)
			N.safety = !N.safety
	N.update_icon()
