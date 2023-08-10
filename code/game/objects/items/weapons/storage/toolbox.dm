/obj/item/weapon/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon = 'icons/obj/storage.dmi'
	icon_state = "red"
	item_state = "toolbox_red"
	flags = CONDUCT
	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 7

	w_class = SIZE_NORMAL
	max_w_class = SIZE_SMALL
	max_storage_space = DEFAULT_BOX_STORAGE + 3 // fits all tools and around 2 extra items

	origin_tech = "combat=1"
	hitsound = list('sound/items/tools/toolbox-hit.ogg')
	attack_verb = list("robusted")

/obj/item/weapon/storage/toolbox/atom_init()
	. = ..()
	if (src.type == /obj/item/weapon/storage/toolbox)
		to_chat(world, "BAD: [src] ([type]) spawned at [COORD(src)]")
		return INITIALIZE_HINT_QDEL

/obj/item/weapon/storage/toolbox/attack(mob/living/M, mob/living/user, def_zone)
	if(!..())
		return
	//Clumsy used only for dna-handlers
	if(!iscarbon(M))
		return
	if(def_zone != BP_HEAD)
		return
	var/mob/living/carbon/C = M
	var/amount_of_effect = 4
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		var/obj/item/organ/external/head = H.get_bodypart(def_zone)
		var/armor = H.getarmor(head, MELEE)
		amount_of_effect = max((100 - armor) / 25, 1)
	var/datum/status_effect/clumsy/S = C.has_status_effect(STATUS_EFFECT_CLUMSY)
	if(!S)
		C.AdjustClumsyStatus(amount_of_effect)
		return
	S.applied_times++
	var/duration_calculate = round(amount_of_effect / S.applied_times) SECONDS
	S.duration += duration_calculate

/obj/item/weapon/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	item_state = "toolbox_red"

/obj/item/weapon/storage/toolbox/emergency/atom_init()
	. = ..()
	new /obj/item/weapon/crowbar/red(src)
	new /obj/item/weapon/reagent_containers/spray/extinguisher/mini/station_spawned(src)
	if(prob(50))
		new /obj/item/device/flashlight(src)
	else
		new /obj/item/device/flashlight/flare(src)
	new /obj/item/device/radio(src)
	new /obj/item/weapon/storage/fancy/glowsticks(src) //Gloooouuuwstiicks :3

/obj/item/weapon/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"

/obj/item/weapon/storage/toolbox/mechanical/atom_init()
	. = ..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/weapon/wirecutters(src)

/obj/item/weapon/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	item_state = "toolbox_yellow"

/obj/item/weapon/storage/toolbox/electrical/atom_init()
	. = ..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/t_scanner(src)
	new /obj/item/weapon/crowbar(src)
	for (var/i in 1 to 2)
		new /obj/item/stack/cable_coil/random(src)
	if(prob(5))
		new /obj/item/clothing/gloves/insulated(src)
	else
		new /obj/item/stack/cable_coil/random(src)

/obj/item/weapon/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	origin_tech = "combat=1;syndicate=1"
	force = 7.0

/obj/item/weapon/storage/toolbox/syndicate/atom_init()
	. = ..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool/largetank(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/multitool(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/glasses/welding(src)
