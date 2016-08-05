/proc/spawn_sec_equip()
	if(!ticker.sec_equip_preset)
		ticker.sec_equip_preset = pick("classic","tactifool","milizei")
	message_admins("\blue Security equipment preset - [ticker.sec_equip_preset]")
	for(var/obj/effect/landmark/sec_equip/E in world)
		E.gimme_it_now()

/obj/effect/landmark/sec_equip
	name = "riot equip spawn"

/obj/effect/landmark/sec_equip/proc/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			new /obj/item/clothing/head/helmet/riot(src.loc)
			new /obj/item/clothing/suit/armor/riot(src.loc)
			new /obj/item/weapon/shield/riot(src.loc)
		if("tactifool")
			new /obj/item/clothing/head/helmet/riot/tactifool(src.loc)
			new /obj/item/clothing/suit/armor/riot/tactifool(src.loc)
			new /obj/item/weapon/shield/riot/tactifool(src.loc)
		if("milizei")
			new /obj/item/clothing/head/helmet/riot/wj(src.loc)
			new /obj/item/clothing/suit/armor/riot/wj(src.loc)
			new /obj/item/weapon/shield/riot/wj(src.loc)
	qdel(src)

/obj/effect/landmark/sec_equip/bulletproof
	name = "bulletproof equip spawn"

/obj/effect/landmark/sec_equip/bulletproof/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			var/obj/item/clothing/suit/armor/bulletproof/B1 = new /obj/item/clothing/suit/armor/bulletproof(src.loc)
			B1.pixel_x = -3
			B1.pixel_y = 3
			new /obj/item/clothing/suit/armor/bulletproof(src.loc)
			var/obj/item/clothing/suit/armor/bulletproof/B2 = new /obj/item/clothing/suit/armor/bulletproof(src.loc)
			B2.pixel_x = 3
			B2.pixel_y = -3
			var/obj/item/clothing/head/helmet/bulletproof/BH1 = new /obj/item/clothing/head/helmet/bulletproof(src.loc)
			BH1.pixel_x = -3
			BH1.pixel_y = 3
			new /obj/item/clothing/head/helmet/bulletproof(src.loc)
			var/obj/item/clothing/head/helmet/bulletproof/BH2 = new /obj/item/clothing/head/helmet/bulletproof(src.loc)
			BH2.pixel_x = 3
			BH2.pixel_y = -3
		if("tactifool")
			var/obj/item/clothing/suit/armor/bulletproof/tactifool/B1 = new /obj/item/clothing/suit/armor/bulletproof/tactifool(src.loc)
			B1.pixel_x = -3
			B1.pixel_y = 3
			new /obj/item/clothing/suit/armor/bulletproof/tactifool(src.loc)
			var/obj/item/clothing/suit/armor/bulletproof/tactifool/B2 = new /obj/item/clothing/suit/armor/bulletproof/tactifool(src.loc)
			B2.pixel_x = 3
			B2.pixel_y = -3
			var/obj/item/clothing/head/helmet/bulletproof/tactifool/BH1 = new /obj/item/clothing/head/helmet/bulletproof/tactifool(src.loc)
			BH1.pixel_x = -3
			BH1.pixel_y = 3
			new /obj/item/clothing/head/helmet/bulletproof/tactifool(src.loc)
			var/obj/item/clothing/head/helmet/bulletproof/tactifool/BH2 = new /obj/item/clothing/head/helmet/bulletproof/tactifool(src.loc)
			BH2.pixel_x = 3
			BH2.pixel_y = -3
		if("milizei")
			var/obj/item/clothing/suit/armor/bulletproof/wj/B1 = new /obj/item/clothing/suit/armor/bulletproof/wj(src.loc)
			B1.pixel_x = -3
			B1.pixel_y = 3
			new /obj/item/clothing/suit/armor/bulletproof/wj(src.loc)
			var/obj/item/clothing/suit/armor/bulletproof/wj/B2 = new /obj/item/clothing/suit/armor/bulletproof/wj(src.loc)
			B2.pixel_x = 3
			B2.pixel_y = -3
			var/obj/item/clothing/head/helmet/bulletproof/wj/BH1 = new /obj/item/clothing/head/helmet/bulletproof/wj(src.loc)
			BH1.pixel_x = -3
			BH1.pixel_y = 3
			new /obj/item/clothing/head/helmet/bulletproof/wj(src.loc)
			var/obj/item/clothing/head/helmet/bulletproof/wj/BH2 = new /obj/item/clothing/head/helmet/bulletproof/wj(src.loc)
			BH2.pixel_x = 3
			BH2.pixel_y = -3
	qdel(src)

