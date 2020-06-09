//AUTOINJECTOR
/obj/item/weapon/reagent_containers/hypospray/autoinjector/combat
	name = "combat autoinjector"
	desc = "Younger brother of combat autoinjector."
	icon_state = "stimpen"
	volume = 10
	list_reagents = list("synaptizine" = 1, "hyperzine" = 2.5, "oxycodone" = 2.5, "anti_toxin" = 5)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine
	name = "Bicaridine autoinjector"
	desc = "For physical injuries."
	icon_state = "autobrut"
	volume = 20
	list_reagents = list("bicaridine" = 20)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline
	name = "Dermaline autoinjector"
	desc = "For burns."
	icon_state = "autoburn"
	volume = 15
	list_reagents = list("dermaline" = 15)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol
	name = "Tramadol autoinjector"
	desc = "Painkiller."
	icon_state = "autopainkiller"
	volume = 15
	list_reagents = list("tramadol" = 15)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox
	name = "Anti-toxins autoinjector"
	desc = "Neutralizes many common toxins."
	icon_state = "autoantitox"
	volume = 20
	list_reagents = list("anti_toxin" = 20)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_imp
	name = "Improved stimpack"
	desc = "It does not contain caffeine"
	icon_state = "auto_minig_t2"
	volume = 20
	list_reagents = list("hyperzine" = 3, "paracetamol" = 10, "tricordrazine" = 7)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_imp/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("hyperzine", 3)
	reagents.add_reagent("paracetamol", 10)
	reagents.add_reagent("tricordrazine", 7)
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_adv
	name = "Advanced stimpack"
	desc = "Even more ore mined"
	icon_state = "auto_minig_t3"
	volume = 25
	list_reagents = list("hyperzine" = 5, "tramadol" = 9, "dexalinp" = 1, "tricordrazine" = 10)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/leporazine
	name = "leporazine autoinjector"
	desc = "Leporazine can be use to stabilize an individuals body temperature."
	icon_state = "autoinjector"
	volume = 15
	list_reagents = list("leporazine" = 15)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/nutriment
	name = "Nutriment autoinjector"
	desc = "To satisfy hunger."
	icon_state = "auto_nutriment"
	volume = 10
	list_reagents = list("nutriment" = 10)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/bonepen
	name = "Bone-R"
	desc = "Getting your bones repaired. Use carefully."
	icon_state = "bonepen"
	volume = 30
	list_reagents = list("nanocalcium" = 30)
