// DRONE ABILITIES
/mob/living/silicon/robot/drone/verb/set_mail_tag()
	set name = "Set Mail Tag"
	set desc = "Tag yourself for delivery through the disposals system."
	set category = "Drone"

	var/new_tag = input("Select the desired destination.", "Set Mail Tag", null) as null|anything in tagger_locations

	if(!new_tag)
		mail_destination = ""
		return

	to_chat(src, "\blue You configure your internal beacon, tagging yourself for delivery to '[new_tag]'.")
	mail_destination = new_tag

	//Auto flush if we use this verb inside a disposal chute.
	var/obj/machinery/disposal/D = src.loc
	if(istype(D))
		to_chat(src, "\blue \The [D] acknowledges your signal.")
		D.flush_count = D.flush_every_ticks

	return

/mob/living/silicon/robot/drone/verb/hide()
	set name = "Hide"
	set desc = "Allows you to hide beneath tables or certain items. Toggled on or off."
	set category = "Drone"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("\blue You are now hiding."))
	else
		layer = MOB_LAYER
		to_chat(src, text("\blue You have stopped hiding."))

//Actual picking-up event.
/mob/living/silicon/robot/drone/attack_hand(mob/living/carbon/human/M)

	if(M.a_intent == "help")
		get_scooped(M)
	..()
