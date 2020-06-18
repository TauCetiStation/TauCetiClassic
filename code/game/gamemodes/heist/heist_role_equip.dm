/* disabled due to pirate gamemode switching back to vox, leaving this for reference.
var/global/raider_tick = 1

/mob/living/carbon/human/proc/equip_raider()

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(src)
	R.set_frequency(SYND_FREQ) //Same frequency as the syndicate team in Nuke mode.
	equip_to_slot_or_del(R, SLOT_L_EAR)

	switch(raider_tick)
		if(1) // Aye Cap'n!
			equip_to_slot_or_del(new /obj/item/clothing/under/pirate(src), SLOT_W_UNIFORM)
			equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(src), SLOT_SHOES)
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/pirate(src), SLOT_WEAR_SUIT)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/pirate(src), SLOT_HEAD)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(src), SLOT_GLASSES)
			equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(src), SLOT_R_HAND)
			equip_to_slot_or_del(new /obj/item/weapon/extraction_pack(src), SLOT_L_HAND)
		if(2) // Piretezzz
			equip_to_slot_or_del(new /obj/item/clothing/under/pirate(src), SLOT_W_UNIFORM)
			equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(src), SLOT_SHOES)
			equip_to_slot_or_del(new /obj/item/clothing/head/bandana(src), SLOT_HEAD)
			//equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(src), SLOT_GLASSES)
			equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(src), SLOT_R_HAND)

	equip_to_slot_or_del(new /obj/item/device/price_tool(src), SLOT_L_STORE)
	equip_to_slot_or_del(new /obj/item/device/flashlight(src), SLOT_R_STORE)

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
	equip_to_slot_or_del(W, SLOT_WEAR_ID)

	raider_tick = 2
	return 1*/

/obj/item/weapon/gun/projectile/automatic/a28/nonlethal
	name = "A28 assault rifle NL"
	icon_state = "a28w"
	item_state = "a28w"
	silenced = 1
	mag_type = /obj/item/ammo_box/magazine/m556/nonlethal
	fire_sound = 'sound/weapons/guns/gunshot_silencer.ogg'

/obj/item/weapon/gun/projectile/automatic/silenced/nonlethal
	name = "Silenced pistol NL"
	icon = 'icons/obj/gun.dmi'
	icon_state = "silenced_pistol_nl"
	mag_type = /obj/item/ammo_box/magazine/sm45/nonlethal

/obj/item/ammo_box/magazine/m556/nonlethal
	name = "A28 magazine (.556NL)"
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
	agony = 55

/obj/item/projectile/bullet/weakbullet/nl_rifle/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_bodypart_damage(20)//+10=30
		S.emplode(2)
	else if(istype(target,/obj/mecha))
		var/obj/mecha/M = target
		M.take_damage(25)
	..()

/obj/item/projectile/bullet/weakbullet/nl_pistol
	stutter = 10
	agony = 30

/obj/item/projectile/bullet/weakbullet/nl_pistol/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_bodypart_damage(10)//+10=20
		S.emplode(2)
	else if(istype(target,/obj/mecha))
		var/obj/mecha/M = target
		M.take_damage(15)
	..()

/obj/item/weapon/storage/backpack/santabag/pirate
	name = "Loot bag"
	desc = "Just another ordinary bag."
	max_w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/grenade/monsternade
	name = "pocketnade"
	desc = "<span class='danger'>Warning:</span> use with extreme caution! Contains various hostile creatures which will hunt anyone on sight and you are not an exception!"
	icon_state = "pocketnade"
	item_state = "flashbang"
	origin_tech = "materials=2;combat=1"

/obj/item/weapon/grenade/monsternade/prime()
	..()
	playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER)
	switch(rand(1,4))
		if(1)
			for(var/i=0,i<2,i++)
				new /mob/living/simple_animal/hostile/samak(loc)
		if(2)
			for(var/i=0, i<7, i++)
				new /mob/living/simple_animal/hostile/diyaab(loc)
		if(3)
			for(var/i=0, i<4, i++)
				new /mob/living/simple_animal/hostile/shantak(loc)
		if(4)
			for(var/i=0, i<3, i++)
				new /mob/living/simple_animal/hostile/clown(loc)
	qdel(src)
	return

/obj/item/device/price_tool
	icon = 'icons/obj/hacktool.dmi'
	name = "appraiser"
	desc = "Use this on anything to get its price."
	icon_state = "hacktool"
	flags = CONDUCT
	force = 0
	w_class = ITEM_SIZE_SMALL
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	m_amt = 50
	g_amt = 20
	origin_tech = "magnets=1;engineering=1"

/obj/item/device/price_tool/attack(mob/living/M, mob/living/user, def_zone)
	if(!istype(M))
		return 0
	var/price_check = M.get_price()
	if(M.stat == DEAD)
		to_chat(user, "<span class='notice'>This [issilicon(M) ? "destroyed thing" : "dead being"] will bring us approximately $[price_check]$</span>")
	else
		to_chat(user, "<span class='notice'>This [issilicon(M) ? "silicon thing" : "living being"] will bring us approximately <span class='danger'>[issilicon(M) ? "DESTROYED:" : "DEAD:"]</span> $[price_check ? price_check / 50 : 0]$ or <span class='danger'>[issilicon(M) ? "WORKING:" : "ALIVE:"]</span>$[price_check]$</span>")
	return 1

/obj/item/device/price_tool/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(!isobj(target))
		return
	var/obj/O = target
	to_chat(user, "<span class='notice'>This object will bring us approximately $[num2text(O.get_price(),9)]$</span>")
	return
