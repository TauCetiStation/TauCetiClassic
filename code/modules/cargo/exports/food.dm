//--------------------------------------------
//----------------Burger--------------
//--------------------------------------------

/datum/export/burger
	cost = 40
	unit_name = "burger"
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/brainburger,
		/obj/item/weapon/reagent_containers/food/snacks/roburger,
		/obj/item/weapon/reagent_containers/food/snacks/xenoburger,
		/obj/item/weapon/reagent_containers/food/snacks/fishburger,
		/obj/item/weapon/reagent_containers/food/snacks/tofuburger,
		/obj/item/weapon/reagent_containers/food/snacks/ghostburger,
		/obj/item/weapon/reagent_containers/food/snacks/clownburger,
		/obj/item/weapon/reagent_containers/food/snacks/mimeburger,
		/obj/item/weapon/reagent_containers/food/snacks/spellburger,
		/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger,
		/obj/item/weapon/reagent_containers/food/snacks/superbiteburger)

//fast food in automate
/datum/export/automateburger
	cost = 10
	unit_name = " automateburger"
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/cheeseburger, /obj/item/weapon/reagent_containers/food/snacks/monkeyburger)
//--------------------------------------------
//----------------Sandwich--------------
//--------------------------------------------

/datum/export/sandwich
	cost = 30
	unit_name = "sandwich"
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/sandwich,
		/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich,
		/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime,
		/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry,
		/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich,
		/obj/item/weapon/reagent_containers/food/snacks/notasandwich)

//--------------------------------------------
//----------------Soup--------------
//--------------------------------------------

/datum/export/soup
	cost = 70
	unit_name = "soup"
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/soup/meatballsoup,
		/obj/item/weapon/reagent_containers/food/snacks/soup/vegetablesoup,
		/obj/item/weapon/reagent_containers/food/snacks/soup/nettlesoup,
		/obj/item/weapon/reagent_containers/food/snacks/soup/tomatosoup,
		/obj/item/weapon/reagent_containers/food/snacks/soup/stew,
		/obj/item/weapon/reagent_containers/food/snacks/soup/milosoup,
		/obj/item/weapon/reagent_containers/food/snacks/soup/bloodsoup,
		/obj/item/weapon/reagent_containers/food/snacks/soup/slimesoup,
		/obj/item/weapon/reagent_containers/food/snacks/soup/mysterysoup,
		/obj/item/weapon/reagent_containers/food/snacks/soup/mushroomsoup,
		/obj/item/weapon/reagent_containers/food/snacks/soup/beetsoup,
		/obj/item/weapon/reagent_containers/food/snacks/soup/wishsoup)


/datum/export/wishsoup
	cost = 1
	unit_name = "wishsoup"
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/soup/wishsoup)

//--------------------------------------------
//----------------Bread--------------
//--------------------------------------------

/datum/export/bread
	cost = 40
	unit_name = "bread"
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/meat,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/xeno,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/spider,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/banana,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/cheese)

/datum/export/plainbread
	cost = 15
	unit_name = "plainbread"
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread)

//--------------------------------------------
//----------------Pie--------------
//--------------------------------------------

/datum/export/pie
	cost = 80
	unit_name = "pie"
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/pumpkin,
		/obj/item/weapon/reagent_containers/food/snacks/pie,
		/obj/item/weapon/reagent_containers/food/snacks/cherrypie,
		/obj/item/weapon/reagent_containers/food/snacks/plump_pie,
		/obj/item/weapon/reagent_containers/food/snacks/meatpie,
		/obj/item/weapon/reagent_containers/food/snacks/tofupie,
		/obj/item/weapon/reagent_containers/food/snacks/xemeatpie,
		/obj/item/weapon/reagent_containers/food/snacks/applepie)

//--------------------------------------------
//----------------Cake--------------
//--------------------------------------------

/datum/export/cake
	cost = 90
	unit_name = "cake"
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/carrot,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/cheese,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/birthday,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/apple,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/orange,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/lime,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/lemon,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/chocolate,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/brain,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/pumpkin)

//--------------------------------------------
//----------------Misc--------------
//--------------------------------------------

/datum/export/misc
	cost = 150
	unit_name = "misc"
	export_types = list(/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff,
		/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey,
		/obj/item/weapon/reagent_containers/food/snacks/jundarek,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/kaholket_alkeha,
		/obj/item/weapon/reagent_containers/food/snacks/appletart,
		/obj/item/weapon/reagent_containers/food/snacks/enchiladas,
		/obj/item/weapon/reagent_containers/food/snacks/el_ehum)