/obj/effect/landmark/sec_equip/ablative
	name = "ablative equip spawn"

/obj/effect/landmark/sec_equip/ablative/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			var/obj/item/clothing/suit/armor/laserproof/L1 = new /obj/item/clothing/suit/armor/laserproof(src.loc)
			L1.pixel_x = -3
			L1.pixel_y = 3
			new /obj/item/clothing/suit/armor/laserproof(src.loc)
			var/obj/item/clothing/suit/armor/laserproof/L2 = new /obj/item/clothing/suit/armor/laserproof(src.loc)
			L2.pixel_x = 3
			L2.pixel_y = -3
			var/obj/item/clothing/head/helmet/laserproof/LH1 = new /obj/item/clothing/head/helmet/laserproof(src.loc)
			LH1.pixel_x = -3
			LH1.pixel_y = 3
			new /obj/item/clothing/head/helmet/laserproof(src.loc)
			var/obj/item/clothing/head/helmet/laserproof/LH2 = new /obj/item/clothing/head/helmet/laserproof(src.loc)
			LH2.pixel_x = 3
			LH2.pixel_y = -3
		if("tactifool")
			var/obj/item/clothing/suit/armor/laserproof/tactifool/L1 = new /obj/item/clothing/suit/armor/laserproof/tactifool(src.loc)
			L1.pixel_x = -3
			L1.pixel_y = 3
			new /obj/item/clothing/suit/armor/laserproof/tactifool(src.loc)
			var/obj/item/clothing/suit/armor/laserproof/tactifool/L2 = new /obj/item/clothing/suit/armor/laserproof/tactifool(src.loc)
			L2.pixel_x = 3
			L2.pixel_y = -3
			var/obj/item/clothing/head/helmet/laserproof/tactifool/LH1 = new /obj/item/clothing/head/helmet/laserproof/tactifool(src.loc)
			LH1.pixel_x = -3
			LH1.pixel_y = 3
			new /obj/item/clothing/head/helmet/laserproof/tactifool(src.loc)
			var/obj/item/clothing/head/helmet/laserproof/tactifool/LH2 = new /obj/item/clothing/head/helmet/laserproof/tactifool(src.loc)
			LH2.pixel_x = 3
			LH2.pixel_y = -3
		if("milizei")
			var/obj/item/clothing/suit/armor/laserproof/wj/L1 = new /obj/item/clothing/suit/armor/laserproof/wj(src.loc)
			L1.pixel_x = -3
			L1.pixel_y = 3
			new /obj/item/clothing/suit/armor/laserproof/wj(src.loc)
			var/obj/item/clothing/suit/armor/laserproof/wj/L2 = new /obj/item/clothing/suit/armor/laserproof/wj(src.loc)
			L2.pixel_x = 3
			L2.pixel_y = -3
			var/obj/item/clothing/head/helmet/laserproof/wj/LH1 = new /obj/item/clothing/head/helmet/laserproof/wj(src.loc)
			LH1.pixel_x = -3
			LH1.pixel_y = 3
			new /obj/item/clothing/head/helmet/laserproof/wj(src.loc)
			var/obj/item/clothing/head/helmet/laserproof/wj/LH2 = new /obj/item/clothing/head/helmet/laserproof/wj(src.loc)
			LH2.pixel_x = 3
			LH2.pixel_y = -3
	qdel(src)

/obj/effect/landmark/sec_equip/energy
	name = "security energy weapon spawn"

