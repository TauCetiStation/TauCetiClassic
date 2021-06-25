/obj/effect/proc_holder/borer/active/noncontrol/escape
	name = "Release Host"
	desc = "Slither out of your host."

/obj/effect/proc_holder/borer/active/noncontrol/escape/activate()
	. = ..()
	if(!holder.host)
		to_chat(holder, "You are not inside a host body.")
		return FALSE

	if(holder.leaving)
		holder.leaving = FALSE
		to_chat(holder, "<span class='userdanger'>You decide against leaving your host.</span>")
		return FALSE

	to_chat(holder, "You begin disconnecting from [holder.host]'s synapses and prodding at their internal ear canal.")

	holder.leaving = TRUE

	if(holder.host.stat == CONSCIOUS)
		to_chat(host, "An odd, uncomfortable pressure begins to build inside your skull, behind your ear...")

	addtimer(CALLBACK(holder, /mob/living/simple_animal/borer/proc/let_go), 200)

/mob/living/simple_animal/borer/proc/let_go()
	if(!host || !src || QDELETED(host) || QDELETED(src))
		return
	if(!leaving)
		return
	if(controlling)
		return
	if(incapacitated())
		to_chat(src, "You cannot infest a target in your current state.")
		return
	to_chat(src, "You wiggle out of [host]'s ear and plop to the ground.")

	leaving = FALSE

	if(host.stat == CONSCIOUS)
		to_chat(host, "Something slimy wiggles out of your ear and plops to the ground!")

	detatch()

/mob/living/simple_animal/borer/proc/detatch()
	if(!host)
		return

	if(ishuman(host))
		var/mob/living/carbon/human/H = host
		var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]

		BP.implants -= src
		if(H.glasses?.hud_list)
			for(var/hud in H.glasses.hud_list)
				var/datum/atom_hud/AH = global.huds[hud]
				AH.remove_hud_from(src)

	forceMove(get_turf(host))
	controlling = FALSE

	reset_view(null)
	machine = null

	host.reset_view(null)
	host.machine = null

	if(host_brain.ckey)
		ckey = host.ckey
		host.ckey = host_brain.ckey
		host_brain.ckey = null
		host_brain.name = "host brain"
		host_brain.real_name = "host brain"
	host.parasites -= src
	host = null
