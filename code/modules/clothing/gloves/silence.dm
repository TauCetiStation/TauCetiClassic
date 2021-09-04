/obj/item/clothing/gloves/black/silence // gloves for creating silence
	siemens_coefficient = 0.2
	var/distance = 1
	var/sound_coefficient = 0.9

/obj/item/clothing/gloves/black/silence/atom_init()
	. = ..()
	AddComponent(/datum/component/silence, distance, sound_coefficient, TRUE)

/obj/item/clothing/gloves/black/silence/equipped(mob/user, slot)
	. = ..()
	if (slot == SLOT_GLOVES)
		to_chat(user, "<span class='notice'>You are enabling the silence gloves!</span>")
		SEND_SIGNAL(src, COMSIG_START_SUPPRESSING)
		SEND_SIGNAL(src, COMSIG_SHOW_RADIUS, user)

/obj/item/clothing/gloves/black/silence/dropped(mob/user)
	. = ..()
	to_chat(user, "<span class='red'>You are disabling the silence gloves!</span>")
	SEND_SIGNAL(src, COMSIG_STOP_SUPPRESSING)
	SEND_SIGNAL(src, COMSIG_HIDE_RADIUS)
