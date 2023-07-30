
/datum/outfit/deathmatch/tea_drinker
	name = "Tea Drinker"
	uniform = /obj/item/clothing/under/lawyer/oldman
	shoes = /obj/item/clothing/shoes/leather
	back = PREFERENCE_BACKPACK
	survival_box = FALSE
	backpack_contents = list()

////////////////////////////////////////////////////
//BLUE TEAM
////////////////////////////////////////////////////

/datum/outfit/deathmatch/blue_team
	mask = /obj/item/clothing/mask/scarf/blue
	uniform = /obj/item/clothing/under/color/blue
	shoes = /obj/item/clothing/shoes/blue
	gloves = /obj/item/clothing/gloves/fingerless/blue
	implants = list(/obj/item/weapon/implant/dexplosive)
	survival_box = FALSE

/datum/outfit/deathmatch/blue_team/leader
	name = "Blue Team Leader"
	suit = /obj/item/clothing/suit/dutch
	head = /obj/item/clothing/head/beret/black
	back = PREFERENCE_BACKPACK
	l_hand = /obj/item/weapon/gun/projectile/automatic/pistol/deagle/weakened/gold
	r_hand = /obj/item/device/megaphone
	l_pocket = /obj/item/weapon/shield/energy
	backpack_contents = list(
        /obj/item/weapon/gun/energy/laser/selfcharging/captain,
        /obj/item/ammo_box/magazine/deagle/weakened,
        /obj/item/ammo_box/magazine/deagle/weakened,
		/obj/item/ammo_box/magazine/deagle/weakened,
		/obj/item/ammo_box/magazine/deagle/weakened,
        /obj/item/ammo_box/magazine/deagle/weakened
        )

/datum/outfit/deathmatch/blue_team/medic
	name = "Blue Team Medic"
	suit = /obj/item/clothing/suit/storage/labcoat/blue
	head = /obj/item/clothing/head/surgery/blue
	back = PREFERENCE_BACKPACK
	r_hand = /obj/item/weapon/gun/medbeam
	backpack_contents = list(
		/obj/item/weapon/storage/firstaid/tactical,
		/obj/item/weapon/gun/projectile/automatic/pistol/wjpp/lethal,
		/obj/item/ammo_box/magazine/wjpp,
		/obj/item/ammo_box/magazine/wjpp,
		/obj/item/ammo_box/magazine/wjpp,
		/obj/item/weapon/circular_saw/alien
	)

/datum/outfit/deathmatch/blue_team/sniper
	name = "Blue Team Sniper"
	suit = /obj/item/clothing/suit/serifcoat
	head = /obj/item/clothing/head/western/cowboy
	back = /obj/item/weapon/gun/energy/sniperrifle
	belt = /obj/item/weapon/storage/pouch/pistol_holster/stechkin
	l_pocket = /obj/item/ammo_box/magazine/stechkin/extended
	r_pocket = /obj/item/ammo_box/magazine/stechkin/extended

/datum/outfit/deathmatch/blue_team/scout
	name = "Blue Team Scout"
	suit = /obj/item/clothing/suit/storage/miljacket_army
	head = /obj/item/clothing/head/ushanka/black_white
	shoes = /obj/item/clothing/shoes/boots/work/jak
	back = PREFERENCE_BACKPACK
	r_hand = /obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon/sawn_off
	l_hand = /obj/item/weapon/kitchenknife/combat
	backpack_contents = list(
		/obj/item/ammo_box/eight_shells,
		/obj/item/ammo_box/eight_shells,
		/obj/item/ammo_box/eight_shells/buckshot,
		/obj/item/ammo_box/eight_shells/buckshot
	)

/obj/item/weapon/gun/projectile/automatic/tommygun/deathmatch
	slot_flags = SLOT_FLAGS_BELT

/obj/item/weapon/shovel/deathmatch
	force = 20

