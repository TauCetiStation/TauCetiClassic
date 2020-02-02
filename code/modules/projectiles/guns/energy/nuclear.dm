/obj/item/weapon/gun/energy/gun
	name = "energy gun"
	desc = "A basic energy-based gun with two settings: Stun and kill."
	icon_state = "energytac"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/stun, /obj/item/ammo_casing/energy/laser)
	origin_tech = "combat=3;magnets=2"
	can_be_holstered = TRUE
	modifystate = 2

/obj/item/weapon/gun/energy/gun/attack_self(mob/living/user)
	..()
	update_icon()
	if(user.hand)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()

/obj/item/weapon/gun/energy/gun/head
	desc = "A basic energy-based gun with two settings: Stun and kill. This one has a grip made of wood."
	icon_state = "energy"

/obj/item/weapon/gun/energy/gun/carbine
	name = "energy carbine"
	desc = "A basic energy-based carbine with two settings: Stun and kill."
	icon = 'icons/obj/gun.dmi'
	icon_state = "ecar"
	icon_custom = null
	can_be_holstered = FALSE

/obj/item/weapon/gun/energy/gun/carbine/atom_init()
	. = ..()
	if(power_supply)
		power_supply.maxcharge = 1500
		power_supply.charge = 1500

/obj/item/weapon/gun/energy/gun/pistol
	icon = 'icons/obj/gun.dmi'
	icon_state = "egun"
	icon_custom = null
	fire_delay = 0
	ammo_type = list(/obj/item/ammo_casing/energy/stun, /obj/item/ammo_casing/energy/laser_pulse)

/obj/item/weapon/gun/energy/gun/nuclear
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	icon = 'icons/obj/gun.dmi'
	icon_state = "nucgun"
	origin_tech = "combat=3;materials=5;powerstorage=3"
	var/lightfail = 0
	var/charge_tick = 0
	modifystate = 0
	can_be_holstered = FALSE

/obj/item/weapon/gun/energy/gun/nuclear/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/weapon/gun/energy/gun/nuclear/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/weapon/gun/energy/gun/nuclear/process()
	charge_tick++
	if(charge_tick < 4) return 0
	charge_tick = 0
	if(!power_supply) return 0
	if((power_supply.charge / power_supply.maxcharge) != 1)
		if(!failcheck())	return 0
		power_supply.give(100)
		update_icon()
	return 1


/obj/item/weapon/gun/energy/gun/nuclear/proc/failcheck()
	lightfail = 0
	if (prob(src.reliability)) return 1 //No failure
	if (prob(src.reliability))
		for (var/mob/living/M in range(0,src)) //Only a minor failure, enjoy your radiation if you're in the same tile or carrying it
			if (src in M.contents)
				to_chat(M, "<span class='warning'>Your gun feels pleasantly warm for a moment.</span>")
			else
				to_chat(M, "<span class='warning'>You feel a warm sensation.</span>")
			M.apply_effect(rand(3,120), IRRADIATE)
		lightfail = 1
	else
		for (var/mob/living/M in range(rand(1,4),src)) //Big failure, TIME FOR RADIATION BITCHES
			if (src in M.contents)
				to_chat(M, "<span class='warning'>Your gun's reactor overloads!</span>")
			to_chat(M, "<span class='warning'>You feel a wave of heat wash over you.</span>")
			M.apply_effect(300, IRRADIATE)
		crit_fail = 1 //break the gun so it stops recharging
		STOP_PROCESSING(SSobj, src)
		update_icon()
	return 0

/obj/item/weapon/gun/energy/gun/nuclear/proc/update_charge()
	if (crit_fail)
		add_overlay("nucgun-whee")
		return
	var/ratio = power_supply.charge / power_supply.maxcharge
	ratio = CEIL(ratio * 4) * 25
	add_overlay("nucgun-[ratio]")

/obj/item/weapon/gun/energy/gun/nuclear/proc/update_reactor()
	if(crit_fail)
		add_overlay("nucgun-crit")
		return
	if(lightfail)
		add_overlay("nucgun-medium")
	else if ((power_supply.charge/power_supply.maxcharge) <= 0.5)
		add_overlay("nucgun-light")
	else
		add_overlay("nucgun-clean")

/obj/item/weapon/gun/energy/gun/nuclear/proc/update_mode()
	if (select == 1)
		add_overlay("nucgun-stun")
	else if (select == 2)
		add_overlay("nucgun-kill")

/obj/item/weapon/gun/energy/gun/nuclear/emp_act(severity)
	..()
	reliability -= round(15/severity)


/obj/item/weapon/gun/energy/gun/nuclear/update_icon()
	cut_overlays()
	update_charge()
	update_reactor()
	update_mode()
