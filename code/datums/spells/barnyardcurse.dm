/obj/effect/proc_holder/spell/targeted/barnyardcurse
	name = "Curse of the Barnyard"
	desc = "This spell dooms an unlucky soul to possess the speech and facial attributes of a barnyard animal."
	school = "transmutation"
	charge_type = "recharge"
	charge_max = 150
	charge_counter = 0
	clothes_req = 0
	stat_allowed = 0
	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = "shout"
	range = 7
	selection_type = "range"
	action_icon_state = "barn"
	var/static/list/compatible_mobs = null

/obj/effect/proc_holder/spell/targeted/barnyardcurse/atom_init()
	. = ..()
	if(!compatible_mobs)
		compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

/obj/effect/proc_holder/spell/targeted/barnyardcurse/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/carbon/target
	while(targets.len)
		target = targets[targets.len]
		targets -= target
		if(istype(target))
			break

	if(!(target.type in compatible_mobs))
		to_chat(user, "<span class='notice'>It'd be stupid to curse [target] head!</span>")
		return

	if(!(target in oview(range)))//If they are not  in overview after selection.
		to_chat(user, "<span class='notice'>They are too far away!</span>")
		return

	var/list/masks = list(/obj/item/clothing/mask/pig, /obj/item/clothing/mask/cowmask, /obj/item/clothing/mask/horsehead, /obj/item/clothing/mask/chicken)
	var/list/mSounds = list('sound/magic/PigHead_curse.ogg', 'sound/magic/CowHead_Curse.ogg', 'sound/magic/HorseHead_curse.ogg', 'sound/magic/ChickenHead_curse.ogg')
	var/randM = rand(1, 4)
	var/choice = masks[randM]
	var/obj/item/clothing/mask/magichead = new choice
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		H.speech_problem_flag = 1
	magichead.canremove = 0
	target.visible_message("<span class='danger'>[target]'s face bursts into flames, and a barnyard animal's head takes its place!</span>", \
						   "<span class='danger'>Your face burns up, and shortly after the fire you realise you have the face of a barnyard animal!</span>")
	playsound(target, mSounds[randM], VOL_EFFECTS_MASTER)
	target.remove_from_mob(target.wear_mask)
	target.equip_to_slot_if_possible(magichead, SLOT_WEAR_MASK)
	target.flash_eyes()
