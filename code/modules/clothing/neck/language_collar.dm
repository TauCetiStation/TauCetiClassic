/obj/item/clothing/neck/language_collar
	name = "language collar"
	desc = "A collar designed to allow the wearer to understand and speak multiple languages. It has a slot for a language cartridge, which can be removed with a screwdriver."
	icon_state = "langcollar"
	item_state = "langcollar"
	item_state_world = "langcollar_w"
	origin_tech = "magnets=5;programming=4;engineering=5"
	flags = SLOT_FLAGS_NECK | HEAR_TALK
	var/working = FALSE
	var/emagged = FALSE
	var/phrase
	var/obj/item/weapon/disk/language/lang_disk
	var/old_default_language
	item_action_types = list(/datum/action/item_action/hands_free/toggle_language_collar)

/obj/item/clothing/neck/language_collar/Destroy()
	QDEL_NULL(lang_disk)
	return ..()

/obj/item/clothing/neck/language_collar/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/disk/language))
		if(lang_disk)
			return
		user.drop_from_inventory(I, src)
		lang_disk = I
		to_chat(user, "<span class='notice'>You insert the [lang_disk] into [src]</span>")
	else if(isscrewing(I))
		if(!lang_disk)
			to_chat(user, "<span class='notice'>There's no language disk to remove from the [src]</span>")
			return
		if(!user.put_in_hands(lang_disk))
			lang_disk.forceMove(get_turf(src))
		lang_disk = null
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You remove the language disk from the [src]</span>")
	else
		return ..()

/obj/item/clothing/neck/language_collar/emag_act(mob/user)
	.=..()
	if(emagged)
		return FALSE
	var/set_phrase = sanitize(input(user, "Введите кодовую фразу:") as text)
	if(!length(set_phrase))
		to_chat(user, "<span class='warning'>Вы не задали фразу активации.</span>")
		return FALSE
	phrase = set_phrase
	emagged = TRUE
	to_chat(user, "<span class='warning'>Теперь взрыв случится после фразы [phrase]. Вот так-то лучше!</span>")
	return TRUE

/obj/item/clothing/neck/language_collar/hear_talk(mob/M, msg)
	if(!phrase)
		return
	if(findtext(msg, phrase))
		explode_collar(M)

/obj/item/clothing/neck/language_collar/proc/explode_collar(mob/user)
	if(slot_equipped == SLOT_NECK)
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/head/M = H.bodyparts_by_name[BP_HEAD]
		if(M)
			M.take_damage(60, used_weapon = "Explosion")
	explosion(get_turf(user), -1, -1, 2, 3)
	qdel(src)

/obj/item/clothing/neck/language_collar/proc/turn_off(mob/user)
	if(working && lang_disk && lang_disk.language)
		user.remove_language(lang_disk.language)
		if(old_default_language)
			user.default_language = old_default_language
		else
			user.default_language = null
		old_default_language = null
		working = FALSE

/obj/item/clothing/neck/language_collar/dropped(mob/user)
	..()
	turn_off(user)

/datum/action/item_action/hands_free/toggle_language_collar
	name = "Toggle Language Collar"

/obj/item/clothing/neck/language_collar/attack_self(mob/user)
	if(user.incapacitated())
		return
	if(slot_equipped != SLOT_NECK || !lang_disk || !lang_disk.language)
		to_chat(user, "<span class='warning'>You need to wear the collar around your neck to use it.</span>")
		return
	if(!working)
		working = TRUE
		old_default_language = user.default_language
		user.add_language(lang_disk.language)
		user.default_language = lang_disk.language
		to_chat(user, "<span class='notice'>You have activated the collar.</span>")
	else
		turn_off(user)
		to_chat(user, "<span class='notice'>You have deactivated the collar.</span>")
