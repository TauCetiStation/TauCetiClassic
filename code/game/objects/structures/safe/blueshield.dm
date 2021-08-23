/obj/structure/safe/floor/blueshield
    name = "code red safe" // WIP

/obj/item/weapon/paper/blueshieldsafe
	name = "Код от сейфа"

/obj/item/weapon/paper/blueshieldsafe/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/paper/blueshieldsafe/atom_init_late()
    var/obj/structure/safe/floor/blueshield/safes = list()
    if(safes_list)
        for (var/obj/structure/safe/safe in safes_list)
            if (istype(safe, /obj/structure/safe/floor/blueshield))
                safes += safe
    
    if (safes)
        info = "<center><h2>Коды от сейфов.</h2></center>"
        for (var/obj/structure/safe/safe in safes)
            info += "<br>[safe.get_combination()]"
    else
        info = "Ваш сейф украли ещё вчера."
        info_links = info
    icon_state = "paper_words"

/obj/item/weapon/paper/blueshieldsafe_wip
	name = "Послание от хозяина"

/obj/item/weapon/paper/blueshieldsafe_wip/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/paper/blueshieldsafe_wip/atom_init_late()
    info = "Work in progress..."
    info_links = info
    icon_state = "paper_words"
