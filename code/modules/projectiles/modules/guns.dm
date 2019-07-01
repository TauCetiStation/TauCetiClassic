//////////////////////LASER

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/laser
	name = "laser rifle"
	desc = "a basic weapon designed kill with concentrated energy bolts."
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/large/laser_rifle
	grip_type = /obj/item/modular/grip/rifle
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/laser)
	all_accessory = list()

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/large/laser_rifle
	grip_type = /obj/item/modular/grip/rifle
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/laser/practice)
	all_accessory = list()
	clumsy_check = 0

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/laser/classic
	name = "laser carbine"
	desc = "J10 carbine, pretty old model of corporate security laser weaponry with constant cooling issues. Faster firerate but reduced damage."
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/medium/laser_pistol
	grip_type = /obj/item/modular/grip/resilient
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/laser)
	all_accessory = list(/obj/item/modular/accessory/optical/small)
	lessdamage = 6
	fire_delay = 14

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/laser/tactifool
	name = "laser rifle"
	desc = "T6 impulse laser rifle"
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/large/laser_rifle
	grip_type = /obj/item/modular/grip/rifle
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/laser_pulse)
	all_accessory = list()
	fire_delay = 12

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/laser/retro
	name = "retro laser"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/medium/laser_pistol
	grip_type = /obj/item/modular/grip
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/laser)
	all_accessory = list()

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/laser/selfcharging/captain
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/medium/laser_pistol
	grip_type = /obj/item/modular/grip/weighted
	magazine_module_type = /obj/item/weapon/stock_parts/cell/super
	lens1 = list(/obj/item/ammo_casing/energy/laser)
	all_accessory = list(/obj/item/modular/accessory/additional_battery)
	selfrecharging = TRUE
	force = 10
	origin_tech = null
	chargespeed = 1
	isHandgun = TRUE

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/laser/scatter
	name = "scatter laser gun"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	chamber_type = /obj/item/modular/chamber/lasershotgun
	barrel_type = /obj/item/modular/barrel/large/laser_rifle
	grip_type = /obj/item/modular/grip/shotgun
	magazine_module_type = /obj/item/weapon/stock_parts/cell/super
	lens1 = list(/obj/item/ammo_casing/energy/laser)
	all_accessory = list()

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/lasercannon
	name = "laser cannon"
	desc = "With the L.A.S.E.R. cannon, the lasing medium is enclosed in a tube lined with uranium-235 and subjected to high neutron flux in a nuclear reactor core. This incredible technology may help YOU achieve high excitation rates with small laser volumes!"
	origin_tech = "combat=4;materials=3;powerstorage=3"
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/large/laser_rifle
	grip_type = /obj/item/modular/grip/rifle
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/laser/heavy)
	all_accessory = list(/obj/item/modular/accessory/additional_battery)
	fire_delay = 20

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/xray
	name = "xray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated xray blasts."
	origin_tech = "combat=5;materials=3;magnets=2;syndicate=2"
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/large/laser_rifle
	grip_type = /obj/item/modular/grip/resilient
	magazine_module_type = /obj/item/weapon/stock_parts/cell/super
	lens1 = list(/obj/item/ammo_casing/energy/xray)
	all_accessory = list(/obj/item/modular/accessory/additional_battery)

/obj/item/weapon/gun/projectile/modulargun/auto_gun/laser/bluetag
	name = "laser tag gun blue"
	desc = "Standard issue weapon of the Imperial Guard."
	origin_tech = "combat=1;magnets=2"
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/medium
	grip_type = /obj/item/modular/grip/rifle
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/laser/bluetag)
	all_accessory = list()
	clumsy_check = 0
	charge_tick = 0

/obj/item/weapon/gun/projectile/modulargun/auto_gun/laser/bluetag/special_check(mob/living/carbon/human/M)
	if(ishuman(M))
		if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
			return ..()
		to_chat(M, "\red You need to be wearing your laser tag vest!")
	return 0

/obj/item/weapon/gun/projectile/modulargun/auto_gun/laser/bluetag/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/weapon/gun/projectile/modulargun/auto_gun/laser/bluetag/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/gun/projectile/modulargun/auto_gun/laser/bluetag/process()
	charge_tick++
	if(charge_tick < 4) return 0
	charge_tick = 0
	if(!power_supply) return 0
	power_supply.give(100)
	update_icon()
	return 1

/obj/item/weapon/gun/projectile/modulargun/auto_gun/laser/redtag
	name = "laser tag gun red"
	desc = "Standard issue weapon of the Imperial Guard."
	origin_tech = "combat=1;magnets=2"
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/medium
	grip_type = /obj/item/modular/grip/rifle
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/laser/redtag)
	all_accessory = list()
	clumsy_check = 0
	charge_tick = 0

/obj/item/weapon/gun/projectile/modulargun/auto_gun/laser/redtag/special_check(mob/living/carbon/human/M)
	if(ishuman(M))
		if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
			return ..()
		to_chat(M, "\red You need to be wearing your laser tag vest!")
	return 0

/obj/item/weapon/gun/projectile/modulargun/auto_gun/laser/redtag/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/weapon/gun/projectile/modulargun/auto_gun/laser/redtag/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/gun/projectile/modulargun/auto_gun/laser/redtag/process()
	charge_tick++
	if(charge_tick < 4) return 0
	charge_tick = 0
	if(!power_supply) return 0
	power_supply.give(100)
	update_icon()
	return 1


