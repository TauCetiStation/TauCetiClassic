//MEDICAL RANDOM
/obj/random/meds/pills
	name = "Random Pill Bottle"
	desc = "This is a random pill bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill_canister"
/obj/random/meds/pills/item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/storage/pill_bottle))

/obj/random/meds/medkit
	name = "Random Medkit"
	desc = "This is a random medical kit."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/meds/medkit/item_to_spawn()
		return pick(\
						prob(5);/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian,\
						prob(3);/obj/item/weapon/storage/firstaid/small_firstaid_kit/space,\
						prob(3);/obj/item/weapon/storage/firstaid/small_firstaid_kit/combat,\
						prob(5);/obj/item/weapon/storage/firstaid/regular,\
						prob(3);/obj/item/weapon/storage/firstaid/fire,\
						prob(3);/obj/item/weapon/storage/firstaid/toxin,\
						prob(3);/obj/item/weapon/storage/firstaid/o2,\
						prob(2);/obj/item/weapon/storage/firstaid/adv,\
						prob(1);/obj/item/weapon/storage/firstaid/tactical\
					)

/obj/random/meds/syringe
	name = "Random Syringe"
	desc = "This is a random syringe."
	icon = 'icons/obj/storage.dmi'
	icon_state = "firstaid"
/obj/random/meds/syringe/item_to_spawn()
		return pick(\
						prob(2);/obj/item/weapon/gun/syringe,\
						prob(1);/obj/item/weapon/reagent_containers/ld50_syringe/choral,\
						prob(4);/obj/item/weapon/storage/box/syringes,\
						prob(8);/obj/item/weapon/reagent_containers/syringe/inaprovaline,\
						prob(8);/obj/item/weapon/reagent_containers/syringe/antitoxin,\
						prob(8);/obj/item/weapon/reagent_containers/syringe/antiviral,\
						prob(20);/obj/item/weapon/reagent_containers/syringe\
					)

/obj/random/meds/medical_tool
	name = "Random Surgery Equipment"
	desc = "This is a random medical surgery equipment."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
/obj/random/meds/medical_tool/item_to_spawn()
		return pick(\
						/obj/item/weapon/circular_saw,\
						/obj/item/weapon/scalpel,\
						/obj/item/weapon/bonesetter,\
						/obj/item/weapon/FixOVein,\
						/obj/item/weapon/bonegel,\
						/obj/item/weapon/cautery,\
						/obj/item/weapon/surgicaldrill,\
						/obj/item/weapon/retractor,\
						/obj/item/weapon/tank/anesthetic,\
						/obj/item/clothing/mask/breath/medical,\
						/obj/item/weapon/reagent_containers/spray/cleaner,\
						/obj/item/weapon/storage/box/gloves,\
						/obj/item/weapon/storage/box/masks\
					)

/obj/random/meds/dna_injector
	name = "Random DNA injector"
	desc = "This is a random dna injector syringe."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
/obj/random/meds/dna_injector/item_to_spawn()
		return pick(subtypesof(/obj/item/weapon/dnainjector))

/obj/random/meds/medical_single_item
	name = "Random small medical item"
	desc = "This is a random small medical item."
	icon = 'icons/obj/items.dmi'
	icon_state = "ointment"
/obj/random/meds/medical_single_item/item_to_spawn()
		return pick(subtypesof(/obj/item/stack/medical) - /obj/item/stack/medical/advanced)

/obj/random/meds/chemical_bottle
	name = "Random Chemical bottle"
	desc = "This is a random Chemical bottle."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
/obj/random/meds/chemical_bottle/item_to_spawn()
		return pick(\
						prob(5);/obj/item/weapon/reagent_containers/glass/bottle/ammonia,\
						prob(5);/obj/item/weapon/reagent_containers/glass/bottle/diethylamine,\
						prob(5);/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline,\
						prob(5);/obj/item/weapon/reagent_containers/glass/bottle/toxin,\
						prob(5);/obj/item/weapon/reagent_containers/glass/bottle/stoxin,\
						prob(5);/obj/item/weapon/reagent_containers/glass/bottle/antitoxin,\
						prob(3);/obj/item/weapon/reagent_containers/glass/bottle/mutagen,\
						prob(3);/obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate,\
						prob(3);/obj/item/weapon/reagent_containers/glass/bottle/acid,\
					)

