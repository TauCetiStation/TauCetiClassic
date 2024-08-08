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
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/metatrombine = 9,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine = 5,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline = 5,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol = 5,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox = 5,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/pill/tox = 3,
		/obj/item/weapon/reagent_containers/pill/stox = 4,
		/obj/item/weapon/reagent_containers/pill/dylovene = 6,
	)
	prices = list(
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine = 120,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline = 120,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol = 150,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox = 50,
    )
	premium = list(
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/nutriment = 3,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/hippiesdelight = 2,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack = 1,
		/obj/item/device/sensor_device = 1,
	)
	refill_canister = /obj/item/weapon/vending_refill/medical
	private = TRUE

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
		/obj/item/weapon/reagent_containers/hypospray/autoinjector = 4,
		/obj/item/device/healthanalyzer = 1,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/metatrombine = 3,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/syringe/antitoxin = 4,
		/obj/item/weapon/reagent_containers/syringe/antiviral = 4,
		/obj/item/weapon/reagent_containers/pill/tox = 1,
	)
	private = TRUE

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
		/obj/item/weapon/reagent_containers/hypospray/autoinjector = 5,
		/obj/item/weapon/reagent_containers/syringe/antitoxin = 3,
		/obj/item/stack/medical/bruise_pack = 3,
		/obj/item/stack/medical/ointment =3,
		/obj/item/device/healthanalyzer = 3,
		/obj/item/weapon/reagent_containers/hypospray/autoinjector/metatrombine = 3,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/pill/tox = 3,
	)
	private = TRUE

/obj/machinery/vending/omskvend
	name = "Omsk-o-mat"
	desc = "Drug dispenser."
	icon_state = "omskvend"
	product_ads = "NORKOMAN SUKA SHTOLE?;STOP NARTCOTICS!; so i heard u liek mudkipz; METRO ZATOPEELO"
	products = list(
		/obj/item/weapon/reagent_containers/pill/happy = 14,
		/obj/item/weapon/reagent_containers/pill/zoom = 14,
		/obj/item/weapon/reagent_containers/pill/LSD = 14,
		/obj/item/weapon/reagent_containers/syringe = 12,
		/obj/item/weapon/reagent_containers/glass/bottle/zombiepowder = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/jenkem = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/ambrosium = 4,
	)
	contraband = list(
		/obj/item/weapon/reagent_containers/glass/bottle/alphaamanitin = 1,
	)
	premium = list(
		/obj/item/weapon/reagent_containers/syringe/antitoxin = 10,
		/obj/item/device/healthanalyzer = 3,
	)
	private = TRUE
