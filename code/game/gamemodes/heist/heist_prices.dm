/atom/movable/var/price = 0

/atom/movable/proc/get_price()
	return price

/obj/item/stack/get_price()
	return price * get_amount()

/obj/machinery/get_price()
	var/my_price = price
	if(stat & BROKEN)
		if(my_price)
			my_price /= 2
	return my_price

/obj/machinery/vending/get_price()
	var/my_total_price = price
	if(stat & BROKEN)
		if(my_total_price)
			my_total_price /= 2
	if(product_records && product_records.len)
		for(var/datum/data/vending_product/VP in product_records)
			my_total_price += VP.amount * VP.price
	return my_total_price

/mob/living/get_price()
	if(price)
		if(stat == DEAD)
			return price / 50
		else if((ishuman(src) || issilicon(src)) && !mind)
			return price / 35
	return price

/mob/living/silicon/robot/price = 36784
/mob/living/silicon/robot/drone/price = 0
/mob/living/silicon/ai/price = 150000
/mob/living/carbon/monkey/price = 50
/mob/living/carbon/human/price = 27841
/mob/living/carbon/human/tajaran/price = 50000
/mob/living/simple_animal/price = 50
/mob/living/simple_animal/corgi/price = 225
/mob/living/carbon/ian/price = 65000
/mob/living/simple_animal/cat/Runtime/price = 55000

/obj/item/ammo_casing/price = 10
/obj/item/ammo_casing/energy/price = 0
/obj/item/ammo_casing/plasma/price = 0
/obj/item/ammo_casing/magic/price = 0

/obj/item/projectile/bullet/price = 50
/obj/item/projectile/bullet/a762/price = 211
/obj/item/projectile/bullet/chameleon/price = 4
/obj/item/projectile/bullet/grenade/r4046/rubber/price = 427
/obj/item/projectile/bullet/gyro/price = 175
/obj/item/projectile/bullet/heavy/a145/price = 708
/obj/item/projectile/bullet/incendiary/price = 522
/obj/item/projectile/bullet/smg/price = 144
/obj/item/projectile/bullet/midbullet2/price = 187
/obj/item/projectile/bullet/midbullet3/price = 210
/obj/item/projectile/bullet/pellet/price = 11
/obj/item/projectile/bullet/revbullet/price = 120
/obj/item/projectile/bullet/rifle1/price = 240
/obj/item/projectile/bullet/rifle2/price = 240
/obj/item/projectile/bullet/stunslug/price = 65
/obj/item/projectile/bullet/weakbullet/price = 27
/obj/item/projectile/missile/price = 1300

/obj/item/ashtray/bronze/price = 30
/obj/item/ashtray/glass/price = 70
/obj/item/ashtray/plastic/price = 5
/obj/item/asteroid/goliath_hide/price = 978
/obj/item/asteroid/hivelord_core/price = 1015
/obj/item/blueprints/price = 120000
/obj/item/bluespace_crystal/price = 14600
/obj/item/bluespace_crystal/artificial/price = 10250
/obj/item/bodybag/cryobag/price = 7000
/obj/item/broken_device/price = 187
/obj/item/candle/price = 15

/obj/item/clothing/glasses/price = 250
/obj/item/clothing/glasses/chameleon/price = 350
/obj/item/clothing/glasses/hud/price = 278
/obj/item/clothing/glasses/hud/security/jensenshades/price = 14000
/obj/item/clothing/glasses/meson/price = 489
/obj/item/clothing/glasses/night/price = 6500
/obj/item/clothing/glasses/thermal/price = 10000
/obj/item/clothing/glasses/thermal/hos_thermals/price = 14000
/obj/item/clothing/glasses/welding/price = 287
/obj/item/clothing/glasses/welding/superior/price = 6200

/obj/item/clothing/gloves/boxing/price = 63
/obj/item/clothing/gloves/combat/price = 880
/obj/item/clothing/gloves/rainbow/price = 443
/obj/item/clothing/gloves/yellow/price = 2181

