//Я думаю, содержимое коробки должно быть сюрпризом, а за гитом подглядывают.
/obj/item/weapon/storage/box/contraband/New()
	..()

	if(prob(30))
		new /obj/item/weapon/storage/box/matches(src)
		new /obj/item/clothing/mask/cigarette/cigar/cohiba(src)
	else if(prob(10))
		new /obj/item/device/guitar(src)
		new /obj/item/clothing/head/sombrero(src)
		new /obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla(src)
	else
		new /obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(src)
		new /obj/item/weapon/storage/fancy/cigarettes(src)
		new /obj/item/weapon/lighter/random(src)