/obj/item/weapon/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 3
	throw_range = 7
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'
	var/cooldown = 0

/obj/item/weapon/scrying/attack_self(mob/living/user)
	if(cooldown >= world.time)
		to_chat(user, "<span class='userdanger' It's still charging</span>")
		return
	to_chat(user, "<span class='notice'>You can see...everything!</span>")
	visible_message("<span class='danger'>[user] stares into [src], their eyes glazing over.</span>")
	cooldown = world.time + 1200
	var/mob/dead/observer/ghost = user.ghostize(FALSE)
	addtimer(CALLBACK(src, .proc/reenter, user, ghost), 300)

/obj/item/weapon/scrying/proc/reenter(mob/living/body, mob/dead/observer/ghost)
	if(body && body.stat != DEAD && ghost && ghost.key)
		body.key = ghost.key
		qdel(ghost)

/obj/item/device/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	item_state = "electronic"
	origin_tech = "bluespace=4;materials=4"
	w_class = 1
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
	if(istype(M.species,/datum/species/skeleton))
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
	H.equip_to_slot_or_del(new hat(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/roman(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), slot_shoes)
	H.put_in_any_hand_if_possible(new /obj/item/weapon/shield/riot/roman(H))
	H.put_in_any_hand_if_possible(new /obj/item/weapon/claymore/light(H))
	H.equip_to_slot_or_del(new /obj/item/weapon/twohanded/spear(H), slot_back)

/////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	w_class = 2
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	var/datum/mind/wizard
	var/uses = 3
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
		dat += "<A href='byond://?src=\ref[src];school=destruction'>Destruction</A><BR>"
		dat += "<I>You will follow the path in offensive magic. They know Magic Missile and Fireball.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=bluespace'>Bluespace Manipulation</A><BR>"
		dat += "<I>You will follow the path in defy physics, melting through solid objects and travelling great distances in the blink of an eye. you will know Teleport and Ethereal Jaunt.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=healing'>Healing</A><BR>"
		dat += "<I>You will learn to cast spells that will aid your master survival. You will know Forcewall and Charge and come with a Staff of Healing.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=robeless'>Robeless</A><BR>"
		dat += "<I>You will be able to cast spells without robes. You will know Knock and Mindswap.</I><BR>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/weapon/contract/Topic(href, href_list)
	..()
	if(!ishuman(usr))
		return 1
	var/mob/living/carbon/human/H = usr
	if(H.mind == wizard)
		to_chat(H, "<span class='danger'>Your school years have long passed.</span>")
		return
	for(var/datum/mind/mind in previous_users)
		if(H.mind == mind)
			to_chat(H, "<span class='notice'>Not so fast, self-confident fulmar</span>")
			return
	if(H.stat || H.incapacitated())
		return

	if(loc == H || (in_range(src, H) && isturf(loc)))
		H.set_machine(src)
		if(href_list["school"])
			if(!uses)
				to_chat(H, "<span class='notice'>On this [src] no more place to signature</span>")
				return
			make_apprentice(H, href_list["school"])

/obj/item/weapon/contract/proc/make_apprentice(mob/living/carbon/human/M, type = "")
	new /obj/effect/effect/smoke(get_turf(src))
	var/wizard_name = "Grand Magus"
	if(wizard)
		wizard_name = wizard.name
	to_chat(M, "<span class='notice'>You are [master]'s apprentice! You are bound by magic contract to follow their orders and help them in accomplishing their goals.</span>")
	switch(type)
		if("destruction")
			M.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(M))
			M.AddSpell(new /obj/effect/proc_holder/spell/in_hand/fireball(M))
			to_chat(M, "<span class='notice'>Your service has not gone unrewarded, however. Studying under [wizard_name], you have learned powerful, destructive spells. You are able to cast magic missile and fireball.</span>")
		if("bluespace")
			M.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(M))
			M.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(M))
			to_chat(M, "<span class='notice'>Your service has not gone unrewarded, however. Studying under [wizard_name], you have learned reality bending mobility spells. You are able to cast teleport and ethereal jaunt.</span>")
		if("healing")
			M.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge(M))
			M.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall(M))
			M.put_in_hands(new /obj/item/weapon/gun/magic/staff/healing/one_person(M,M.mind))
			to_chat(M, "<span class='notice'>Your service has not gone unrewarded, however. Studying under [wizard_name], you have learned livesaving survival spells. You are able to cast charge and forcewall.</span>")
		if("robeless")
			M.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(M))
			M.AddSpell(new /obj/effect/proc_holder/spell/targeted/mind_transfer(M))
			to_chat(M, "<span class='notice'>Your service has not gone unrewarded, however. Studying under [wizard_name], you have learned stealthy, robeless spells. You are able to cast knock and mindswap.</span>")
	equip_apprentice(M)
	if(wizard && wizard.current)
		var/datum/objective/protect/new_objective = new /datum/objective/protect
		new_objective.owner = M.mind
		new_objective.target = wizard
		new_objective.explanation_text = "Protect [wizard.current.real_name], the wizard."
		M.mind.objectives += new_objective
	uses--
	previous_users += M.mind
//	M << sound('sound/effects/magic.ogg')

/obj/item/weapon/contract/proc/equip_apprentice(mob/living/carbon/human/target)
	for(var/obj/item/I in target)
		target.remove_from_mob(I)
	target.equip_to_slot_or_del(new /obj/item/device/radio/headset(target), slot_l_ear)
	target.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(target), slot_w_uniform)
	target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(target), slot_shoes)
	target.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(target), slot_wear_suit)
	target.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(target), slot_head)
	target.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(target), slot_back)
	target.equip_to_slot_or_del(new /obj/item/weapon/storage/box(target), slot_in_backpack)
	target.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(target), slot_r_store)