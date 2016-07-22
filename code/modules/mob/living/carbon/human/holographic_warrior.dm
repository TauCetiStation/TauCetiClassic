/datum/holy_war
	var/list/warriors = list()

/datum/holy_war/proc/request_client_to_war(var/mob/M)
	spawn(0)
		if(!M.client)
			return
		var/response = alert(M.client, "Someone is started Holy War For Crew Transfer Call. Would you like to play as Warrior?", "Holy war starder", "Yes, call shuttle", "Yes, left on station", "No")
		if(!M.client || !M.mind || !M.key)
			return
		if(SSvote && SSvote.time_remaining < 10)
			return
		var/mob/living/carbon/human/holo_warrior/H
		if(response == "Yes, call shuttle")
			H = spawn_warrior(SIDE_CALL)
		else if(response == "Yes, left on station")
			H = spawn_warrior(SIDE_STATION)
		else
			return
		warriors.Add(H)
		if(istype(M,/mob/living/carbon/human))
			M.mind.active = 0
			M.mind.transfer_to(H)
			H.key = M.key
			H.host = M
		else if(istype(M,/mob/dead/observer))
			M.mind.transfer_to(H)
			H.key = M.key
			H.host = null
		else
			warriors.Remove(H)
			qdel(H)
			world << "Oops, error"
		return


/datum/holy_war/proc/spawn_warrior(var/side = 0)
	if(!side)
		return null
	if(!tdome1.len || !tdome2.len)
		return null
	var/mob/living/carbon/human/holo_warrior/H
	if(side == SIDE_CALL)
		H = new /mob/living/carbon/human/holo_warrior(pick(tdome1))
	else
		H = new /mob/living/carbon/human/holo_warrior(pick(tdome2))
	H.equip_warrior(side)
	H.name = "[H.name] ([rand(1, 1000)])"
	H.real_name = H.name
	H.side = side
	return H

/datum/species/human/holo_warrior
	name = "Holographic Warrior"

/mob/living/carbon/human/holo_warrior
	var/mob/living/carbon/human/host
	var/side = 0

/mob/living/carbon/human/holo_warrior/New(var/new_loc)
	..(new_loc, "Holographic Warrior")

/mob/living/carbon/human/holo_warrior/verb/return_to_host()
	set name = "Return to host"
	set category = "IC"

	if( stat || weakened || paralysis || resting || sleeping || (status_flags & FAKEDEATH) || buckled)
		return

	if (!mind || !key)
		return

	if (!host)
		return

	if(host)
		mind.active = 0
		mind.transfer_to(host)
		host.key = key
	qdel(src)

	//slot_wear_suit

/mob/living/carbon/human/holo_warrior/proc/equip_warrior(var/side = 0)
	if(side == SIDE_CALL)
		equip_to_slot_or_del(new /obj/item/clothing/under/color/green(src), slot_w_uniform)
	else
		equip_to_slot_or_del(new /obj/item/clothing/under/color/red(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/black(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/black(src), slot_gloves)
	equip_to_slot_or_del(new /obj/item/clothing/head/helmet/swat(src), slot_head)
	equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun/nuclear(src), slot_r_hand)
	equip_to_slot_or_del(new /obj/item/weapon/shield/energy(src), slot_l_hand)
	equip_to_slot_or_del(new /obj/item/weapon/katana(src), slot_belt)