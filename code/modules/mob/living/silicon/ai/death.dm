/mob/living/silicon/ai/death(gibbed)
	if(stat == DEAD)	return
	stat = DEAD
	if("[icon_state]_dead" in icon_states(src.icon,1))
		icon_state = "[icon_state]_dead"
	else
		icon_state = "ai_dead"

	update_canmove()
	if(eyeobj)
		eyeobj.setLoc(get_turf(src))
	update_sight()
	client.screen.Cut()
	remove_ai_verbs(src)

	var/callshuttle = 0

	for(var/obj/machinery/computer/communications/commconsole in communications_list)
		if(is_centcom_level(commconsole.z))
			continue
		if(istype(commconsole.loc,/turf))
			break
		callshuttle++

	for(var/obj/item/weapon/circuitboard/communications/commboard in circuitboard_communications_list)
		if(is_centcom_level(commboard.z))
			continue
		if(istype(commboard.loc,/turf) || istype(commboard.loc,/obj/item/weapon/storage))
			break
		callshuttle++

	for(var/mob/living/silicon/ai/shuttlecaller in player_list)
		if(is_centcom_level(shuttlecaller.z))
			continue
		if(shuttlecaller.stat == CONSCIOUS && shuttlecaller.client && istype(shuttlecaller.loc,/turf))
			break
		callshuttle++

	if(find_faction_by_type(/datum/faction/revolution) || find_faction_by_type(/datum/faction/malf_silicons) || sent_strike_team)
		callshuttle = 0

	if(callshuttle == 3) //if all three conditions are met
		SSshuttle.incall(2)
		log_game("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
		message_admins("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
		SSshuttle.announce_emer_called.play()

	if(explosive)
		spawn(10)
			explosion(src.loc, 3, 6, 12, 14)

	for(var/obj/machinery/ai_status_display/O in ai_status_display_list) //change status
		spawn( 0 )
		O.mode = 2
		if (istype(loc, /obj/item/device/aicard))
			loc.icon_state = "aicard-404"

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)

	return ..(gibbed)