/obj/effect/landmark/sec_equip/energy/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			var/obj/item/weapon/gun/energy/gun/carbine/EG1 = new /obj/item/weapon/gun/energy/gun/carbine(src.loc)
			EG1.pixel_x = -3
			EG1.pixel_y = 3
			new /obj/item/weapon/gun/energy/gun/carbine(src.loc)
			var/obj/item/weapon/gun/energy/gun/carbine/EG2 = new /obj/item/weapon/gun/energy/gun/carbine(src.loc)
			EG2.pixel_x = 3
			EG2.pixel_y = -3
		if("tactifool")
			var/obj/item/weapon/gun/energy/gun/pistol/EG1 = new /obj/item/weapon/gun/energy/gun/pistol(src.loc)
			EG1.pixel_x = -3
			EG1.pixel_y = 3
			new /obj/item/weapon/gun/energy/gun/pistol(src.loc)
			var/obj/item/weapon/gun/energy/gun/pistol/EG2 = new /obj/item/weapon/gun/energy/gun/pistol(src.loc)
			EG2.pixel_x = 3
			EG2.pixel_y = -3
		if("milizei")
			var/obj/item/weapon/gun/energy/gun/EG1 = new /obj/item/weapon/gun/energy/gun(src.loc)
			EG1.pixel_x = -3
			EG1.pixel_y = 3
			new /obj/item/weapon/gun/energy/gun(src.loc)
			var/obj/item/weapon/gun/energy/gun/EG2 = new /obj/item/weapon/gun/energy/gun(src.loc)
			EG2.pixel_x = 3
			EG2.pixel_y = -3
	qdel(src)

/obj/effect/landmark/sec_equip/ion
	name = "security ion weapon spawn"

/obj/effect/landmark/sec_equip/ion/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			var/obj/item/weapon/gun/energy/ionrifle/classic/I1 = new /obj/item/weapon/gun/energy/ionrifle/classic(src.loc)
			I1.pixel_x = -3
			I1.pixel_y = 3
			new /obj/item/weapon/gun/energy/ionrifle/classic(src.loc)
		if("tactifool")
			var/obj/item/weapon/gun/energy/ionrifle/tactifool/I1 = new /obj/item/weapon/gun/energy/ionrifle/tactifool(src.loc)
			I1.pixel_x = -3
			I1.pixel_y = 3
			new /obj/item/weapon/gun/energy/ionrifle/tactifool(src.loc)
		if("milizei")
			var/obj/item/weapon/gun/energy/ionrifle/I1 = new /obj/item/weapon/gun/energy/ionrifle(src.loc)
			I1.pixel_x = -3
			I1.pixel_y = 3
			new /obj/item/weapon/gun/energy/ionrifle(src.loc)
	qdel(src)

/obj/effect/landmark/sec_equip/shotgun
	name = "security shotgun spawn"

/obj/effect/landmark/sec_equip/shotgun/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			var/obj/item/weapon/gun/projectile/shotgun/classic/S1 = new /obj/item/weapon/gun/projectile/shotgun/classic(src.loc)
			S1.pixel_x = -3
			S1.pixel_y = 3
			new /obj/item/weapon/gun/projectile/shotgun/classic(src.loc)
			var/obj/item/weapon/gun/projectile/shotgun/classic/S2 = new /obj/item/weapon/gun/projectile/shotgun/classic(src.loc)
			S2.pixel_x = 3
			S2.pixel_y = -3
		if("tactifool")
			var/obj/item/weapon/gun/projectile/shotgun/tactifool/S1 = new /obj/item/weapon/gun/projectile/shotgun/tactifool(src.loc)
			S1.pixel_x = -3
			S1.pixel_y = 3
			new /obj/item/weapon/gun/projectile/shotgun/tactifool(src.loc)
			var/obj/item/weapon/gun/projectile/shotgun/tactifool/S2 = new /obj/item/weapon/gun/projectile/shotgun/tactifool(src.loc)
			S2.pixel_x = 3
			S2.pixel_y = -3
		if("milizei")
			var/obj/item/weapon/gun/projectile/shotgun/S1 = new /obj/item/weapon/gun/projectile/shotgun(src.loc)
			S1.pixel_x = -3
			S1.pixel_y = 3
			new /obj/item/weapon/gun/projectile/shotgun(src.loc)
			var/obj/item/weapon/gun/projectile/shotgun/S2 = new /obj/item/weapon/gun/projectile/shotgun(src.loc)
			S2.pixel_x = 3
			S2.pixel_y = -3
	qdel(src)

