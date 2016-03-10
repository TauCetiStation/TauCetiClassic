//MEDICAL RANDOM
/obj/random/pills
	name = "Random Pill Bottle"
	desc = "This is a random pill bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill_canister"
	item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/storage/pill_bottle/))

/obj/random/medkit
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
	item_to_spawn()
		return pick(prob(5);/obj/item/weapon/storage/firstaid/regular,\
					prob(3);/obj/item/weapon/storage/firstaid/fire,\
					prob(3);/obj/item/weapon/storage/firstaid/toxin,\
					prob(3);/obj/item/weapon/storage/firstaid/o2,\
					prob(2);/obj/item/weapon/storage/firstaid/adv,\
					prob(1);/obj/item/weapon/storage/firstaid/tactical)

/obj/random/syringe
	name = "Random Syringe"
	desc = "This is a random syringe."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
	item_to_spawn()
		return pick(prob(2);/obj/item/weapon/reagent_containers/syringe/inaprovaline,\
					prob(2);/obj/item/weapon/reagent_containers/syringe/antitoxin,\
					prob(2);/obj/item/weapon/reagent_containers/syringe/antiviral,\
					prob(10);/obj/item/weapon/reagent_containers/syringe)

/obj/random/medical_tool
	name = "Random Surgery Equipment"
	desc = "This is a random medical surgery equipment."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	item_to_spawn()
		return pick(prob(1);/obj/item/weapon/circular_saw,\
					prob(1);/obj/item/weapon/scalpel,\
					prob(1);/obj/item/weapon/bonesetter,\
					prob(1);/obj/item/weapon/FixOVein,\
					prob(1);/obj/item/weapon/bonegel,\
					prob(1);/obj/item/weapon/cautery,\
					prob(1);/obj/item/weapon/surgicaldrill,\
					prob(1);/obj/item/weapon/retractor,\
					prob(1);/obj/item/weapon/tank/anesthetic,\
					prob(1);/obj/item/clothing/mask/breath/medical,\
					prob(1);/obj/item/weapon/reagent_containers/spray/cleaner,\
					prob(1);/obj/item/weapon/storage/box/gloves,\
					prob(1);/obj/item/weapon/storage/box/masks)

/obj/random/dna_injector
	name = "Random DNA injector"
	desc = "This is a random dna injector syringe."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/dnainjector))

/obj/random/medical_single_item
	name = "Random small medical item"
	desc = "This is a random small medical item."
	icon = 'icons/obj/items.dmi'
	icon_state = "ointment"
	item_to_spawn()
		return pick(subtypesof(/obj/item/stack/medical) - /obj/item/stack/medical/advanced)

/obj/random/chemical_bottle
	name = "Random Chemical bottle"
	desc = "This is a random Chemical bottle."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw3"
	item_to_spawn()
		return pick(prob(5);/obj/item/weapon/reagent_containers/glass/bottle/ammonia,\
					prob(5);/obj/item/weapon/reagent_containers/glass/bottle/diethylamine,\
					prob(5);/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,\
					prob(5);/obj/item/weapon/reagent_containers/glass/bottle/toxin,\
					prob(5);/obj/item/weapon/reagent_containers/glass/bottle/stoxin,\
					prob(5);/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,\
					prob(3);/obj/item/weapon/reagent_containers/glass/bottle/mutagen,\
					prob(3);/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate,\
					prob(1);/obj/item/weapon/reagent_containers/glass/bottle/random)

/obj/random/medical_supply
	name = "Random medical supply"
	desc = "This is a random medical supply."
	icon = 'icons/obj/items.dmi'
	icon_state = "traumakit"
	item_to_spawn()
		return pick(prob(20);/obj/random/medical_single_item,\
					prob(15);/obj/random/syringe,\
					prob(10);/obj/random/chemical_bottle,\
					prob(8);/obj/random/medkit,\
					prob(8);/obj/random/medical_tool,\
					prob(6);/obj/random/pills,\
					prob(1);/obj/random/dna_injector)