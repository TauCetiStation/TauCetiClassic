/obj/item/weapon/paper/talisman
	icon_state = "paper_talisman"
	var/datum/religion_rites/rite
	var/datum/religion/religion

/obj/item/weapon/paper/talisman/atom_init(mapload, datum/religion/_religion, datum/religion_rites/_rite)
	. = ..()
	rite = _rite
	religion = _religion

/obj/item/weapon/paper/talisman/attack_self(mob/living/user)
	if(!religion?.is_member(user))
		user.examinate(src)
		return

	user.adjustBruteLoss(5)
	rite?.perform_rite(user, src)

/obj/item/weapon/paper/talisman/chaplain/examine(mob/user)
	..()
	if(religion?.is_member(user) && rite)
		to_chat(user, "<span class='piety'>Божественным почерком написано: [religion.rites_info[rite.name]]</span>.")

/obj/item/weapon/paper/talisman/cult
	icon_state = "scrap_bloodied"

/obj/item/weapon/paper/talisman/cult/examine(mob/user)
	..()
	if(religion?.is_member(user) && rite)
		to_chat(user, "<span class='cult'>Кровью наскрябано: [religion.rites_info[rite.name]]</span>.")
