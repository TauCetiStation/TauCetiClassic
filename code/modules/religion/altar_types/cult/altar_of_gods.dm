/obj/structure/altar_of_gods/cult
	name = "Altar of the Death"
	desc = "Алтарь, позволяющий главе церкви выбирать религиозное учение и приносить жертвы для того, чтобы заработать милость богов."
	icon = 'icons/obj/structures/chapel.dmi'
	icon_state = "cultaltar"

	look_piety = TRUE

/obj/structure/altar_of_gods/cult/start_rite()
	. = ..()
	icon_state = "cultaltar-blood"

/obj/structure/altar_of_gods/cult/reset_rite()
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/altar_of_gods/cult/interact_religious_tool(obj/item/I, mob/user)
	if(!chosen_aspect)
		if(user.mind.holy_role != CULT_ROLE_MASTER)
			to_chat(user, "<span class='warning'>Только лидер культа может выбирать аспекты!</span>")
			return
	..()