/obj/effect/landmark/sec_equip/pistol
	name = "security pistol spawn"

/obj/effect/landmark/sec_equip/pistol/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			var/obj/item/weapon/gun/projectile/sec_pistol/P1 = new /obj/item/weapon/gun/projectile/sec_pistol(src.loc)
			P1.pixel_x = -3
			P1.pixel_y = 3
			new /obj/item/weapon/gun/projectile/sec_pistol(src.loc)
			var/obj/item/weapon/gun/projectile/sec_pistol/P2 = new /obj/item/weapon/gun/projectile/sec_pistol(src.loc)
			P1.pixel_x = 2
			P2.pixel_y = -2
		if("tactifool")
			var/obj/item/weapon/gun/projectile/sec_pistol/acm38/P1 = new /obj/item/weapon/gun/projectile/sec_pistol/acm38(src.loc)
			P1.pixel_x = -3
			P1.pixel_y = 3
			new /obj/item/weapon/gun/projectile/sec_pistol/acm38(src.loc)
			var/obj/item/weapon/gun/projectile/sec_pistol/acm38/P2 = new /obj/item/weapon/gun/projectile/sec_pistol/acm38(src.loc)
			P1.pixel_x = 2
			P2.pixel_y = -2
		if("milizei")
			var/obj/item/weapon/gun/projectile/sigi/P1 = new /obj/item/weapon/gun/projectile/sigi(src.loc)
			P1.pixel_x = -3
			P1.pixel_y = 3
			new /obj/item/weapon/gun/projectile/sigi(src.loc)
			var/obj/item/weapon/gun/projectile/sigi/P2 = new /obj/item/weapon/gun/projectile/sigi(src.loc)
			P1.pixel_x = 2
			P2.pixel_y = -2
	qdel(src)

/obj/effect/landmark/sec_equip/special
	name = "security special weapon spawn"

/obj/effect/landmark/sec_equip/special/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			var/obj/item/weapon/gun/projectile/automatic/c5/SP1 = new /obj/item/weapon/gun/projectile/automatic/c5(src.loc)
			SP1.pixel_x = -3
			SP1.pixel_y = 3
			new /obj/item/weapon/gun/projectile/automatic/c5(src.loc)
		if("tactifool")
			var/obj/item/weapon/gun/projectile/automatic/l13/SP1 = new /obj/item/weapon/gun/projectile/automatic/l13(src.loc)
			SP1.pixel_x = -3
			SP1.pixel_y = 3
			new /obj/item/weapon/gun/projectile/automatic/l13(src.loc)
		if("milizei")
			var/obj/item/weapon/gun/projectile/automatic/l10c/SP1 = new /obj/item/weapon/gun/projectile/automatic/l10c(src.loc)
			SP1.pixel_x = -3
			SP1.pixel_y = 3
			new /obj/item/weapon/gun/projectile/automatic/l10c(src.loc)
	qdel(src)

/obj/effect/landmark/sec_equip/laser
	name = "security laser weapon spawn"

/obj/effect/landmark/sec_equip/laser/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			var/obj/item/weapon/gun/energy/laser/classic/LC1 = new /obj/item/weapon/gun/energy/laser/classic(src.loc)
			LC1.pixel_x = -3
			LC1.pixel_y = 3
			new /obj/item/weapon/gun/energy/laser/classic(src.loc)
			var/obj/item/weapon/gun/energy/laser/classic/LC2 = new /obj/item/weapon/gun/energy/laser/classic(src.loc)
			LC2.pixel_x = 3
			LC2.pixel_y = -3
		if("tactifool")
			var/obj/item/weapon/gun/energy/laser/tactifool/LC1 = new /obj/item/weapon/gun/energy/laser/tactifool(src.loc)
			LC1.pixel_x = -3
			LC1.pixel_y = 3
			new /obj/item/weapon/gun/energy/laser/tactifool(src.loc)
			var/obj/item/weapon/gun/energy/laser/tactifool/LC2 = new /obj/item/weapon/gun/energy/laser/tactifool(src.loc)
			LC2.pixel_x = 3
			LC2.pixel_y = -3
		if("milizei")
			var/obj/item/weapon/gun/energy/laser/LC1 = new /obj/item/weapon/gun/energy/laser(src.loc)
			LC1.pixel_x = -3
			LC1.pixel_y = 3
			new /obj/item/weapon/gun/energy/laser(src.loc)
			var/obj/item/weapon/gun/energy/laser/LC2 = new /obj/item/weapon/gun/energy/laser(src.loc)
			LC2.pixel_x = 3
			LC2.pixel_y = -3
	qdel(src)

