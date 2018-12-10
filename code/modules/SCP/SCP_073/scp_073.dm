/datum/unarmed_attack/punch/scp073_attack
	damage = 10

/datum/species/scp073
	name = "SCP-073"
	icobase = 'code/modules/SCP/SCP_073/scp-073.dmi'
	deform = 'code/modules/SCP/SCP_073/scp-073.dmi'
	dietflags = DIET_OMNI
	unarmed_type = /datum/unarmed_attack/punch/scp073_attack
	eyes = "blank_eyes"

	flags = list(
	HAS_LIPS = TRUE
	,HAS_UNDERWEAR = TRUE
	,HAS_HAIR = TRUE
	)

	brute_mod = 0.5
	burn_mod = 0.5
	brain_mod = 0
	speed_mod = -0.7

	has_gendered_icons = FALSE

/mob/living/carbon/human/scp073
	real_name = "SCP-073"
	desc = "Arabic man with a lot of prosthetic body parts and a strange symbol on his head. You feel uneasy with him nearby"

/mob/living/carbon/human/scp073/atom_init(mapload)
	. = ..(mapload, "SCP-073")
	universal_speak = TRUE
	universal_understand = TRUE

	underwear = 5
	equip_to_slot_or_del(new /obj/item/clothing/under/shorts/black(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(src), slot_shoes)
	update_body()


/mob/living/carbon/human/scp073/examine(mob/user)
	to_chat(user, "<b><span class = 'info'><big>SCP-073</big></span></b> - [desc]")
	return ..(user)

/mob/living/carbon/human/scp073/bullet_act(obj/item/projectile/P, def_zone)
	if(ishuman(P.firer) && P.firer != src)
		var/mob/living/carbon/human/H = P.firer
		if(H != src)
			apply_effect(P.damage / 3 + P.agony / 3,AGONY,0)
		return H.bullet_act(P, def_zone)
	else
		. = ..(P, def_zone)

/mob/living/carbon/human/scp073/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(ishuman(user) && user != src)
		var/mob/living/carbon/human/H = user
		H.do_attack_animation(src)
		if(H != src)
			apply_effect(I.force,AGONY,0)
		return H.attacked_by(I, user, def_zone)
	else
		. = ..(I, user, def_zone)

/mob/living/carbon/human/scp073/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == "hurt" && M != src)
		M.attack_hand(M)
		M.do_attack_animation(src)
		if(M != src)
			apply_effect(5,AGONY,0)
	else
		. = ..(M)

/mob/living/carbon/human/scp073/attack_animal(mob/living/simple_animal/M)
	if(M)
		if(M.melee_damage_upper == 0)
			M.emote("[M.friendly] [src]")
			return TRUE
		else
			if(M.attack_sound)
				playsound(loc, M.attack_sound, 50, 1, 1)
			visible_message("<span class='userdanger'><B>[M]</B>[M.attacktext] [src]!</span>")
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
			M.adjustBruteLoss(damage)
			M.do_attack_animation(src)
			apply_effect(damage,AGONY,0)
			return TRUE
		return FALSE
	else
		. = ..(M)

/mob/living/carbon/human/scp073/Life()
	. = ..()

	for(var/obj/item/I in list(l_hand,r_hand))
		if(istype(I, /obj/item/weapon/paper) || istype(I, /obj/item/weapon/reagent_containers/food/snacks/grown))
			visible_message("<span class='rose'>[I] burns when it touches [src]'s hand, turning into ash. It flutters through the air before settling on the floor in a heap.</span>")
			drop_from_inventory(I)
			new /obj/effect/decal/cleanable/ash(I.loc)
			qdel(I)

	var/list/mytargets = list(loc, get_step(loc, EAST), get_step(loc, WEST), get_step(loc, NORTH), get_step(loc, SOUTH))
	var/foundgrass = FALSE
	for(var/turf/T in mytargets)

		if(T.icon_state in list("grass1", "grass2", "grass3", "grass4"))
			T.icon_state = "asteroid"
			foundgrass = TRUE
		for(var/obj/structure/flora/F in T.contents)
			F.color = next_in_list(F.color, list("#ffffd1", "#cccca7", "#898970", "#555570", "#000000"))

			if(F.color == "#000000")
				qdel(F)

	if(foundgrass)
		visible_message("<span class='warning'>The grass around [src] quickly dies and turns yellow.</span>")

	if(machine)
		machine.interact(src)

/mob/living/carbon/human/scp073/movement_delay()
	..()
	var/tally = species.speed_mod
	if(crawling)
		tally += 7
	if(buckled) // so, if we buckled we have large debuff
		tally += 5.5
	if(pull_debuff)
		tally += pull_debuff
	if(health-halloss <= 50)
		tally += 0.5
	if(health-halloss <= 0)
		tally += 1
	if(health-halloss <= -50)
		tally += 1

	var/chem_nullify_debuff = FALSE
	if(!species.flags[NO_BLOOD] && ( reagents.has_reagent("hyperzine") || reagents.has_reagent("nuka_cola") )) // hyperzine removes equipment slowdowns (no blood = no chemical effects).
		chem_nullify_debuff = TRUE

	if(wear_suit && wear_suit.slowdown && !(wear_suit.slowdown > 0 && chem_nullify_debuff))
		tally += wear_suit.slowdown

	if(back && back.slowdown && !(back.slowdown > 0 && chem_nullify_debuff))
		tally += back.slowdown

	if(shoes && shoes.slowdown && !(shoes.slowdown > 0 && chem_nullify_debuff))
		tally += shoes.slowdown

	return (tally + config.human_delay)