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
			new /obj/item/clothing/gloves/insulated(src)
			new /obj/item/weapon/plastique(src)

		if("guns")
			new /obj/item/weapon/gun/projectile/revolver/syndie(src)
			new /obj/item/ammo_box/speedloader/a357(src)
			new /obj/item/weapon/card/emag(src)
			new /obj/item/weapon/card/id/syndicate(src)
			new /obj/item/weapon/plastique(src)

		if("implant")
			new /obj/item/weapon/implanter/freedom(src)
			new /obj/item/weapon/implanter/uplink(src)
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
			new /obj/item/weapon/gun/projectile/automatic/pistol/stechkin(src)
			new /obj/item/weapon/silencer(src)
			new /obj/item/ammo_box/magazine/stechkin(src)
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
			new /obj/item/weapon/reagent_containers/glass/bottle/sanguisacid(src)
			new /obj/item/weapon/reagent_containers/glass/bottle/bonebreaker(src)
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
			new /obj/item/clothing/gloves/power(src)
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
	new /obj/item/weapon/implanter/freedom(src)

/obj/item/weapon/storage/box/syndie_kit/imp_explosive
	name = "box (E)"

/obj/item/weapon/storage/box/syndie_kit/imp_explosive/atom_init()
	new /obj/item/weapon/implanter/explosive(src)
	. = ..()

/obj/item/weapon/storage/box/syndie_kit/imp_adrenaline/atom_init()
	. = ..()
	new /obj/item/weapon/implanter/adrenaline(src)

/obj/item/weapon/storage/box/syndie_kit/imp_adrenaline
	name = "box (A)"

/obj/item/weapon/storage/box/syndie_kit/imp_emp/atom_init()
	. = ..()
	new /obj/item/weapon/implanter/emp(src)

/obj/item/weapon/storage/box/syndie_kit/imp_emp
	name = "box (M)"

/obj/item/weapon/storage/box/syndie_kit/imp_uplink
	name = "boxed uplink implant (with injector)"

/obj/item/weapon/storage/box/syndie_kit/imp_uplink/atom_init()
	. = ..()
	new /obj/item/weapon/implanter/uplink(src)

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
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/heavy_rig
	name = "box (H)"

/obj/item/weapon/storage/box/syndie_kit/heavy_rig/atom_init()
	. = ..()

	new /obj/item/clothing/head/helmet/space/rig/syndi/heavy(src)
	new /obj/item/clothing/suit/space/rig/syndi/heavy(src)
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

/obj/item/weapon/storage/box/syndie_kit/revolution/posters
	name = "box (RP)"
	desc = "Box containing some provocative posters."
	icon_state = "rev_box"

/obj/item/weapon/storage/box/syndie_kit/revolution/posters/atom_init()
	. = ..()
	for(var/i in 0 to 3)
		new /obj/item/weapon/poster/revolution(src)
	make_exact_fit()

/obj/item/weapon/storage/box/syndie_kit/revolution/armor
	name = "box (RA)"
	desc = "Box containing a set of surplus military armor."
	icon_state = "rev_box"

/obj/item/weapon/storage/box/syndie_kit/revolution/armor/atom_init()
	. = ..()
	new /obj/item/clothing/suit/armor/vest/surplus(src)
	new /obj/item/clothing/head/helmet/surplus(src)
	new /obj/item/clothing/mask/balaclava(src)
	make_exact_fit()

//loadouts

/obj/item/weapon/storage/backpack/dufflebag/nuke/scout
	name = "scout kit"
	startswith = list(
	/obj/item/ammo_box/magazine/c20r/hv,
	/obj/item/ammo_box/magazine/c20r/hp,
	/obj/item/ammo_box/magazine/c20r/imp,
	/obj/item/ammo_box/magazine/c20r = 3,
	/obj/item/weapon/gun/projectile/automatic/c20r,
	/obj/item/weapon/implanter/adrenaline,
	/obj/item/weapon/reagent_containers/hypospray/combat,
	/obj/item/clothing/glasses/thermal/syndi,
	/obj/item/weapon/card/emag,
	)

/obj/item/weapon/storage/backpack/dufflebag/nuke/assaultman
	name = "assaultman kit"
	startswith = list(
	/obj/item/ammo_box/magazine/a74 = 3,
	/obj/item/weapon/gun/projectile/automatic/a74,
	/obj/item/weapon/shield/energy,
	/obj/item/weapon/grenade/flashbang = 4,
	/obj/item/weapon/storage/firstaid/small_firstaid_kit/space,
	/obj/item/weapon/plastique = 2,
	)

