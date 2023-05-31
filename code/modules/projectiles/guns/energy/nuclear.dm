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
	update_inv_mob()

/obj/item/weapon/gun/energy/gun/head
	desc = "A basic energy-based gun with two settings: Stun and kill. This one has a grip made of wood."
	icon_state = "energy"

/obj/item/weapon/gun/energy/gun/hos
	name = "\"Revenant\" Energy Advanced Pistol"
	desc = "Feat of weapon engineering, this pistol is able to fire taser bolts, lasers and EMP bursts. Only issued to high-ranking members of security teams."
	icon_state = "hosgun"
	ammo_type = list(/obj/item/ammo_casing/energy/stun, /obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/ion/small)
	origin_tech = "combat=4;magnets=3"

/obj/item/weapon/gun/energy/gun/adv
	name = "Energy Gun Mark II"
	desc = "The latest model of energy weapons. New, cutting edge design features improved cooling system and internal battery."
	icon_state = "advgun"
	origin_tech = "combat=6;magnets=5;powerstorage=2;syndicate=1"
	fire_delay = 4

/obj/item/weapon/gun/energy/gun/adv/atom_init()
	. = ..()
	if(power_supply)
		power_supply.maxcharge = 1500
		power_supply.charge = 1500

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
		irradiate_in_dist(get_turf(src), rand(3, 120), 0)
		lightfail = 1
	else
		irradiate_in_dist(get_turf(src), 300, rand(1, 4))
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
