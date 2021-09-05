/obj/machinery/vending/medical
	name = "NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	light_color = "#e6fff2"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access = list(5)
	products = list(
		/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/stoxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/toxin = 4,
		/obj/item/weapon/reagent_containers/syringe/antiviral = 4,
		/obj/item/weapon/reagent_containers/syringe = 12,
		/obj/item/device/healthanalyzer = 5,
		/obj/item/weapon/reagent_containers/glass/beaker = 4,
		/obj/item/weapon/reagent_containers/dropper = 2,
		/obj/item/stack/medical/advanced/bruise_pack = 3,
		/obj/item/stack/medical/advanced/ointment = 3,
		/obj/item/stack/medical/splint = 2,
		/obj/item/stack/medical/suture = 6,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/pill/tox = 3,
		/obj/item/weapon/reagent_containers/pill/stox = 4,
		/obj/item/weapon/reagent_containers/pill/dylovene = 6,
	)
	refill_canister = /obj/item/weapon/vending_refill/medical

/obj/machinery/vending/wallmed1
	name = "NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?"
	icon_state = "wallmed"
	light_power_on = 1
	light_color = "#e6fff2"
	icon_deny = "wallmed-deny"
	density = FALSE //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/inaprovaline = 4,
		/obj/item/device/healthanalyzer = 1,
		/obj/item/stack/medical/suture = 2,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/syringe/antitoxin = 4,
		/obj/item/weapon/reagent_containers/syringe/antiviral = 4,
		/obj/item/weapon/reagent_containers/pill/tox = 1,
	)

/obj/machinery/vending/wallmed2
	name = "NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	light_power_on = 1
	light_color = "#e6fff2"
	icon_deny = "wallmed-deny"
	req_access = list(5)
	density = FALSE //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/inaprovaline = 5,
		/obj/item/weapon/reagent_containers/syringe/antitoxin = 3,
		/obj/item/stack/medical/bruise_pack = 3,
		/obj/item/stack/medical/ointment =3,
		/obj/item/device/healthanalyzer = 3,
		/obj/item/stack/medical/suture = 2,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/pill/tox = 3,
	)

/obj/machinery/vending/omskvend
	name = "Omsk-o-mat"
	desc = "Drug dispenser."
	icon_state = "omskvend"
	product_ads = "NORKOMAN SUKA SHTOLE?;STOP NARTCOTICS!; so i heard u liek mudkipz; METRO ZATOPEELO"
	products = list(
		/obj/item/device/healthanalyzer = 5,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 4,
	)

/obj/item/weapon/reagent_containers/pill/LSD
	name = "LSD"
	desc = "Ahaha oh wow."
	icon_state = "pill9"

/obj/item/weapon/reagent_containers/pill/LSD/atom_init()
	. = ..()
	reagents.add_reagent("mindbreaker", 0)

/obj/item/weapon/reagent_containers/glass/beaker/LSD
	name = "LSD IV"
	desc = "Ahaha oh wow."

/obj/item/weapon/reagent_containers/glass/beaker/LSD/atom_init()
	. = ..()
	reagents.add_reagent("mindbreaker", 0)
	update_icon()
