/obj/item/proc/copy_item_icon_info(obj/item/copying_from)
	icon = copying_from.icon
	icon_state = copying_from.icon_state
	item_state = copying_from.item_state
	lefthand_file = copying_from.lefthand_file
	righthand_file = copying_from.righthand_file
	icon_override = copying_from.icon_override
	transform = copying_from.transform
	pixel_x = copying_from.pixel_x
	pixel_y = copying_from.pixel_y

	slot_flags = copying_from.slot_flags

/mob/living/carbon/monkey/diona/proc/morph(obj/item/copy_item)
	if(copy_item.dionified) // While a copy of a copy sounds funny, it's not.
		return
	if(nutrition < 220 + copy_item.w_class * 10) // Lower than 250 and the item will demorph.
		return
	nutrition -= copy_item.w_class * 10
	if(istype(loc, /obj/item/nymph_morph_ball))
		qdel(loc)
	var/obj/item/nymph_morph_ball/NM = new(loc, copy_item)
	if(ismob(loc))
		var/mob/M = loc
		M.put_in_hands(NM, M.loc)
	forceMove(NM)

/obj/item/nymph_morph_ball
	name = "ball of biomass"
	desc = "It still slightly resembles those of dionaea specimen."

	dionified = TRUE
	var/obj/item/morphed_into
	var/demorphing = FALSE

/obj/item/nymph_morph_ball/atom_init(mapload, obj/item/copy_item)
	. = ..()
	var/obj/item/I = new copy_item.type(src)
	morphed_into = I.dionify(copy_item)
	morphed_into.copy_item_icon_info(I) // Sometimes we end up with a different item than we started with, but we need starting one's icons.

	update_icon()

	morphed_into.item_holder = src // Here lies the greates heresy of all, read items.dm.

/obj/item/nymph_morph_ball/Destroy()
	demorph()
	return ..()

/obj/item/nymph_morph_ball/proc/demorph()
	if(demorphing) // To prevent qdel-looping.
		return
	demorphing = TRUE
	var/mob/living/carbon/monkey/diona/D = locate() in src
	if(D)
		if(D.stat == DEAD)
			morphed_into.forceMove(loc)
			morphed_into = null
			return
		else if(ismob(loc))
			D.get_scooped(loc)
		else if(istype(loc, /obj/item/weapon/storage))
			var/obj/H = D.create_holder()
			H.forceMove(loc)
		else if(istype(loc, /obj/item/organ/external))
			var/obj/item/organ/external/BP = loc
			BP.droplimb(no_explode = TRUE, clean = TRUE, disintegrate = DROPLIMB_EDGE)
		else
			D.forceMove(loc)
	for(var/obj/item/I in morphed_into)
		if(!I.dionified)
			I.forceMove(loc)
			if(ismob(loc))
				var/mob/M = loc
				M.put_in_hands(I)
	QDEL_NULL(morphed_into)

/obj/item/nymph_morph_ball/examine(mob/user)
	..()
	if(user.get_species() == DIONA)
		var/mob/living/carbon/monkey/diona/D = locate() in src
		if(D)
			to_chat(user, "<span class='notice'>You clearly see that this is [D] in disguise.</span>")

/obj/item/nymph_morph_ball/pickup(mob/user)
	..()
	if(user)
		user.status_flags |= PASSEMOTES

/obj/item/nymph_morph_ball/dropped(mob/living/carbon/user)
	..()
	if(user)
		user.remove_passemotes_flag()

/obj/item/nymph_morph_ball/update_icon()
	if(QDELETED(morphed_into))
		qdel(src)
		return

	copy_item_icon_info(morphed_into)

	var/list/L = list(icon_dionify(icon(morphed_into.icon, morphed_into.icon_state)))
	overlays = L
	morphed_into.overlays = L

/obj/item/nymph_morph_ball/relaymove(mob/user, direction)
	if(istype(loc, /obj/item/organ))
		var/obj/item/organ/O = loc
		O.owner.relaymove(user, direction)
	else
		qdel(src)

/obj/item/nymph_morph_ball/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	morphed_into.afterattack(target, user, proximity_flag, click_parameters)
	update_icon()

/obj/item/nymph_morph_ball/attack(mob/living/M, mob/living/user)
	morphed_into.attack(M, user)
	update_icon()

/obj/item/nymph_morph_ball/attack_self(mob/user)
	morphed_into.attack_self(user)
	update_icon()

/obj/item/nymph_morph_ball/attack_hand(mob/user)
	if(user.a_intent == I_HURT)
		var/mob/living/carbon/monkey/diona/D = locate() in src
		if(D)
			D.attack_hand(user)
	else
		morphed_into.attack_hand(user)
		update_icon()

/obj/item/nymph_morph_ball/attack_paw(mob/user)
	if(user.a_intent == I_HURT)
		var/mob/living/carbon/monkey/diona/D = locate() in src
		if(D)
			D.attack_hand(user)
	else
		morphed_into.attack_paw(user)
		update_icon()

/obj/item/nymph_morph_ball/attackby(obj/item/weapon/W, mob/user)
	if(user.a_intent == I_HURT)
		var/mob/living/carbon/monkey/diona/D = locate() in src
		if(D)
			D.attack_hand(user)
	else
		morphed_into.attackby(W, user)
		update_icon()

/obj/item/nymph_morph_ball/emp_act(severity)
	for(var/obj/item/I in contents)
		I.emp_act(severity)
	update_icon()

/obj/item/nymph_morph_ball/ex_act(severity)
	for(var/obj/item/I in contents)
		I.ex_act(severity)
	update_icon()

/obj/item/nymph_morph_ball/MouseDrop_T(atom/movable/target, mob/user)
	morphed_into.MouseDrop_T(target, user)
	update_icon()

/obj/item/nymph_morph_ball/hear_talk(mob/M, text, verb, datum/language/speaking)
	var/mob/living/carbon/monkey/diona/D = locate() in src
	if(D)
		D.hear_say(text, verb, language = speaking, speaker = M)

/obj/item/nymph_morph_ball/verb/poke()
	set name = "Poke"
	set category = "Object"
	set src in usr

	qdel(src)