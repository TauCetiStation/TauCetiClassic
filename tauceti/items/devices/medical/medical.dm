/obj/item/weapon/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by operatives trained in medical practices to quickly heal injuries in the field."
	amount_per_transfer_from_this = 10
	icon = 'tauceti/items/devices/medical/medical.dmi'
	icon_state = "combat_hypo"
	volume = 60

/obj/item/weapon/reagent_containers/hypospray/combat/New()
	if (!possible_transfer_amounts)
		src.verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT
	var/datum/reagents/R = new/datum/reagents(volume)
	reagents = R
	R.my_atom = src
	reagents.add_reagent("synaptizine", 5)
	reagents.add_reagent("hyperzine", 15)
	reagents.add_reagent("oxycodone", 15)
	reagents.add_reagent("anti_toxin", 25)

//AUTOINJECTOR
/obj/item/weapon/reagent_containers/hypospray/autoinjector/combat
	name = "combat autoinjector"
	desc = "Younger brother of combat autoinjector."
	icon_state = "stimpen"
	volume = 10
	amount_per_transfer_from_this = 10

	New()
		..()
		reagents.add_reagent("synaptizine", 1)
		reagents.add_reagent("hyperzine", 2.5)
		reagents.add_reagent("oxycodone", 2.5)
		reagents.add_reagent("anti_toxin", 5)
		update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine
	name = "Bicaridine autoinjector"
	desc = "For physical injures."
	icon_state = "autobrut"
	volume = 20
	amount_per_transfer_from_this = 20

	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("bicaridine", 20)
		update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline
	name = "Dermaline autoinjector"
	desc = "For burns."
	icon_state = "autoburn"
	volume = 15
	amount_per_transfer_from_this = 15

	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("dermaline", 15)
		update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol
	name = "Tramadol autoinjector"
	desc = "Piankiller."
	icon_state = "autopainkiller"
	volume = 15
	amount_per_transfer_from_this = 15

	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("tramadol", 15)
		update_icon()
		return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox
	name = "Anti-toxins autoinjector"
	desc = "Neutralizes many common toxins."
	icon_state = "autoantitox"
	volume = 20
	amount_per_transfer_from_this = 20

	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent("anti_toxin", 20)
		update_icon()
		return

//PILL
/obj/item/weapon/reagent_containers/pill/dermaline
	name = "Dermaline pill"
	desc = "Used to treat burns."
	icon_state = "pill11"
	New()
		..()
		reagents.add_reagent("dermaline", 15)

/obj/item/weapon/storage/pill_bottle/dermaline
	name = "bottle of dermaline pills"
	desc = "Contains pills used to treat burns."

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/dermaline( src )
		new /obj/item/weapon/reagent_containers/pill/dermaline( src )
		new /obj/item/weapon/reagent_containers/pill/dermaline( src )
		new /obj/item/weapon/reagent_containers/pill/dermaline( src )
		new /obj/item/weapon/reagent_containers/pill/dermaline( src )
		new /obj/item/weapon/reagent_containers/pill/dermaline( src )
		new /obj/item/weapon/reagent_containers/pill/dermaline( src )

/obj/item/weapon/storage/pill_bottle/bicaridine
	name = "bottle of bicaridine pills"
	desc = "Contains pills used to treat physical injures."

	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )
		new /obj/item/weapon/reagent_containers/pill/bicaridine( src )

//FIRST-AID KIT
/obj/item/weapon/storage/firstaid/tactical
	name = "first-aid kit"
	icon_state = "bezerk"
	desc = "I hope you've got insurance."
	max_w_class = 3

	New()
		..()
		if (empty) return
		new /obj/item/weapon/reagent_containers/hypospray/combat( src )
		new /obj/item/weapon/storage/pill_bottle/bicaridine( src )
		new /obj/item/weapon/storage/pill_bottle/dermaline( src )
		new /obj/item/weapon/storage/pill_bottle/antitox( src )
		new /obj/item/weapon/storage/pill_bottle/tramadol(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
		new /obj/item/device/healthanalyzer(src)
		return

/obj/item/weapon/storage/firstaid/small_firstaid_kit/combat
	name = "Combat first-aid small kit"
	icon_state = "medbriefcase"
	desc = "I hope you've got insurance."
	max_w_class = 2
	w_class = 2

	New()
		..()
		if (empty) return
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/combat( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
		new /obj/item/device/healthanalyzer(src)
		return

/obj/item/weapon/storage/firstaid/small_firstaid_kit/space
	name = "Space first-aid small kit"
	icon_state = "medbriefcase"
	desc = "Med kit. For space..."
	max_w_class = 2
	w_class = 2

	New()
		..()
		if (empty) return
		new /obj/item/weapon/patcher( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
		new /obj/item/device/healthanalyzer(src)
		return



