/obj/item/weapon/storage/internal/imp
	name = "bluespace pocket"
	cases = list("блюспейс карман", "блюспейс кармана", "блюспейс карману", "блюспейс карман", "блюспейс карманом", "блюспейс кармане")
	max_w_class = SIZE_SMALL
	storage_slots = 2
	cant_hold = list(/obj/item/weapon/disk/nuclear)

/obj/item/weapon/implant/storage
	name = "storage implant"
	cases = list("имплант хранения", "импланта хранения", "импланту хранения", "имплант хранения", "имплантом хранения", "импланте хранения")
	desc = "Может хранить до двух вещей большого размера в блюспейс кармане."
	icon_state = "implant_evil"
	legal = FALSE
	origin_tech = "materials=2;magnets=4;bluespace=5;syndicate=4"
	var/obj/item/weapon/storage/internal/imp/storage
	item_action_types = list(/datum/action/item_action/implant/storage_implant)

/datum/action/item_action/implant/storage_implant
	name = "Блюспейс карман"

/datum/action/item_action/implant/storage_implant/Activate()
	var/obj/item/weapon/implant/storage/S = target
	S.use_implant()

/obj/item/weapon/implant/storage/activate()
	storage.open(implanted_mob)

/obj/item/weapon/implant/storage/atom_init()
	. = ..()
	storage = new /obj/item/weapon/storage/internal/imp(src)

/obj/item/weapon/implant/storage/eject()
	storage.close_all()
	for(var/obj/item/I in storage)
		storage.remove_from_storage(I, get_turf(src))
	. = ..()

/obj/item/weapon/implant/storage/Destroy()
	. = ..()
	qdel(storage)
