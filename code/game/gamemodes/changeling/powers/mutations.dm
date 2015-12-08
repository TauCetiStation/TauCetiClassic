//Parent to shields and blades because muh copypasted code.
/obj/effect/proc_holder/changeling/weapon
	name = "Organic Weapon"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at Miauw and/or Perakp"
	chemical_cost = 1000
	genomecost = -1
	genetic_damage = 1000

	var/weapon_type
	var/weapon_name_simple

/obj/effect/proc_holder/changeling/weapon/try_to_sting(var/mob/user, var/mob/target)
	if(istype(user.l_hand, weapon_type)) //Not the nicest way to do it, but eh
		qdel(user.l_hand)
		user.visible_message("<span class='warning'>With a sickening crunch, [user] reforms his [weapon_name_simple] into an arm!</span>", "<span class='notice'>We assimilate the [weapon_name_simple] back into our body.</span>", "<span class='warning>You hear organic matter ripping and tearing!</span>")
		user.update_inv_l_hand()
		return
	if(istype(user.r_hand, weapon_type))
		qdel(user.r_hand)
		user.visible_message("<span class='warning'>With a sickening crunch, [user] reforms his [weapon_name_simple] into an arm!</span>", "<span class='notice'>We assimilate the [weapon_name_simple] back into our body.</span>", "<span class='warning>You hear organic matter ripping and tearing!</span>")
		user.update_inv_r_hand()
		return
	..(user, target)

/obj/effect/proc_holder/changeling/weapon/sting_action(var/mob/user)
	if(!user.unEquip(user.get_active_hand()))
		user << "The [user.get_active_hand()] is stuck to your hand, you cannot grow a [weapon_name_simple] over it!"
		return
	var/obj/item/W = new weapon_type(user)
	user.put_in_hands(W)
	return W

//Parent to space suits and armor.
/obj/effect/proc_holder/changeling/suit
	name = "Organic Suit"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at Miauw and/or Perakp"
	chemical_cost = 1000
	genomecost = -1
	genetic_damage = 1000

	var/helmet_type = /obj/item
	var/suit_type = /obj/item
	var/suit_name_simple = "    "
	var/helmet_name_simple = "     "
	var/recharge_slowdown = 0
	var/blood_on_castoff = 0

/obj/effect/proc_holder/changeling/suit/try_to_sting(var/mob/user, var/mob/target)
	var/datum/changeling/changeling = user.mind.changeling
	if(!ishuman(user) || !changeling)
		return

	var/mob/living/carbon/human/H = user
	if(istype(H.wear_suit, suit_type) || istype(H.head, helmet_type))
		H.visible_message("<span class='warning'>[H] casts off their [suit_name_simple]!</span>", "<span class='warning'>We cast off our [suit_name_simple][genetic_damage > 0 ? ", temporarily weakening our genomes." : "."]</span>", "<span class='warning'>You hear the organic matter ripping and tearing!</span>")
		qdel(H.wear_suit)
		qdel(H.head)
		H.update_inv_wear_suit()
		H.update_inv_head()
		H.update_hair()

		if(blood_on_castoff)
			var/turf/simulated/T = get_turf(H)
			if(istype(T))
				T.add_blood(H) //So real blood decals
				playsound(H.loc, 'sound/effects/splat.ogg', 50, 1) //So real sounds

		changeling.geneticdamage += genetic_damage //Casting off a space suit leaves you weak for a few seconds.
		changeling.chem_recharge_slowdown -= recharge_slowdown
		return
	..(H, target)

/obj/effect/proc_holder/changeling/suit/sting_action(var/mob/living/carbon/human/user)
	if(!user.unEquip(user.wear_suit))
		user << "\the [user.wear_suit] is stuck to your body, you cannot grow a [suit_name_simple] over it!"
		return
	if(!user.unEquip(user.head))
		user << "\the [user.head] is stuck on your head, you cannot grow a [helmet_name_simple] over it!"
		return

	user.drop_from_inventory(user.head)
	user.drop_from_inventory(user.wear_suit)

	user.equip_to_slot_if_possible(new suit_type(user), slot_wear_suit, 1, 1, 1)
	user.equip_to_slot_if_possible(new helmet_type(user), slot_head, 1, 1, 1)

	var/datum/changeling/changeling = user.mind.changeling
	changeling.chem_recharge_slowdown += recharge_slowdown
	return 1

