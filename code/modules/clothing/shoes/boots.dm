/obj/item/clothing/shoes/boots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "wjboots"
	item_state = "wjboots"
	siemens_coefficient = 0.7
	var/obj/item/knife

/obj/item/clothing/shoes/boots/Destroy()
	QDEL_NULL(knife)
	return ..()

/obj/item/clothing/shoes/boots/attack_hand(mob/living/user)
	if(knife && loc == user && !user.incapacitated())
		if(user.put_in_active_hand(knife))
			playsound(user, 'sound/effects/throat_cutting.ogg', VOL_EFFECTS_MASTER, 25)
			to_chat(user, "<span class='notice'>You slide [knife] out of [src].</span>")
			remove_knife()
			if(icon_state == "wjbootsknifed")
				icon_state = "wjboots"
				user.update_inv_shoes()
			update_icon()
	else
		return ..()

/obj/item/clothing/shoes/boots/attackby(obj/item/I, mob/user, params)
	if(knife)
		return ..()

	if(I.get_quality(QUALITY_CUTTING) > 0)
		user.drop_from_inventory(I, src)
		playsound(user, 'sound/items/lighter.ogg', VOL_EFFECTS_MASTER, 25)
		to_chat(user, "<span class='notice'>You slide [I] into [src].</span>")
		add_knife(I)
		if(icon_state == "wjboots")
			icon_state = "wjbootsknifed"
			user.update_inv_shoes()
		update_icon()
		return

	return ..()

/obj/item/clothing/shoes/boots/proc/add_knife(obj/item/K)
	knife = K
	RegisterSignal(knife, list(COMSIG_PARENT_QDELETING), .proc/remove_knife)

/obj/item/clothing/shoes/boots/proc/remove_knife()
	UnregisterSignal(knife, list(COMSIG_PARENT_QDELETING))
	knife = null

/obj/item/clothing/shoes/boots/wizard

/obj/item/clothing/shoes/boots/wizard/atom_init(mapload, ...)
	. = ..()
	AddComponent(/datum/component/magic_item/wizard)

/obj/item/clothing/shoes/boots/galoshes
	desc = "Rubber boots."
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	flags = NOSLIP
	slowdown = SHOES_SLOWDOWN + 0.5
	species_restricted = null

/obj/item/clothing/shoes/boots/work
	name = "work boots"
	desc = "Boots of a simple working man."
	icon_state = "workboots"
	item_state = "b_shoes"  // need sprites for this

/obj/item/clothing/shoes/boots/swat
	name = "SWAT shoes"
	desc = "When you want to turn up the heat."
	icon_state = "swat"
	flags = NOSLIP
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/boots/combat //Basically SWAT shoes combined with galoshes.
	name = "combat boots"
	desc = "When you REALLY want to turn up the heat"
	icon_state = "swat"
	flags = NOSLIP
	siemens_coefficient = 0.6

	cold_protection = LEGS
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = LEGS
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/boots/cult
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	item_state = "cult"

	cold_protection = LEGS
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = LEGS
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = null

/obj/item/clothing/shoes/boots/police
	desc = "Nanotrasen-issue police combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "police_boots"
	item_state = "wjboots"
	siemens_coefficient = 0.7

#define UNEQUIP_TIMER_LOWEST 10 SECONDS
#define UNEQUIP_TIMER_HIGHEST 30 SECONDS

/obj/item/clothing/shoes/boots/work/jak
	name = "Boots of Springheel Jak"
	desc = "A pair of some old boots."
	slowdown = -2.0 //because we don't have acrobatics skill
	var/unequip_timer

/obj/item/clothing/shoes/boots/work/jak/proc/try_unequip(mob/living/carbon/user, slot)
	unequip_timer = null
	if(user?.shoes != src)
		return
	user.unEquip(src, TRUE)
	user.visible_message("<span class='notice'>[name] flies off \the [user] feet.", "<span class='notice'>[name] slips off your feet</span>")
	throw_at(get_step(user, user.dir), 6, 5)
	user.Stun(1)
	user.Weaken(3)

/obj/item/clothing/shoes/boots/work/jak/proc/on_equip(datum/source, mob/living/carbon/user, slot)
	SIGNAL_HANDLER

	if(slot != SLOT_SHOES)
		return
	if(iswizard(user) || iswizardapprentice(user))
		deltimer(unequip_timer)
		return
	if(unequip_timer)
		return
	unequip_timer = addtimer(CALLBACK(src, .proc/try_unequip, user, slot), rand(UNEQUIP_TIMER_LOWEST, UNEQUIP_TIMER_HIGHEST), TIMER_STOPPABLE)

/obj/item/clothing/shoes/boots/work/jak/atom_init(mapload, ...)
	. = ..()
	AddComponent(/datum/component/magic_item/wizard)
	RegisterSignal(src, list(COMSIG_ITEM_EQUIPPED), .proc/on_equip)

/obj/item/clothing/shoes/boots/work/jak/Destroy()
	deltimer(unequip_timer)
	UnregisterSignal(src, COMSIG_ITEM_EQUIPPED)
	return ..()

#undef UNEQUIP_TIMER_LOWEST
#undef UNEQUIP_TIMER_HIGHEST
