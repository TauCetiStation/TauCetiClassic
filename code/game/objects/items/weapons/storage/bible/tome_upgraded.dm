
/obj/item/weapon/storage/bible/tome/upgraded
	name = "strange book"
	icon_state = "strange_book"
	build_cd = 15
	rune_cd = 5
	scribe_time = 1
	cost_coef = 0.5

/obj/item/weapon/storage/bible/tome/upgraded/attack_hand(mob/living/carbon/human/user)
	if(!ishuman(user))
		return ..()
	if(!iscultist(user))
		user.visible_message("<span class='warning'>При попытке открыть книгу, сквозь обложку просачивается яркий красный шар света, который через мгновенье рассеивается.</span>",
		"<span class='warning'>При попытке открыть книгу, сквозь обложку просачивается яркий красный шар света, который невольно обжигает ваши руки и быстро рассеивается.</span>")
		user.take_certain_bodypart_damage(list(BP_L_ARM, BP_R_ARM), 0, 10)
		user.blurEyes(15)
		return
	return ..()

/obj/item/weapon/storage/bible/tome/upgraded/Crossed(atom/movable/AM)
	. = ..()
	if(!ishuman(AM))
		return
	if(!iscultist(AM))
		var/mob/living/carbon/human/H = AM
		to_chat(H, "<span class='warning'>Наступив на книгу вы чувствуете невыносимо жгучую боль в ступнях.</span>")
		H.take_certain_bodypart_damage(list(BP_L_LEG, BP_R_LEG), 0, 10)
		return

/obj/item/weapon/storage/bible/tome/eminence
	name = "Tome of Eminence"
	icon_state = "strange_book"
	scribe_time = 1
	destr_cd = 10 SECONDS
	rune_cd = 10 SECONDS
	cost_coef = 1.5
	build_cd = 10 SECONDS

/obj/item/weapon/storage/bible/tome/eminence/can_destroy(atom/target, mob/user)
	var/area/area = get_area(user)
	if(!istype(religion, area.religion?.type))
		to_chat(user, "<span class='warning'>Только в подконтрольной зоне вашей религии вы способны на подобное проявление силы!</span>")
		return FALSE
	return ..()

/obj/item/weapon/storage/bible/tome/eminence/can_build_here(mob/user, datum/rune/rune)
	var/area/area = get_area(user)
	if(!istype(religion, area.religion?.type))
		to_chat(user, "<span class='warning'>Вы не всемогущи, а потому можете строить только в зоне, подконтрольной вашей религии!</span>")
		return FALSE
	return TRUE