/obj/item/clothing/head/helmet/price = 3000
/obj/item/clothing/head/helmet/gladiator/price = 432
/obj/item/clothing/head/helmet/HoS/dermal/price = 12888
/obj/item/clothing/head/helmet/cap/price = 3866
/obj/item/clothing/head/helmet/helmet_of_justice/price = 9166
/obj/item/clothing/head/helmet/space/price = 8700
/obj/item/clothing/head/helmet/space/rig/price = 12300
/obj/item/clothing/head/helmet/tactical/price = 4444
/obj/item/clothing/head/welding/price = 250

/obj/item/clothing/shoes/boots/combat/price = 2000
/obj/item/clothing/shoes/boots/galoshes/price = 660
/obj/item/clothing/shoes/boots/price = 440
/obj/item/clothing/shoes/magboots/price = 5550
/obj/item/clothing/shoes/rainbow/price = 176
/obj/item/clothing/shoes/slippers/price = 333
/obj/item/clothing/shoes/boots/swat/price = 3200

/obj/item/clothing/suit/armor/price = 5000
/obj/item/clothing/suit/armor/bulletproof/price = 18500
/obj/item/clothing/suit/armor/captain/price = 9990
/obj/item/clothing/suit/armor/hos/price = 27000
/obj/item/clothing/suit/armor/hos/jensen/price = 29500
/obj/item/clothing/suit/armor/laserproof/price = 16500
/obj/item/clothing/suit/armor/reactive/price = 50000
/obj/item/clothing/suit/armor/swat/price = 33500
/obj/item/clothing/suit/armor/tactical/price = 9990
/obj/item/clothing/suit/captunic/price = 6000
/obj/item/clothing/suit/ianshirt/price = 7500
/obj/item/clothing/suit/space/price = 24456
/obj/item/clothing/suit/space/rig/price = 32547
/obj/item/clothing/suit/storage/labcoat/cmo/price = 5500
/obj/item/clothing/accessory/holobadge/price = 350
/obj/item/clothing/accessory/holster/price = 1600
/obj/item/clothing/accessory/medal/price = 9500
/obj/item/clothing/accessory/medal/gold/captain/price = 70000
/obj/item/clothing/under/M35_Jacket/price = 750
/obj/item/clothing/under/M35_Jacket_Oficer/price = 1000
/obj/item/clothing/under/chameleon/price = 444
/obj/item/clothing/under/dress/dress_cap/price = 654
/obj/item/clothing/under/dress/dress_hop/price = 654
/obj/item/clothing/under/dress/dress_hr/price = 654
/obj/item/clothing/under/ert/price = 777
/obj/item/clothing/under/nt_pmc_uniform/price = 1000
/obj/item/clothing/under/nt_pmc_uniform_light/price = 1000
/obj/item/clothing/under/rank/price = 140
/obj/item/clothing/under/rank/captain/price = 5500
/obj/item/clothing/under/rank/centcom/price = 3500
/obj/item/clothing/under/rank/centcom_commander/price = 3500
/obj/item/clothing/under/rank/centcom_commander_old/price = 3500
/obj/item/clothing/under/rank/centcom_officer/price = 3500
/obj/item/clothing/under/rank/centcom_officer_old/price = 3500
/obj/item/clothing/under/rank/head_of_personnel/price = 5000
/obj/item/clothing/under/rank/head_of_personnel_whimsy/price = 5000
/obj/item/clothing/under/rank/head_of_security/price = 5000
/obj/item/clothing/under/rank/head_of_security_fem/price = 5000
/obj/item/clothing/under/rank/research_director/price = 5000
/obj/item/clothing/under/rank/warden/price = 1765

/obj/item/device/price = 150
/obj/item/device/aicard/price = 13333
/obj/item/device/flash/price = 450
/obj/item/device/flash/synthetic/price = 880
/obj/item/device/flashlight/price = 65
/obj/item/device/guitar/price = 8880
/obj/item/device/mass_spectrometer/price = 2650
/obj/item/device/mass_spectrometer/adv/price = 3020
/obj/item/device/mmi/posibrain/price = 30090
/obj/item/device/radio/headset/price = 150
/obj/item/device/radio/headset/ert/price = 7000
/obj/item/device/radio/headset/heads/price = 5500
/obj/item/device/radio/headset/heads/captain/price = 6000

