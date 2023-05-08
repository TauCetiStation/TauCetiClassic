/*
 *	Everything derived from the common cardboard box.
 *	Basically everything except the original is a kit (starts full).
 *
 *	Contains:
 *		 -Box -Starter boxes (survival/engineer)
 *		 -Alien -Latex gloves
 *		 -Masks -Syringes
 *		 -Beakers -Injectors
 *		 -Beanbags -Flashbangs
 *		 -Teargas -Smokegrenades
 *		 -Rubber 40x46mm -EMPs
 *		 -Track implant -Chemical implant
 *		 -Stimpack -Prescription glasses
 *		 -Drinking glasses -Death alarm
 *		 -Condiment bottles -Paper cups
 *		 -Donk-pockets -Monkey cube
 *		 -Farwa cube -Stok cube
 *		 -Neaera cube -Spare IDs
 *		 -R.O.B.U.S.T. Cartridges -Handcuffs
 *		 -Alien handcuffs -Mousetraps
 *		 -Pill bottles -Snap pop
 *		 -Matchbox -Autoinjectors
 *		 -Replacement bulbs -Replacement tubes
 *		 -Mixed replacement lights -Body bags
 *		 -Holobadge -Evidence bag
 *		 -Solution tray -Spare PDAs
 *		 -Shotgun ammo -Hair dyes
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

//Box
/obj/item/weapon/storage/box
	name = "box"
	desc = "It's just an ordinary box. Nothing special."
	icon_state = "box"
	item_state = "syringe_kit"
	max_storage_space = DEFAULT_BOX_STORAGE
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

//Survival boxes, given by NanoTrasen
/obj/item/weapon/storage/box/survival
	name = "emergency box"
	desc = "It's a box, issued to every employee of NanoTrasen, contains essential items for employee's survival incase of an emergency. It has a ton of ads all over its back."

//Engineer
/obj/item/weapon/storage/box/engineer
	name = "emergency box"
	desc = "It's a box, issued to every employee of NanoTrasen, contains a mask and a spare air tank. It has a ton of ads all over its back."
	startswith = list(/obj/item/clothing/mask/breath, /obj/item/weapon/tank/emergency_oxygen/engi)

//Alien
/obj/item/weapon/storage/box/alien
	name = "alien box"
	icon_state = "alien_box"

//Latex gloves
/obj/item/weapon/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains latex and nitrile gloves. Must-have of a doctor."
	icon_state = "latex_box"
	startswith = list(
						/obj/item/clothing/gloves/latex,
						/obj/item/clothing/gloves/latex,
						/obj/item/clothing/gloves/latex,
						/obj/item/clothing/gloves/latex,
						/obj/item/clothing/gloves/latex,
						/obj/item/clothing/gloves/latex/nitrile,
						/obj/item/clothing/gloves/latex/nitrile
					)

//Masks
/obj/item/weapon/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile_mask_box"
	startswith = list(
						/obj/item/clothing/mask/surgical,
						/obj/item/clothing/mask/surgical,
						/obj/item/clothing/mask/surgical,
						/obj/item/clothing/mask/surgical,
						/obj/item/clothing/mask/surgical,
						/obj/item/clothing/mask/surgical,
						/obj/item/clothing/mask/surgical
					)

//Syringes
/obj/item/weapon/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	icon_state = "syringe_box"
	startswith = list(
						/obj/item/weapon/reagent_containers/syringe,
						/obj/item/weapon/reagent_containers/syringe,
						/obj/item/weapon/reagent_containers/syringe,
						/obj/item/weapon/reagent_containers/syringe,
						/obj/item/weapon/reagent_containers/syringe,
						/obj/item/weapon/reagent_containers/syringe,
						/obj/item/weapon/reagent_containers/syringe
					)

//Beakers
/obj/item/weapon/storage/box/beakers
	name = "box of beakers"
	icon_state = "beaker_box"
	startswith = list(
						/obj/item/weapon/reagent_containers/glass/beaker,
						/obj/item/weapon/reagent_containers/glass/beaker,
						/obj/item/weapon/reagent_containers/glass/beaker,
						/obj/item/weapon/reagent_containers/glass/beaker,
						/obj/item/weapon/reagent_containers/glass/beaker,
						/obj/item/weapon/reagent_containers/glass/beaker,
						/obj/item/weapon/reagent_containers/glass/beaker
					)

//Injectors
/obj/item/weapon/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors it seems."
	icon_state = "dnainjector_box"
	startswith = list(
						/obj/item/weapon/dnainjector/h2m,
						/obj/item/weapon/dnainjector/h2m,
						/obj/item/weapon/dnainjector/h2m,
						/obj/item/weapon/dnainjector/m2h,
						/obj/item/weapon/dnainjector/m2h,
						/obj/item/weapon/dnainjector/m2h
					)

//Beanbags
/obj/item/weapon/storage/box/beanbags
	name = "box of beanbag shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	icon_state = "shotgun_ammo_beanbag"
	startswith = list(
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag
					)

//Flashbangs
/obj/item/weapon/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<span class='bold'>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</span>"
	icon_state = "flashbang_box"
	startswith = list(
						/obj/item/weapon/grenade/flashbang,
						/obj/item/weapon/grenade/flashbang,
						/obj/item/weapon/grenade/flashbang,
						/obj/item/weapon/grenade/flashbang,
						/obj/item/weapon/grenade/flashbang,
						/obj/item/weapon/grenade/flashbang,
						/obj/item/weapon/grenade/flashbang
					)

//Teargas
/obj/item/weapon/storage/box/teargas
	name = "box of tear gas grenades (WARNING)"
	desc = "<span class='bold'>WARNING: These devices are extremely dangerous and can cause blindness and skin irritation.</span>"
	icon_state = "flashbang_box"
	startswith = list(
						/obj/item/weapon/grenade/chem_grenade/teargas,
						/obj/item/weapon/grenade/chem_grenade/teargas,
						/obj/item/weapon/grenade/chem_grenade/teargas,
						/obj/item/weapon/grenade/chem_grenade/teargas,
						/obj/item/weapon/grenade/chem_grenade/teargas,
						/obj/item/weapon/grenade/chem_grenade/teargas,
						/obj/item/weapon/grenade/chem_grenade/teargas
					)

//Smokegrenades
/obj/item/weapon/storage/box/smokegrenades
	name = "box of smoke grenades"
	desc = "This box contains smoke grenades it seems."
	icon_state = "flashbang_box"
	startswith = list(
						/obj/item/weapon/grenade/smokebomb,
						/obj/item/weapon/grenade/smokebomb,
						/obj/item/weapon/grenade/smokebomb,
						/obj/item/weapon/grenade/smokebomb,
						/obj/item/weapon/grenade/smokebomb,
						/obj/item/weapon/grenade/smokebomb,
						/obj/item/weapon/grenade/smokebomb
					)

/obj/item/weapon/storage/box/r4046
	name = "box of 40x46mm rubber grenades (WARNING)"
	desc = "<span class='bold'>WARNING: These devices are extremely dangerous and can cause injury.</span>"
	icon_state = "4046_box(r)"

//Rubber 40x46mm
/obj/item/weapon/storage/box/r4046/rubber
	name = "box of 40x46mm rubber grenades (WARNING)"
	desc = "<span class='bold'>WARNING: These devices are extremely dangerous and can cause injury.</span>"
	icon_state = "4046_box(r)"
	startswith = list(
						/obj/item/ammo_casing/r4046,
						/obj/item/ammo_casing/r4046,
						/obj/item/ammo_casing/r4046,
						/obj/item/ammo_casing/r4046,
						/obj/item/ammo_casing/r4046,
						/obj/item/ammo_casing/r4046,
						/obj/item/ammo_casing/r4046
					)

//Teargas 40x46mm
/obj/item/weapon/storage/box/r4046/teargas
	name = "box of 40x46mm teargas grenades (WARNING)"
	desc = "<span class='bold'>WARNING: These devices are extremely dangerous and can cause injury.</span>"
	icon_state = "4046_box(gas)"
	startswith = list(
						/obj/item/ammo_casing/r4046/chem/teargas,
						/obj/item/ammo_casing/r4046/chem/teargas,
						/obj/item/ammo_casing/r4046/chem/teargas,
						/obj/item/ammo_casing/r4046/chem/teargas,
						/obj/item/ammo_casing/r4046/chem/teargas,
						/obj/item/ammo_casing/r4046/chem/teargas,
						/obj/item/ammo_casing/r4046/chem/teargas
					)

//EMP 40x46mm
/obj/item/weapon/storage/box/r4046/EMP
	name = "box of 40x46mm EMP grenades (WARNING)"
	desc = "<span class='bold'>WARNING: These devices are extremely dangerous and can cause injury.</span>"
	icon_state = "4046_box(emp)"
	startswith = list(
						/obj/item/ammo_casing/r4046/chem/EMP,
						/obj/item/ammo_casing/r4046/chem/EMP,
						/obj/item/ammo_casing/r4046/chem/EMP,
						/obj/item/ammo_casing/r4046/chem/EMP,
						/obj/item/ammo_casing/r4046/chem/EMP,
						/obj/item/ammo_casing/r4046/chem/EMP,
						/obj/item/ammo_casing/r4046/chem/EMP
					)

//EMPs
/obj/item/weapon/storage/box/emps
	name = "box of emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang_box"
	startswith = list(
						/obj/item/weapon/grenade/empgrenade,
						/obj/item/weapon/grenade/empgrenade,
						/obj/item/weapon/grenade/empgrenade,
						/obj/item/weapon/grenade/empgrenade,
						/obj/item/weapon/grenade/empgrenade
					)

//Track implant
/obj/item/weapon/storage/box/trackimp
	name = "boxed tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant_box"
	startswith = list(
						/obj/item/weapon/implanter,
						/obj/item/weapon/implantpad,
						/obj/item/weapon/locator,
						/obj/item/weapon/implantcase/tracking,
						/obj/item/weapon/implantcase/tracking,
						/obj/item/weapon/implantcase/tracking,
						/obj/item/weapon/implantcase/tracking
					)

//Chemical implant
/obj/item/weapon/storage/box/chemimp
	name = "boxed chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant_box"
	startswith = list(
						/obj/item/weapon/implanter,
						/obj/item/weapon/implantpad,
						/obj/item/weapon/implantcase/chem,
						/obj/item/weapon/implantcase/chem,
						/obj/item/weapon/implantcase/chem,
						/obj/item/weapon/implantcase/chem,
						/obj/item/weapon/implantcase/chem
					)

//Stimpack
/obj/item/weapon/storage/box/autoinjector/stimpack
	name = "stimpack value kit"
	desc = "A box with several stimpack autoinjectors for the economical miner."
	icon_state = "box"
	startswith = list(
						/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack,
						/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack,
						/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack,
						/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack,
						/obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack
					)

//Prescription glasses
/obj/item/weapon/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses_box"
	startswith = list(
						/obj/item/clothing/glasses/regular,
						/obj/item/clothing/glasses/regular,
						/obj/item/clothing/glasses/regular,
						/obj/item/clothing/glasses/regular,
						/obj/item/clothing/glasses/regular,
						/obj/item/clothing/glasses/regular,
						/obj/item/clothing/glasses/regular
					)

//Drinking glasses
/obj/item/weapon/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."
	icon_state = "drinking_glass_box"
	startswith = list(
						/obj/item/weapon/reagent_containers/food/drinks/drinkingglass,
						/obj/item/weapon/reagent_containers/food/drinks/drinkingglass,
						/obj/item/weapon/reagent_containers/food/drinks/drinkingglass,
						/obj/item/weapon/reagent_containers/food/drinks/drinkingglass,
						/obj/item/weapon/reagent_containers/food/drinks/drinkingglass,
						/obj/item/weapon/reagent_containers/food/drinks/drinkingglass
					)

//Death alarm
/obj/item/weapon/storage/box/cdeathalarm_kit
	name = "Death Alarm Kit"
	desc = "Box of stuff used to implant death alarms."
	icon_state = "implant_box"
	startswith = list(
						/obj/item/weapon/implanter,
						/obj/item/weapon/implantcase/death_alarm,
						/obj/item/weapon/implantcase/death_alarm,
						/obj/item/weapon/implantcase/death_alarm,
						/obj/item/weapon/implantcase/death_alarm,
						/obj/item/weapon/implantcase/death_alarm,
						/obj/item/weapon/implantcase/death_alarm
					)

//Condiment bottles
/obj/item/weapon/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."
	startswith = list(
						/obj/item/weapon/reagent_containers/food/condiment,
						/obj/item/weapon/reagent_containers/food/condiment,
						/obj/item/weapon/reagent_containers/food/condiment,
						/obj/item/weapon/reagent_containers/food/condiment,
						/obj/item/weapon/reagent_containers/food/condiment,
						/obj/item/weapon/reagent_containers/food/condiment
					)

//Paper cups
/obj/item/weapon/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	icon_state = "cups_box"
	startswith = list(
						/obj/item/weapon/reagent_containers/food/drinks/sillycup,
						/obj/item/weapon/reagent_containers/food/drinks/sillycup,
						/obj/item/weapon/reagent_containers/food/drinks/sillycup,
						/obj/item/weapon/reagent_containers/food/drinks/sillycup,
						/obj/item/weapon/reagent_containers/food/drinks/sillycup,
						/obj/item/weapon/reagent_containers/food/drinks/sillycup,
						/obj/item/weapon/reagent_containers/food/drinks/sillycup
					)

//Donk-pockets
/obj/item/weapon/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<span class='bold'>Instructions:</span> Heat in microwave. Product will cool if not eaten within seven minutes."
	icon_state = "donk_box"
	startswith = list(
						/obj/item/weapon/reagent_containers/food/snacks/donkpocket,
						/obj/item/weapon/reagent_containers/food/snacks/donkpocket,
						/obj/item/weapon/reagent_containers/food/snacks/donkpocket,
						/obj/item/weapon/reagent_containers/food/snacks/donkpocket,
						/obj/item/weapon/reagent_containers/food/snacks/donkpocket,
						/obj/item/weapon/reagent_containers/food/snacks/donkpocket
					)

//Monkey cube
/obj/item/weapon/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/food.dmi'
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/monkeycube)
	startswith = list(
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped
					)

//Farwa cube
/obj/item/weapon/storage/box/monkeycubes/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes, shipped from Ahdomai. Just add water!"
	startswith = list(
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube
					)

//Stok cube
/obj/item/weapon/storage/box/monkeycubes/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes, shipped from Moghes. Just add water!"
	startswith = list(
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube
					)

//Neaera cube
/obj/item/weapon/storage/box/monkeycubes/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes, shipped from Jargon 4. Just add water!"
	startswith = list(
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube,
						/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube
					)

//Spare IDs
/obj/item/weapon/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id_box"
	startswith = list(
						/obj/item/weapon/card/id,
						/obj/item/weapon/card/id,
						/obj/item/weapon/card/id,
						/obj/item/weapon/card/id,
						/obj/item/weapon/card/id,
						/obj/item/weapon/card/id,
						/obj/item/weapon/card/id
					)

//R.O.B.U.S.T. Cartridges
/obj/item/weapon/storage/box/seccarts
	name = "box of spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon_state = "pda_box"
	startswith = list(
						/obj/item/weapon/cartridge/security,
						/obj/item/weapon/cartridge/security,
						/obj/item/weapon/cartridge/security,
						/obj/item/weapon/cartridge/security,
						/obj/item/weapon/cartridge/security,
						/obj/item/weapon/cartridge/security,
						/obj/item/weapon/cartridge/security
					)

//Handcuffs
/obj/item/weapon/storage/box/handcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff_box"
	startswith = list(
						/obj/item/weapon/handcuffs,
						/obj/item/weapon/handcuffs,
						/obj/item/weapon/handcuffs,
						/obj/item/weapon/handcuffs,
						/obj/item/weapon/handcuffs,
						/obj/item/weapon/handcuffs,
						/obj/item/weapon/handcuffs
					)

//Alien handcuffs
/obj/item/weapon/storage/box/alienhandcuffs
	name = "box of spare alien handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "aliencuffs_box"
	startswith = list(
						/obj/item/weapon/handcuffs/alien,
						/obj/item/weapon/handcuffs/alien,
						/obj/item/weapon/handcuffs/alien,
						/obj/item/weapon/handcuffs/alien,
						/obj/item/weapon/handcuffs/alien,
						/obj/item/weapon/handcuffs/alien,
						/obj/item/weapon/handcuffs/alien
					)

//Mousetraps
/obj/item/weapon/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<FONT color='red'><B>WARNING:</B></FONT> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps_box"
	startswith = list(
						/obj/item/device/assembly/mousetrap,
						/obj/item/device/assembly/mousetrap,
						/obj/item/device/assembly/mousetrap,
						/obj/item/device/assembly/mousetrap,
						/obj/item/device/assembly/mousetrap,
						/obj/item/device/assembly/mousetrap
					)

//Pill bottles
/obj/item/weapon/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	icon_state = "pills_box"
	startswith = list(
						/obj/item/weapon/storage/pill_bottle,
						/obj/item/weapon/storage/pill_bottle,
						/obj/item/weapon/storage/pill_bottle,
						/obj/item/weapon/storage/pill_bottle,
						/obj/item/weapon/storage/pill_bottle,
						/obj/item/weapon/storage/pill_bottle,
						/obj/item/weapon/storage/pill_bottle
					)

//Snap pop
/obj/item/weapon/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	storage_slots = 8
	can_hold = list(/obj/item/toy/snappop)

/obj/item/weapon/storage/box/snappops/atom_init()
	. = ..()
	for(var/i in 1 to storage_slots)
		new /obj/item/toy/snappop(src)

//Matchbox
/obj/item/weapon/storage/box/matches
	name = "matchbox"
	desc = "A small box of 'Space-Proof' premium matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	storage_slots = 10
	w_class = SIZE_MINUSCULE
	slot_flags = SLOT_FLAGS_BELT
	can_hold = list(/obj/item/weapon/match)

/obj/item/weapon/storage/box/matches/atom_init()
	. = ..()
	for(var/i in 1 to storage_slots)
		new /obj/item/weapon/match(src)

/obj/item/weapon/storage/box/matches/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/match))
		var/obj/item/weapon/match/M = I
		if(M.lit || M.burnt)
			return

		if(prob(20))
			playsound(src, 'sound/items/matchstick_hit.ogg', VOL_EFFECTS_MASTER, 20)
			return

		playsound(src, 'sound/items/matchstick_light.ogg', VOL_EFFECTS_MASTER, 20)
		M.lit = TRUE
		M.damtype = BURN
		M.icon_state = "match_lit"
		START_PROCESSING(SSobj, M)
		M.update_icon()

	else
		return ..()

//Autoinjectors
/obj/item/weapon/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "syringe_box"
	startswith = list(
						/obj/item/weapon/reagent_containers/hypospray/autoinjector,
						/obj/item/weapon/reagent_containers/hypospray/autoinjector,
						/obj/item/weapon/reagent_containers/hypospray/autoinjector,
						/obj/item/weapon/reagent_containers/hypospray/autoinjector,
						/obj/item/weapon/reagent_containers/hypospray/autoinjector,
						/obj/item/weapon/reagent_containers/hypospray/autoinjector,
						/obj/item/weapon/reagent_containers/hypospray/autoinjector
					)

//Replacement bulbs
/obj/item/weapon/storage/box/lights
	name = "box of replacement bulbs"
	icon_state = "lightbulb_box"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	storage_slots = 21
	max_storage_space = 42
	can_hold = list(/obj/item/weapon/light/tube, /obj/item/weapon/light/bulb)
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/weapon/storage/box/lights/bulbs/atom_init()
	. = ..()
	for(var/i in 1 to storage_slots)
		new /obj/item/weapon/light/bulb(src)

//Replacement tubes
/obj/item/weapon/storage/box/lights/tubes
	name = "box of replacement tubes"
	icon_state = "lighttube_box"

/obj/item/weapon/storage/box/lights/tubes/atom_init()
	. = ..()
	for(var/i in 1 to storage_slots)
		new /obj/item/weapon/light/tube(src)

//Mixed replacement lights
/obj/item/weapon/storage/box/lights/mixed
	name = "box of replacement lights"
	icon_state = "lightmixed_box"

/obj/item/weapon/storage/box/lights/mixed/atom_init()
	. = ..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/light/tube(src)
	for(var/i in 1 to 7)
		new /obj/item/weapon/light/tube/smart(src)
	for(var/i in 1 to 7)
		new /obj/item/weapon/light/bulb(src)

//Body bags
/obj/item/weapon/storage/box/bodybags
	name = "body bags"
	desc = "This box contains body bags."
	icon_state = "bodybags_box"
	startswith = list(
						/obj/item/bodybag,
						/obj/item/bodybag,
						/obj/item/bodybag,
						/obj/item/bodybag,
						/obj/item/bodybag,
						/obj/item/bodybag,
						/obj/item/bodybag
					)

//Holobadge
/obj/item/weapon/storage/box/holobadge
	name = "holobadge box"
	desc = "A box claiming to contain holobadges."
	icon_state = "holobadge_box"
	startswith = list(
						/obj/item/clothing/accessory/holobadge,
						/obj/item/clothing/accessory/holobadge,
						/obj/item/clothing/accessory/holobadge,
						/obj/item/clothing/accessory/holobadge,
						/obj/item/clothing/accessory/holobadge/cord,
						/obj/item/clothing/accessory/holobadge/cord,
						/obj/item/clothing/accessory/holobadge/cord
					)

//Evidence bag
/obj/item/weapon/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."
	icon_state = "evidence_box"
	startswith = list(
						/obj/item/weapon/evidencebag,
						/obj/item/weapon/evidencebag,
						/obj/item/weapon/evidencebag,
						/obj/item/weapon/evidencebag,
						/obj/item/weapon/evidencebag,
						/obj/item/weapon/evidencebag
					)

//Solution tray
/obj/item/weapon/storage/box/solution_trays
	name = "solution tray box"
	icon_state = "solution_trays_box"
	startswith = list(
						/obj/item/weapon/reagent_containers/glass/solution_tray,
						/obj/item/weapon/reagent_containers/glass/solution_tray,
						/obj/item/weapon/reagent_containers/glass/solution_tray,
						/obj/item/weapon/reagent_containers/glass/solution_tray,
						/obj/item/weapon/reagent_containers/glass/solution_tray,
						/obj/item/weapon/reagent_containers/glass/solution_tray,
						/obj/item/weapon/reagent_containers/glass/solution_tray
					)

//Spare PDAs
/obj/item/weapon/storage/box/PDAs
	name = "box of spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon_state = "pda_box"

/obj/item/weapon/storage/box/PDAs/atom_init()
	. = ..()
	var/newcart = pick(	/obj/item/weapon/cartridge/engineering,
							/obj/item/weapon/cartridge/security,
							/obj/item/weapon/cartridge/medical,
							/obj/item/weapon/cartridge/signal/science,
							/obj/item/weapon/cartridge/quartermaster)
	new newcart(src)
	new /obj/item/weapon/cartridge/head(src)
	for(var/i in 1 to 4)
		new /obj/item/device/pda(src)

//Shotgun ammo

/obj/item/weapon/storage/box/shotgun
	name = "box of shotgun shell"
	icon_state = "shotgun_ammo_slug"
	foldable = /obj/item/stack/sheet/cardboard
	can_hold = list(/obj/item/ammo_casing/shotgun)

/obj/item/weapon/storage/box/shotgun/slug
	name = "box of shotgun shell (slug)"
	icon_state = "shotgun_ammo_slug"
	startswith = list(
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun,
						/obj/item/ammo_casing/shotgun
					)

/obj/item/weapon/storage/box/shotgun/slug/atom_init()
	. = ..()
	make_exact_fit()


/obj/item/weapon/storage/box/shotgun/buckshot
	name = "box of shotgun shell (buckshot)"
	icon_state = "shotgun_ammo_buckshot"
	startswith = list(
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot,
						/obj/item/ammo_casing/shotgun/buckshot
					)

/obj/item/weapon/storage/box/shotgun/buckshot/atom_init()
	. = ..()
	make_exact_fit()


/obj/item/weapon/storage/box/shotgun/beanbag
	name = "box of shotgun shell (beanbag)"
	icon_state = "shotgun_ammo_beanbag"
	startswith = list(
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag,
						/obj/item/ammo_casing/shotgun/beanbag
					)

/obj/item/weapon/storage/box/shotgun/beanbag/atom_init()
	. = ..()
	make_exact_fit()

//Hair sprays
/obj/item/weapon/storage/box/hairdyes
	name = "hair spray dye box"
	desc = "A box full of hair spray dyes."
	startswith = list(
						/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/white,
						/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/red,
						/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/green,
						/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/blue,
						/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/black,
						/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/brown,
						/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/blond
					)

/obj/item/weapon/storage/box/lipstick
	name = "lipstick box"
	desc = "A box full of lipstick."
	startswith = list(
						/obj/item/weapon/lipstick,
						/obj/item/weapon/lipstick/purple,
						/obj/item/weapon/lipstick/jade,
						/obj/item/weapon/lipstick/black,
						/obj/item/weapon/paper
					)

// Don't know where is original box itself, so just put it here.
/obj/item/weapon/storage/box/contraband
	name = "box"
	desc = "Strange box."
	icon_state = "doom_box"

/obj/item/weapon/storage/box/contraband/atom_init()
	. = ..()
	if(prob(30))
		new /obj/item/weapon/storage/box/matches(src)
		new /obj/item/clothing/mask/cigarette/cigar/cohiba(src)
	else if(prob(10))
		new /obj/item/device/guitar(src)
		new /obj/item/clothing/head/sombrero(src)
		new /obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla(src)
	else
		new /obj/item/weapon/reagent_containers/food/drinks/bottle/vodka(src)
		new /obj/item/weapon/storage/fancy/cigarettes(src)
		new /obj/item/weapon/lighter/random(src)

/obj/item/weapon/storage/box/ians_box
	name = "Ian's box"
	desc = "It's a box with a corgi on it. YAP! Looks like somebody lost it."
	icon_state = "corgi_box"
	startswith = list(
						/obj/item/weapon/bikehorn/dogtoy,
						/obj/item/weapon/reagent_containers/food/snacks/cookie,
						/obj/item/weapon/reagent_containers/food/snacks/cookie,
						/obj/item/weapon/reagent_containers/food/snacks/cookie,
						/obj/item/weapon/reagent_containers/food/snacks/cookie,
						/obj/item/toy/plushie/girly_corgi
					)

/obj/item/weapon/storage/box/mines
	name = "box of mines"
	desc = "Full of military-grade mines, just add a foot."
	icon_state = "mine_box"

/obj/item/weapon/storage/box/mines/explosive
	name = "box of HE mines"
	startswith = list(
						/obj/item/mine,
						/obj/item/mine,
						/obj/item/mine,
						/obj/item/mine
					)

/obj/item/weapon/storage/box/mines/explosive/atom_init()
	. = ..()
	make_exact_fit()

/obj/item/weapon/storage/box/mines/shock
	name = "box of shock mines"
	startswith = list(
						/obj/item/mine/shock,
						/obj/item/mine/shock,
						/obj/item/mine/shock,
						/obj/item/mine/shock
					)

/obj/item/weapon/storage/box/mines/shock/atom_init()
	. = ..()
	make_exact_fit()

/obj/item/weapon/storage/box/rare_seeds
	name = "granny's gift"
	desc = "XOXO! - Granny"
	startswith = list(/obj/item/seeds/gourdseed = 1, /obj/item/seeds/gelthi = 1, /obj/item/seeds/vale = 1, /obj/item/seeds/surik = 1, /obj/item/seeds/blackberry = 1, /obj/item/seeds/amauri = 1, /obj/item/seeds/jurlmah = 1)

//NOT USED ANYWHERE
/obj/item/weapon/storage/box/syndielogo_box
	name = "syndie box"
	desc = "It's a red box with an 'S' on it. Strange."
	icon_state = "syndie_box"

/obj/item/weapon/storage/box/nanotrasenlogo_box
	name = "NT box"
	desc = "It's a blue box with an 'N' on it. Glory to NanoTrasen!"
	icon_state = "nanotrasen_box"
