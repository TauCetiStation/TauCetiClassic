/obj/item/weapon/storage/food

/obj/item/weapon/storage/food/small
    w_class = SIZE_TINY
    max_w_class = SIZE_TINY
    max_storage_space = 3

/obj/item/weapon/storage/food/small/chips
	name = "small bag of chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips_small"

/obj/item/weapon/storage/food/small/chips/atom_init()
	. = ..()
	for(var/i in 1 to 4)
		new /obj/item/weapon/reagent_containers/food/snacks/chips(src)

/obj/item/weapon/storage/food/normal
    w_class = SIZE_SMALL
    max_w_class = SIZE_SMALL
    max_storage_space = 6

/obj/item/weapon/storage/food/normal/chips
	name = "bag of chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"

/obj/item/weapon/storage/food/normal/chips/atom_init()
	. = ..()
	for(var/i in 1 to 8)
		new /obj/item/weapon/reagent_containers/food/snacks/chips(src)

/obj/item/weapon/storage/food/normal/honkers
	name = "Cheesie Honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	icon_state = "cheesie_honkers"

/obj/item/weapon/storage/food/normal/honkers/atom_init()
	. = ..()
	for(var/i in 1 to 8)
		new /obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers(src)

/obj/item/weapon/storage/food/normal/syndi_cakes
	name = "Syndi-Cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	icon_state = "syndi_cakes"
	max_storage_space = 8

/obj/item/weapon/storage/food/normal/syndi_cakes/atom_init()
	. = ..()
	for(var/i in 1 to 4)
		new /obj/item/weapon/reagent_containers/food/snacks/syndicake(src)

/obj/item/weapon/storage/food/normal/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	desc = "Beef jerky made from the finest space cows."
	icon_state = "sosjerky"

/obj/item/weapon/storage/food/normal/sosjerky/atom_init()
	. = ..()
	for(var/i in 1 to 8)
		new /obj/item/weapon/reagent_containers/food/snacks/sosjerky(src)

/obj/item/weapon/storage/food/normal/no_raisin
	name = "4no Raisins"
	desc = "Best raisins in the universe. Not sure why."
	icon_state = "4no_raisins"

/obj/item/weapon/storage/food/normal/no_raisin/atom_init()
	. = ..()
	for(var/i in 1 to 8)
		new /obj/item/weapon/reagent_containers/food/snacks/no_raisin(src)

/obj/item/weapon/storage/food/big
    w_class = SIZE_NORMAL
    max_w_class = SIZE_SMALL
    max_storage_space = DEFAULT_BACKPACK_STORAGE

/obj/item/weapon/storage/food/big/chips
	name = "huge bag of chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips_huge"

/obj/item/weapon/storage/food/big/chips/atom_init()
	. = ..()
	for(var/i in 1 to 36)
		new /obj/item/weapon/reagent_containers/food/snacks/chips(src)
