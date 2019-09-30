//AUTOINJECTOR
/obj/item/weapon/reagent_containers/hypospray/autoinjector/combat
	name = "combat autoinjector"
	desc = "Younger brother of combat autoinjector."
	icon_state = "stimpen"
	volume = 10

/obj/item/weapon/reagent_containers/hypospray/autoinjector/combat/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("synaptizine", 1)
	reagents.add_reagent("hyperzine", 2.5)
	reagents.add_reagent("oxycodone", 2.5)
	reagents.add_reagent("anti_toxin", 5)
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine
	name = "Bicaridine autoinjector"
	desc = "For physical injuries."
	icon_state = "autobrut"
	volume = 20

/obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("bicaridine", 20)
	update_icon()


/obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline
	name = "Dermaline autoinjector"
	desc = "For burns."
	icon_state = "autoburn"
	volume = 15

/obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("dermaline", 15)
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol
	name = "Tramadol autoinjector"
	desc = "Painkiller."
	icon_state = "autopainkiller"
	volume = 15

/obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("tramadol", 15)
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox
	name = "Anti-toxins autoinjector"
	desc = "Neutralizes many common toxins."
	icon_state = "autoantitox"
	volume = 20

/obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("anti_toxin", 20)
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/metatrombine
	name = "Metatrombine autoinjector"
	desc = "Induces quick blood clotting."
	icon_state = "autoquickclot"
	volume = 20

/obj/item/weapon/reagent_containers/hypospray/autoinjector/metatrombine/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("metatrombine", 20)
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stabyzol
	name = "Stabyzol autoinjector"
	desc = "Temporarily prevents symptoms of organ failure."
	icon_state = "autostaby"
	volume = 9 // 10 is an overdose.

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stabyzol/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("stabyzol", 9)
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/aclometasone
	name = "Aclometasone autoinjector"
	desc = "Shuts down metabolism until let out of bloodstream."
	icon_state = "autoaclo"
	volume = 1 // There's no point for more, if it's in the system, it works.

/obj/item/weapon/reagent_containers/hypospray/autoinjector/aclometasone/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("aclometasone", 1)
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_imp
	name = "Improved stimpack"
	desc = "It does not contain caffeine"
	icon_state = "auto_minig_t2"
	volume = 20

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

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_adv/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("hyperzine", 5)
	reagents.add_reagent("tramadol", 9)
	reagents.add_reagent("dexalinp", 1)
	reagents.add_reagent("tricordrazine", 10)
	update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/leporazine
	name = "leporazine autoinjector"
	desc = "Leporazine can be use to stabilize an individuals body temperature."
	icon_state = "autoinjector"
	volume = 15

/obj/item/weapon/reagent_containers/hypospray/autoinjector/leporazine/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("leporazine", 15)
