/obj/item/weapon/gun/energy/laser
	name = "laser rifle"
	desc = "a basic weapon designed kill with concentrated energy bolts."
	icon = 'icons/obj/gun.dmi'
	icon_state = "laser"
	item_state = null	//so the human update icon uses the icon_state instead.
	w_class = ITEM_SIZE_NORMAL
	m_amt = 2000
	origin_tech = "combat=3;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/laser)
	slot_flags = SLOT_FLAGS_BACK
	can_be_holstered = FALSE

/obj/item/weapon/gun/energy/laser/atom_init()
	. = ..()
	if(power_supply)
		power_supply.maxcharge = 1500
		power_supply.charge = 1500

/obj/item/weapon/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = 0

/obj/item/weapon/gun/energy/laser/classic
	name = "laser carbine"
	desc = "J10 carbine, pretty old model of corporate security laser weaponry with constant cooling issues. Faster firerate but reduced damage."
	icon_state = "oldlaser"
	icon_custom = null
	fire_delay = 5

/obj/item/weapon/gun/energy/laser/tactifool
	name = "laser rifle"
	desc = "T6 impulse laser rifle"
	icon_state = "lasor"
	icon_custom = null
	fire_delay = 0
	ammo_type = list(/obj/item/ammo_casing/energy/laser_pulse)


/obj/item/weapon/gun/energy/laser/classic/newshot()
	if (!ammo_type || !power_supply)	return
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if (!power_supply.use(shot.e_cost))	return
	chambered = shot
	if(chambered && chambered.BB)
		chambered.BB.damage -= 10
	chambered.newshot()
	return

/obj/item/weapon/gun/energy/laser/retro
	name ="retro laser"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	can_be_holstered = TRUE

/obj/item/weapon/gun/energy/laser/selfcharging
	var/charge_tick = 0
	var/chargespeed = 0

/obj/item/weapon/gun/energy/laser/selfcharging/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/weapon/gun/energy/laser/selfcharging/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/weapon/gun/energy/laser/selfcharging/process()
	charge_tick++
	if(charge_tick < 4) return 0
	charge_tick = 0
	if(!power_supply) return 0
	power_supply.give(100 * chargespeed)
	update_icon()
	return 1

/obj/item/weapon/gun/energy/laser/cyborg/newshot()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost))
				chambered = shot
				chambered.newshot()
	return

/obj/item/weapon/gun/energy/laser/selfcharging/captain
	name = "antique laser gun"
	icon_state = "caplaser"
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	force = 10
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = null
	can_be_holstered = TRUE
	chargespeed = 1

/obj/item/weapon/gun/energy/laser/selfcharging/alien
	name = "Alien blaster"
	icon_state = "egun"
	desc = " The object menaces with spikes of energy. You don't kmown what kind of weapon."
	force = 5
	origin_tech = null
	chargespeed = 2

/obj/item/weapon/gun/energy/laser/scatter
	name = "scatter laser gun"
	icon_state = "oldlaser"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	can_be_holstered = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/laser/scatter)

/obj/item/weapon/gun/energy/laser/scatter/attack_self(mob/living/user)
	..()
	update_icon()

/obj/item/weapon/gun/energy/laser/scatter/alien
	name = "scatter laser rife"
	icon_state = "subegun"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/laser/scatter)
	origin_tech = null

/obj/item/weapon/gun/energy/lasercannon
	name = "laser cannon"
	desc = "With the L.A.S.E.R. cannon, the lasing medium is enclosed in a tube lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core. This incredible technology may help YOU achieve high excitation rates with small laser volumes!"
	icon_state = "lasercannon"
	item_state = null
	origin_tech = "combat=4;materials=3;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/heavy)

	fire_delay = 20

/obj/item/weapon/gun/energy/lasercannon/cyborg/newshot()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost))
				chambered = shot
				chambered.newshot()
	return

/obj/item/weapon/gun/energy/xray
	name = "xray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated xray blasts."
	icon_state = "xray"
	item_state = null
	origin_tech = "combat=5;materials=3;magnets=2;syndicate=2"
	ammo_type = list(/obj/item/ammo_casing/energy/xray)

////////Laser Tag////////////////////

/obj/item/weapon/gun/energy/laser/lasertag
	name = "laser tag gun"
	icon_state = "retro"
	desc = "Standard issue weapon of the Imperial Guard."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/omnitag)
	origin_tech = "combat=1;magnets=2"
	clumsy_check = 0
	can_be_holstered = TRUE
	var/charge_tick = 0

	var/lasertag_color = "none"

/obj/item/weapon/gun/energy/laser/lasertag/special_check(mob/living/carbon/human/M)
	if(ishuman(M))
		if(istype(M.wear_suit, /obj/item/clothing/suit/lasertag))
			var/obj/item/clothing/suit/lasertag/L = M.wear_suit
			if(L.lasertag_color == lasertag_color)
				return ..()
		to_chat(M, "<span class='warning'>You need to be wearing your appropriate color laser tag vest!</span>")
	return 0

/obj/item/weapon/gun/energy/laser/lasertag/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/gun/energy/laser/lasertag/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/gun/energy/laser/lasertag/process()
	charge_tick++
	if(charge_tick < 4)
		return FALSE
	charge_tick = 0
	if(!power_supply)
		return FALSE
	power_supply.give(130)
	update_icon()
	return TRUE

/obj/item/weapon/gun/energy/laser/lasertag/bluetag
	fire_delay = 5
	icon_state = "bluetag"
	item_state = "l_tag_blue"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)
	lasertag_color = "blue"

/obj/item/weapon/gun/energy/laser/lasertag/redtag
	fire_delay = 5
	icon_state = "redtag"
	item_state = "l_tag_red"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)
	lasertag_color = "red"
