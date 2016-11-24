/proc/spawn_sec_equip()
	if(!ticker.sec_equip_preset)
		ticker.sec_equip_preset = pick("classic","tactifool","milizei")
	message_admins("\blue Security equipment preset - [ticker.sec_equip_preset]")
	for(var/obj/effect/landmark/sec_equip/E in landmarks_list)
		E.gimme_it_now()

/obj/effect/landmark/sec_equip
	name = "riot equip spawn"

/obj/effect/landmark/sec_equip/proc/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			new /obj/item/clothing/head/helmet/riot(loc)
			new /obj/item/clothing/suit/armor/riot(loc)
			new /obj/item/weapon/shield/riot(loc)
		if("tactifool")
			new /obj/item/clothing/head/helmet/riot/tactifool(loc)
			new /obj/item/clothing/suit/armor/riot/tactifool(loc)
			new /obj/item/weapon/shield/riot/tactifool(loc)
		if("milizei")
			new /obj/item/clothing/head/helmet/riot/wj(loc)
			new /obj/item/clothing/suit/armor/riot/wj(loc)
			new /obj/item/weapon/shield/riot/wj(loc)
	qdel(src)

/obj/effect/landmark/sec_equip/bulletproof
	name = "bulletproof equip spawn"

/obj/effect/landmark/sec_equip/bulletproof/gimme_it_now()
	var/atom/A
	switch(ticker.sec_equip_preset)
		if("classic")
			for(var/i = 1 to 3)
				A = new /obj/item/clothing/suit/armor/bulletproof(loc)
				A.pixel_x = -6 + (i * 3) // -3, 0, 3
				A.pixel_y = 6 - (i * 3)  // 3, 0 -3
				A = new /obj/item/clothing/head/helmet/bulletproof(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("tactifool")
			for(var/i = 1 to 3)
				A = new /obj/item/clothing/suit/armor/bulletproof/tactifool(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
				A = new /obj/item/clothing/head/helmet/bulletproof/tactifool(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("milizei")
			for(var/i = 1 to 3)
				A = new /obj/item/clothing/suit/armor/bulletproof/wj(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
				A = new /obj/item/clothing/head/helmet/bulletproof/wj(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
	qdel(src)

/obj/effect/landmark/sec_equip/ablative
	name = "ablative equip spawn"

/obj/effect/landmark/sec_equip/ablative/gimme_it_now()
	var/atom/A
	switch(ticker.sec_equip_preset)
		if("classic")
			for(var/i = 1 to 3)
				A = new /obj/item/clothing/suit/armor/laserproof(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
				A = new /obj/item/clothing/head/helmet/laserproof(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("tactifool")
			for(var/i = 1 to 3)
				A = new /obj/item/clothing/suit/armor/laserproof/tactifool(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
				A = new /obj/item/clothing/head/helmet/laserproof/tactifool(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("milizei")
			for(var/i = 1 to 3)
				A = new /obj/item/clothing/suit/armor/laserproof/wj(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
				A = new /obj/item/clothing/head/helmet/laserproof/wj(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
	qdel(src)

/obj/effect/landmark/sec_equip/energy
	name = "security energy weapon spawn"

/obj/effect/landmark/sec_equip/energy/gimme_it_now()
	var/atom/A
	switch(ticker.sec_equip_preset)
		if("classic")
			for(var/i = 1 to 3)
				A = new /obj/item/weapon/gun/energy/gun/carbine(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("tactifool")
			for(var/i = 1 to 3)
				A = new /obj/item/weapon/gun/energy/gun/pistol(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("milizei")
			for(var/i = 1 to 3)
				A = new /obj/item/weapon/gun/energy/gun(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
	qdel(src)

/obj/effect/landmark/sec_equip/ion
	name = "security ion weapon spawn"

/obj/effect/landmark/sec_equip/ion/gimme_it_now()
	var/atom/A
	switch(ticker.sec_equip_preset)
		if("classic")
			for(var/i = 1 to 2)
				A = new /obj/item/weapon/gun/energy/ionrifle/classic(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("tactifool")
			for(var/i = 1 to 2)
				A = new /obj/item/weapon/gun/energy/ionrifle/tactifool(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("milizei")
			for(var/i = 1 to 2)
				A = new /obj/item/weapon/gun/energy/ionrifle(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
	qdel(src)

/obj/effect/landmark/sec_equip/shotgun
	name = "security shotgun spawn"

/obj/effect/landmark/sec_equip/shotgun/gimme_it_now()
	var/atom/A
	switch(ticker.sec_equip_preset)
		if("classic")
			for(var/i = 1 to 3)
				A = new /obj/item/weapon/gun/projectile/shotgun/classic(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("tactifool")
			for(var/i = 1 to 3)
				A = new /obj/item/weapon/gun/projectile/shotgun/tactifool(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("milizei")
			for(var/i = 1 to 3)
				A = new /obj/item/weapon/gun/projectile/shotgun(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
	qdel(src)

/obj/effect/landmark/sec_equip/pistol
	name = "security pistol spawn"

/obj/effect/landmark/sec_equip/pistol/gimme_it_now()
	var/atom/A
	switch(ticker.sec_equip_preset)
		if("classic")
			for(var/i = 1 to 3)
				A = new /obj/item/weapon/gun/projectile/sec_pistol(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("tactifool")
			for(var/i = 1 to 3)
				A = new /obj/item/weapon/gun/projectile/sec_pistol/acm38(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("milizei")
			for(var/i = 1 to 3)
				A = new /obj/item/weapon/gun/projectile/sigi(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
	qdel(src)

/obj/effect/landmark/sec_equip/special
	name = "security special weapon spawn"

/obj/effect/landmark/sec_equip/special/gimme_it_now()
	var/atom/A
	switch(ticker.sec_equip_preset)
		if("classic")
			for(var/i = 1 to 2)
				A = new /obj/item/weapon/gun/projectile/automatic/c5(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("tactifool")
			for(var/i = 1 to 2)
				A = new /obj/item/weapon/gun/projectile/automatic/l13(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("milizei")
			for(var/i = 1 to 2)
				A = new /obj/item/weapon/gun/projectile/automatic/l10c(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
	qdel(src)

/obj/effect/landmark/sec_equip/laser
	name = "security laser weapon spawn"

/obj/effect/landmark/sec_equip/laser/gimme_it_now()
	var/atom/A
	switch(ticker.sec_equip_preset)
		if("classic")
			for(var/i = 1 to 3)
				A = new /obj/item/weapon/gun/energy/laser/classic(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("tactifool")
			for(var/i = 1 to 3)
				A = new /obj/item/weapon/gun/energy/laser/tactifool(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
		if("milizei")
			for(var/i = 1 to 3)
				A = new /obj/item/weapon/gun/energy/laser(loc)
				A.pixel_x = -6 + (i * 3)
				A.pixel_y = 6 - (i * 3)
	qdel(src)

/obj/effect/landmark/sec_equip/ammo
	name = "security ammo spawn"

/obj/effect/landmark/sec_equip/ammo/gimme_it_now()
	new /obj/item/ammo_box/shotgun(loc)
	for(var/i = 1 to 2)
		new /obj/item/ammo_box/shotgun/beanbag(loc)
	switch(ticker.sec_equip_preset)
		if("classic")
			for(var/i = 1 to 2)
				new /obj/item/ammo_box/magazine/c5_9mm(loc)
				new /obj/item/ammo_box/magazine/c5_9mm/letal(loc)
				new /obj/item/ammo_box/magazine/at7_45/letal(loc)
			for(var/i = 1 to 3)
				new /obj/item/ammo_box/magazine/at7_45(loc)
		if("tactifool")
			for(var/i = 1 to 2)
				new /obj/item/ammo_box/magazine/l13_38(loc)
				new /obj/item/ammo_box/magazine/l13_38/lethal(loc)
			for(var/i = 1 to 3)
				new /obj/item/ammo_box/magazine/acm38_38(loc)
				new /obj/item/ammo_box/magazine/acm38_38/lethal(loc)
		if("milizei")
			for(var/i = 1 to 3)
				new /obj/item/ammo_box/magazine/m9mm_2(loc)
				new /obj/item/ammo_box/magazine/m9mmr_2(loc)
	qdel(src)

/obj/effect/landmark/sec_equip/mask
	name = "security mask spawn"

/obj/effect/landmark/sec_equip/mask/gimme_it_now()
	var/atom/A
	switch(ticker.sec_equip_preset)
		if("classic")
			for(var/i = 1 to 6)
				A = new /obj/item/clothing/mask/gas/sechailer(loc)
				A.pixel_x = rand(-6, 6)
				A.pixel_y = rand(-6, 6)
		if("tactifool")
			for(var/i = 1 to 6)
				A = new /obj/item/clothing/mask/gas/sechailer/tactifool(loc)
				A.pixel_x = rand(-6, 6)
				A.pixel_y = rand(-6, 6)
		if("milizei")
			for(var/i = 1 to 6)
				A = new /obj/item/clothing/mask/gas/sechailer/wj(loc)
				A.pixel_x = rand(-6, 6)
				A.pixel_y = rand(-6, 6)
	qdel(src)

/obj/effect/landmark/sec_equip/hos
	name = "hos closet spawn"

/obj/effect/landmark/sec_equip/hos/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			new /obj/structure/closet/secure_closet/hos(loc)
		if("tactifool")
			new /obj/structure/closet/secure_closet/hos_tactifool(loc)
		if("milizei")
			new /obj/structure/closet/secure_closet/hos_wj(loc)
	qdel(src)

/obj/effect/landmark/sec_equip/warden
	name = "warden closet spawn"

/obj/effect/landmark/sec_equip/warden/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			new /obj/structure/closet/secure_closet/warden(loc)
		if("tactifool")
			new /obj/structure/closet/secure_closet/warden_tactifool(loc)
		if("milizei")
			new /obj/structure/closet/secure_closet/warden_wj(loc)
	qdel(src)

/obj/effect/landmark/sec_equip/officer
	name = "officer closet spawn"

/obj/effect/landmark/sec_equip/officer/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			new /obj/structure/closet/secure_closet/security(loc)
		if("tactifool")
			new /obj/structure/closet/secure_closet/security_tactifool(loc)
		if("milizei")
			new /obj/structure/closet/secure_closet/security_wj(loc)
	qdel(src)
