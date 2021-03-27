#define SCHOOL_DESTRUCTION 1
#define SCHOOL_BLUESPACE 2
#define SCHOOL_HEAL 4
#define SCHOOL_ROBELESS 8
#define WHOLE_SCHOOLS 15

/obj/item/device/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	item_state = "electronic"
	origin_tech = "bluespace=4;materials=4"
	w_class = ITEM_SIZE_TINY
	var/list/spooky_scaries = list()
	var/unlimited = 0

/obj/item/device/necromantic_stone/unlimited
	unlimited = 1

/obj/item/device/necromantic_stone/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(!istype(M))
		return ..()

	if(!istype(user) || user.incapacitated())
		return

	if(M.stat != DEAD)
		to_chat(user, "<span class='warning'>This artifact can only affect the dead!</span>")
		return
	if(M.species.name == SKELETON)
		to_chat(user, "<span class='warning'>This body has been already dried!</span>")
		return

	if(!M.mind || !M.client)
		to_chat(user, "<span class='warning'>There is no soul connected to this body...</span>")
		return

	check_spooky()//clean out/refresh the list
	if(spooky_scaries.len >= 3 && !unlimited)
		to_chat(user, "<span class='warning'>This artifact can only affect three undead at a time!</span>")
		return
	M.set_species(SKELETON)
	M.revive()
	spooky_scaries |= M
	to_chat(M, "<span class='userdanger'>You have been revived by </span><B>[user.real_name]!</B>")
	to_chat(M, "<span class='userdanger'>[user.real_name] your master now, assist them even if it costs you your new life!</span>")
	equip_roman_skeleton(M)
	M.regenerate_icons()
	desc = "A shard capable of resurrecting humans as skeleton thralls[unlimited ? "." : ", [spooky_scaries.len]/3 active thralls."]"

/obj/item/device/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return

	for(var/X in spooky_scaries)
		if(!ishuman(X))
			spooky_scaries.Remove(X)
			continue
		var/mob/living/carbon/human/H = X
		if(H.stat == DEAD)
			spooky_scaries.Remove(X)
			continue
	listclearnulls(spooky_scaries)

