//AUTOINJECTOR
/obj/item/weapon/reagent_containers/hypospray/autoinjector/combat
	name = "combat autoinjector"
	desc = "Younger brother of combat autoinjector."
	icon_state = "stimpen"
	volume = 10
	amount_per_transfer_from_this = 10

/obj/item/weapon/reagent_containers/hypospray/autoinjector/combat/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent("synaptizine", 1)
	reagents.add_reagent("hyperzine", 2.5)
	reagents.add_reagent("oxycodone", 2.5)
	reagents.add_reagent("anti_toxin", 5)
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine
	name = "Bicaridine autoinjector"
	desc = "For physical injures."
	icon_state = "autobrut"
	volume = 20
	amount_per_transfer_from_this = 20

/obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent("bicaridine", 20)
	update_icon()


/obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline
	name = "Dermaline autoinjector"
	desc = "For burns."
	icon_state = "autoburn"
	volume = 15
	amount_per_transfer_from_this = 15

/obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent("dermaline", 15)
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol
	name = "Tramadol autoinjector"
	desc = "Piankiller."
	icon_state = "autopainkiller"
	volume = 15
	amount_per_transfer_from_this = 15

/obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol/New()
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

/obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent("anti_toxin", 20)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_imp
	name = "Improved stimpack"
	desc = "It does not contain caffeine"
	icon_state = "auto_minig_t2"
	volume = 20
	amount_per_transfer_from_this = 20

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_imp/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent("hyperzine", 3)
	reagents.add_reagent("paracetamol", 10)
	reagents.add_reagent("tricordrazine", 7)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_adv
	name = "Advanced stimpack"
	desc = "Even more ore mined"
	icon_state = "auto_minig_t3"
	volume = 25
	amount_per_transfer_from_this = 25

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_adv/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent("hyperzine", 5)
	reagents.add_reagent("tramadol", 9)
	reagents.add_reagent("dexalinp", 1)
	reagents.add_reagent("tricordrazine", 10)
	update_icon()
	return