/obj/item/robot_parts/price = 1000
/obj/item/roller/price = 125
/obj/item/seeds/price = 150
/obj/item/slime_extract/price = 35
/obj/item/slime_extract/adamantine/price = 2500
/obj/item/slime_extract/bluespace/price = 4000
/obj/item/slime_extract/rainbow/price = 8500

/obj/item/stack/medical/advanced/price = 220
/obj/item/stack/medical/splint/price = 130
/obj/item/stack/nanopaste/price = 1250

/obj/item/stack/sheet/animalhide/price = 2000
/obj/item/stack/sheet/cloth/price = 66
/obj/item/stack/sheet/glass/price = 17
/obj/item/stack/sheet/glass/phoronglass/price = 20
/obj/item/stack/sheet/glass/phoronrglass/price = 37
/obj/item/stack/sheet/leather/price = 220
/obj/item/stack/sheet/metal/price = 14
/obj/item/stack/sheet/mineral/diamond/price = 11500
/obj/item/stack/sheet/mineral/gold/price = 730
/obj/item/stack/sheet/mineral/iron/price = 12
/obj/item/stack/sheet/mineral/phoron/price = 30
/obj/item/stack/sheet/mineral/platinum/price = 44
/obj/item/stack/sheet/mineral/silver/price = 340
/obj/item/stack/sheet/mineral/tritium/price = 11
/obj/item/stack/sheet/mineral/uranium/price = 890
/obj/item/stack/sheet/plasteel/price = 18
/obj/item/stack/sheet/rglass/price = 27
/obj/item/stack/sheet/wood/price = 6

/obj/item/weapon/ore/diamond/price = 8500
/obj/item/weapon/ore/glass/price = 8
/obj/item/weapon/ore/gold/price = 440
/obj/item/weapon/ore/iron/price = 6
/obj/item/weapon/ore/phoron/price = 15
/obj/item/weapon/ore/silver/price = 115
/obj/item/weapon/ore/uranium/price = 420

