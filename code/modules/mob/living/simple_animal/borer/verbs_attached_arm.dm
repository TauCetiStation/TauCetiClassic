/obj/item/verbs/borer/attached_arm/verb/borer_speak(message as text)
	set category = "Alien"
	set name = "Borer Speak"
	set desc = "Communicate with your brethren."

	if(!message)
		return

	var/msg = message
	msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
	msg = capitalize(msg)

	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		return
	B.borer_speak(msg)

/obj/item/verbs/borer/attached_arm/verb/evolve()
	set category = "Alien"
	set name = "Evolve"
	set desc = "Upgrade yourself or your host."

	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		return
	B.evolve()

/obj/item/verbs/borer/attached_arm/verb/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		return
	B.secrete_chemicals()

/obj/item/verbs/borer/attached_arm/verb/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		return
	B.abandon_host()

/obj/item/verbs/borer/attached_arm/em_pulse/verb/em_pulse()
	set category = "Alien"
	set name = "Electromagnetic Pulse"
	set desc = "Expend a great deal of chemicals to produce a small electromagnetic pulse."

	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		return
	B.em_pulse()

/mob/living/simple_animal/borer/proc/em_pulse()
	set category = "Alien"
	set name = "Electromagnetic Pulse"
	set desc = "Expend a great deal of chemicals to produce a small electromagnetic pulse."

	if(!check_can_do(TRUE))
		return

	if(chemicals < 100)
		to_chat(src, "<span class='warning'>You need at least 100 chemicals to do this.</span>")
		return
	else
		chemicals -= 100
		empulse(get_turf(src), 1, 2, 1)

/obj/item/verbs/borer/attached_arm/bone_sword/verb/bone_sword()
	set category = "Alien"
	set name = "Bone Sword"
	set desc = "Expend chemicals constantly to form a large blade of bone for your host."

	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		return
	B.bone_sword()

/mob/living/simple_animal/borer/proc/bone_sword()
	set category = "Alien"
	set name = "Bone Sword"
	set desc = "Expend chemicals constantly to form a large blade of bone for your host."
	if(!check_can_do(FALSE))
		return
	if(channeling && !channeling_bone_sword)
		to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
		return
	else if(channeling)
		to_chat(src, "You cease your efforts to sustain a blade of bone for your host.")
		channeling = FALSE
		channeling_bone_sword = FALSE
	else if(chemicals < 5)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	else
		var/obj/item/weapon/melee/bone_sword/S = new(get_turf(host), src)
		if(hostlimb == BP_R_ARM)
			if(host.get_active_hand())
				if(istype(host.get_active_hand(), /obj/item/weapon/melee/bone_sword))
					to_chat(src, "<span class='warning'>Your host already has a bone sword on this arm.</span>")
					qdel(S)
					return
				host.drop_item(host.get_active_hand(), force_drop = 1)
			host.put_in_r_hand(S)
		else
			if(host.get_active_hand())
				if(istype(host.get_active_hand(), /obj/item/weapon/melee/bone_sword))
					to_chat(src, "<span class='warning'>Your host already has a bone sword on this arm.</span>")
					qdel(S)
					return
				host.drop_item(host.get_active_hand(), force_drop = 1)
			host.put_in_l_hand(S)
		to_chat(src, "You begin to focus your efforts on sustaining a blade of bone for your host.")
		channeling = TRUE
		channeling_bone_sword = TRUE
		host.visible_message("<span class='warning'>A blade of bone erupts from \the [host.name]'s [hostlimb == BP_R_ARM ? "right" : "left"] arm!</span>","<span class='warning'>A blade of bone erupts from your [hostlimb == BP_R_ARM ? "right" : "left"] arm!</span>")
		spawn()
			var/time_spent_channeling = 0
			while(channeling && channeling_bone_sword && chemicals >= 3)
				time_spent_channeling++
				chemicals -= 2
				sleep(10)
			channeling = FALSE
			channeling_bone_sword = FALSE
			S.Destroy()
			host.visible_message("<span class='notice'>\The [host]'s bone sword crumbles into nothing.</span>","<span class='notice'>Your bone sword crumbles into nothing.</span>")
			if(chemicals < 5)
				to_chat(src, "<span class='warning'>You lose consciousness as the last of your chemicals are expended.</span>")
				passout(time_spent_channeling, FALSE)

/obj/item/weapon/melee/bone_sword
	name = "bone sword"
	desc = "A somewhat gruesome blade that appears to be made of solid bone."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bone_sword"
	item_state = "bone_sword"
	hitsound = "sound/weapons/bloodyslice.ogg"
	flags = ABSTRACT | DROPDEL
	force = 20
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	canremove = 0
	var/mob/living/simple_animal/borer/parent_borer = null

/obj/item/weapon/melee/bone_sword/atom_init(mapload, atom/A, p_borer)
	. = ..(A)
	if(istype(p_borer, /mob/living/simple_animal/borer))
		parent_borer = p_borer
	if(!parent_borer)
		return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/melee/bone_sword/atom_init_late()
	qdel(src)

/obj/item/weapon/melee/bone_sword/dropped(mob/user)
	to_chat(user, "<span class='notice'>You can not remove this bone growth from your arm!</span>")
	return

/obj/item/weapon/melee/bone_sword/Destroy()
	if(parent_borer)
		if(parent_borer.channeling_bone_sword)
			parent_borer.channeling_bone_sword = FALSE
		if(parent_borer.channeling)
			parent_borer.channeling = FALSE
		parent_borer = null
	..()

/obj/item/verbs/borer/attached_arm/bone_shield/verb/bone_shield()
	set category = "Alien"
	set name = "Bone Shield"
	set desc = "Expend chemicals constantly to form a large shield of bone for your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.bone_shield()

