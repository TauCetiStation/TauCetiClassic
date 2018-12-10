/obj/item/weapon/card/id/SCP_005
	icon = 'code/modules/SCP/SCP_005/key/stuff.dmi'
	name = "SCP-005"
	desc = "Rusty key... nothing suspicious. "
	icon_state = "key"
	item_state = "key"
	lefthand_file = 'code/modules/SCP/SCP_005/key/left.dmi'
	righthand_file = 'code/modules/SCP/SCP_005/key/right.dmi'
	access = list(access_security, access_brig, access_armory, access_forensics_lockers, access_medical, access_morgue, access_tox, access_tox_storage, access_genetics, access_engine, access_engine_equip, access_maint_tunnels, access_external_airlocks, access_emergency_storage, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers, access_chapel_office, access_tech_storage, access_atmospherics, access_bar, access_janitor, access_crematorium, access_kitchen, access_robotics, access_rd, access_cargo, access_construction, access_chemistry, access_cargo_bot, access_hydroponics, access_manufacturing, access_library, access_lawyer, access_virology, access_cmo, access_qm, access_court , access_clown, access_mime, access_surgery, access_theatre, access_research, access_mining, access_mining_office, access_mailsorting, access_mint, access_mint_vault, access_heads_vault, access_mining_station, access_xenobiology, access_ce, access_hop, access_hos, access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway , access_sec_doors, access_psychiatrist, access_xenoarch, access_minisat, access_recycler, access_detective, access_barber, access_paramedic, access_cent_general, access_cent_thunder, access_cent_specops, access_cent_medical, access_cent_living, access_cent_storage, access_cent_teleporter, access_cent_creed, access_cent_captain, access_syndicate, access_syndicate_commander)
	w_class = ITEM_SIZE_HUGE
	slot_flags = 0 // Can't wear as ID

/obj/item/weapon/card/id/SCP_005/pickup(mob/living/carbon/human/user)
	assignment = name
	registered_name = user.real_name

/obj/item/weapon/card/id/SCP_005/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(istype(target, /obj/machinery/door))
		var/obj/machinery/door/door = target

		if(istype(door, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/A = door
			INVOKE_ASYNC(A, /obj/machinery/door/airlock/proc/unbolt)
		//INVOKE_ASYNC(door, /obj/machinery/door/proc/open)
	else
		. = ..()

/obj/item/weapon/card/id/SCP_005/attack_self(mob/H)
	H.visible_message("<span class='warning'>The key strangely glows in [H]'s hands!</span>")
	var/list/mytargets = list(H.loc, get_step(H.loc, EAST), get_step(H.loc, WEST), get_step(H.loc, NORTH), get_step(H.loc, SOUTH))
	for(var/turf/T in mytargets)
		for(var/obj/machinery/door/door in T.contents)
			if(door.density)
				if(istype(door, /obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/A = door
					INVOKE_ASYNC(A, /obj/machinery/door/airlock/proc/unbolt)
				INVOKE_ASYNC(door, /obj/machinery/door/proc/open)
		for(var/obj/structure/closet/C in T.contents)
			if(C.density)
				C.locked = 0
				INVOKE_ASYNC(C, /obj/structure/closet/proc/open)
				return