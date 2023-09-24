/obj/item/weapon/paper/talisman
	icon_state = "paper_talisman"
	var/busy = FALSE
	var/datum/religion_rites/rite
	var/datum/religion/religion

	var/disposable = FALSE
	var/text_befor_riteinfo

/obj/item/weapon/paper/talisman/atom_init(mapload, datum/religion/_religion, datum/religion_rites/_rite)
	. = ..()
	RegisterSignal(src, list(COMSIG_OBJ_RESET_RITE), PROC_REF(reset_rite))

	rite = _rite
	religion = _religion
	verbs -= /obj/item/weapon/paper/verb/crumple

/obj/item/weapon/paper/talisman/Destroy()
	rite = null
	religion = null
	return ..()

/obj/item/weapon/paper/talisman/update_icon()
	return

/obj/item/weapon/paper/talisman/proc/reset_rite()
	busy = FALSE

/obj/item/weapon/paper/talisman/examine(mob/user)
	..()
	if(religion?.is_member(user) && rite)
		var/rite_info = religion.rites_info[rite.name] ? religion.rites_info[rite.name] : religion.get_rite_info(rite)
		to_chat(user, "<span class='[religion.style_text]'>[text_befor_riteinfo]: [rite_info]</span>.")

/obj/item/weapon/paper/talisman/attack_self(mob/living/user)
	if(!religion?.is_member(user))
		user.examinate(src)
		return
	if(busy)
		to_chat(user, "<span class='[religion.style_text]'>Талисман уже используется.</span>")
		return

	busy = TRUE
	user.take_overall_damage(rand(1, 5), rand(1, 5))
	if(rite?.perform_rite(user, src))
		if(disposable)
			qdel(src)

/obj/item/weapon/paper/talisman/chaplain
	text_befor_riteinfo = "Божественным почерком написано"

/obj/item/weapon/paper/talisman/cult
	icon_state = "scrap_bloodied"
	text_befor_riteinfo = "Кровью наскребено"