/datum/outfit/deathmatch/blue_team/soldier
	name = "Blue Team Soldier"
	suit = /obj/item/clothing/suit/storage/postal_dude_coat
	head = /obj/item/clothing/head/soft/nt_pmc_cap
	back = PREFERENCE_BACKPACK
	r_hand = /obj/item/weapon/gun/projectile/automatic/tommygun/deathmatch
	backpack_contents = list(
		/obj/item/ammo_box/magazine/tommygun,
		/obj/item/ammo_box/magazine/tommygun,
        /obj/item/ammo_box/magazine/tommygun,
		/obj/item/weapon/shovel/deathmatch
    )

/datum/outfit/deathmatch/blue_team/pirate
	name = "Blue Team Pirate"
	suit = /obj/item/clothing/suit/pirate
	head = /obj/item/clothing/head/pirate
	back = PREFERENCE_BACKPACK
	r_hand = /obj/item/weapon/melee/energy/sword/blue
	backpack_contents = list(
		/obj/item/weapon/implanter/adrenaline,
		/obj/item/weapon/legcuffs/bola/tactical,
		/obj/item/weapon/legcuffs/bola/tactical,
		/obj/item/weapon/legcuffs/bola/tactical,
		/obj/item/weapon/legcuffs/bola,
		/obj/item/weapon/legcuffs/bola,
		/obj/item/weapon/legcuffs/bola
	)

/datum/outfit/deathmatch/blue_team/experimental
	name = "Blue Team Experimental"
	suit = /obj/item/clothing/suit/jacket/letterman_nanotrasen
	head = /obj/item/clothing/head/bearpelt
	back = PREFERENCE_BACKPACK
	r_hand = /obj/item/weapon/gun/tesla
	backpack_contents = list(
		/obj/item/weapon/gun/energy/decloner,
		/obj/item/weapon/gun/energy/temperature,
		/obj/item/weapon/gun/energy/floragun
	)

/obj/item/weapon/gun/magic/fireball/deathmatch
	global_access = TRUE
	recharge_rate = 10
	max_charges = 5

/datum/outfit/deathmatch/blue_team/mage
	name = "Blue Team Mage"
	suit = /obj/item/clothing/suit/wizrobe/wiz_blue
	head = /obj/item/clothing/head/wizard/bluehood
	back = /obj/item/weapon/gun/magic/fireball/deathmatch
	l_hand = /obj/item/weapon/katana

////////////////////////////////////////////////////
//RED TEAM
////////////////////////////////////////////////////

/datum/outfit/deathmatch/red_team
	mask = /obj/item/clothing/mask/scarf/red
	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/red
	gloves = /obj/item/clothing/gloves/fingerless/red
	implants = list(/obj/item/weapon/implant/dexplosive)
	survival_box = FALSE


/datum/outfit/deathmatch/red_team/leader
	name = "Red Team Leader"
	suit = /obj/item/clothing/suit/dutch
	head = /obj/item/clothing/head/beret/black
	back = PREFERENCE_BACKPACK
	l_hand = /obj/item/weapon/gun/projectile/automatic/pistol/deagle/weakened/gold
	r_hand = /obj/item/device/megaphone
	l_pocket = /obj/item/weapon/shield/energy
	backpack_contents = list(
        /obj/item/weapon/gun/energy/laser/selfcharging/captain,
        /obj/item/ammo_box/magazine/deagle/weakened,
        /obj/item/ammo_box/magazine/deagle/weakened,
		/obj/item/ammo_box/magazine/deagle/weakened,
		/obj/item/ammo_box/magazine/deagle/weakened,
        /obj/item/ammo_box/magazine/deagle/weakened
        )