/mob/living/simple_animal/borer/proc/bone_shield()
	set category = "Alien"
	set name = "Bone Shield"
	set desc = "Expend chemicals constantly to form a large shield of bone for your host."

	if(!check_can_do(FALSE))
		return

	if(channeling && !channeling_bone_shield)
		to_chat(src, "<span class='warning'>You can't do this while your focus is directed elsewhere.</span>")
		return
	else if(channeling)
		to_chat(src, "You cease your efforts to sustain a shield of bone for your host.")
		channeling = FALSE
		channeling_bone_shield = FALSE
	else if(chemicals < 3)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	else
		var/obj/item/weapon/shield/riot/bone/S = new(get_turf(host), src)
		if(hostlimb == BP_R_ARM)
			if(host.get_active_hand())
				if(istype(host.get_active_hand(), /obj/item/weapon/shield/riot/bone))
					to_chat(src, "<span class='warning'>Your host already has a bone shield on this arm.</span>")
					qdel(S)
					return
				host.drop_item(host.get_active_hand(), force_drop = 1)
			host.put_in_r_hand(S)
		else
			if(host.get_active_hand())
				if(istype(host.get_active_hand(), /obj/item/weapon/shield/riot/bone))
					to_chat(src, "<span class='warning'>Your host already has a bone shield on this arm.</span>")
					qdel(S)
					return
				host.drop_item(host.get_active_hand(), force_drop = 1)
			host.put_in_l_hand(S)
		to_chat(src, "You begin to focus your efforts on sustaining a blade of bone for your host.")
		channeling = TRUE
		channeling_bone_shield = TRUE
		host.visible_message("<span class='warning'>A shield of bone erupts from \the [host.name]'s [hostlimb == BP_R_ARM ? "right" : "left"] arm!</span>","<span class='warning'>A shield of bone erupts from your [hostlimb == BP_R_ARM ? "right" : "left"] arm!</span>")
		spawn()
			var/time_spent_channeling = 0
			while(channeling && channeling_bone_shield && chemicals >= 3)
				time_spent_channeling++
				chemicals -= 2
				sleep(10)
			channeling = FALSE
			channeling_bone_shield = FALSE
			S.Destroy()
			host.visible_message("<span class='notice'>\The [host]'s bone shield crumbles into nothing.</span>","<span class='notice'>Your bone shield crumbles into nothing.</span>")
			if(chemicals < 3)
				to_chat(src, "<span class='warning'>You lose consciousness as the last of your chemicals are expended.</span>")
				passout(time_spent_channeling, FALSE)

/obj/item/weapon/shield/riot/bone
	name = "bone shield"
	desc = "A somewhat gruesome shield that appears to be made of solid bone."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bone_shield"
	item_state = "bone_shield"
	flags = ABSTRACT | DROPDEL
	force = 13
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	canremove = 0
	var/mob/living/simple_animal/borer/parent_borer = null

/obj/item/weapon/shield/riot/bone/atom_init(mapload, atom/A, p_borer)
	. = ..(A)
	if(istype(p_borer, /mob/living/simple_animal/borer))
		parent_borer = p_borer
	if(!parent_borer)
		return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/shield/riot/bone/atom_init_late()
	qdel(src)

/obj/item/weapon/shield/riot/bone/dropped(mob/user)
	to_chat(user, "<span class='notice'>You can not remove this bone growth from your arm!</span>")
	return

/obj/item/weapon/shield/riot/bone/Destroy()
	if(parent_borer)
		if(parent_borer.channeling_bone_shield)
			parent_borer.channeling_bone_shield = FALSE
		if(parent_borer.channeling)
			parent_borer.channeling = FALSE
		parent_borer = null
	..()

/obj/item/verbs/borer/attached_arm/repair_bone/verb/repair_bone()
	set category = "Alien"
	set name = "Repair Bone"
	set desc = "Expend chemicals to repair bones in your host's arm."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.repair_bone()

/mob/living/simple_animal/borer/proc/repair_bone()
	set category = "Alien"
	set name = "Repair Bone"
	set desc = "Expend chemicals to repair bones in your host's arm."

	if(!check_can_do(TRUE))
		return

	if (!host)
		return
	if(!istype(host, /mob/living/carbon/human))
		to_chat(src, "<span class='warning'>You can't seem to repair your host's strange biology.</span>")
		return
	if(chemicals < 30)
		to_chat(src, "<span class='warning'>You don't have enough chemicals stored to do this.</span>")
		return
	var/has_healed_bones = FALSE
	var/mob/living/carbon/human/H = host
	var/obj/item/organ/external/current_limb = null
	current_limb = H.bodyparts_by_name[hostlimb]

	if(current_limb.is_broken())
		if(chemicals < 50)
			to_chat(src, "<span class='warning'>You must have at least 50 chemicals stored to heal a broken arm.</span>")
			return
		current_limb.status &= ~ORGAN_BROKEN
		current_limb.perma_injury = 0
		current_limb.heal_damage(current_limb.brute_dam - ((current_limb.min_broken_damage * config.organ_health_multiplier) - 1))
		to_chat(src, "<span class='notice'>You've repaired the bones in your host's [hostlimb == BP_R_ARM ? "right" : "left"] arm.</span>")
		to_chat(host, "<span class='notice'>You feel the bones in your [hostlimb == BP_R_ARM ? "right" : "left"] arm mend together.</span>")
		chemicals -= 50
		has_healed_bones = TRUE
	if(!has_healed_bones)
		to_chat(src, "<span class='notice'>None of the bones in your host's [hostlimb == BP_R_ARM ? "right" : "left"] arm are broken.</span>")
