/obj/item/weapon/reagent_containers/food/drinks/mug
	name = "mug"
	desc = "Just a plain mug for drinks."
	icon = 'icons/obj/mugs.dmi'
	icon_state = "mug"
	volume = 30

/obj/item/weapon/reagent_containers/food/drinks/mug/golden
	name = "golden mug"
	desc = "A mug made of gold."
	icon_state = "mug_golden"

/obj/item/weapon/reagent_containers/food/drinks/mug/nanotrasen
	name = "Nanotrasen mug"
	desc = "A mug with Nanotrasen logo on it."
	icon_state = "mug_nt"

/obj/item/weapon/reagent_containers/food/drinks/mug/britain
	name = "Britain mug"
	desc = "A mug with the British flag emblazoned on it."
	icon_state = "mug_uk"

/obj/item/weapon/reagent_containers/food/drinks/mug/ukraine
	name = "Ukraine mug"
	desc = "A mug with the Ukrainian flag emblazoned on it."
	icon_state = "mug_ua"

/obj/item/weapon/reagent_containers/food/drinks/mug/russia
	name = "Russia mug"
	desc = "A mug with the Russian flag emblazoned on it."
	icon_state = "mug_ru"

/obj/item/weapon/reagent_containers/food/drinks/mug/ireland
	name = "Ireland mug"
	desc = "A mug with the Irish flag emblazoned on it."
	icon_state = "mug_ie"

/obj/item/weapon/reagent_containers/food/drinks/mug/random/atom_init()
	. = ..()
	var/list/mug_blacklist = list(src.type, /obj/item/weapon/reagent_containers/food/drinks/mug/golden)
	var/list/mug_types = typesof(/obj/item/weapon/reagent_containers/food/drinks/mug) - mug_blacklist
	var/mug_type = pick(mug_types)
	var/obj/item/src_mug = new mug_type
	name = src_mug.name
	desc = src_mug.desc
	icon_state = src_mug.icon_state
