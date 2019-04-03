/datum/unarmed_attack/punch/scp076_attack
	damage = 14

/datum/species/scp076
	name = "SCP-076"
	icobase = 'code/modules/SCP/SCP_076/scp-076.dmi'
	deform = 'code/modules/SCP/SCP_076/scp-076.dmi'
	dietflags = DIET_OMNI
	unarmed_type = /datum/unarmed_attack/punch/scp076_attack
	eyes = "blank_eyes"

	flags = list(
	HAS_LIPS = TRUE
	,HAS_UNDERWEAR = FALSE
	,NO_PAIN = TRUE
	,VIRUS_IMMUNE = TRUE
	)

	brute_mod = 0.3
	burn_mod = 0.5
	oxy_mod = 0.2
	tox_mod = 0
	brain_mod = 0
	speed_mod = -1.0

	has_gendered_icons = FALSE

/datum/species/scp076/on_gain(mob/living/carbon/human/H)
	H.status_flags &= ~(CANSTUN | CANWEAKEN | CANPARALYSE)
	return ..()

/mob/living/carbon/human/scp076
	real_name = "SCP-076"
	desc = "Lean Semitic man with strange tattoos all over the body"

/mob/living/carbon/human/scp076/atom_init(mapload)
	. = ..(mapload, "SCP-076")
	universal_speak = TRUE
	universal_understand = TRUE

	equip_to_slot_or_del(new /obj/item/clothing/under/scp076_pants(src), SLOT_W_UNIFORM)
	equip_to_slot_or_del(new /obj/item/clothing/suit/scp076_mantle(src), SLOT_WEAR_SUIT)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(src), SLOT_SHOES)
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/scp076_sword)


/mob/living/carbon/human/scp076/examine(mob/user)
	to_chat(user, "<b><span class = 'info'><big>SCP-076</big></span></b> - [desc]")
	return ..(user)

/mob/living/carbon/human/scp076/movement_delay()
	..()
	var/tally = species.speed_mod
	if(crawling)
		tally += 7
	if(buckled) // so, if we buckled we have large debuff
		tally += 5.5
	if(pull_debuff)
		tally += pull_debuff
	if(health-halloss <= 50)
		tally += 0.4
	if(health-halloss <= 0)
		tally += 0.4

	var/chem_nullify_debuff = FALSE
	if(!species.flags[NO_BLOOD] && ( reagents.has_reagent("hyperzine") || reagents.has_reagent("nuka_cola") )) // hyperzine removes equipment slowdowns (no blood = no chemical effects).
		chem_nullify_debuff = TRUE

	if(wear_suit && wear_suit.slowdown && !(wear_suit.slowdown > 0 && chem_nullify_debuff))
		tally += wear_suit.slowdown

	if(back && back.slowdown && !(back.slowdown > 0 && chem_nullify_debuff))
		tally += back.slowdown

	if(shoes && shoes.slowdown && !(shoes.slowdown > 0 && chem_nullify_debuff))
		tally += shoes.slowdown

	return (tally + config.human_delay)

/mob/living/carbon/human/scp076/eyecheck()
	return 2

/mob/living/carbon/human/scp076/IsAdvancedToolUser()
	return FALSE

/obj/item/clothing/under/scp076_pants
	name = "pants"

	icon = 'code/modules/SCP/SCP_076/clothing.dmi'
	icon_custom = 'code/modules/SCP/SCP_076/clothing.dmi'
	icon_state = "pants"
	item_state = "pants"
	item_color = "pants"

/obj/item/clothing/suit/scp076_mantle
	name = "mantle"

	icon = 'code/modules/SCP/SCP_076/clothing.dmi'
	icon_custom = 'code/modules/SCP/SCP_076/clothing.dmi'
	icon_state = "mantle"
	item_state = "mantle"
	item_color = "mantle"

/obj/item/weapon/melee/scp076_sword
	name = "blade"
	desc = "Completely black sword looking thing."
	icon = 'code/modules/SCP/SCP_076/clothing.dmi'
	icon_state = "sword"
	item_state = "sword"
	lefthand_file = 'code/modules/SCP/SCP_076/blade/left.dmi'
	righthand_file = 'code/modules/SCP/SCP_076/blade/right.dmi'
	flags = DROPDEL
	w_class = 5.0
	force = 25
	throwforce = 0
	throw_range = 0
	throw_speed = 0

/obj/item/weapon/melee/scp076_sword/dropped(mob/user)
	if(!QDELETED(src))
		qdel(src)

/obj/effect/proc_holder/spell/aoe_turf/scp076_sword
	name = "Materialize blade"
	desc = ""
	panel = "SCP"
	charge_max = 10
	clothes_req = 0
	range = 1

/obj/effect/proc_holder/spell/aoe_turf/scp076_sword/cast(list/targets)
	var/mob/living/carbon/human/H = usr

	if(H.is_busy(H) || H.restrained() || H.incapacitated())
		to_chat(H,"<span class='userdanger'>You can't materialize a blade while restrained</span>")
		return

	if(!H.unEquip(H.get_active_hand()))
		return

	H.visible_message("<span class='warning'>[H] materializes a completely black blade!</span>")
	var/obj/item/weapon/melee/scp076_sword/W = new /obj/item/weapon/melee/scp076_sword(H)
	H.put_in_active_hand(W)