/obj/random/meds/medical_pills
	name = "Random medical pills"
	desc = "This is a random medical pills."
	icon = 'icons/obj/items.dmi'
	icon_state = "pill_canister"
/obj/random/meds/medical_pills/item_to_spawn()
		return pick(\
						prob(40);/obj/item/weapon/reagent_containers/pill/dylovene,\
						prob(20);/obj/item/weapon/reagent_containers/pill/dermaline,\
						prob(40);/obj/item/weapon/reagent_containers/pill/kelotane,\
						prob(40);/obj/item/weapon/reagent_containers/pill/paracetamol,\
						prob(20);/obj/item/weapon/reagent_containers/pill/tramadol,\
						prob(40);/obj/item/weapon/reagent_containers/pill/inaprovaline,\
						prob(40);/obj/item/weapon/reagent_containers/pill/dexalin,\
						prob(20);/obj/item/weapon/reagent_containers/pill/dexalin_plus,\
						prob(25);/obj/item/weapon/reagent_containers/pill/bicaridine,\
						prob(20);/obj/item/weapon/reagent_containers/pill/happy,\
						prob(30);/obj/item/weapon/reagent_containers/pill/lipozine,\
						prob(15);/obj/item/weapon/reagent_containers/pill/spaceacillin,\
						prob(15);/obj/item/weapon/reagent_containers/pill/antirad,\
						prob(5);/obj/item/weapon/reagent_containers/pill/cyanide\
					)

/obj/random/meds/medical_autoinjectors
	name = "Random medical autoinjectors"
	desc = "This is a random medical autoinjectors."
	icon = 'icons/obj/items.dmi'
	icon_state = "pill_canister"
/obj/random/meds/medical_autoinjectors/item_to_spawn()
		return pick(\
						prob(40);/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack,\
						prob(20);/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_imp,\
						prob(10);/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_adv,\
						prob(20);/obj/item/weapon/reagent_containers/hypospray/autoinjector/leporazine,\
						prob(10);/obj/item/weapon/reagent_containers/hypospray/autoinjector/nutriment,\
						prob(25);/obj/item/weapon/reagent_containers/hypospray/autoinjector/hippiesdelight,\
						prob(15);/obj/item/weapon/reagent_containers/hypospray/autoinjector/lean,\
						prob(15);/obj/item/weapon/reagent_containers/hypospray/autoinjector/space_drugs,\
						prob(20);/obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine,\
						prob(20);/obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline,\
						prob(30);/obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol,\
						prob(30);/obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox,\
						prob(15);/obj/item/weapon/reagent_containers/hypospray/autoinjector/combat,\
						prob(10);/obj/item/weapon/reagent_containers/hypospray/autoinjector/bonepen\
					)

/obj/random/meds/medical_supply
	name = "Random medical supply"
	desc = "This is a random medical supply."
	icon = 'icons/obj/items.dmi'
	icon_state = "traumakit"
/obj/random/meds/medical_supply/item_to_spawn()
		return pick(\
						prob(20);/obj/random/meds/medical_single_item,\
						prob(20);/obj/random/meds/medical_pills,\
						prob(20);/obj/random/meds/medical_autoinjectors,\
						prob(12);/obj/random/meds/syringe,\
						prob(10);/obj/random/meds/chemical_bottle,\
						prob(10);/obj/random/meds/medkit,\
						prob(9);/obj/random/meds/medical_tool,\
						prob(6);/obj/random/meds/pills,\
						prob(3);/obj/random/meds/dna_injector,\
					)

