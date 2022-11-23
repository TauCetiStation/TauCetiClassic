/obj/item/device/expedition
	name = "Exped-I-Marker"
	icon = 'icons/obj/pda.dmi'
	icon_state = "pai"
	item_state = "electronic"
	w_class = SIZE_TINY
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "programming=5"
	var/list/adventurers = list()
	var/max_number_of_adventurers = 5

/obj/item/device/expedition/attack_self(mob/user)
	var/turf/T = get_turf(src)
	var/area/A = T.loc
	if(A.type != /area/station/gateway)
		to_chat(user, "This can only be used near Gateway")
		return
	for(var/mob/living/carbon/human/H in A.contents)
		if(H == user)
			continue
		if(H in adventurers)
			continue
		if(length(adventurers) >= max_number_of_adventurers)
			to_chat(user, "Max number of adventurers reached!")
			return
		adventurers += H
		to_chat(user, "Adding [H] to database...")

/obj/item/device/expedition/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(ishuman(target))
		if(target in adventurers)
			to_chat(user, "<span class='warning'>[target] уже отмечен[VERB_RU(target)].</span>")
			return
		if(length(adventurers) >= max_number_of_adventurers)
			to_chat(user, "<span class='warning'>Достигнут лимит экспедиции.</span>")
			return
		adventurers += target
		to_chat(user, "<span class='notice'>[target] отмечен[VERB_RU(target)] и может войти в Гейтвей .</span>")
		return

/obj/item/device/expedition/examine(mob/user)
	. = ..()
	to_chat(user, "Допущены к экспедиции: [get_english_list(adventurers)]")