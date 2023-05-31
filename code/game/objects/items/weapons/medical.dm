/obj/item/weapon/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by operatives trained in medical practices to quickly heal injuries in the field."
	amount_per_transfer_from_this = 10
	icon = 'icons/obj/items.dmi'
	icon_state = "combat_hypo"
	volume = 60
	list_reagents = list("stimulants" = 5, "bicaridine" = 15, "oxycodone" = 15, "kelotane" = 15, "doctorsdelight" = 10)
/obj/item/weapon/reagent_containers/hypospray/combat/atom_init()
	. = ..()
	if (!possible_transfer_amounts)
		src.verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT

//FIRST-AID KIT
/obj/item/weapon/storage/firstaid/tactical
	name = "first-aid kit"
	icon_state = "bezerk"
	item_state = "firstaid-syndi"
	desc = "I hope you've got insurance."
	max_w_class = SIZE_SMALL

/obj/item/weapon/storage/firstaid/tactical/atom_init()
	. = ..()
	if (empty)
		return
	new /obj/item/weapon/reagent_containers/hypospray/combat(src)
	new /obj/item/weapon/storage/pill_bottle/bicaridine(src)
	new /obj/item/weapon/storage/pill_bottle/dermaline(src)
	new /obj/item/weapon/storage/pill_bottle/dylovene(src)
	new /obj/item/weapon/storage/pill_bottle/tramadol(src)
	new /obj/item/stack/medical/suture(src)
	new /obj/item/device/healthanalyzer(src)

/obj/item/weapon/storage/firstaid/small_firstaid_kit/combat
	name = "Combat first-aid small kit"
	icon_state = "first_aid_kit_com"
	desc = "A small kit of auto injectors with drugs placed in his pocket. It`s combat version"
	max_w_class = SIZE_TINY
	w_class = SIZE_TINY

/obj/item/weapon/storage/firstaid/small_firstaid_kit/combat/atom_init()
	. = ..()

	if (empty)
		return

	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/combat(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/metatrombine(src)
	new /obj/item/device/healthanalyzer(src)

/obj/item/weapon/storage/firstaid/small_firstaid_kit/psyops
	name = "psyops small kit"
	icon_state = "first_aid_kit_com"
	desc = "A small kit of auto injectors with drugs. Like the real deal drugs."
	max_w_class = SIZE_TINY
	w_class = SIZE_TINY

/obj/item/weapon/storage/firstaid/small_firstaid_kit/psyops/atom_init()
	. = ..()

	if (empty)
		return

	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/nuka_cola(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/hippiesdelight(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/lean(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/space_drugs(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/nuka_cola(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/hippiesdelight(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/lean(src)

/obj/item/weapon/storage/firstaid/small_firstaid_kit/space
	name = "Space first-aid small kit"
	icon_state = "first_aid_kit_sp"
	desc = "A small kit of auto injectors with drugs placed in his pocket. It`s space version"
	max_w_class = SIZE_TINY
	w_class = SIZE_TINY

/obj/item/weapon/storage/firstaid/small_firstaid_kit/space/atom_init()
	. = ..()

	if (empty)
		return

	new /obj/item/weapon/patcher(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/bicaridine(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/dermaline(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/antitox(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/tramadol(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/device/healthanalyzer(src)

/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian
	name = "Civilan first-aid small kit"
	icon_state = "first_aid_kit_civilan"
	desc = "A small cheap kit with medical items."
	max_w_class = SIZE_TINY
	w_class = SIZE_TINY

/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian/atom_init()
	. = ..()

	if (empty)
		return

	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/weapon/reagent_containers/pill/dylovene(src)
	new /obj/item/weapon/reagent_containers/pill/dexalin(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector/metatrombine(src)
	new /obj/item/device/healthanalyzer(src)

/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian/strike
	name = "Emergency Small first-aid kit"

/obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian/strike/atom_init()
	. = ..()

	if (empty)
		return

	new /obj/item/stack/medical/suture(src)

/obj/item/weapon/storage/firstaid/small_firstaid_kit/nutriment
	name = "Emergency nutriment kit"
	icon_state = "emergency_nutriment_kit"
	desc = "A small kit to satisfy hunger."
	max_w_class = SIZE_TINY
	w_class = SIZE_TINY

/obj/item/weapon/storage/firstaid/small_firstaid_kit/nutriment/atom_init()
	. = ..()

	if (empty)
		return

	for (var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/nutriment(src)

/obj/item/weapon/reagent_containers/hypospray/combat/bleed
	name = "bloodloss hypospray"
	desc = "A modified air-needle autoinjector, used by operatives trained in medical practices to quickly heal injuries in the field. This one is filled with reagents to stop the bleedings."
	icon_state = "qc_hypo"
	volume = 100
	list_reagents = list("metatrombine" = 5, "iron" = 25, "dexalin" = 25, "bicaridine" = 25, "inaprovaline" = 20)

/obj/item/weapon/reagent_containers/hypospray/combat/bruteburn
	name = "bruteburn hypospray"
	desc = "A modified air-needle autoinjector, used by operatives trained in medical practices to quickly heal injuries in the field. This one is filled with reagents to heal brute and burn damage."
	icon_state = "bruteburn_hypo"
	volume = 100
	list_reagents = list("kelotane" = 25, "dermaline" = 25, "bicaridine" = 25, "tricordrazine" = 25)

/obj/item/weapon/reagent_containers/hypospray/combat/dexalin
	name = "dexalin+ hypospray"
	desc = "A modified air-needle autoinjector, used by operatives trained in medical practices to quickly heal injuries in the field. This one is filled with pure dexalin plus."
	amount_per_transfer_from_this = 1
	icon_state = "dex_hypo"
	volume = 10
	list_reagents = list("dexalinp" = 10)

/obj/item/weapon/reagent_containers/hypospray/combat/atoxin
	name = "anti-toxin hypospray"
	desc = "A modified air-needle autoinjector, used by operatives trained in medical practices to quickly heal injuries in the field. This one is filled with reagents that combat radioactive and regular poisoning."
	icon_state = "atox_hypo"
	volume = 100
	list_reagents = list("anti_toxin" = 60, "hyronalin" = 40)

/obj/item/weapon/reagent_containers/hypospray/combat/intdam
	name = "internal damage hypospray"
	desc = "A modified air-needle autoinjector, used by operatives trained in medical practices to quickly heal injuries in the field. This one is filled with reagents which will restore internal organs of patient."
	icon_state = "intdam_hypo"
	volume = 100
	list_reagents = list("peridaxon" = 25, "dextromethorphan" = 25, "alkysine" = 25, "imidazoline" = 25)

/obj/item/weapon/reagent_containers/hypospray/combat/pain
	name = "painstop hypospray"
	desc = "A modified air-needle autoinjector, used by operatives trained in medical practices to quickly heal injuries in the field. This one is filled with reagents which will quench the pain."
	icon_state = "pain_hypo"
	volume = 100
	list_reagents = list("tramadol" = 25, "paracetamol" = 25, "oxycodone" = 25, "inaprovaline" = 25)
	
/obj/item/weapon/reagent_containers/hypospray/combat/bone
	name = "Bone-repair hypospray"
	desc = "A modified air-needle autoinjector, used by operatives trained in medical practices to quickly heal injuries in the field. This one is filled with reagents which will mend the bones."
	icon_state = "bone_hypo"
	amount_per_transfer_from_this = 10.3
	volume = 100
	list_reagents = list("nanocalcium" = 60, "mednanobots" = 1.8)