/obj/effect/proc_holder/changeling/weapon/arm_blade
	name = "Arm Blade"
	desc = "We reform one of our arms into a deadly blade."
	helptext = "Cannot be used while in lesser form."
	chemical_cost = 20
	genomecost = 5
	genetic_damage = 10
	req_human = 1
	max_genetic_damage = 10
	weapon_type = /obj/item/weapon/melee/arm_blade
	weapon_name_simple = "blade"

/obj/item/weapon/melee/arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter"
	icon = 'tauceti/icons/mob/mutant_stuff.dmi'
	tc_custom = 'tauceti/icons/mob/mutant_stuff.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	flags = ABSTRACT
	canremove = 0
	w_class = 5.0
	force = 25
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0

/obj/item/weapon/melee/arm_blade/New()
	..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>A grotesque blade forms around [loc.name]\'s arm!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a deadly blade.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")

/obj/item/weapon/melee/arm_blade/dropped(mob/user)
	visible_message("<span class='warning'>With a sickening crunch, [user] reforms his blade into an arm!</span>", "<span class='notice'>We assimilate the blade back into our body.</span>", "<span class='warning>You hear organic matter ripping and tearing!</span>")
	qdel(src)

/obj/item/weapon/melee/arm_blade/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/structure/table))
		var/obj/structure/table/T = target
		T.destroy()

	else if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/C = target
		C.attack_alien(user) //muh copypasta

	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if(!A.requiresID() || A.allowed(user)) //This is to prevent stupid shit like hitting a door with an arm blade, the door opening because you have acces and still getting a "the airlocks motors resist our efforts to force it" message.
			return

		if(A.arePowerSystemsOn() && !(A.stat & NOPOWER))
			user << "<span class='notice'>The airlock's motors resist our efforts to force it.</span>"
			return

		else if(A.locked)
			user << "<span class='notice'>The airlock's bolts prevent it from being forced.</span>"
			return

		else
			//user.say("Heeeeeeeeeerrre's Johnny!")
			user.visible_message("<span class='warning'>[user] forces the door to open with \his [src]!</span>", "<span class='warning'>We force the door to open.</span>", "<span class='warning'>You hear a metal screeching sound.</span>")
			A.open(1)

/obj/effect/proc_holder/changeling/weapon/shield
	name = "Organic Shield"
	desc = "We reform one of our arms into hard shield."
	helptext = "Organic tissue cannot resist damage forever, the shield will break after it is hit too much. The more genomes we absorb, the stronger it is. Cannot be used while in lesser form."
	chemical_cost = 20
	genomecost = 3
	genetic_damage = 12
	req_human = 1
	max_genetic_damage = 10

	weapon_type = /obj/item/weapon/shield/changeling
	weapon_name_simple = "shield"

/obj/item/weapon/shield/changeling
	name = "shield-like mass"
	desc = "A mass of tough, boney tissue. You can still see the fingers as a twisted pattern in the shield."
	canremove = 0
	icon = 'tauceti/icons/mob/mutant_stuff.dmi'
	tc_custom = 'tauceti/icons/mob/mutant_stuff.dmi'
	icon_state = "ling_shield"
	var/remaining_uses = 0//Set by the changeling ability.

/obj/item/weapon/shield/changeling/New()
//	..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>The end of [loc.name]\'s hand inflates rapidly, forming a huge shield-like mass!</span>", "<span class='warning'>We inflate our hand into a strong shield.</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")
	remaining_uses = rand(3,6)

/obj/item/weapon/shield/changeling/dropped()
	qdel(src)

/obj/item/weapon/shield/changeling/IsShield()
	if(remaining_uses < 1)
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			visible_message("<span class='warning'>With a sickening crunch, [H] reforms his shield into an arm!</span>", "<span class='notice'>We assimilate our shield into our body</span>", "<span class='warning>You hear organic matter ripping and tearing!</span>")
			H.unEquip(src, 1)
		qdel(src)
		return 0
	else
		remaining_uses--
		return 1

/obj/effect/proc_holder/changeling/suit/organic_space_suit
	name = "Organic Space Suit"
	desc = "We grow an organic suit to protect ourselves from space exposure."
	helptext = "We must constantly repair our form to make it space-proof, reducing chemical production while we are protected. Retreating the suit damages our genomes. Cannot be used in lesser form."
	chemical_cost = 20
	genomecost = 2
	genetic_damage = 8
	req_human = 1
	max_genetic_damage = 8

	suit_type = /obj/item/clothing/suit/space/changeling
	helmet_type = /obj/item/clothing/head/helmet/space/changeling
	suit_name_simple = "flesh shell"
	helmet_name_simple = "space helmet"
	recharge_slowdown = 0.5
	blood_on_castoff = 1

