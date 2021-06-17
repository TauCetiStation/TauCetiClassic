/obj/effect/proc_holder/borer/active/noncontrol/escape
	name = "Release Host"
	desc = "Slither out of your host."

/obj/effect/proc_holder/borer/active/noncontrol/escape/activate(mob/living/simple_animal/borer/B)
	if(!B.host)
		to_chat(B, "You are not inside a host body.")
		return

	if(B.incapacitated())
		to_chat(B, "You cannot leave your host in your current state.")
		return

	if(B.docile)
		to_chat(B, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return

	if(B.leaving)
		B.leaving = FALSE
		to_chat(B, "<span class='userdanger'>You decide against leaving your host.</span>")
		return

	to_chat(B, "You begin disconnecting from [B.host]'s synapses and prodding at their internal ear canal.")

	B.leaving = TRUE

	if(B.host.stat == CONSCIOUS)
		to_chat(host, "An odd, uncomfortable pressure begins to build inside your skull, behind your ear...")

	addtimer(CALLBACK(B, /mob/living/simple_animal/borer/proc/let_go), 200)

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