/obj/item/weapon/storage/belt/utility/hacker
	startswith = list(
	/obj/item/weapon/multi/hand_drill,
	/obj/item/weapon/multi/jaws_of_life,
	/obj/item/weapon/weldingtool/largetank,
	/obj/item/device/multitool,
	/obj/item/device/flashlight/emp,)

/obj/item/weapon/storage/backpack/dufflebag/nuke/hacker
	name = "hacker kit"
	startswith = list(
	/obj/item/ammo_box/magazine/bulldog = 4,
	/obj/item/ammo_box/magazine/bulldog/stun,
	/obj/item/ammo_box/magazine/bulldog/incendiary,
	/obj/item/weapon/gun/projectile/automatic/bulldog,
	/obj/item/weapon/aiModule/freeform/syndicate,
	/obj/item/weapon/grenade/spawnergrenade/manhacks,
	/obj/item/device/debugger,
	/obj/item/weapon/storage/belt/utility/hacker,
	/obj/item/weapon/card/emag,
	)

/obj/item/weapon/storage/backpack/dufflebag/nuke/sniper
	name = "sniper kit"
	startswith = list(
	/obj/item/ammo_casing/a145 = 6,
	/obj/item/weapon/gun/projectile/heavyrifle,
	/obj/item/device/chameleon,
	/obj/item/clothing/glasses/thermal/syndi,
	/obj/item/weapon/card/emag,
	/obj/item/weapon/pen/edagger,
	/obj/item/weapon/grenade/smokebomb = 3,
	)

/obj/item/weapon/storage/backpack/dufflebag/nuke/demo
	name = "demolition and explosion kit"
	startswith = list(
	/obj/item/ammo_casing/r4046/explosive = 3,
	/obj/item/ammo_casing/r4046/chem/EMP = 3,
	/obj/item/ammo_box/magazine/drozd,
	/obj/item/weapon/gun/projectile/automatic/drozd,
	/obj/item/weapon/plastique = 4,
	/obj/item/weapon/grenade/syndieminibomb = 2,
	/obj/item/device/radio/beacon/syndicate_bomb,
	)

/obj/item/weapon/storage/backpack/dufflebag/nuke/melee
	name = "melee weapon kit"
	startswith = list(
	/obj/item/weapon/dualsaber,
	/obj/item/weapon/gun/energy/crossbow,
	/obj/item/weapon/implanter/adrenaline,
	/obj/item/weapon/implanter/emp,
	/obj/item/weapon/reagent_containers/hypospray/combat,
	/obj/item/weapon/legcuffs/bola/tactical = 2,
	/obj/item/weapon/reagent_containers/food/snacks/soap/syndie,
	/obj/item/weapon/card/emag,
	)

/obj/item/weapon/storage/backpack/dufflebag/nuke/heavygunner
	name = "heavy machine gunner kit"
	startswith = list(
	/obj/item/ammo_box/magazine/saw = 3,
	/obj/item/weapon/gun/projectile/automatic/l6_saw,
	)

/obj/item/weapon/storage/backpack/dufflebag/nuke/medic
	name = "field medic kit"
	startswith = list(
	/obj/item/weapon/gun/medbeam/syndi,
	/obj/item/clothing/glasses/hud/health/night,
	/obj/item/weapon/storage/firstaid/small_firstaid_kit/space,
	/obj/item/weapon/storage/firstaid/small_firstaid_kit/combat,
	/obj/item/weapon/storage/pouch/medical_supply/syndicate,
	/obj/item/clothing/gloves/power,
	)


/obj/item/weapon/storage/backpack/dufflebag/nuke/chemwarfare
	name = "chemical fighter kit"
	startswith = list(
	/obj/item/weapon/reagent_containers/watertank_backpack/syndie,
	/obj/item/weapon/lighter/zippo/syndi,
	/obj/item/weapon/gun/projectile/revolver/syndie,
	/obj/item/ammo_box/speedloader/a357 = 2,
	/obj/item/weapon/melee/energy/sword,
	/obj/item/weapon/grenade/chem_grenade/acid = 3,
	/obj/item/weapon/grenade/chem_grenade/incendiary = 2,
	/obj/item/weapon/card/emag,
	/obj/item/clothing/head/helmet/space/rig/syndi/hazmat,
	/obj/item/clothing/suit/space/rig/syndi/hazmat,
	)


/obj/item/weapon/storage/backpack/dufflebag/nuke/custom
	name = "custom kit"
	startswith = list(
	/obj/item/device/radio/uplink,
	/obj/item/stack/telecrystal/twenty,
	)