/obj/effect/landmark/sec_equip/ammo
	name = "security ammo spawn"

/obj/effect/landmark/sec_equip/ammo/gimme_it_now()
	new /obj/item/ammo_box/shotgun(src.loc)
	new /obj/item/ammo_box/shotgun/beanbag(src.loc)
	new /obj/item/ammo_box/shotgun/beanbag(src.loc)
	switch(ticker.sec_equip_preset)
		if("classic")
			new /obj/item/ammo_box/magazine/c5_9mm(src.loc)
			new /obj/item/ammo_box/magazine/c5_9mm(src.loc)
			new /obj/item/ammo_box/magazine/c5_9mm/letal(src.loc)
			new /obj/item/ammo_box/magazine/c5_9mm/letal(src.loc)
			new /obj/item/ammo_box/magazine/at7_45(src.loc)
			new /obj/item/ammo_box/magazine/at7_45(src.loc)
			new /obj/item/ammo_box/magazine/at7_45(src.loc)
			new /obj/item/ammo_box/magazine/at7_45/letal(src.loc)
			new /obj/item/ammo_box/magazine/at7_45/letal(src.loc)
		if("tactifool")
			new /obj/item/ammo_box/magazine/l13_38(src.loc)
			new /obj/item/ammo_box/magazine/l13_38(src.loc)
			new /obj/item/ammo_box/magazine/l13_38/lethal(src.loc)
			new /obj/item/ammo_box/magazine/l13_38/lethal(src.loc)
			new /obj/item/ammo_box/magazine/acm38_38/lethal(src.loc)
			new /obj/item/ammo_box/magazine/acm38_38/lethal(src.loc)
			new /obj/item/ammo_box/magazine/acm38_38/lethal(src.loc)
			new /obj/item/ammo_box/magazine/acm38_38(src.loc)
			new /obj/item/ammo_box/magazine/acm38_38(src.loc)
			new /obj/item/ammo_box/magazine/acm38_38(src.loc)
		if("milizei")
			new /obj/item/ammo_box/magazine/m9mmr_2(src.loc)
			new /obj/item/ammo_box/magazine/m9mmr_2(src.loc)
			new /obj/item/ammo_box/magazine/m9mmr_2(src.loc)
			new /obj/item/ammo_box/magazine/m9mm_2(src.loc)
			new /obj/item/ammo_box/magazine/m9mm_2(src.loc)
			new /obj/item/ammo_box/magazine/m9mm_2(src.loc)
	qdel(src)

/obj/effect/landmark/sec_equip/mask
	name = "security mask spawn"

