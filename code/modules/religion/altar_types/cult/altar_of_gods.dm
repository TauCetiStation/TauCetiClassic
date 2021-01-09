/obj/structure/altar_of_gods/cult
	name = "Altar of the Death"
	desc = "An altar which allows the head of the church to choose a sect of religious teachings as well as provide sacrifices to earn favor."
	icon = 'icons/obj/structures/chapel.dmi'
	icon_state = "satanaltar"

	look_piety = TRUE
	change_preset_name = FALSE
	custom_sect_type = /datum/religion_sect/custom/cult

	type_of_sects = /datum/religion_sect/preset/cult

/obj/structure/altar_of_gods/cult/interact_bible(obj/item/I, mob/user)
	if(!chosen_aspect && !choosing_sects)
		..(I, user)
	else
		interact_nullrod(I, user)
