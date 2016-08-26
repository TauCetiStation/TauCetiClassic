var/global/raider_tick = 1

/mob/living/carbon/human/proc/equip_raider(race_choice)

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(src)
	R.set_frequency(SYND_FREQ) //Same frequency as the syndicate team in Nuke mode.
	equip_to_slot_or_del(R, slot_l_ear)

	switch(raider_tick)
		if(1) // Aye Cap'n!
			switch(race_choice)
				if("Human")
					equip_to_slot_or_del(new /obj/item/clothing/under/pirate(src), slot_w_uniform)
					equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(src), slot_shoes)
					equip_to_slot_or_del(new /obj/item/clothing/suit/space/pirate(src), slot_wear_suit)
					equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/pirate(src), slot_head)
					equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(src), slot_glasses)
					//equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(src), slot_r_hand)
					//equip_to_slot_or_del(new /obj/item/weapon/extraction_pack(src), slot_l_hand)
		if(2) // Piretezzz
			switch(race_choice)
				if("Human")
					equip_to_slot_or_del(new /obj/item/clothing/under/pirate(src), slot_w_uniform)
					equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(src), slot_shoes)
					equip_to_slot_or_del(new /obj/item/clothing/head/bandana(src), slot_head)
					//equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(src), slot_glasses)
					//equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(src), slot_r_hand)

	equip_to_slot_or_del(new /obj/item/device/price_tool(src), slot_l_store)
	equip_to_slot_or_del(new /obj/item/device/flashlight(src), slot_r_store)

	var/obj/item/weapon/card/id/syndicate/C = new(src)
	C.name = "[real_name]'s Legitimate Human ID Card"
	C.icon_state = "id"
	C.access = list(access_syndicate)
	C.assignment = "Pirate"
	C.registered_name = real_name
	C.registered_user = src
	var/obj/item/weapon/storage/wallet/W = new(src)
	W.handle_item_insertion(C)
	spawn_money(rand(50,150)*10,W)
	equip_to_slot_or_del(W, slot_wear_id)

	raider_tick = 2
	return 1

/obj/item/weapon/gun/projectile/automatic/a28/nonlethal
	name = "A28 assault rifle NL"
	icon = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	tc_custom = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	icon_state = "a28w"
	item_state = "a28w"
	silenced = 1
	mag_type = /obj/item/ammo_box/magazine/m556/nonlethal
	fire_sound = 'tauceti/sounds/weapon/Gunshot_silenced.ogg'

/obj/item/weapon/gun/projectile/automatic/silenced/nonlethal
	name = "Silenced pistol NL"
	icon = 'icons/obj/gun.dmi'
	icon_state = "silenced_pistol_nl"
	mag_type = /obj/item/ammo_box/magazine/sm45/nonlethal

/obj/item/weapon/gun/projectile/automatic/a28/nonlethal/update_icon()
	src.overlays = 0
	update_magazine()
	icon_state = "a28w[chambered ? "" : "-e"]"
	return

/obj/item/ammo_box/magazine/m556/nonlethal
	name = "A28 magazine (.556NL)"
	icon = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	ammo_type = /obj/item/ammo_casing/a556/nonlethal
	caliber = "5.56mm"
	max_ammo = 30

/obj/item/ammo_box/magazine/sm45/nonlethal
	name = "magazine (.45NL)"
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c45/nonlethal
	caliber = ".45"
	max_ammo = 12

/obj/item/ammo_casing/a556/nonlethal
	desc = "A 5.56mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/weakbullet/nl_rifle

/obj/item/ammo_casing/c45/nonlethal
	desc = "A .45 bullet casing."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/weakbullet/nl_pistol

/obj/item/projectile/bullet/weakbullet/nl_rifle
	stutter = 10
	agony = 40

/obj/item/projectile/bullet/weakbullet/nl_rifle/on_hit(atom/target, blocked = 0)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_organ_damage(20)
	else if(istype(target, /obj/mecha))
		var/obj/mecha/M = target
		M.take_damage(25)
	..()

/obj/item/projectile/bullet/weakbullet/nl_pistol
	stutter = 10
	agony = 20

/obj/item/projectile/bullet/weakbullet/nl_pistol/on_hit(atom/target, blocked = 0)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_organ_damage(10)
	else if(istype(target,/obj/mecha))
		var/obj/mecha/M = target
		M.take_damage(15)
	..()

/obj/item/weapon/storage/backpack/santabag/pirate
	name = "Loot bag"
	desc = "Just another ordinary bag."
	max_w_class = 3

/obj/item/weapon/grenade/monsternade
	name = "pocketnade"
	desc = "<span class='danger'>Warning:</span> use with extreme caution! Contains various hostile creatures which will hunt anyone on sight and you are not an exception!"
	icon_state = "pocketnade"
	item_state = "flashbang"
	origin_tech = "materials=2;combat=1"

/obj/item/weapon/grenade/monsternade/prime()
	..()
	var/spawn_location = loc
	if(ismob(loc))
		spawn_location = loc.loc
	playsound(spawn_location, 'sound/effects/bang.ogg', 50, 1, 5)
	switch(rand(1,4))
		if(1)
			for(var/i = 1 to 3)
				new /mob/living/simple_animal/hostile/samak(spawn_location)
		if(2)
			for(var/i = 1 to 8)
				new /mob/living/simple_animal/hostile/diyaab(spawn_location)
		if(3)
			for(var/i = 1 to 5)
				new /mob/living/simple_animal/hostile/shantak(spawn_location)
		if(4)
			for(var/i = 1 to 4)
				new /mob/living/simple_animal/hostile/clown(spawn_location)
	qdel(src)