/obj/effect/landmark/sec_equip/mask/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			var/obj/item/clothing/mask/gas/sechailer/M1 = new /obj/item/clothing/mask/gas/sechailer(src.loc)
			M1.pixel_x = 6
			M1.pixel_y = -6
			var/obj/item/clothing/mask/gas/sechailer/M2 = new /obj/item/clothing/mask/gas/sechailer(src.loc)
			M2.pixel_x = 5
			var/obj/item/clothing/mask/gas/sechailer/M3 = new /obj/item/clothing/mask/gas/sechailer(src.loc)
			M3.pixel_x = -6
			M3.pixel_y = 6
			var/obj/item/clothing/mask/gas/sechailer/M4 = new /obj/item/clothing/mask/gas/sechailer(src.loc)
			M4.pixel_x = 3
			M4.pixel_y = -3
			var/obj/item/clothing/mask/gas/sechailer/M5 = new /obj/item/clothing/mask/gas/sechailer(src.loc)
			M5.pixel_x = 0
			var/obj/item/clothing/mask/gas/sechailer/M6 = new /obj/item/clothing/mask/gas/sechailer(src.loc)
			M6.pixel_x = -3
			M6.pixel_y = 3
		if("tactifool")
			var/obj/item/clothing/mask/gas/sechailer/tactifool/M1 = new /obj/item/clothing/mask/gas/sechailer/tactifool(src.loc)
			M1.pixel_x = 6
			M1.pixel_y = -6
			var/obj/item/clothing/mask/gas/sechailer/tactifool/M2 = new /obj/item/clothing/mask/gas/sechailer/tactifool(src.loc)
			M2.pixel_x = 5
			var/obj/item/clothing/mask/gas/sechailer/tactifool/M3 = new /obj/item/clothing/mask/gas/sechailer/tactifool(src.loc)
			M3.pixel_x = -6
			M3.pixel_y = 6
			var/obj/item/clothing/mask/gas/sechailer/tactifool/M4 = new /obj/item/clothing/mask/gas/sechailer/tactifool(src.loc)
			M4.pixel_x = 3
			M4.pixel_y = -3
			var/obj/item/clothing/mask/gas/sechailer/tactifool/M5 = new /obj/item/clothing/mask/gas/sechailer/tactifool(src.loc)
			M5.pixel_x = 0
			var/obj/item/clothing/mask/gas/sechailer/tactifool/M6 = new /obj/item/clothing/mask/gas/sechailer/tactifool(src.loc)
			M6.pixel_x = -3
			M6.pixel_y = 3
		if("milizei")
			var/obj/item/clothing/mask/gas/sechailer/wj/M1 = new /obj/item/clothing/mask/gas/sechailer/wj(src.loc)
			M1.pixel_x = 6
			M1.pixel_y = -6
			var/obj/item/clothing/mask/gas/sechailer/wj/M2 = new /obj/item/clothing/mask/gas/sechailer/wj(src.loc)
			M2.pixel_x = 5
			var/obj/item/clothing/mask/gas/sechailer/wj/M3 = new /obj/item/clothing/mask/gas/sechailer/wj(src.loc)
			M3.pixel_x = -6
			M3.pixel_y = 6
			var/obj/item/clothing/mask/gas/sechailer/wj/M4 = new /obj/item/clothing/mask/gas/sechailer/wj(src.loc)
			M4.pixel_x = 3
			M4.pixel_y = -3
			var/obj/item/clothing/mask/gas/sechailer/wj/M5 = new /obj/item/clothing/mask/gas/sechailer/wj(src.loc)
			M5.pixel_x = 0
			var/obj/item/clothing/mask/gas/sechailer/wj/M6 = new /obj/item/clothing/mask/gas/sechailer/wj(src.loc)
			M6.pixel_x = -3
			M6.pixel_y = 3
	qdel(src)

/obj/effect/landmark/sec_equip/hos
	name = "hos closet spawn"

/obj/effect/landmark/sec_equip/hos/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			new /obj/structure/closet/secure_closet/hos(src.loc)
		if("tactifool")
			new /obj/structure/closet/secure_closet/hos_tactifool(src.loc)
		if("milizei")
			new /obj/structure/closet/secure_closet/hos_wj(src.loc)
	qdel(src)

/obj/effect/landmark/sec_equip/warden
	name = "warden closet spawn"

/obj/effect/landmark/sec_equip/warden/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			new /obj/structure/closet/secure_closet/warden(src.loc)
		if("tactifool")
			new /obj/structure/closet/secure_closet/warden_tactifool(src.loc)
		if("milizei")
			new /obj/structure/closet/secure_closet/warden_wj(src.loc)
	qdel(src)

/obj/effect/landmark/sec_equip/officer
	name = "officer closet spawn"

/obj/effect/landmark/sec_equip/officer/gimme_it_now()
	switch(ticker.sec_equip_preset)
		if("classic")
			new /obj/structure/closet/secure_closet/security(src.loc)
		if("tactifool")
			new /obj/structure/closet/secure_closet/security_tactifool(src.loc)
		if("milizei")
			new /obj/structure/closet/secure_closet/security_wj(src.loc)
	qdel(src)