/obj/item/device/necromantic_stone/proc/equip_roman_skeleton(mob/living/carbon/human/H)
	for(var/obj/item/I in H)
		H.remove_from_mob(I)

	var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionaire)
	H.equip_to_slot_or_del(new hat(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/roman(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), SLOT_SHOES)
	H.put_in_any_hand_if_possible(new /obj/item/weapon/shield/riot/roman(H))
	H.put_in_any_hand_if_possible(new /obj/item/weapon/claymore/light(H))
	H.equip_to_slot_or_del(new /obj/item/weapon/twohanded/spear(H), SLOT_BACK)

/////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	var/datum/mind/wizard
	var/uses = 3
	var/free_school_flags = WHOLE_SCHOOLS
	var/list/previous_users = list()

/obj/item/weapon/contract/attack_self(mob/living/carbon/user)
	user.set_machine(src)
	var/dat
	if(!uses)
		dat = "<B>On this [src] no more place to signature.</B><BR>"
	else
		dat = "<B>Contract of Apprenticeship:</B><BR>"
		dat += "<I>Using this contract, you agree to become an apprentice .</I><BR>"
		dat += "<B>Which school of magic you want to studying?:</B><BR>"
		if(free_school_flags & SCHOOL_DESTRUCTION)
			dat += "<A href='byond://?src=\ref[src];school=destruction'>Destruction</A><BR>"
			dat += "<I>You will follow the path in offensive magic. They know Magic Missile and Fireball.</I><BR>"
		if(free_school_flags & SCHOOL_BLUESPACE)
			dat += "<A href='byond://?src=\ref[src];school=bluespace'>Bluespace Manipulation</A><BR>"
			dat += "<I>You will follow the path in defy physics, melting through solid objects and travelling great distances in the blink of an eye. you will know Teleport and Ethereal Jaunt.</I><BR>"
		if(free_school_flags & SCHOOL_HEAL)
			dat += "<A href='byond://?src=\ref[src];school=healing'>Healing</A><BR>"
			dat += "<I>You will learn to cast spells that will aid your master survival. You will know Charge, ressurection and healing.</I><BR>"
		if(free_school_flags & SCHOOL_ROBELESS)
			dat += "<A href='byond://?src=\ref[src];school=robeless'>Robeless</A><BR>"
			dat += "<I>You will be able to cast spells without robes. You will know Knock and Mindswap.</I><BR>"
	dat += "<BR>"
	for(var/datum/mind/M in previous_users)
		dat += "<I>[M.name]</I><BR>"

	var/datum/browser/popup = new(user, "window=radio", "Contract")
	popup.set_content(dat)
	popup.open()

/obj/item/weapon/contract/Topic(href, href_list)
	..()
	if(!ishuman(usr))
		return 1
	var/mob/living/carbon/human/H = usr
	if(H.mind.special_role == "Wizard")
		to_chat(H, "<span class='danger'>Your school years have long passed.</span>")
		return

	if(ismindshielded(H))
		to_chat(H, "<span class='notice'>Something prevents you from becoming a magic girl that you've allways dreamed of</span>")
		return

	for(var/datum/mind/mind in previous_users)
		if(H.mind == mind)
			to_chat(H, "<span class='notice'>Not so fast, self-confident fulmar</span>")
			return
	if(H.incapacitated())
		return

	if(loc == H || (in_range(src, H) && isturf(loc)))
		H.set_machine(src)
		if(href_list["school"])
			if(!uses)
				to_chat(H, "<span class='notice'>On this [src] no more place to signature</span>")
				return
			make_apprentice(H, href_list["school"])

/obj/item/weapon/contract/proc/make_apprentice(mob/living/carbon/human/M, type = "")
	new /obj/effect/effect/smoke (get_turf(src))
	var/wizard_name = "Grand Magus"
	if(wizard)
		wizard_name = wizard.name
	if(M.mind.special_role == "traitor")
		to_chat(M, "<span class='notice'>You succeed in getting those precious powers from that fool. Now it's time to show [master] what you are realy after.</span>")
	else
		to_chat(M, "<span class='notice'>You are [master]'s apprentice! You are bound by magic contract to follow their orders and help them in accomplishing their goals.</span>")
	switch(type)
		if("destruction")
			if(free_school_flags & SCHOOL_DESTRUCTION)
				free_school_flags &= ~SCHOOL_DESTRUCTION
				M.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(M))
				M.AddSpell(new /obj/effect/proc_holder/spell/in_hand/fireball(M))
				to_chat(M, "<span class='notice'>Studying under [wizard_name], you have learned powerful, destructive spells. You are able to cast magic missile and fireball.</span>")
		if("bluespace")
			if(free_school_flags & SCHOOL_BLUESPACE)
				free_school_flags &= ~SCHOOL_BLUESPACE
				M.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(M))
				M.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(M))
				M.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall(M))
				to_chat(M, "<span class='notice'>Studying under [wizard_name], you have learned reality bending mobility spells. You are able to cast teleport and ethereal jaunt, forcewall.</span>")
		if("healing")
			if(free_school_flags & SCHOOL_HEAL)
				free_school_flags &= ~SCHOOL_HEAL
				M.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge(M))
				M.AddSpell(new /obj/effect/proc_holder/spell/in_hand/res_touch(M))
				M.AddSpell(new /obj/effect/proc_holder/spell/in_hand/heal(M))
				to_chat(M, "<span class='notice'>Studying under [wizard_name], you have learned livesaving survival spells. You are able to cast charge, resurrection and heal.</span>")
		if("robeless")
			if(free_school_flags & SCHOOL_ROBELESS)
				free_school_flags &= ~SCHOOL_ROBELESS
				M.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(M))
				M.AddSpell(new /obj/effect/proc_holder/spell/targeted/mind_transfer(M))
				to_chat(M, "<span class='notice'>Studying under [wizard_name], you have learned stealthy, robeless spells. You are able to cast knock and mindswap.</span>")
	equip_apprentice(M)
	if(wizard && wizard.current)
		if(M.mind.special_role == "traitor")  //Because traitors gonna trait. Besides, mage with dualsaber and revolver is a bit too OP for this station
			var/datum/objective/protect/new_objective = new /datum/objective/assassinate
			new_objective.explanation_text = "Assassinate [wizard.current.real_name], the wizard."
			new_objective.owner = M.mind
			new_objective.target = wizard
			M.mind.objectives += new_objective
		else
			var/datum/objective/protect/new_objective = new /datum/objective/protect
			new_objective.explanation_text = "Protect [wizard.current.real_name], the wizard."
			new_objective.owner = M.mind
			new_objective.target = wizard
			M.mind.objectives += new_objective
	uses--
	previous_users += M.mind
	playsound(M, 'sound/effects/magic.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/contract/proc/equip_apprentice(mob/living/carbon/human/target)
	for(var/obj/item/I in target)
		target.remove_from_mob(I)
	target.equip_to_slot_or_del(new /obj/item/device/radio/headset(target), SLOT_L_EAR)
	target.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(target), SLOT_W_UNIFORM)
	target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(target), SLOT_SHOES)
	target.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(target), SLOT_WEAR_SUIT)
	target.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(target), SLOT_HEAD)
	target.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(target), SLOT_BACK)
	target.equip_to_slot_or_del(new /obj/item/weapon/storage/box(target), SLOT_IN_BACKPACK)
	target.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(target), SLOT_R_STORE)

#undef SCHOOL_DESTRUCTION
#undef SCHOOL_BLUESPACE
#undef SCHOOL_HEAL
#undef SCHOOL_ROBELESS
#undef WHOLE_SCHOOLS
