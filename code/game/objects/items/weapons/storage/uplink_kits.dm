/obj/item/weapon/storage/box/syndicate
	icon_state = "doom_box"

/obj/item/weapon/storage/box/syndicate/atom_init()
	. = ..()
	var/tagname = pick("bloodyspai", "stealth", "screwed", "ninja", "guns", "implant", "hacker", "smoothoperator", "poisons", "gadgets")
	switch (tagname)
		if("bloodyspai")
			new /obj/item/clothing/under/chameleon(src)
			new /obj/item/clothing/mask/gas/voice(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/clothing/shoes/syndigaloshes(src)
			new /obj/item/weapon/melee/powerfist(src)
			new /obj/item/device/camera_bug(src)
			new /obj/item/weapon/grenade/clusterbuster/soap(src)

		if("stealth")
			new /obj/item/weapon/gun/energy/crossbow(src)
			new /obj/item/device/healthanalyzer/rad_laser(src)
			new /obj/item/device/chameleon(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/clothing/gloves/black/strip(src)

		if("screwed")
			for (var/i in 1 to 2)
				new /obj/item/weapon/grenade/syndieminibomb(src)
			new /obj/item/device/powersink(src)
			new /obj/item/clothing/suit/space/syndicate(src)
			new /obj/item/clothing/head/helmet/space/syndicate(src)
			new /obj/item/clothing/gloves/yellow(src)
			new /obj/item/weapon/plastique(src)

		if("guns")
			new /obj/item/weapon/gun/projectile/revolver/syndie(src)
			new /obj/item/ammo_box/a357(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/weapon/plastique(src)

		if("implant")
			var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(src)
			O.imp = new /obj/item/weapon/implant/freedom(O)
			var/obj/item/weapon/implanter/U = new /obj/item/weapon/implanter(src)
			U.imp = new /obj/item/weapon/implant/uplink(U)
			new /obj/item/weapon/implanter/explosive(src)
			new /obj/item/weapon/implanter/adrenaline(src)
			new /obj/item/weapon/implanter/emp(src)
			new /obj/item/weapon/implanter/storage(src)

		if("hacker")
			new /obj/item/weapon/aiModule/freeform/syndicate(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/device/encryptionkey/binary(src)
			new /obj/item/device/multitool/ai_detect(src)
			new /obj/item/device/flashlight/emp(src)

		if("smoothoperator")
			new /obj/item/weapon/gun/projectile/automatic/pistol(src)
			new /obj/item/weapon/silencer(src)
			new /obj/item/ammo_box/magazine/m9mm(src)
			new /obj/item/weapon/reagent_containers/food/snacks/soap/syndie(src)
			new /obj/item/weapon/storage/bag/trash(src)
			new /obj/item/bodybag(src)
			new /obj/item/clothing/under/suit_jacket/reinforced(src)
			new /obj/item/clothing/shoes/laceup(src)
			new /obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate(src)
			new /obj/item/clothing/glasses/sunglasses/big(src)


		if("poisons")
			new /obj/item/weapon/reagent_containers/glass/bottle/carpotoxin(src)
			new /obj/item/weapon/reagent_containers/glass/bottle/alphaamanitin(src)
			new /obj/item/weapon/reagent_containers/glass/bottle/chefspecial(src)
			new /obj/item/weapon/reagent_containers/glass/bottle/cyanide(src)
			new /obj/item/weapon/reagent_containers/glass/bottle/chloralhydrate(src)
			new /obj/item/weapon/reagent_containers/syringe(src)
			new /obj/item/weapon/gun/syringe/syndicate(src)

		if("ninja")
			new /obj/item/weapon/pen/edagger(src)
			new /obj/item/weapon/melee/energy/sword/black(src)
			new /obj/item/device/powersink(src)
			new /obj/item/weapon/storage/box/syndie_kit/throwing_weapon(src)
			new /obj/item/clothing/under/color/black(src)
			new /obj/item/clothing/head/chaplain_hood(src)
			new /obj/item/clothing/glasses/thermal/syndi(src)
			new /obj/item/clothing/mask/gas/voice(src)
			new /obj/item/clothing/gloves/black/strip(src)
			new /obj/item/clothing/shoes/syndigaloshes(src)
			new /obj/item/weapon/storage/backpack/satchel/flat(src)

		if("gadgets")
			new /obj/item/clothing/gloves/yellow(src)
			new /obj/item/clothing/glasses/thermal/syndi(src)
			new /obj/item/device/flashlight/emp(src)
			new /obj/item/clothing/shoes/syndigaloshes(src)
			new /obj/item/device/multitool/ai_detect(src)
			new /obj/item/device/chameleon(src)

	tag = tagname
	make_exact_fit()


/obj/item/weapon/storage/box/syndie_kit
	name = "box"
	desc = "A sleek, sturdy box."
	icon_state = "doom_box"

/obj/item/weapon/storage/box/syndie_kit/bonepen
	name = "Prototype Bone Repair Kit"
	desc = "Bonehurting feeling erupts you."
/obj/item/weapon/storage/box/syndie_kit/bonepen/atom_init()
	. = ..()
	for(var/i in 0 to 3)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/bonepen(src)

/obj/item/weapon/storage/box/syndie_kit/imp_freedom
	name = "boxed freedom implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_freedom/atom_init()
	. = ..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/freedom(O)
	O.update()

/obj/item/weapon/storage/box/syndie_kit/imp_compress
	name = "box (C)"

/obj/item/weapon/storage/box/syndie_kit/imp_compress/atom_init()
	new /obj/item/weapon/implanter/compressed(src)
	. = ..()

/obj/item/weapon/storage/box/syndie_kit/imp_explosive
	name = "box (E)"

/obj/item/weapon/storage/box/syndie_kit/imp_explosive/atom_init()
	new /obj/item/weapon/implanter/explosive(src)
	. = ..()

/obj/item/weapon/storage/box/syndie_kit/imp_adrenaline/atom_init()
	. = ..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/adrenaline(O)
	O.update()

/obj/item/weapon/storage/box/syndie_kit/imp_adrenaline
	name = "box (A)"

/obj/item/weapon/storage/box/syndie_kit/imp_emp/atom_init()
	. = ..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/emp(O)
	O.update()

/obj/item/weapon/storage/box/syndie_kit/imp_emp
	name = "box (M)"

/obj/item/weapon/storage/box/syndie_kit/imp_uplink
	name = "boxed uplink implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_uplink/atom_init()
	. = ..()
	var/obj/item/weapon/implanter/O = new(src)
	O.imp = new /obj/item/weapon/implant/uplink(O)
	O.update()

/obj/item/weapon/storage/box/syndie_kit/space
	name = "boxed space suit and helmet"

/obj/item/weapon/storage/box/syndie_kit/space/atom_init()
	. = ..()
	new /obj/item/clothing/suit/space/syndicate(src)
	new /obj/item/clothing/head/helmet/space/syndicate(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/chameleon
	name = "Chameleon Kit"
	desc = "Comes with all the clothes you need to impersonate most people.  Acting lessons sold seperately."

/obj/item/weapon/storage/box/syndie_kit/chameleon/atom_init()
	. = ..()
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/head/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/weapon/storage/backpack/chameleon(src)
	new /obj/item/clothing/gloves/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/clothing/glasses/chameleon(src)
	new /obj/item/weapon/gun/projectile/chameleon(src)
	new /obj/item/ammo_box/magazine/chameleon(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/throwing_weapon
	name = "box (F)"

/obj/item/weapon/storage/box/syndie_kit/throwing_weapon/atom_init()
	. = ..()
	for (var/i in 1 to 2)
		new /obj/item/weapon/legcuffs/bola/tactical(src)
	for (var/i in 1 to 5)
		new /obj/item/weapon/throwing_star(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/cutouts
	name = "box (G)"

/obj/item/weapon/storage/box/syndie_kit/cutouts/atom_init()
	. = ..()
	for(var/i = 1 to 3)
		new /obj/item/cardboard_cutout(src)
	new /obj/item/toy/crayon/rainbow (src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/rig
	name = "box (J)"

/obj/item/weapon/storage/box/syndie_kit/rig/atom_init()
	. = ..()

	new /obj/item/clothing/head/helmet/space/rig/syndi(src)
	new /obj/item/clothing/suit/space/rig/syndi(src)
	new /obj/item/clothing/shoes/magboots/syndie(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/heavy_rig
	name = "box (H)"

/obj/item/weapon/storage/box/syndie_kit/heavy_rig/atom_init()
	. = ..()

	new /obj/item/clothing/head/helmet/space/rig/syndi/heavy(src)
	new /obj/item/clothing/suit/space/rig/syndi/heavy(src)
	new /obj/item/clothing/shoes/magboots/syndie(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/armor
	name = "box (K)"

/obj/item/weapon/storage/box/syndie_kit/armor/atom_init()
	. = ..()
	new /obj/item/clothing/suit/armor/syndiassault(src)
	if(prob(50))
		new /obj/item/clothing/head/helmet/syndiassault(src)
	else
		new /obj/item/clothing/head/helmet/syndiassault/alternate(src)
	make_exact_fit()


/obj/item/weapon/storage/box/syndie_kit/light_armor
	name = "box (L)"

/obj/item/weapon/storage/box/syndie_kit/light_armor/atom_init()
	. = ..()
	new /obj/item/clothing/suit/armor/syndilight(src)
	new /obj/item/clothing/head/helmet/syndilight(src)
	make_exact_fit()


/obj/item/weapon/storage/box/syndie_kit/cheap_armor
	name = "box (CA)"

/obj/item/weapon/storage/box/syndie_kit/cheap_armor/atom_init()
	. = ..()
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/helmet(src)
	make_exact_fit()


/obj/item/weapon/storage/box/syndie_kit/fake
	name = "box (B)"
	desc = "This set allows you to forge various documents at the station."

/obj/item/weapon/storage/box/syndie_kit/fake/atom_init()
	. = ..()
	new /obj/item/weapon/pen/chameleon(src)
	new /obj/item/weapon/stamp/chameleon(src)

/obj/item/weapon/storage/box/syndie_kit/posters
	name = "box (P)"

/obj/item/weapon/storage/box/syndie_kit/posters/atom_init()
	. = ..()
	for(var/i in 0 to 6)
		new /obj/item/weapon/poster/contraband(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/merch
	name = "box (M)"
	desc = "Box containing some Syndicate merchandise for real agents!"
	icon_state = "syndie_box"

/obj/item/weapon/storage/box/syndie_kit/merch/atom_init()
	. = ..()
	new /obj/item/clothing/head/soft/red(src)
	new /obj/item/clothing/suit/syndieshirt(src)
	new /obj/item/toy/syndicateballoon(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/chemical
	name = "box (CH)"
	desc = "Box containing Spacegeneva violation."
	icon_state = "syndie_box"

/obj/item/weapon/storage/box/syndie_kit/chemical/atom_init()
	. = ..()
	new /obj/item/clothing/head/helmet/space/rig/syndi/hazmat(src)
	new /obj/item/clothing/suit/space/rig/syndi/hazmat(src)
	new /obj/item/clothing/shoes/magboots/syndie(src)
	new /obj/item/weapon/reagent_containers/watertank_backpack/syndie(src)
	new /obj/item/weapon/lighter/zippo(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/drone
	name = "box (D)"
	desc = "Box containing a brand-new Cybersun Industries RC drone."
	icon_state = "syndie_box"

/obj/item/weapon/storage/box/syndie_kit/drone/atom_init()
	. = ..()
	var/obj/item/weapon/holder/syndi_drone/drone_holder = new /obj/item/weapon/holder/syndi_drone(src)
	var/obj/item/clothing/glasses/syndidroneRC/rc_glasses = new /obj/item/clothing/glasses/syndidroneRC(src)
	rc_glasses.slave = new /mob/living/silicon/robot/drone/syndi(drone_holder)
	make_exact_fit()

//loadouts

/obj/item/weapon/storage/box/syndie_kit/nuke/scout
	name = "scout kit"

/obj/item/weapon/storage/box/syndie_kit/nuke/scout/atom_init()
	. = ..()
	new /obj/item/ammo_box/magazine/m12mm/hv(src)
	new /obj/item/ammo_box/magazine/m12mm/hp(src)
	new /obj/item/ammo_box/magazine/m12mm/imp(src)
	for (var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/m12mm(src)
	new /obj/item/weapon/gun/projectile/automatic/c20r(src)
	new /obj/item/weapon/implanter/adrenaline(src)
	new /obj/item/weapon/reagent_containers/hypospray/combat(src)
	new /obj/item/clothing/glasses/thermal/syndi(src)
	new	/obj/item/weapon/card/emag(src)
	new /obj/item/clothing/suit/space/rig/syndi(src)
	new /obj/item/clothing/head/helmet/space/rig/syndi(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/nuke/assaultman
	name = "assaultman kit"

/obj/item/weapon/storage/box/syndie_kit/nuke/assaultman/atom_init()
	. = ..()
	for (var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/a74mm(src)
	new /obj/item/weapon/gun/projectile/automatic/a74(src)
	new /obj/item/weapon/shield/energy(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/weapon/storage/firstaid/small_firstaid_kit/space(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/plastique(src)
	new /obj/item/clothing/suit/space/rig/syndi(src)
	new /obj/item/clothing/head/helmet/space/rig/syndi(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/nuke/hacker
	name = "hacker kit"

/obj/item/weapon/storage/box/syndie_kit/nuke/hacker/atom_init()
	. = ..()
	for (var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g/stun(src)
	new /obj/item/ammo_box/magazine/m12g/incendiary(src)
	new /obj/item/weapon/gun/projectile/automatic/bulldog(src)
	new /obj/item/weapon/grenade/spawnergrenade/manhacks(src)
	new /obj/item/weapon/wrench/power(src)
	new /obj/item/weapon/wirecutters/power(src)
	new /obj/item/weapon/weldingtool/largetank(src)
	new /obj/item/device/debugger(src)
	new /obj/item/device/multitool(src)
	new /obj/item/clothing/glasses/meson(src)
	new	/obj/item/device/hud_calibrator(src)
	new /obj/item/weapon/card/emag(src)
	new /obj/item/device/flashlight/emp(src)
	new /obj/item/clothing/suit/space/rig/syndi(src)
	new /obj/item/clothing/head/helmet/space/rig/syndi(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/nuke/sniper
	name = "sniper kit"

/obj/item/weapon/storage/box/syndie_kit/nuke/sniper/atom_init()
	. = ..()
	for (var/i in 1 to 6)
		new /obj/item/ammo_casing/a145(src)
	new /obj/item/weapon/gun/projectile/heavyrifle(src)
	new /obj/item/device/chameleon(src)
	new /obj/item/clothing/glasses/thermal/syndi(src)
	new /obj/item/weapon/card/emag(src)
	new /obj/item/weapon/pen/edagger(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/grenade/smokebomb(src)
	new /obj/item/clothing/suit/space/rig/syndi(src)
	new /obj/item/clothing/head/helmet/space/rig/syndi(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/nuke/demo
	name = "demolition and explosion kit"

/obj/item/weapon/storage/box/syndie_kit/nuke/demo/atom_init()
	. = ..()
	for (var/i in 1 to 3)
		new /obj/item/ammo_casing/r4046/explosive(src)
	new /obj/item/ammo_box/magazine/drozd127(src)
	new /obj/item/weapon/gun/projectile/automatic/drozd(src)
	for (var/i in 1 to 5)
		new /obj/item/weapon/plastique(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/grenade/syndieminibomb(src)
	new /obj/item/device/radio/beacon/syndicate_bomb(src)
	new /obj/item/weapon/storage/box/emps(src)
	new /obj/item/clothing/suit/space/rig/syndi(src)
	new /obj/item/clothing/head/helmet/space/rig/syndi(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/nuke/melee
	name = "melee weapon kit"

/obj/item/weapon/storage/box/syndie_kit/nuke/melee/atom_init()
	. = ..()
	new /obj/item/weapon/melee/energy/sword(src)
	new	/obj/item/weapon/gun/energy/crossbow(src)
	new /obj/item/weapon/implanter/adrenaline(src)
	new /obj/item/weapon/implanter/emp(src)
	new /obj/item/weapon/reagent_containers/hypospray/combat(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/legcuffs/bola/tactical(src)
	new /obj/item/weapon/reagent_containers/food/snacks/soap/syndie(src)
	new /obj/item/weapon/card/emag(src)
	new /obj/item/clothing/suit/space/rig/syndi(src)
	new /obj/item/clothing/head/helmet/space/rig/syndi(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/nuke/heavygunner
	name = "heavy machine gunner kit"

/obj/item/weapon/storage/box/syndie_kit/nuke/heavygunner/atom_init()
	. = ..()
	for (var/i in 1 to 2)
		new /obj/item/ammo_box/magazine/m762(src)
	new	/obj/item/weapon/gun/projectile/automatic/l6_saw(src)
	new /obj/item/clothing/suit/space/rig/syndi/heavy(src)
	new	/obj/item/clothing/head/helmet/space/rig/syndi/heavy(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/nuke/custom
	name = "custom kit"

/obj/item/weapon/storage/box/syndie_kit/nuke/custom/atom_init()
	. = ..()
	new /obj/item/device/radio/uplink(src)
	new /obj/item/stack/telecrystal/twenty(src)
	new /obj/item/clothing/suit/space/rig/syndi(src)
	new /obj/item/clothing/head/helmet/space/rig/syndi(src)
