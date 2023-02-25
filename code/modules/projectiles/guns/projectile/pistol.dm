/obj/item/weapon/gun/projectile/automatic/silenced
	name = "silenced pistol"
	desc = "A small, quiet,  easily concealable gun. Uses .45 rounds."
	icon_state = "silenced_pistol"
	item_state = "gun"
	w_class = SIZE_SMALL
	silenced = 1
	origin_tech = "combat=2;materials=2;syndicate=8"
	initial_mag = /obj/item/ammo_box/magazine/sm45
	fire_sound = 'sound/weapons/guns/gunshot_silencer.ogg'
	can_be_holstered = TRUE

/obj/item/weapon/gun/projectile/automatic/glock
	name = "G17"
	desc = "Semi-automatic service pistol of 9x19mm cal. Designed for professionals."
	icon_state = "9mm_glock"
	item_state = "9mm_glock"
	origin_tech = "combat=2;materials=2"
	initial_mag = /obj/item/ammo_box/magazine/m9mm_2/rubber
	suitable_mags = list(/obj/item/ammo_box/magazine/m9mm_2, /obj/item/ammo_box/magazine/m9mm_2/rubber)
	fire_sound = 'sound/weapons/guns/gunshot_light.ogg'
	can_be_holstered = TRUE

/obj/item/weapon/gun/projectile/automatic/glock/spec
	name = "G17 GEN3"
	icon_state = "9mm_glock_spec"
	item_state = "9mm_glock_spec"

/obj/item/weapon/gun/projectile/automatic/deagle
	name = "desert eagle"
	desc = "A robust handgun that uses .50 AE ammo."
	icon_state = "deagle"
	item_state = "deagle"
	force = 14.0
	initial_mag = /obj/item/ammo_box/magazine/m50
	suitable_mags = list(/obj/item/ammo_box/magazine/m50, /obj/item/ammo_box/magazine/m50/weakened)
	can_be_holstered = TRUE
	fire_sound = 'sound/weapons/guns/gunshot_heavy.ogg'

/obj/item/weapon/gun/projectile/automatic/deagle/gold
	desc = "A gold plated gun folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/weapon/gun/projectile/automatic/deagle/weakened
	initial_mag = /obj/item/ammo_box/magazine/m50/weakened

/obj/item/weapon/gun/projectile/automatic/deagle/weakened/gold
	desc = "A gold plated gun folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/weapon/gun/projectile/automatic/pistol
	name = "Stechkin pistol"
	desc = "A small, easily concealable gun. Uses 9mm rounds."
	icon_state = "stechkin"
	item_state = "9mm_glock"
	w_class = SIZE_TINY
	silenced = FALSE
	origin_tech = "combat=2;materials=2;syndicate=2"
	can_be_holstered = TRUE
	initial_mag = /obj/item/ammo_box/magazine/m9mm
	suitable_mags = list(/obj/item/ammo_box/magazine/m9mm, /obj/item/ammo_box/magazine/m9mm/ex)
	can_be_silenced = TRUE

/obj/item/weapon/gun/projectile/automatic/colt1911
	desc = "A cheap Martian knock-off of a Colt M1911. Uses less-than-lethal .45 rounds."
	name = "Colt M1911"
	icon_state = "colt"
	item_state = "colt"
	w_class = SIZE_SMALL
	initial_mag = /obj/item/ammo_box/magazine/c45m/rubber
	suitable_mags = list(/obj/item/ammo_box/magazine/c45m/rubber, /obj/item/ammo_box/magazine/c45m)
	can_be_holstered = TRUE
	fire_sound = 'sound/weapons/guns/gunshot_colt1911.ogg'

/obj/item/weapon/gun/projectile/automatic/colt1911/dungeon
	desc = "A single-action, semi-automatic, magazine-fed, recoil-operated pistol chambered for the .45 ACP cartridge."
	name = "Colt M1911"
	initial_mag = /obj/item/ammo_box/magazine/c45m

/obj/item/weapon/gun/projectile/revolver/doublebarrel/derringer
	name = "Derringer"
	desc = "A small pocket pistol and your best friend. Manufactured by Hephaestus Industries without much changes from the earliest designs. Chambered in .38."
	icon_state = "derringer"
	item_state = null
	w_class = SIZE_TINY
	two_hand_weapon = FALSE
	force = 2
	flags =  CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "combat=1;materials=1"
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/dualshot/derringer
	can_be_holstered = TRUE
	can_be_shortened = FALSE
	fire_sound = 'sound/weapons/guns/gunshot_derringer.ogg'
	recoil = 2

/obj/item/weapon/gun/projectile/revolver/doublebarrel/derringer/syndicate
	name = "Opressor"
	desc = "Issued to Syndicate agents who aren't really valuable to HQ. Atleast the name sounds badass. Chambered in .357 Magnum."
	icon_state = "synderringer"
	force = 5
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/dualshot/derringer/syndicate
	recoil = 3
	fire_sound = 'sound/weapons/guns/gunshot_heavy.ogg'