/datum/outfit/deathmatch/red_team/medic
	name = "Red Team Medic"
	suit = /obj/item/clothing/suit/storage/labcoat/red
	head = /obj/item/clothing/head/surgery/purple
	back = PREFERENCE_BACKPACK
	r_hand = /obj/item/weapon/gun/medbeam
	l_pocket = /obj/item/weapon/gun/projectile/automatic/pistol/wjpp/lethal
	backpack_contents = list(
		/obj/item/weapon/storage/firstaid/tactical,
		/obj/item/weapon/gun/projectile/automatic/pistol/wjpp/lethal,
		/obj/item/ammo_box/magazine/wjpp,
		/obj/item/ammo_box/magazine/wjpp,
		/obj/item/ammo_box/magazine/wjpp,
		/obj/item/weapon/circular_saw/alien
	)

/datum/outfit/deathmatch/red_team/sniper
	name = "Red Team Sniper"
	suit = /obj/item/clothing/suit/serifcoat
	head = /obj/item/clothing/head/western/cowboy
	back = /obj/item/weapon/gun/energy/sniperrifle
	belt = /obj/item/weapon/storage/pouch/pistol_holster/stechkin
	l_pocket = /obj/item/ammo_box/magazine/stechkin/extended
	r_pocket = /obj/item/ammo_box/magazine/stechkin/extended

/datum/outfit/deathmatch/red_team/scout
	name = "Red Team Scout"
	suit = /obj/item/clothing/suit/storage/miljacket_army
	head = /obj/item/clothing/head/ushanka/black_white
	shoes = /obj/item/clothing/shoes/boots/work/jak
	back = PREFERENCE_BACKPACK
	r_hand = /obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon/sawn_off
	l_hand = /obj/item/weapon/kitchenknife/combat
	backpack_contents = list(
		/obj/item/ammo_box/eight_shells,
		/obj/item/ammo_box/eight_shells,
		/obj/item/ammo_box/eight_shells/buckshot,
		/obj/item/ammo_box/eight_shells/buckshot
	)

/datum/outfit/deathmatch/red_team/soldier
	name = "Red Team Soldier"
	suit = /obj/item/clothing/suit/storage/postal_dude_coat
	head = /obj/item/clothing/head/soft/nt_pmc_cap
	back = PREFERENCE_BACKPACK
	r_hand = /obj/item/weapon/gun/projectile/automatic/tommygun/deathmatch
	backpack_contents = list(
		/obj/item/ammo_box/magazine/tommygun,
		/obj/item/ammo_box/magazine/tommygun,
        /obj/item/ammo_box/magazine/tommygun,
		/obj/item/weapon/shovel/deathmatch
    )

/datum/outfit/deathmatch/red_team/pirate
	name = "Red Team Pirate"
	suit = /obj/item/clothing/suit/pirate
	head = /obj/item/clothing/head/pirate
	back = PREFERENCE_BACKPACK
	r_hand = /obj/item/weapon/melee/energy/sword/red
	backpack_contents = list(
		/obj/item/weapon/implanter/adrenaline,
		/obj/item/weapon/legcuffs/bola/tactical,
		/obj/item/weapon/legcuffs/bola/tactical,
		/obj/item/weapon/legcuffs/bola/tactical,
		/obj/item/weapon/legcuffs/bola,
		/obj/item/weapon/legcuffs/bola,
		/obj/item/weapon/legcuffs/bola
	)

/datum/outfit/deathmatch/red_team/experimental
	name = "Red Team Experimental"
	suit = /obj/item/clothing/suit/jacket/letterman_red
	head = /obj/item/clothing/head/bearpelt
	back = PREFERENCE_BACKPACK
	r_hand = /obj/item/weapon/gun/tesla
	backpack_contents = list(
		/obj/item/weapon/gun/energy/decloner,
		/obj/item/weapon/gun/energy/temperature,
		/obj/item/weapon/gun/energy/floragun
	)

/datum/outfit/deathmatch/red_team/mage
	name = "Red Team Mage"
	suit = /obj/item/clothing/suit/wizrobe/wiz_red
	head = /obj/item/clothing/head/wizard/redhood
	back = /obj/item/weapon/gun/magic/fireball/deathmatch
	l_hand = /obj/item/weapon/katana
