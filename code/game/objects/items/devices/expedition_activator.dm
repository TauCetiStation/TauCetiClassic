/obj/item/device/expedition
	name = "Exped-I-Marker"
	desc = "There are some instructions on the back: \"1. Mark your expeditionary team. 2. Activate Gateway via this marker. 3. It is advised that the captain does not participate in expedition\"."
	icon_state = "gangtool-a"
	w_class = SIZE_TINY
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "programming=5"
	var/list/adventurers = list()
	var/max_number_of_adventurers = 5

/obj/item/device/expedition/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(ishuman(target))
		if(target in adventurers)
			to_chat(user, "<span class='warning'>[target] is already marked.</span>")
			return
		if(length(adventurers) >= max_number_of_adventurers)
			to_chat(user, "<span class='warning'>Max number of adventurers reached.</span>")
			return
		adventurers += target
		to_chat(user, "<span class='notice'>[target] is now marked and can enter the Gateway.</span>")
		return

/obj/item/device/expedition/examine(mob/user)
	. = ..()
	if(!length(adventurers))
		return
	else
		to_chat(user, "Adventurers: [get_english_list(adventurers)]")