/obj/item/weapon/FixOVein/price = 1250
/obj/item/weapon/bananapeel/price = 650
/obj/item/weapon/bedsheet/price = 240
/obj/item/weapon/bikehorn/rubberducky/price = 5490
/obj/item/weapon/bonegel/price = 1250
/obj/item/weapon/bonesetter/price = 1250
/obj/item/weapon/card/price = 10
/obj/item/weapon/cautery/price = 1250
/obj/item/weapon/stock_parts/cell/price = 850
/obj/item/weapon/stock_parts/cell/crap/price = 30
/obj/item/weapon/stock_parts/cell/high/price = 2400
/obj/item/weapon/stock_parts/cell/hyper/price = 4250
/obj/item/weapon/stock_parts/cell/potato/price = 5
/obj/item/weapon/stock_parts/cell/super/price = 3800
/obj/item/weapon/circular_saw/price = 1250
/obj/item/weapon/claymore/price = 5000
/obj/item/weapon/claymore/religion/price = 2000
/obj/item/weapon/coin/price = 15
/obj/item/weapon/coin/bananium/price = 3000
/obj/item/weapon/coin/diamond/price = 20000
/obj/item/weapon/coin/gold/price = 7300
/obj/item/weapon/coin/uranium/price = 3200
/obj/item/weapon/defibrillator/price = 300
/obj/item/weapon/reagent_containers/spray/extinguisher/price = 140
/obj/item/weapon/gun/price = 2000
/obj/item/weapon/gun/energy/gun/nuclear/price = 7770
/obj/item/weapon/gun/energy/ionrifle/price = 5860
/obj/item/weapon/gun/energy/kinetic_accelerator/price = 2760
/obj/item/weapon/gun/energy/laser/price = 4380
/obj/item/weapon/gun/energy/laser/selfcharging/captain/price = 13500
/obj/item/weapon/gun/energy/laser/retro/price = 5430
/obj/item/weapon/gun/energy/lasercannon/price = 6600
/obj/item/weapon/gun/energy/sniperrifle/price = 5700
/obj/item/weapon/gun/energy/taser/stunrevolver/price = 3200
/obj/item/weapon/gun/energy/taser/price = 1800
/obj/item/weapon/gun/energy/temperature/price = 11000
/obj/item/weapon/gun/energy/toxgun/price = 8300
/obj/item/weapon/gun/energy/xray/price = 14000
/obj/item/weapon/gun/grenadelauncher/price = 3000
/obj/item/weapon/gun/projectile/automatic/colt1911/price = 6500
/obj/item/weapon/gun/projectile/m79/price = 2500
/obj/item/weapon/gun/projectile/shotgun/price = 4000
/obj/item/weapon/gun/projectile/shotgun/combat/price = 6500
/obj/item/weapon/gun/projectile/wjpp/price = 3000
/obj/item/weapon/hand_tele/price = 8000
/obj/item/weapon/hemostat/price = 1250
/obj/item/weapon/implantcase/death_alarm/price = 750
/obj/item/weapon/implantcase/loyalty/price = 850
/obj/item/weapon/implantcase/tracking/price = 400
/obj/item/weapon/inflatable_duck/price = 1110
/obj/item/weapon/lighter/zippo/price = 3000
/obj/item/weapon/medical/teleporter/price = 4440
/obj/item/weapon/melee/baton/price = 1500
/obj/item/weapon/melee/telebaton/price = 1000
/obj/item/weapon/pen/price = 5
/obj/item/weapon/pickaxe/price = 35
/obj/item/weapon/pickaxe/diamond/price = 8000
/obj/item/weapon/pickaxe/drill/diamond_drill/price = 19000
/obj/item/weapon/pickaxe/drill/jackhammer/price = 13000
/obj/item/weapon/pickaxe/gold/price = 5000
/obj/item/weapon/pickaxe/silver/price = 2770
/obj/item/weapon/pinpointer/price = 8000
/obj/item/weapon/rcd/price = 19000
/obj/item/weapon/rcd_ammo/price = 1700
/obj/item/weapon/retractor/price = 1250
/obj/item/weapon/scalpel/price = 1250
/obj/item/weapon/soap/nanotrasen/price = 222
/obj/item/weapon/stamp/price = 3330
/obj/item/weapon/stamp/captain/price = 990
/obj/item/weapon/stamp/clown/price = 25000
/obj/item/weapon/stock_parts/price = 350
/obj/item/weapon/storage/backpack/clown/price = 13000
/obj/item/weapon/storage/belt/champion/price = 8500
/obj/item/weapon/surgicaldrill/price = 1250
/obj/item/weapon/table_parts/price = 95
/obj/item/weapon/tank/jetpack/price = 22000
/obj/item/weapon/tank/price = 45
/obj/item/weapon/twohanded/fireaxe/price = 2500
/obj/item/weapon/weldingtool/price = 120
/obj/item/weapon/weldpack/price = 180

/obj/machinery/deployable/barrier/price = 1500
/obj/machinery/faxmachine/price = 19500
/obj/machinery/flasher/portable/price = 400
/obj/machinery/field_generator/price = 7500
/obj/machinery/floodlight/price = 150
/obj/machinery/giga_drill/price = 40000
/obj/machinery/gravity_generator/price = 7500
/obj/machinery/iv_drip/price = 250
/obj/machinery/nuclearbomb/price = 35333
/obj/machinery/pipedispenser/price = 850
/obj/machinery/recharger/price = 350
/obj/machinery/shield_gen/price = 11000
/obj/machinery/shieldgen/price = 700
/obj/machinery/shieldwallgen/price = 700
/obj/machinery/the_singularitygen/price = 25223
/obj/machinery/vending/price = 15000

/obj/mecha/working/ripley/price = 40000
/obj/mecha/working/hoverpod/price = 25000
/obj/mecha/medical/odysseus/price = 30000
/obj/mecha/combat/price = 70000
/obj/structure/closet/price = 200
/obj/structure/device/piano/price = 25000
/obj/structure/flora/price = 300
/obj/structure/stool/bed/chair/janitorialcart/price = 3000
/obj/structure/mopbucket/price = 1500
/obj/structure/particle_accelerator/price = 20000
/obj/structure/sign/price = 987
