/obj/structure/altar_of_gods/cult
	name = "Altar of the Death"
	desc = "An altar which allows the head of the church to choose a sect of religious teachings as well as provide sacrifices to earn favor."
	icon = 'icons/obj/structures/chapel.dmi'
	icon_state = "cultaltar"

	look_piety = TRUE
	custom_sect_type = /datum/religion_sect/custom/cult

	type_of_sects = /datum/religion_sect/preset/cult

/obj/structure/altar_of_gods/cult/start_rite()
	. = ..()
	icon_state = "cultaltar-blood"

/obj/structure/altar_of_gods/cult/reset_rite()
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/altar_of_gods/cult/interact_bible(obj/item/I, mob/user)
	if(!chosen_aspect)
		if(user.mind.holy_role != CULT_ROLE_MASTER)
			to_chat(user, "<span class='warning'>Только лидер культа может выбирать аспекты!</span>")
			return
	interact_nullrod(I, user)
