/obj/item/weapon/gun/energy/dubstep
	name = "dubstep gun"
	desc = "Experemental gun fires long-range pulses of energy to the beat of an electronic song."
	icon = 'icons/obj/gun.dmi'
	icon_state = "dubstep"
	item_state = "nucgun"
	w_class = 3.0
	m_amt = 3000
	origin_tech = "combat=3;magnets=3;biotech=3"
	ammo_type = list(/obj/item/ammo_casing/energy/dubstep)
	fire_delay = 35
	var/sound_delay = 60
	var/last_scan_time = 0
	var/message = "WUB DA BUP"


/obj/item/weapon/gun/energy/dubstep/New()
	..()
	if(power_supply)
		power_supply.maxcharge = 3000
		power_supply.charge = 3000


/obj/item/weapon/gun/energy/dubstep/isHandgun()
	return 0

/obj/item/weapon/gun/energy/dubstep/attack_self(mob/user)
	if(world.time - last_scan_time >= sound_delay)
		message = "WUB DA BUP"
		playsound(user, pick('sound/weapons/dubstep1.ogg', 'sound/weapons/dubstep2.ogg', 'sound/weapons/dubstep3.ogg', 'sound/weapons/dubstep4.ogg'), 100)
		last_scan_time = world.time
	else
		message = "Dubstep gun is recharging."

	to_chat(user, "<span class='info'>[message]</span>")
