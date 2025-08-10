/obj/item/clothing/neck/language_collar
	name = "language collar"
	desc = "A collar designed to allow the wearer to understand and speak multiple languages. It has a slot for a language cartridge, which can be removed with a screwdriver."
	icon_state = "langcollar"
	item_state = "langcollar"
	item_state_world = "langcollar_w"
	flags = SLOT_FLAGS_NECK
	var/working = FALSE
	var/obj/item/weapon/disk/language/lang_disk
	item_action_types = list(/datum/action/item_action/hands_free/toggle_language_collar)

/obj/item/clothing/neck/language_collar/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/disk/language))
		if(lang_disk)
			return
		user.drop_from_inventory(I, src)
		lang_disk = I
		lang_disk.holder = src
		to_chat(user, "<span class='notice'>You insert the [lang_disk] into the [src]</span>")
	else if(isscrewing(I))
		if(!lang_disk)
			to_chat(user, "<span class='notice'>There's no language disk to remove from the [src]</span>")
			return
		lang_disk.holder = null
		if(!user.put_in_hands(lang_disk))
			lang_disk.forceMove(get_turf(src))
		lang_disk = null
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You remove the [lang_disk] from the [src]</span>")

/obj/item/clothing/neck/language_collar/dropped(mob/user)
    ..()
    if(working && lang_disk && lang_disk.language)
        user.remove_language(lang_disk.language)
        user.default_language = null
        working = FALSE
    return

/datum/action/item_action/hands_free/toggle_language_collar
	name = "Toggle Language Collar"

/obj/item/clothing/neck/language_collar/attack_self(mob/user)
    if(user.incapacitated())
        return
    if(!lang_disk || !lang_disk.language)
        to_chat(user, "<span class='warning'>You need a language disk installed in the collar to use it.</span>")
        return
    if(slot_equipped == SLOT_NECK)
        if(!working)
            working = TRUE
            user.add_language(lang_disk.language)
            user.default_language = lang_disk.language
            to_chat(user, "<span class='notice'>You have activated the collar.</span>")
        else
            working = FALSE
            user.remove_language(lang_disk.language)
            user.default_language = null
            to_chat(user, "<span class='notice'>You have deactivated the collar.</span>")

/obj/item/clothing/neck/language_collar/monkey
	desc = "A language collar designed for monkeys, everyone knows that monkeys are the best at languages."
	species_restricted = list(MONKEY)

/obj/item/clothing/neck/language_collar/monkey/atom_init()
	. = ..()
	lang_disk = new /obj/item/weapon/disk/language/solcommon()
	lang_disk.holder = src