/obj/item/clothing/suit/space/changeling
	name = "flesh mass"
	icon = 'tauceti/icons/mob/mutant_stuff.dmi'
	tc_custom = 'tauceti/icons/mob/mutant_stuff.dmi'
	icon_state = "lingspacesuit"
	desc = "A huge, bulky mass of pressure and temperature-resistant organic tissue, evolved to facilitate space travel."
	flags = STOPSPRESSUREDMAGE //Not THICKMATERIAL because it's organic tissue, so if somebody tries to inject something into it, it still ends up in your blood. (also balance but muh fluff)
	canremove = 0
	allowed = list(/obj/item/device/flashlight, /obj/item/weapon/tank/emergency_oxygen, /obj/item/weapon/tank/oxygen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0) //No armor at all.

/obj/item/clothing/suit/space/changeling/New()
	..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>[loc.name]\'s flesh rapidly inflates, forming a bloated mass around their body!</span>", "<span class='warning'>We inflate our flesh, creating a spaceproof suit!</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")
	processing_objects += src

/obj/item/clothing/suit/space/changeling/dropped()
	qdel(src)

/obj/item/clothing/suit/space/changeling/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.reagents.add_reagent("dexalinp", REAGENTS_METABOLISM)
		var/datum/organ/internal/lungs/L = H.internal_organs_by_name["lungs"]
		if(L.damage >= 5)
			L.damage -= 5

/obj/item/clothing/head/helmet/space/changeling
	name = "flesh mass"
	icon = 'tauceti/icons/mob/mutant_stuff.dmi'
	tc_custom = 'tauceti/icons/mob/mutant_stuff.dmi'
	icon_state = "lingspacehelmet"
	desc = "A covering of pressure and temperature-resistant organic tissue with a glass-like chitin front."
	flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE
	canremove = 0
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/space/changeling/dropped()
	qdel(src)

/obj/effect/proc_holder/changeling/suit/armor
	name = "Chitinous Armor"
	desc = "We turn our skin into tough chitin to protect us from damage."
	helptext = "Upkeep of the armor requires a low expenditure of chemicals. The armor is strong against brute force, but does not provide much protection from lasers. Retreating the armor damages our genomes. Cannot be used in lesser form."
	chemical_cost = 25
	genomecost = 7
	genetic_damage = 10
	req_human = 1
	max_genetic_damage = 10

	suit_type = /obj/item/clothing/suit/armor/changeling
	helmet_type = /obj/item/clothing/head/helmet/changeling
	suit_name_simple = "armor"
	helmet_name_simple = "helmet"
	recharge_slowdown = 0.25

/obj/item/clothing/suit/armor/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin."
	icon = 'tauceti/icons/mob/mutant_stuff.dmi'
	tc_custom = 'tauceti/icons/mob/mutant_stuff.dmi'
	icon_state = "lingarmor"
	canremove = 0
	flags = THICKMATERIAL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	slowdown = 2
	armor = list(melee = 65, bullet = 35, laser = 35, energy = 35, bomb = 25, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	cold_protection = 0
	heat_protection = 0
	siemens_coefficient = 0.4

/obj/item/clothing/suit/armor/changeling/New()
	..()
	if(ismob(loc))
		loc.visible_message("<span class='warning'>[loc.name]\'s flesh turns black, quickly transforming into a hard, chitinous mass!</span>", "<span class='warning'>We harden our flesh, creating a suit of armor!</span>", "<span class='warning'>You hear organic matter ripping and tearing!</span>")

/obj/item/clothing/suit/armor/changeling/dropped()
	qdel(src)

/obj/item/clothing/head/helmet/changeling
	name = "chitinous mass"
	desc = "A tough, hard covering of black chitin with transparent chitin in front."
	icon = 'tauceti/icons/mob/mutant_stuff.dmi'
	tc_custom = 'tauceti/icons/mob/mutant_stuff.dmi'
	icon_state = "lingarmorhelmet"
	flags = HEADCOVERSEYES | BLOCKHAIR | THICKMATERIAL
	canremove = 0
	armor = list(melee = 70, bullet = 35, laser = 35,energy = 35, bomb = 25, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.4

/obj/item/clothing/head/helmet/changeling/dropped()
	qdel(src)