////////////////////////////PULSE

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/pulse_rifle
	name = "pulse rifle"
	desc = "A heavy-duty, pulse-based energy weapon, preferred by front-line combat personnel."
	force = 10
	chamber_type = /obj/item/modular/chamber/triolas
	barrel_type = /obj/item/modular/barrel/large/laser_rifle
	grip_type = /obj/item/modular/grip/rifle
	magazine_module_type = /obj/item/weapon/stock_parts/cell/super
	lens1 = list(/obj/item/ammo_casing/energy/laser/pulse, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	all_accessory = list(/obj/item/modular/accessory/additional_battery)
	fire_delay = 25

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/pulse_rifle/destroyer
	name = "pulse destroyer"
	desc = "A heavy-duty, pulse-based energy weapon."
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/large/laser_rifle
	grip_type = /obj/item/modular/grip/rifle
	magazine_module_type = /obj/item/weapon/stock_parts/cell/infinite
	lens1 = list(/obj/item/ammo_casing/energy/laser/pulse)
	all_accessory = list(/obj/item/modular/accessory/additional_battery)

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/pulse_rifle/M1911
	name = "m1911-P"
	desc = "It's not the size of the gun, it's the size of the hole it puts through people."
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/large/laser_rifle
	grip_type = /obj/item/modular/grip/rifle
	magazine_module_type = /obj/item/weapon/stock_parts/cell/infinite
	lens1 = list(/obj/item/ammo_casing/energy/laser/pulse)
	all_accessory = list(/obj/item/modular/accessory/additional_battery)
	isHandgun = TRUE

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats."
	origin_tech = "combat=2;magnets=4"
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/large/laser_rifle
	grip_type = /obj/item/modular/grip/resilient
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/ion)
	all_accessory = list()

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/ionrifle/classic
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats."
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/medium/laser_pistol
	grip_type = /obj/item/modular/grip/rifle
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/ion)
	all_accessory = list()

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	origin_tech = "combat=5;materials=4;powerstorage=3"
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/medium/laser_pistol
	grip_type = /obj/item/modular/grip/resilient
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/declone)
	all_accessory = list()

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	origin_tech = "materials=2;biotech=3;powerstorage=3"
	chamber_type = /obj/item/modular/chamber/duolas
	barrel_type = /obj/item/modular/barrel/medium/laser_pistol
	grip_type = /obj/item/modular/grip
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/flora/mut, /obj/item/ammo_casing/energy/flora/yield)
	all_accessory = list()
	selfrecharging = TRUE

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/mindflayer
	name = "mind flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/medium/laser_pistol
	grip_type = /obj/item/modular/grip/weighted
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/mindflayer)
	all_accessory = list()

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/toxgun
	name = "phoron pistol"
	desc = "A specialized firearm designed to fire lethal bolts of phoron."
	origin_tech = "combat=5;phorontech=4"
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/medium/laser_pistol
	grip_type = /obj/item/modular/grip/weighted
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/toxin)
	all_accessory = list(/obj/item/modular/accessory/additional_battery)

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/sniperrifle
	name = "sniper rifle"
	desc = "Designed by W&J Company, W2500-E sniper rifle constructed of lightweight materials, fitted with a SMART aiming-system scope."
	origin_tech = "combat=6;materials=5;powerstorage=4"
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/large
	grip_type = /obj/item/modular/grip/rifle
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/sniper)
	all_accessory = list(/obj/item/modular/accessory/additional_battery, /obj/item/modular/accessory/optical/large)
	fire_delay = 30
	var/zoom = FALSE

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/sniperrifle/rails
	name = "Rails rifle"
	desc = "With this weapon you'll be the boss at any Arena."
	origin_tech = "combat=6;materials=5;powerstorage=4"
	chamber_type = /obj/item/modular/chamber/laser
	barrel_type = /obj/item/modular/barrel/large
	grip_type = /obj/item/modular/grip/rifle
	magazine_module_type = /obj/item/weapon/stock_parts/cell/high
	lens1 = list(/obj/item/ammo_casing/energy/rails)
	all_accessory = list(/obj/item/modular/accessory/additional_battery, /obj/item/modular/accessory/optical/large)
	origin_tech = null
	fire_delay = 20

////////////////////STUN

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/taser
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	chamber_type = /obj/item/modular/chamber/duolas
	barrel_type = /obj/item/modular/barrel/medium/laser_pistol
	grip_type = /obj/item/modular/grip
	magazine_module_type = /obj/item/weapon/stock_parts/cell/crap
	lens1 = list(/obj/item/ammo_casing/energy/stun, /obj/item/ammo_casing/energy/electrode)
	all_accessory = list()

/obj/item/weapon/gun/projectile/modulargun/auto_gun/energy/stunrevolver
	name = "stun revolver"
	desc = "A high-tech revolver that fires stun cartridges. The stun cartridges can be recharged using a conventional energy weapon recharger."
	origin_tech = "combat=3;materials=3;powerstorage=2"
	chamber_type = /obj/item/modular/chamber/duolas
	barrel_type = /obj/item/modular/barrel/medium/laser_pistol
	grip_type = /obj/item/modular/grip
	magazine_module_type = /obj/item/weapon/stock_parts/cell
	lens1 = list(/obj/item/ammo_casing/energy/stun, /obj/item/ammo_casing/energy/electrode)