/obj/item/device/price_tool
	icon = 'icons/obj/hacktool.dmi'
	name = "appraiser"
	desc = "Use this on anything to get its price."
	icon_state = "hacktool"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	m_amt = 50
	g_amt = 20
	origin_tech = "magnets=1;engineering=1"

/obj/item/device/price_tool/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(!istype(M))
		return 0
	var/price_check = M.get_price()
	if(M.stat == DEAD)
		user << "<span class='notice'>This [issilicon(M) ? "destroyed thing" : "dead being"] will bring us approximately $[price_check]$</span>"
	else
		user << "<span class='notice'>This [issilicon(M) ? "silicon thing" : "living being"] will bring us approximately <span class='danger'>[issilicon(M) ? "DESTROYED:" : "DEAD:"]</span> $[price_check ? price_check / 50 : 0]$ or <span class='danger'>[issilicon(M) ? "WORKING:" : "ALIVE:"]</span>$[price_check]$</span>"
	return 1

/obj/item/device/price_tool/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity) return
	if(!istype(O))
		return
	user << "<span class='notice'>This object will bring us approximately $[num2text(O.get_price(),9)]$</span>"
	return

/obj/effect/landmark/heist/item_spawner
	name = "heist_equip_spawner"

/obj/effect/landmark/heist/item_spawner/proc/spawn_items()
	. = loc
	var/obj/structure/closet/C = locate(/obj/structure/closet/syndicate) in loc
	if(C)
		. = C
	return .

/obj/effect/landmark/heist/item_spawner/closet_1/spawn_items(race_choice)
	var/target = ..()

	switch(race_choice)
		//DLC content
		//if("Skrell")
		//if("Tajaran")
		//if("Unathi")
		//if("Diona")
		if("Human")
			for(var/i = 1 to 6)
				new /obj/item/weapon/gun/projectile/automatic/a28/nonlethal(target)
				new /obj/item/weapon/gun/projectile/automatic/silenced/nonlethal(target)
			for(var/i = 1 to 12)
				new /obj/item/ammo_box/magazine/m556/nonlethal(target)
				new /obj/item/ammo_box/magazine/sm45/nonlethal(target)
	qdel(src)

/*
/obj/effect/landmark/heist/item_spawner/closet_2/spawn_items(race_choice)
	var/target = ..()

	switch(race_choice)
		if("Human")
			*/

/obj/effect/landmark/heist/item_spawner/closet_3/spawn_items(race_choice)
	var/target = ..()

	switch(race_choice)
		if("Human")
			for(var/i = 1 to 6)
				new /obj/item/device/debugger(target)
	qdel(src)

/obj/effect/landmark/heist/item_spawner/closet_4/spawn_items(race_choice)
	var/target = ..()

	switch(race_choice)
		if("Human")
			for(var/i = 1 to 5)
				new /obj/item/weapon/storage/box/smokegrenades(target)
				new /obj/item/weapon/grenade/monsternade(target)
	qdel(src)

/obj/effect/landmark/heist/item_spawner/closet_5/spawn_items(race_choice)
	var/target = ..()

	switch(race_choice)
		if("Human")
			for(var/i = 1 to 10)
				new /obj/item/seeds/kudzuseed(target)
	qdel(src)

/obj/effect/landmark/heist/item_spawner/table_1/spawn_items(race_choice)
	var/target = ..()

	switch(race_choice)
		if("Human")
			for(var/i = 1 to 4)
				new /obj/item/weapon/storage/toolbox/syndicate(target)
	qdel(src)

/obj/effect/landmark/heist/item_spawner/table_2/spawn_items(race_choice)
	var/target = ..()

	switch(race_choice)
		if("Human")
			for(var/i = 1 to 4)
				new /obj/item/weapon/storage/box/handcuffs(target)
			for(var/i = 1 to 10)
				new /obj/item/weapon/melee/baton(target)
	qdel(src)

/obj/effect/landmark/heist/item_spawner/table_3/spawn_items(race_choice)
	var/target = ..()

	switch(race_choice)
		if("Human")
			for(var/i = 1 to 4)
				new /obj/item/weapon/storage/box/handcuffs(target)
			for(var/i = 1 to 10)
				new /obj/item/weapon/melee/baton(target)
	qdel(src)

/*
/obj/effect/landmark/heist/item_spawner/table_4/spawn_items(race_choice)
	var/target = ..()

	switch(race_choice)
		if("Human")
	qdel(src)*/

/obj/effect/landmark/heist/item_spawner/rig_rack/spawn_items(race_choice)
	var/target = ..()

	switch(race_choice)
		if("Human")
			for(var/i = 1 to 3) //2 + 1 spare per spawn.
				new /obj/item/clothing/suit/space/globose/black/pirate(target)
				new /obj/item/clothing/head/helmet/space/globose/black/pirate(target)
				var/obj/O = new /obj/item/clothing/shoes/magboots/syndie(target)
				O.name = "pirate stickboots"
				O = new /obj/item/clothing/tie/storage/black_vest(target)
				O.name = "pirate webbing vest"
				new /obj/item/clothing/glasses/night(target)
				new /obj/item/clothing/mask/breath(target)
				new /obj/item/weapon/storage/belt/military(target)
				new /obj/item/weapon/storage/backpack/santabag/pirate(target)
	qdel(src)

/obj/effect/landmark/heist/item_spawner/rack_4/spawn_items(race_choice)
	var/target = ..()

	switch(race_choice)
		if("Human")
			for(var/i = 1 to 10)
				new /obj/item/weapon/tank/emergency_oxygen/double(target)
	qdel(src)
