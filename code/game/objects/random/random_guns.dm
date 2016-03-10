//GUNS RANDOM
/obj/random/handgun_security
	name = "Random Handgun"
	desc = "This is a random security sidearm."
	icon = 'icons/obj/gun.dmi'
	icon_state = "sigi250"
	item_to_spawn()
		return pick(prob(3);/obj/item/weapon/gun/projectile/sigi,\
					prob(1);/obj/item/weapon/gun/projectile/sigi/spec)

/obj/random/projectile_security
	name = "Random Projectile Weapon"
	desc = "This is a random security weapon."
	icon = 'icons/obj/gun.dmi'
	icon_state = "revolver"
	item_to_spawn()
		return pick(prob(3);/obj/item/weapon/gun/projectile/shotgun,\
					prob(1);/obj/item/weapon/gun/projectile/shotgun/combat)

/obj/random/energy_weapon
	name = "Random Energy Weapon"
	desc = "This is a random energy weapon."
	icon = 'icons/obj/gun.dmi'
	icon_state = "laser"
	item_to_spawn()
		return pick(prob(15);/obj/item/weapon/gun/energy/laser/retro,\
					prob(12);/obj/item/weapon/gun/energy/laser/practice,\
					prob(10);/obj/item/weapon/gun/energy/toxgun,\
					prob(10);/obj/item/weapon/gun/energy/laser,\
					prob(10);/obj/item/weapon/gun/energy/taser,\
					prob(8);/obj/item/weapon/gun/energy/ionrifle,\
					prob(4);/obj/item/weapon/gun/projectile/automatic/l10c,\
					prob(4);/obj/item/weapon/gun/energy/xray,\
					prob(4);/obj/item/weapon/gun/energy/gun,\
					prob(4);/obj/item/weapon/gun/energy/decloner,\
					prob(4);/obj/item/weapon/gun/energy/mindflayer,\
					prob(3);/obj/item/weapon/gun/energy/laser/captain,\
					prob(3);/obj/item/weapon/gun/energy/sniperrifle,\
					prob(3);/obj/item/weapon/gun/energy/gun/nuclear,\
					prob(2);/obj/item/weapon/gun/energy/pulse_rifle,\
					prob(2);/obj/item/weapon/gun/energy/crossbow,\
					prob(1);/obj/item/weapon/gun/energy/pulse_rifle/M1911,\
					prob(1);/obj/item/weapon/gun/energy/laser/captain)

/obj/random/projectile_handgun
	name = "Random Handgun"
	desc = "This is a random energy weapon."
	icon = 'icons/obj/gun.dmi'
	icon_state = "revolver"
	item_to_spawn()
		return pick(prob(15);/obj/item/weapon/gun/projectile/sigi,\
					prob(15);/obj/item/weapon/gun/projectile/automatic/pistol,\
					prob(15);/obj/item/weapon/gun/projectile/automatic/colt1911,\
					prob(15);/obj/item/weapon/gun/projectile/automatic/luger,\
					prob(15);/obj/item/weapon/gun/projectile/automatic/silenced,\
					prob(15);/obj/item/weapon/gun/projectile/revolver/peacemaker,\
					prob(15);/obj/item/weapon/gun/projectile/revolver/detective,\
					prob(9);/obj/item/weapon/gun/projectile/automatic/silenced/nonlethal,\
					prob(9);/obj/item/weapon/gun/projectile/revolver/syndie,\
					prob(9);/obj/item/weapon/gun/projectile/revolver,\
					prob(9);/obj/item/weapon/gun/projectile/automatic/deagle,\
					prob(2);/obj/item/weapon/gun/projectile/automatic/gyropistol,\
					prob(2);/obj/item/weapon/gun/projectile/sigi/spec,\
					prob(2);/obj/item/weapon/gun/projectile/automatic/deagle/gold,\
					prob(2);/obj/item/weapon/gun/projectile/revolver/mateba)

/obj/random/projectile_shotgun
	name = "Random Shotgun"
	desc = "This is a random shotgun."
	icon = 'icons/obj/gun.dmi'
	icon_state = "shotgun"
	item_to_spawn()
		return pick(prob(20);/obj/item/weapon/gun/projectile/revolver/doublebarrel,\
					prob(15);/obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon/sawn_off,\
					prob(10);/obj/item/weapon/gun/projectile/shotgun,\
					prob(7);/obj/item/weapon/gun/projectile/shotgun/combat,\
					prob(5);/obj/item/weapon/gun/projectile/automatic/bulldog)

/obj/random/projectile_assault
	name = "Random Shotgun"
	desc = "This is a random shotgun."
	icon = 'icons/obj/gun.dmi'
	icon_state = "shotgun"
	item_to_spawn()
		return pick(prob(15);/obj/item/weapon/gun/projectile/shotgun/bolt_action,\
					prob(15);/obj/item/weapon/gun/projectile/shotgun/repeater,\
					prob(15);/obj/item/weapon/gun/projectile/automatic,\
					prob(14);/obj/item/weapon/gun/projectile/automatic/c20r,\
					prob(12);/obj/item/weapon/gun/projectile/automatic/mini_uzi,\
					prob(10);/obj/item/weapon/gun/projectile/automatic/bar,\
					prob(8);/obj/item/weapon/gun/projectile/automatic/tommygun,\
					prob(8);/obj/item/weapon/gun/projectile/automatic/a28,\
					prob(8);/obj/item/weapon/gun/projectile/automatic/a28/nonlethal,\
					prob(5);/obj/item/weapon/gun/projectile/heavyrifle,\
					prob(5);/obj/item/weapon/gun/projectile/automatic/l6_saw)

/obj/random/projectile_grenade
	name = "Random Grenade Launcher"
	desc = "This is a random shotgun."
	icon = 'icons/obj/gun.dmi'
	icon_state = "riotgun"
	item_to_spawn()
		return pick(prob(6);/obj/item/weapon/gun/grenadelauncher,\
					prob(1);/obj/item/weapon/gun/projectile/revolver/rocketlauncher,\
					prob(3);/obj/item/weapon/gun/projectile/m79)

/obj/random/weapon_item
	name = "Random Weapon"
	desc = "This is a random weapon."
	icon = 'icons/obj/gun.dmi'
	icon_state = "saber-18"
	item_to_spawn()
		return pick(prob(100);/obj/random/energy_weapon,\
					prob(70);/obj/random/projectile_handgun,\
					prob(50);/obj/random/projectile_assault,\
					prob(30);/obj/random/projectile_shotgun,\
					prob(10);/obj/random/projectile_grenade)