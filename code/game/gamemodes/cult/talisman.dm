/obj/item/weapon/paper/talisman
	icon_state = "scrap_bloodied"
	var/datum/religion_rites/rite

/obj/item/weapon/paper/talisman/New(mapload, datum/religion_rites/_rite)
	rite = _rite

/obj/item/weapon/paper/talisman/attack_self(mob/living/user)
	if(!iscultist(user))
		user.examinate(src)
		return
	user.adjustBruteLoss(5)
	rite?.action(user)

/obj/item/weapon/paper/talisman/examine(mob/user)
	..()
	if(iscultist(user) && rite)
		to_chat(user, "Кровью наскрябано: <span class='cult'>[rite.name]</span>.")
