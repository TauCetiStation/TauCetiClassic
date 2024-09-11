/obj/item/weapon/storage/food

/obj/item/weapon/storage/food/atom_init()
	. = ..()
	use_sound = 'sound/items/snack.ogg'

/obj/item/weapon/storage/food/update_icon()
	if (contents.len == 0)
		icon_state = "[initial(icon_state)]0"
	else
		icon_state = "[initial(icon_state)]"
	return

/obj/item/weapon/storage/food/small
    w_class = SIZE_TINY
    max_w_class = SIZE_TINY
    max_storage_space = 3

/obj/item/weapon/storage/food/small/chips
	name = "small pack of chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips_small"
	item_state = "chips"
	startswith = list(/obj/item/weapon/reagent_containers/food/snacks/chips = 4)

/obj/item/weapon/storage/food/normal
    w_class = SIZE_SMALL
    max_w_class = SIZE_SMALL
    max_storage_space = 6

/obj/item/weapon/storage/food/normal/chips
	name = "pack of chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	item_state = "chips"
	startswith = list(/obj/item/weapon/reagent_containers/food/snacks/chips = 8)

/obj/item/weapon/storage/food/normal/honkers
	name = "Cheesie Honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	icon_state = "cheesie_honkers"

/obj/item/weapon/storage/food/normal/honkers/atom_init()
	. = ..()
	if (prob(25))
		for(var/i in 1 to 5)
			new /obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers(src)
		new /obj/random/randomfigure(src)
	else
		for(var/i in 1 to 8)
			new /obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers(src)

/obj/item/weapon/storage/food/normal/syndi_cakes
	name = "Syndi-Cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	icon_state = "syndi_cakes"
	max_storage_space = 8
	startswith = list(/obj/item/weapon/reagent_containers/food/snacks/syndicake = 4)

/obj/item/weapon/storage/food/normal/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	desc = "Beef jerky made from the finest space cows."
	icon_state = "sosjerky"
	startswith = list(/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 8)

/obj/item/weapon/storage/food/normal/no_raisin
	name = "4no Raisins"
	desc = "Best raisins in the universe. Not sure why."
	icon_state = "4no_raisins"
	startswith = list(/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 8)

/obj/item/weapon/storage/food/big
    w_class = SIZE_NORMAL
    max_w_class = SIZE_SMALL
    max_storage_space = DEFAULT_BACKPACK_STORAGE

/obj/item/weapon/storage/food/big/chips
	name = "huge bag of chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips_huge"
	item_state = "chips"
	startswith = list(/obj/item/weapon/reagent_containers/food/snacks/chips = 36)
