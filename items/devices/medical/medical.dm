/obj/item/weapon/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by operatives trained in medical practices to quickly heal injuries in the field."
	amount_per_transfer_from_this = 10
	icon = 'tauceti/items/devices/medical/medical.dmi'
	icon_state = "combat_hypo"
	volume = 60

/obj/item/weapon/reagent_containers/hypospray/combat/New()
	..()
	reagents.add_reagent("synaptizine", 30)

/obj/item/weapon/reagent_containers/pill/dermaline
	name = "Dermaline pill"
	desc = "Used to treat burns."
	icon_state = "pill11"
	New()
		..()
		reagents.add_reagent("dermaline", 15)

/obj/item/weapon/reagent_containers/pill/tramadol
	name = "Tramadol pill"
	desc = "Painkiller"
	icon_state = "pill11"
	New()
		..()
		reagents.add_reagent("tramadol", 15)

/obj/item/weapon/storage/firstaid/tactical
	name = "first-aid kit"
	icon_state = "bezerk"
	desc = "I hope you've got insurance."
	max_w_class = 3

	New()
		..()
		if (empty) return
		new /obj/item/weapon/reagent_containers/hypospray/combat( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/dermaline( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
		new /obj/item/device/healthanalyzer(src)
		return