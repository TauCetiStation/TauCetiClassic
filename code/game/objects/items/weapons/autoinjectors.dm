//AUTOINJECTOR
/obj/item/weapon/reagent_containers/hypospray/autoinjector/combat
	name = "combat autoinjector"
	desc = "Younger brother of combat autoinjector."
	icon_state = "stimpen"
	item_state = "autoinjector_empty"
	volume = 15
	list_reagents = list("doctorsdelight" = 5, "stimulants" = 1, "bicaridine" = 2.5, "oxycodone" = 2.5, "kelotane" = 5)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine
	name = "bicaridine autoinjector"
	desc = "For physical injuries."
	icon_state = "autobrut"
	item_state = "autobrut"
	volume = 20
	list_reagents = list("bicaridine" = 20)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline
	name = "dermaline autoinjector"
	desc = "For burns."
	icon_state = "autoburn"
	item_state = "autoburn"
	volume = 15
	list_reagents = list("dermaline" = 15)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol
	name = "tramadol autoinjector"
	desc = "Painkiller."
	icon_state = "autopainkiller"
	item_state = "autopainkiller"
	volume = 15
	list_reagents = list("tramadol" = 15)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox
	name = "anti-toxin autoinjector"
	desc = "Neutralizes many common toxins."
	icon_state = "autoantitox"
	item_state = "autoantitox"
	volume = 20
	list_reagents = list("anti_toxin" = 20)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_imp
	name = "improved stimpack"
	desc = "It does not contain caffeine"
	icon_state = "auto_minig_t2"
	item_state = "autoburn"
	volume = 20
	list_reagents = list("kelotane" = 1.5, "bicaridine" = 1.5, "paracetamol" = 10, "tricordrazine" = 7)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_adv
	name = "advanced stimpack"
	desc = "Even more ore mined"
	icon_state = "auto_minig_t3"
	item_state = "autobrut"
	volume = 25
	list_reagents = list("dermaline" = 2.5, "bicaridine" = 2.5, "tramadol" = 9, "dexalinp" = 1, "doctorsdelight" = 10)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/leporazine
	name = "leporazine autoinjector"
	desc = "Leporazine can be use to stabilize an individuals body temperature."
	icon_state = "autoinjector"
	volume = 15
	list_reagents = list("leporazine" = 15)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/nutriment
	name = "nutriment autoinjector"
	desc = "To satisfy hunger."
	icon_state = "autonutriment"
	item_state = "autonutriment"
	volume = 10
	list_reagents = list("nutriment" = 10)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/bonepen
	name = "Bone-R"
	desc = "Getting your bones repaired. Use carefully."
	icon_state = "bonepen"
	item_state = "bonepen"
	volume = 30
	list_reagents = list("nanocalcium" = 30)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/nuka_cola
	name = "nuka cola autoinjector"
	desc = "Drugs, drugs never change."
	icon_state = "autobrut"
	item_state = "autobrut"
	volume = 15
	list_reagents = list("nuka_cola" = 15)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/hippiesdelight
	name = "hippie's delight autoinjector"
	desc = "Drugs, drugs never change."
	icon_state = "autoantitox"
	item_state = "autoantitox"
	volume = 15
	list_reagents = list("hippiesdelight" = 15)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/lean
	name = "lean autoinjector"
	desc = "Drugs, drugs never change."
	icon_state = "autopainkiller"
	item_state = "autopainkiller"
	volume = 15
	list_reagents = list("lean" = 15)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/space_drugs
	name = "space drugs autoinjector"
	desc = "Drugs, drugs never change."
	icon_state = "autonutriment"
	item_state = "autonutriment"
	volume = 15
	list_reagents = list("space_drugs" = 15)

// shitspawn only
/obj/item/weapon/lazarus_injector/revive
	name = "heal injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise spacemans from the dead, making them become friendly to the user... or something like that. Five uses only."
	loaded = 5

/obj/item/weapon/lazarus_injector/revive/revive(mob/living/target, mob/living/user)
	if(user.is_busy(src) || !do_after(user, 5 SECONDS, target = target))
		return
	target.revive()
	loaded--
	user.visible_message("<span class='notice'>[user] injects [target] with [src], completely healing it.</span>")
	playsound(src, 'sound/effects/refill.ogg', VOL_EFFECTS_MASTER)

	if(!loaded)
		icon_state = "lazarus_empty"
