/proc/spawn_sec_equip()
	if(!ticker.sec_equip_preset)
		ticker.sec_equip_preset = pick("classic","tactifool","milizei")
	message_admins("\blue Security equipment preset - [ticker.sec_equip_preset]")
	switch(ticker.sec_equip_preset)
		if("classic")
			for(var/obj/structure/closet/secure_closet/hos/H in world) //Hos shit
				if(prob(50))
					new /obj/item/weapon/storage/backpack/security(H)
				else
					new /obj/item/weapon/storage/backpack/satchel_sec(H)
				new /obj/item/clothing/head/helmet/HoS(H)
				new /obj/item/clothing/suit/armor/hos(H)
				new /obj/item/clothing/under/rank/head_of_security/corp(H)
				new /obj/item/clothing/under/rank/head_of_security(H)
				new /obj/item/clothing/under/rank/head_of_security_fem(H)
				new /obj/item/weapon/storage/belt/security(H)
				new /obj/item/clothing/mask/gas/sechailer/hos(H)
			for(var/obj/structure/closet/secure_closet/warden/W in world) //warden shit
				if(prob(50))
					new /obj/item/weapon/storage/backpack/security(W)
				else
					new /obj/item/weapon/storage/backpack/satchel_sec(W)
				new /obj/item/clothing/head/helmet/warden(W)
				new /obj/item/clothing/under/rank/warden(W)
				new /obj/item/clothing/under/rank/warden_fem(W)
				new /obj/item/clothing/under/rank/warden/corp(W)
				new /obj/item/clothing/suit/armor/vest/security(W)
				new /obj/item/clothing/suit/armor/vest/warden(W)
				new /obj/item/weapon/gun/energy/taser(W)
				new /obj/item/weapon/storage/belt/security(W)
				new /obj/item/clothing/mask/gas/sechailer/warden(W)
			for(var/obj/structure/closet/secure_closet/security/C in world) //officer shit
				if(prob(50))
					new /obj/item/weapon/storage/backpack/security(C)
				else
					new /obj/item/weapon/storage/backpack/satchel_sec(C)
				new /obj/item/clothing/gloves/security(C)
				new /obj/item/clothing/suit/armor/vest/security(C)
				new /obj/item/clothing/head/helmet(C)
				new /obj/item/weapon/storage/belt/security(C)
				new /obj/item/weapon/gun/energy/taser(C)
				new /obj/item/clothing/head/soft/sec/corp(C)
				new /obj/item/clothing/under/rank/security/corp(C)
				new /obj/item/clothing/tie/storage/black_vest(C)
			for(var/obj/effect/landmark/sec_equip/laser/LAZER in landmarks_list) //laser spawn
				var/obj/item/weapon/gun/energy/laser/classic/LC1 = new /obj/item/weapon/gun/energy/laser/classic(LAZER.loc)
				LC1.pixel_x = -3
				LC1.pixel_y = 3
				new /obj/item/weapon/gun/energy/laser/classic(LAZER.loc)
				var/obj/item/weapon/gun/energy/laser/classic/LC2 = new /obj/item/weapon/gun/energy/laser/classic(LAZER.loc)
				LC2.pixel_x = 3
				LC2.pixel_y = -3
				qdel(LAZER)
			for(var/obj/effect/landmark/sec_equip/energy/EGUN in landmarks_list) //egun spawn
				var/obj/item/weapon/gun/energy/gun/carbine/EG1 = new /obj/item/weapon/gun/energy/gun/carbine(EGUN.loc)
				EG1.pixel_x = -3
				EG1.pixel_y = 3
				new /obj/item/weapon/gun/energy/gun/carbine(EGUN.loc)
				var/obj/item/weapon/gun/energy/gun/carbine/EG2 = new /obj/item/weapon/gun/energy/gun/carbine(EGUN.loc)
				EG2.pixel_x = 3
				EG2.pixel_y = -3
				qdel(EGUN)
			for(var/obj/effect/landmark/sec_equip/ion/ION in landmarks_list)
				var/obj/item/weapon/gun/energy/ionrifle/classic/I1 = new /obj/item/weapon/gun/energy/ionrifle/classic(ION.loc)
				I1.pixel_x = -3
				I1.pixel_y = 3
				new /obj/item/weapon/gun/energy/ionrifle/classic(ION.loc)
				qdel(ION)
			for(var/obj/effect/landmark/sec_equip/shotgun/SHOTGUN in landmarks_list) //shotgun spawn
				var/obj/item/weapon/gun/projectile/shotgun/classic/S1 = new /obj/item/weapon/gun/projectile/shotgun/classic(SHOTGUN.loc)
				S1.pixel_x = -3
				S1.pixel_y = 3
				new /obj/item/weapon/gun/projectile/shotgun/classic(SHOTGUN.loc)
				var/obj/item/weapon/gun/projectile/shotgun/classic/S2 = new /obj/item/weapon/gun/projectile/shotgun/classic(SHOTGUN.loc)
				S2.pixel_x = 3
				S2.pixel_y = -3
				qdel(SHOTGUN)
			for(var/obj/effect/landmark/sec_equip/special/SPEC in landmarks_list)
				var/obj/item/weapon/gun/projectile/automatic/c5/SP1 = new /obj/item/weapon/gun/projectile/automatic/c5(SPEC.loc)
				SP1.pixel_x = -3
				SP1.pixel_y = 3
				new /obj/item/weapon/gun/projectile/automatic/c5(SPEC.loc)
				qdel(SPEC)
			for(var/obj/effect/landmark/sec_equip/pistol/PISTOL in landmarks_list)
				var/obj/item/weapon/gun/projectile/sec_pistol/P1 = new /obj/item/weapon/gun/projectile/sec_pistol(PISTOL.loc)
				P1.pixel_x = -3
				P1.pixel_y = 3
				new /obj/item/weapon/gun/projectile/sec_pistol(PISTOL.loc)
				var/obj/item/weapon/gun/projectile/sec_pistol/P2 = new /obj/item/weapon/gun/projectile/sec_pistol(PISTOL.loc)
				P1.pixel_x = 2
				P2.pixel_y = -2
				qdel(PISTOL)
			for(var/obj/effect/landmark/sec_equip/ammo/AMMO in landmarks_list)
				new /obj/item/ammo_box/magazine/c5_9mm(AMMO.loc)
				new /obj/item/ammo_box/magazine/c5_9mm(AMMO.loc)
				new /obj/item/ammo_box/magazine/c5_9mm/letal(AMMO.loc)
				new /obj/item/ammo_box/magazine/c5_9mm/letal(AMMO.loc)
				new /obj/item/ammo_box/magazine/at7_45(AMMO.loc)
				new /obj/item/ammo_box/magazine/at7_45(AMMO.loc)
				new /obj/item/ammo_box/magazine/at7_45(AMMO.loc)
				new /obj/item/ammo_box/magazine/at7_45/letal(AMMO.loc)
				new /obj/item/ammo_box/magazine/at7_45/letal(AMMO.loc)
				new /obj/item/ammo_box/shotgun(AMMO.loc)
				new /obj/item/ammo_box/shotgun/beanbag(AMMO.loc)
				new /obj/item/ammo_box/shotgun/beanbag(AMMO.loc)
				qdel(AMMO)
			for(var/obj/effect/landmark/sec_equip/ablative/F in landmarks_list)
				new /obj/item/clothing/suit/armor/laserproof(F.loc)
				new /obj/item/clothing/suit/armor/laserproof(F.loc)
				new /obj/item/clothing/suit/armor/laserproof(F.loc)
				new /obj/item/clothing/head/helmet/laserproof(F.loc)
				new /obj/item/clothing/head/helmet/laserproof(F.loc)
				new /obj/item/clothing/head/helmet/laserproof(F.loc)
				qdel(F)
			for(var/obj/effect/landmark/sec_equip/bulletproof/E in landmarks_list)
				new /obj/item/clothing/suit/armor/bulletproof(E.loc)
				new /obj/item/clothing/suit/armor/bulletproof(E.loc)
				new /obj/item/clothing/suit/armor/bulletproof(E.loc)
				new /obj/item/clothing/head/helmet/bulletproof(E.loc)
				new /obj/item/clothing/head/helmet/bulletproof(E.loc)
				new /obj/item/clothing/head/helmet/bulletproof(E.loc)
				qdel(E)
			for(var/obj/effect/landmark/sec_equip/mask/MASKA in landmarks_list)
				var/obj/item/clothing/mask/gas/sechailer/M1 = new /obj/item/clothing/mask/gas/sechailer(MASKA.loc)
				M1.pixel_x = 5
				var/obj/item/clothing/mask/gas/sechailer/M2 = new /obj/item/clothing/mask/gas/sechailer(MASKA.loc)
				M2.pixel_x = -5
				var/obj/item/clothing/mask/gas/sechailer/M3 = new /obj/item/clothing/mask/gas/sechailer(MASKA.loc)
				M3.pixel_x = 3
				var/obj/item/clothing/mask/gas/sechailer/M4 = new /obj/item/clothing/mask/gas/sechailer(MASKA.loc)
				M4.pixel_x = -3
				var/obj/item/clothing/mask/gas/sechailer/M5 = new /obj/item/clothing/mask/gas/sechailer(MASKA.loc)
				M5.pixel_x = -1
				var/obj/item/clothing/mask/gas/sechailer/M6 = new /obj/item/clothing/mask/gas/sechailer(MASKA.loc)
				M6.pixel_x = 1
				qdel(MASKA)
			for(var/obj/effect/landmark/sec_equip/D in landmarks_list)
				new /obj/item/clothing/head/helmet/riot(D.loc)
				new /obj/item/clothing/suit/armor/riot(D.loc)
				new /obj/item/weapon/shield/riot(D.loc)
				qdel(D)
		if("tactifool")
			for(var/obj/structure/closet/secure_closet/hos/H in world)
				if(prob(50))
					new /obj/item/weapon/storage/backpack/security/tactifool(H)
				else
					new /obj/item/weapon/storage/backpack/satchel_sec/tactifool(H)
				new /obj/item/clothing/shoes/jackboots/secshoes(H)
				new /obj/item/clothing/head/helmet/HoS/tactifool(H)
				new /obj/item/clothing/suit/armor/hos/coat(H)
				new /obj/item/clothing/under/rank/head_of_security/tactifool/fancy(H)
				new /obj/item/clothing/under/rank/head_of_security/tactifool(H)
				new /obj/item/weapon/storage/belt/security/improved(H)
				new /obj/item/clothing/mask/gas/sechailer/tactifool(H)
			for(var/obj/structure/closet/secure_closet/warden/W in world) //warden shit
				if(prob(50))
					new /obj/item/weapon/storage/backpack/security/tactifool(W)
				else
					new /obj/item/weapon/storage/backpack/satchel_sec/tactifool(W)
				new /obj/item/clothing/shoes/jackboots/secshoes(W)
				new /obj/item/clothing/head/helmet/warden/tactifool(W)
				new /obj/item/clothing/under/rank/warden/tactifool(W)
				new /obj/item/clothing/suit/armor/vest/tactifool(W)
				new /obj/item/clothing/suit/armor/vest/warden/tactifool(W)
				new /obj/item/weapon/gun/energy/taser/tactifool(W)
				new /obj/item/weapon/storage/belt/security/improved(W)
				new /obj/item/clothing/mask/gas/sechailer/tactifool(W)
			for(var/obj/structure/closet/secure_closet/security/C in world) //officer shit
				if(prob(50))
					new /obj/item/weapon/storage/backpack/security/tactifool(C)
				else
					new /obj/item/weapon/storage/backpack/satchel_sec/tactifool(C)
				new /obj/item/clothing/shoes/jackboots/secshoes(C)
				new /obj/item/clothing/gloves/security/fight(C)
				new /obj/item/clothing/suit/armor/vest/tactifool(C)
				new /obj/item/clothing/head/helmet/tactifool(C)
				new /obj/item/weapon/storage/belt/security/improved(C)
				new /obj/item/weapon/gun/energy/taser/tactifool(C)
				new /obj/item/clothing/head/soft/sec/tactifool(C)
				new /obj/item/clothing/under/rank/security/tactifool(C)
			for(var/obj/effect/landmark/sec_equip/laser/LAZER in landmarks_list) //laser spawn
				var/obj/item/weapon/gun/energy/laser/tactifool/LC1 = new /obj/item/weapon/gun/energy/laser/tactifool(LAZER.loc)
				LC1.pixel_x = -3
				LC1.pixel_y = 3
				new /obj/item/weapon/gun/energy/laser/tactifool(LAZER.loc)
				var/obj/item/weapon/gun/energy/laser/tactifool/LC2 = new /obj/item/weapon/gun/energy/laser/tactifool(LAZER.loc)
				LC2.pixel_x = 3
				LC2.pixel_y = -3
				qdel(LAZER)
			for(var/obj/effect/landmark/sec_equip/energy/EGUN in landmarks_list) //egun spawn
				var/obj/item/weapon/gun/energy/gun/pistol/EG1 = new /obj/item/weapon/gun/energy/gun/pistol(EGUN.loc)
				EG1.pixel_x = -3
				EG1.pixel_y = 3
				new /obj/item/weapon/gun/energy/gun/pistol(EGUN.loc)
				var/obj/item/weapon/gun/energy/gun/pistol/EG2 = new /obj/item/weapon/gun/energy/gun/pistol(EGUN.loc)
				EG2.pixel_x = 3
				EG2.pixel_y = -3
				qdel(EGUN)
			for(var/obj/effect/landmark/sec_equip/ion/ION in landmarks_list)
				var/obj/item/weapon/gun/energy/ionrifle/tactifool/I1 = new /obj/item/weapon/gun/energy/ionrifle/tactifool(ION.loc)
				I1.pixel_x = -3
				I1.pixel_y = 3
				new /obj/item/weapon/gun/energy/ionrifle/tactifool(ION.loc)
				qdel(ION)
			for(var/obj/effect/landmark/sec_equip/shotgun/SHOTGUN in landmarks_list) //shotgun spawn
				var/obj/item/weapon/gun/projectile/shotgun/tactifool/S1 = new /obj/item/weapon/gun/projectile/shotgun/tactifool(SHOTGUN.loc)
				S1.pixel_x = -3
				S1.pixel_y = 3
				new /obj/item/weapon/gun/projectile/shotgun/tactifool(SHOTGUN.loc)
				var/obj/item/weapon/gun/projectile/shotgun/tactifool/S2 = new /obj/item/weapon/gun/projectile/shotgun/tactifool(SHOTGUN.loc)
				S2.pixel_x = 3
				S2.pixel_y = -3
				qdel(SHOTGUN)
			for(var/obj/effect/landmark/sec_equip/special/SPEC in landmarks_list)
				var/obj/item/weapon/gun/projectile/automatic/l13/SP1 = new /obj/item/weapon/gun/projectile/automatic/l13(SPEC.loc)
				SP1.pixel_x = -3
				SP1.pixel_y = 3
				new /obj/item/weapon/gun/projectile/automatic/l13(SPEC.loc)
				qdel(SPEC)
			for(var/obj/effect/landmark/sec_equip/pistol/PISTOL in landmarks_list)
				var/obj/item/weapon/gun/projectile/sec_pistol/acm38/P1 = new /obj/item/weapon/gun/projectile/sec_pistol/acm38(PISTOL.loc)
				P1.pixel_x = -3
				P1.pixel_y = 3
				new /obj/item/weapon/gun/projectile/sec_pistol/acm38(PISTOL.loc)
				var/obj/item/weapon/gun/projectile/sec_pistol/acm38/P2 = new /obj/item/weapon/gun/projectile/sec_pistol/acm38(PISTOL.loc)
				P1.pixel_x = 2
				P2.pixel_y = -2
				qdel(PISTOL)
			for(var/obj/effect/landmark/sec_equip/ammo/AMMO in landmarks_list)
				new /obj/item/ammo_box/magazine/l13_38(AMMO.loc)
				new /obj/item/ammo_box/magazine/l13_38(AMMO.loc)
				new /obj/item/ammo_box/magazine/l13_38/lethal(AMMO.loc)
				new /obj/item/ammo_box/magazine/l13_38/lethal(AMMO.loc)
				new /obj/item/ammo_box/magazine/acm38_38(AMMO.loc)
				new /obj/item/ammo_box/magazine/acm38_38(AMMO.loc)
				new /obj/item/ammo_box/magazine/acm38_38(AMMO.loc)
				new /obj/item/ammo_box/magazine/acm38_38/lethal(AMMO.loc)
				new /obj/item/ammo_box/magazine/acm38_38/lethal(AMMO.loc)
				new /obj/item/ammo_box/magazine/acm38_38/lethal(AMMO.loc)
				new /obj/item/ammo_box/shotgun(AMMO.loc)
				new /obj/item/ammo_box/shotgun/beanbag(AMMO.loc)
				new /obj/item/ammo_box/shotgun/beanbag(AMMO.loc)
				qdel(AMMO)
			for(var/obj/effect/landmark/sec_equip/mask/MASKA in landmarks_list)
				var/obj/item/clothing/mask/gas/sechailer/tactifool/M1 = new /obj/item/clothing/mask/gas/sechailer/tactifool(MASKA.loc)
				M1.pixel_x = 5
				var/obj/item/clothing/mask/gas/sechailer/tactifool/M2 = new /obj/item/clothing/mask/gas/sechailer/tactifool(MASKA.loc)
				M2.pixel_x = -5
				var/obj/item/clothing/mask/gas/sechailer/tactifool/M3 = new /obj/item/clothing/mask/gas/sechailer/tactifool(MASKA.loc)
				M3.pixel_x = 3
				var/obj/item/clothing/mask/gas/sechailer/tactifool/M4 = new /obj/item/clothing/mask/gas/sechailer/tactifool(MASKA.loc)
				M4.pixel_x = -3
				var/obj/item/clothing/mask/gas/sechailer/tactifool/M5 = new /obj/item/clothing/mask/gas/sechailer/tactifool(MASKA.loc)
				M5.pixel_x = -1
				var/obj/item/clothing/mask/gas/sechailer/tactifool/M6 = new /obj/item/clothing/mask/gas/sechailer/tactifool(MASKA.loc)
				M6.pixel_x = 1
				qdel(MASKA)
			for(var/obj/effect/landmark/sec_equip/ablative/F in landmarks_list)
				new /obj/item/clothing/suit/armor/laserproof/tactifool(F.loc)
				new /obj/item/clothing/suit/armor/laserproof/tactifool(F.loc)
				new /obj/item/clothing/suit/armor/laserproof/tactifool(F.loc)
				new /obj/item/clothing/head/helmet/laserproof/tactifool(F.loc)
				new /obj/item/clothing/head/helmet/laserproof/tactifool(F.loc)
				new /obj/item/clothing/head/helmet/laserproof/tactifool(F.loc)
				qdel(F)
			for(var/obj/effect/landmark/sec_equip/bulletproof/E in landmarks_list)
				new /obj/item/clothing/suit/armor/bulletproof/tactifool(E.loc)
				new /obj/item/clothing/suit/armor/bulletproof/tactifool(E.loc)
				new /obj/item/clothing/suit/armor/bulletproof/tactifool(E.loc)
				new /obj/item/clothing/head/helmet/bulletproof/tactifool(E.loc)
				new /obj/item/clothing/head/helmet/bulletproof/tactifool(E.loc)
				new /obj/item/clothing/head/helmet/bulletproof/tactifool(E.loc)
				qdel(E)
			for(var/obj/effect/landmark/sec_equip/D in landmarks_list)
				new /obj/item/clothing/head/helmet/riot/tactifool(D.loc)
				new /obj/item/clothing/suit/armor/riot/tactifool(D.loc)
				new /obj/item/weapon/shield/riot/tactifool(D.loc)
				qdel(D)
		if("milizei")
			for(var/obj/structure/closet/secure_closet/hos/H in world)
				if(prob(50))
					new /obj/item/weapon/storage/backpack/security/wj(H)
				else
					new /obj/item/weapon/storage/backpack/satchel_sec/wj(H)
				new /obj/item/clothing/head/helmet/HoS/wj(H)
				new /obj/item/clothing/head/helmet/wj/hos(H)
				new /obj/item/clothing/suit/armor/hos/wj(H)
				new /obj/item/clothing/under/rank/head_of_security/wj(H)
				new /obj/item/weapon/storage/belt/security/wj(H)
				new /obj/item/clothing/mask/gas/sechailer/wj(H)
				new /obj/item/clothing/shoes/jackboots/wj(H)
			for(var/obj/structure/closet/secure_closet/warden/W in world) //warden shit
				if(prob(50))
					new /obj/item/weapon/storage/backpack/security/wj(W)
				else
					new /obj/item/weapon/storage/backpack/satchel_sec/wj(W)
				new /obj/item/clothing/shoes/jackboots/wj(W)
				new /obj/item/clothing/head/helmet/warden/wj(W)
				new /obj/item/clothing/head/helmet/wj/warden(W)
				new /obj/item/clothing/under/rank/warden/wj(W)
				new /obj/item/clothing/suit/armor/vest/wj(W)
				new /obj/item/clothing/suit/armor/vest/warden/wj(W)
				new /obj/item/weapon/gun/energy/taser/wj(W)
				new /obj/item/weapon/storage/belt/security/wj(W)
				new /obj/item/clothing/mask/gas/sechailer/wj(W)
			for(var/obj/structure/closet/secure_closet/security/C in world) //officer shit
				if(prob(50))
					new /obj/item/weapon/storage/backpack/security/wj(C)
				else
					new /obj/item/weapon/storage/backpack/satchel_sec/wj(C)
				new /obj/item/clothing/shoes/jackboots/wj(C)
				new /obj/item/clothing/gloves/security/wj(C)
				new /obj/item/clothing/suit/armor/vest/wj(C)
				new /obj/item/clothing/head/helmet/wj(C)
				new /obj/item/weapon/storage/belt/security/wj(C)
				new /obj/item/weapon/gun/energy/taser/wj(C)
				new /obj/item/clothing/head/soft/sec/wj(C)
				new /obj/item/clothing/under/rank/security/wj(C)
			for(var/obj/effect/landmark/sec_equip/laser/LAZER in landmarks_list) //laser spawn
				var/obj/item/weapon/gun/energy/laser/LC1 = new /obj/item/weapon/gun/energy/laser(LAZER.loc)
				LC1.pixel_x = -3
				LC1.pixel_y = 3
				new /obj/item/weapon/gun/energy/laser(LAZER.loc)
				var/obj/item/weapon/gun/energy/laser/LC2 = new /obj/item/weapon/gun/energy/laser(LAZER.loc)
				LC2.pixel_x = 3
				LC2.pixel_y = -3
				qdel(LAZER)
			for(var/obj/effect/landmark/sec_equip/energy/EGUN in landmarks_list) //egun spawn
				var/obj/item/weapon/gun/energy/gun/EG1 = new /obj/item/weapon/gun/energy/gun(EGUN.loc)
				EG1.pixel_x = -3
				EG1.pixel_y = 3
				new /obj/item/weapon/gun/energy/gun(EGUN.loc)
				var/obj/item/weapon/gun/energy/gun/EG2 = new /obj/item/weapon/gun/energy/gun(EGUN.loc)
				EG2.pixel_x = 3
				EG2.pixel_y = -3
				qdel(EGUN)
			for(var/obj/effect/landmark/sec_equip/ion/ION in landmarks_list)
				var/obj/item/weapon/gun/energy/ionrifle/I1 = new /obj/item/weapon/gun/energy/ionrifle(ION.loc)
				I1.pixel_x = -3
				I1.pixel_y = 3
				new /obj/item/weapon/gun/energy/ionrifle(ION.loc)
				qdel(ION)
			for(var/obj/effect/landmark/sec_equip/shotgun/SHOTGUN in landmarks_list) //shotgun spawn
				var/obj/item/weapon/gun/projectile/shotgun/S1 = new /obj/item/weapon/gun/projectile/shotgun(SHOTGUN.loc)
				S1.pixel_x = -3
				S1.pixel_y = 3
				new /obj/item/weapon/gun/projectile/shotgun(SHOTGUN.loc)
				var/obj/item/weapon/gun/projectile/shotgun/S2 = new /obj/item/weapon/gun/projectile/shotgun(SHOTGUN.loc)
				S2.pixel_x = 3
				S2.pixel_y = -3
				qdel(SHOTGUN)
			for(var/obj/effect/landmark/sec_equip/special/SPEC in landmarks_list)
				var/obj/item/weapon/gun/projectile/automatic/l10c/SP1 = new /obj/item/weapon/gun/projectile/automatic/l10c(SPEC.loc)
				SP1.pixel_x = -3
				SP1.pixel_y = 3
				new /obj/item/weapon/gun/projectile/automatic/l10c(SPEC.loc)
				qdel(SPEC)
			for(var/obj/effect/landmark/sec_equip/pistol/PISTOL in landmarks_list)
				var/obj/item/weapon/gun/projectile/sigi/P1 = new /obj/item/weapon/gun/projectile/sigi(PISTOL.loc)
				P1.pixel_x = -3
				P1.pixel_y = 3
				new /obj/item/weapon/gun/projectile/sigi(PISTOL.loc)
				var/obj/item/weapon/gun/projectile/sigi/P2 = new /obj/item/weapon/gun/projectile/sigi(PISTOL.loc)
				P1.pixel_x = 2
				P2.pixel_y = -2
				qdel(PISTOL)
			for(var/obj/effect/landmark/sec_equip/ammo/AMMO in landmarks_list)
				new /obj/item/ammo_box/magazine/m9mmr_2(AMMO.loc)
				new /obj/item/ammo_box/magazine/m9mmr_2(AMMO.loc)
				new /obj/item/ammo_box/magazine/m9mmr_2(AMMO.loc)
				new /obj/item/ammo_box/magazine/m9mm_2(AMMO.loc)
				new /obj/item/ammo_box/magazine/m9mm_2(AMMO.loc)
				new /obj/item/ammo_box/magazine/m9mm_2(AMMO.loc)
				new /obj/item/ammo_box/shotgun(AMMO.loc)
				new /obj/item/ammo_box/shotgun/beanbag(AMMO.loc)
				new /obj/item/ammo_box/shotgun/beanbag(AMMO.loc)
				qdel(AMMO)
			for(var/obj/effect/landmark/sec_equip/mask/MASKA in landmarks_list)
				var/obj/item/clothing/mask/gas/sechailer/wj/M1 = new /obj/item/clothing/mask/gas/sechailer/wj(MASKA.loc)
				M1.pixel_x = 5
				var/obj/item/clothing/mask/gas/sechailer/wj/M2 = new /obj/item/clothing/mask/gas/sechailer/wj(MASKA.loc)
				M2.pixel_x = -5
				var/obj/item/clothing/mask/gas/sechailer/wj/M3 = new /obj/item/clothing/mask/gas/sechailer/wj(MASKA.loc)
				M3.pixel_x = 3
				var/obj/item/clothing/mask/gas/sechailer/wj/M4 = new /obj/item/clothing/mask/gas/sechailer/wj(MASKA.loc)
				M4.pixel_x = -3
				var/obj/item/clothing/mask/gas/sechailer/wj/M5 = new /obj/item/clothing/mask/gas/sechailer/wj(MASKA.loc)
				M5.pixel_x = -1
				var/obj/item/clothing/mask/gas/sechailer/wj/M6 = new /obj/item/clothing/mask/gas/sechailer/wj(MASKA.loc)
				M6.pixel_x = 1
				qdel(MASKA)
			for(var/obj/effect/landmark/sec_equip/ablative/F in landmarks_list)
				new /obj/item/clothing/suit/armor/laserproof/wj(F.loc)
				new /obj/item/clothing/suit/armor/laserproof/wj(F.loc)
				new /obj/item/clothing/suit/armor/laserproof/wj(F.loc)
				new /obj/item/clothing/head/helmet/laserproof/wj(F.loc)
				new /obj/item/clothing/head/helmet/laserproof/wj(F.loc)
				new /obj/item/clothing/head/helmet/laserproof/wj(F.loc)
				qdel(F)
			for(var/obj/effect/landmark/sec_equip/bulletproof/E in landmarks_list)
				new /obj/item/clothing/suit/armor/bulletproof/wj(E.loc)
				new /obj/item/clothing/suit/armor/bulletproof/wj(E.loc)
				new /obj/item/clothing/suit/armor/bulletproof/wj(E.loc)
				new /obj/item/clothing/head/helmet/bulletproof/wj(E.loc)
				new /obj/item/clothing/head/helmet/bulletproof/wj(E.loc)
				new /obj/item/clothing/head/helmet/bulletproof/wj(E.loc)
				qdel(E)
			for(var/obj/effect/landmark/sec_equip/D in landmarks_list)
				new /obj/item/clothing/head/helmet/riot/wj(D.loc)
				new /obj/item/clothing/suit/armor/riot/wj(D.loc)
				new /obj/item/weapon/shield/riot/wj(D.loc)
				qdel(D)

/obj/effect/landmark/sec_equip
	name = "riot equip spawn"

/obj/effect/landmark/sec_equip/bulletproof
	name = "bulletproof equip spawn"

/obj/effect/landmark/sec_equip/ablative
	name = "ablative equip spawn"

/obj/effect/landmark/sec_equip/energy
	name = "security energy weapon spawn"

/obj/effect/landmark/sec_equip/ion
	name = "security ion weapon spawn"

/obj/effect/landmark/sec_equip/shotgun
	name = "security shotgun spawn"

/obj/effect/landmark/sec_equip/pistol
	name = "security pistol spawn"

/obj/effect/landmark/sec_equip/special
	name = "security special weapon spawn"

/obj/effect/landmark/sec_equip/laser
	name = "security laser weapon spawn"

/obj/effect/landmark/sec_equip/ammo
	name = "security ammo spawn"

/obj/effect/landmark/sec_equip/mask
	name = "security mask spawn"