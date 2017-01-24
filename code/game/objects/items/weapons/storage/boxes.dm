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
 *		 -Shotgun ammo
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

//Box
/obj/item/weapon/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

//Survival
/obj/item/weapon/storage/box/survival/New()
	..()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/emergency_oxygen(src)

//Engineer
/obj/item/weapon/storage/box/engineer/New()
	..()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)

//Alien
/obj/item/weapon/storage/box/alien
	icon_state = "alienbox"

//Latex gloves
/obj/item/weapon/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains white gloves."
	icon_state = "latex"

/obj/item/weapon/storage/box/gloves/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/clothing/gloves/latex(src)

//Masks
/obj/item/weapon/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile"

/obj/item/weapon/storage/box/masks/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/clothing/mask/surgical(src)

//Syringes
/obj/item/weapon/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	desc = "A biohazard alert warning is printed on the box"
	icon_state = "syringe"

/obj/item/weapon/storage/box/syringes/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/syringe(src)

//Beakers
/obj/item/weapon/storage/box/beakers
	name = "box of beakers"
	icon_state = "beaker"

/obj/item/weapon/storage/box/beakers/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)

//Injectors
/obj/item/weapon/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors it seems."

/obj/item/weapon/storage/box/injectors/New()
	..()
	for(var/i in 1 to 3)
		new /obj/item/weapon/dnainjector/h2m(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/dnainjector/m2h(src)

//Beanbags
/obj/item/weapon/storage/box/beanbags
	name = "box of beanbag shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."

/obj/item/weapon/storage/box/beanbags/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/beanbag(src)

//Flashbangs
/obj/item/weapon/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang"

/obj/item/weapon/storage/box/flashbangs/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/grenade/flashbang(src)

//Teargas
/obj/item/weapon/storage/box/teargas
	name = "box of tear gas grenades (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness and skin irritation.</B>"
	icon_state = "flashbang"

/obj/item/weapon/storage/box/teargas/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/grenade/chem_grenade/teargas(src)

//Smokegrenades
/obj/item/weapon/storage/box/smokegrenades
	name = "box of smoke grenades"
	desc = "This box contains smoke grenades it seems."
	icon_state = "flashbang"

/obj/item/weapon/storage/box/smokegrenades/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/grenade/smokebomb(src)

//Rubber 40x46mm
/obj/item/weapon/storage/box/r4046
	name = "box of 40x46mm rubber grenades (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause injury.</B>"
	icon_state = "box_4046"

/obj/item/weapon/storage/box/r4046/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/r4046(src)

//EMPs
/obj/item/weapon/storage/box/emps
	name = "box of emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang"

/obj/item/weapon/storage/box/emps/New()
	..()
	for(var/i in 1 to 5)
		new /obj/item/weapon/grenade/empgrenade(src)

//Track implant
/obj/item/weapon/storage/box/trackimp
	name = "boxed tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant"

/obj/item/weapon/storage/box/trackimp/New()
	..()
	new /obj/item/weapon/implanter(src)
	new /obj/item/weapon/implantpad(src)
	new /obj/item/weapon/locator(src)
	for(var/i in 1 to 4)
		new /obj/item/weapon/implantcase/tracking(src)

//Chemical implant
/obj/item/weapon/storage/box/chemimp
	name = "boxed chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"

/obj/item/weapon/storage/box/chemimp/New()
	..()
	new /obj/item/weapon/implanter(src)
	new /obj/item/weapon/implantpad(src)
	for(var/i in 1 to 5)
		new /obj/item/weapon/implantcase/chem(src)

//Stimpack
/obj/item/weapon/storage/box/autoinjector/stimpack
	name = "stimpack value kit"
	desc = "A box with several stimpack autoinjectors for the economical miner."
	icon_state = "syringe"

/obj/item/weapon/storage/box/autoinjector/stimpack/New()
	..()
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack(src)

//Prescription glasses
/obj/item/weapon/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"

/obj/item/weapon/storage/box/rxglasses/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/clothing/glasses/regular(src)

//Drinking glasses
/obj/item/weapon/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."

/obj/item/weapon/storage/box/drinkingglasses/New()
	..()
	for(var/i in 1 to 6)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)

//Death alarm
/obj/item/weapon/storage/box/cdeathalarm_kit
	name = "Death Alarm Kit"
	desc = "Box of stuff used to implant death alarms."
	icon_state = "implant"
	item_state = "syringe_kit"

/obj/item/weapon/storage/box/cdeathalarm_kit/New()
	..()
	new /obj/item/weapon/implanter(src)
	for(var/i in 1 to 6)
		new /obj/item/weapon/implantcase/death_alarm(src)

//Condiment bottles
/obj/item/weapon/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."

/obj/item/weapon/storage/box/condimentbottles/New()
	..()
	for(var/i in 1 to 6)
		new /obj/item/weapon/reagent_containers/food/condiment(src)

//Paper cups
/obj/item/weapon/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."

/obj/item/weapon/storage/box/cups/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )

//Donk-pockets
/obj/item/weapon/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"

/obj/item/weapon/storage/box/donkpockets/New()
	..()
	for(var/i in 1 to 6)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)

//Monkey cube
/obj/item/weapon/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/food.dmi'
	icon_state = "monkeycubebox"
	storage_slots = 7
	can_hold = list("/obj/item/weapon/reagent_containers/food/snacks/monkeycube")

/obj/item/weapon/storage/box/monkeycubes/New()
	..()
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(src)

//Farwa cube
/obj/item/weapon/storage/box/monkeycubes/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes, shipped from Ahdomai. Just add water!"

/obj/item/weapon/storage/box/monkeycubes/farwacubes/New()
	..()
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube(src)

//Stok cube
/obj/item/weapon/storage/box/monkeycubes/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes, shipped from Moghes. Just add water!"

/obj/item/weapon/storage/box/monkeycubes/stokcubes/New()
	..()
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube(src)

//Neaera cube
/obj/item/weapon/storage/box/monkeycubes/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes, shipped from Jargon 4. Just add water!"

/obj/item/weapon/storage/box/monkeycubes/neaeracubes/New()
	..()
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube(src)

//Spare IDs
/obj/item/weapon/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"

/obj/item/weapon/storage/box/ids/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/card/id(src)

//R.O.B.U.S.T. Cartridges
/obj/item/weapon/storage/box/seccarts
	name = "box of spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon_state = "pda"

/obj/item/weapon/storage/box/seccarts/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/cartridge/security(src)

//Handcuffs
/obj/item/weapon/storage/box/handcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"

/obj/item/weapon/storage/box/handcuffs/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/handcuffs(src)

//Alien handcuffs
/obj/item/weapon/storage/box/alienhandcuffs
	name = "box of spare alien handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "alienboxCuffs"

/obj/item/weapon/storage/box/alienhandcuffs/New()
	..()
	for(var/i in 1 to 7)
		new	/obj/item/weapon/handcuffs/alien(src)

//Mousetraps
/obj/item/weapon/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<FONT color='red'><B>WARNING:</B></FONT> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps"

/obj/item/weapon/storage/box/mousetraps/New()
	..()
	for(var/i in 1 to 6)
		new /obj/item/device/assembly/mousetrap(src)

//Pill bottles
/obj/item/weapon/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."

/obj/item/weapon/storage/box/pillbottles/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/storage/pill_bottle( src )

//Snap pop
/obj/item/weapon/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"
	storage_slots = 8
	can_hold = list("/obj/item/toy/snappop")

/obj/item/weapon/storage/box/snappops/New()
	..()
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
	w_class = 1
	slot_flags = SLOT_BELT
	can_hold = list("/obj/item/weapon/match")

/obj/item/weapon/storage/box/matches/New()
	..()
	for(var/i in 1 to storage_slots)
		new /obj/item/weapon/match(src)

/obj/item/weapon/storage/box/matches/attackby(obj/item/weapon/match/W, mob/user)
	if(istype(W) && !W.lit && !W.burnt)
		if (prob (20))
			playsound(src, 'sound/items/matchstick_hit.ogg', 20, 1, 1)
			return
		playsound(src, 'sound/items/matchstick_light.ogg', 20, 1, 1)
		W.lit = 1
		W.damtype = "burn"
		W.icon_state = "match_lit"
		SSobj.processing |= W
	W.update_icon()
	return

//Autoinjectors
/obj/item/weapon/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "syringe"

/obj/item/weapon/storage/box/autoinjectors/New()
	..()
	for(var/i in 1 to storage_slots)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)

//Replacement bulbs
/obj/item/weapon/storage/box/lights
	name = "box of replacement bulbs"
	icon = 'icons/obj/storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	storage_slots = 21
	can_hold = list("/obj/item/weapon/light/tube", "/obj/item/weapon/light/bulb")
	max_combined_w_class = 42	//holds 21 items of w_class 2
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/weapon/storage/box/lights/bulbs/New()
	..()
	for(var/i in 1 to storage_slots)
		new /obj/item/weapon/light/bulb(src)

//Replacement tubes
/obj/item/weapon/storage/box/lights/tubes
	name = "box of replacement tubes"
	icon_state = "lighttube"

/obj/item/weapon/storage/box/lights/tubes/New()
	..()
	for(var/i in 1 to storage_slots)
		new /obj/item/weapon/light/tube(src)

//Mixed replacement lights
/obj/item/weapon/storage/box/lights/mixed
	name = "box of replacement lights"
	icon_state = "lightmixed"

/obj/item/weapon/storage/box/lights/mixed/New()
	..()
	for(var/i in 1 to 14)
		new /obj/item/weapon/light/tube(src)
	for(var/i in 1 to 7)
		new /obj/item/weapon/light/bulb(src)

//Body bags
/obj/item/weapon/storage/box/bodybags
	name = "body bags"
	desc = "This box contains body bags."
	icon_state = "bodybags"

/obj/item/weapon/storage/box/bodybags/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/bodybag(src)

//Holobadge
/obj/item/weapon/storage/box/holobadge
	name = "holobadge box"
	desc = "A box claiming to contain holobadges."

/obj/item/weapon/storage/box/holobadge/New()
	..()
	for(var/i in 1 to 4)
		new /obj/item/clothing/tie/holobadge(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/tie/holobadge/cord(src)

//Evidence bag
/obj/item/weapon/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."

/obj/item/weapon/storage/box/evidence/New()
	..()
	for(var/i in 1 to 6)
		new /obj/item/weapon/evidencebag(src)

//Solution tray
/obj/item/weapon/storage/box/solution_trays
	name = "solution tray box"
	icon_state = "solution_trays"

/obj/item/weapon/storage/box/solution_trays/New()
	..()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/glass/solution_tray(src)

//Spare PDAs
/obj/item/weapon/storage/box/PDAs
	name = "box of spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdabox"

/obj/item/weapon/storage/box/PDAs/New()
	..()
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
	icon = 'icons/obj/storage.dmi'
	icon_state = "shotgun_ammo_slug"
	foldable = /obj/item/stack/sheet/cardboard
	storage_slots = 16
	can_hold = list("/obj/item/ammo_casing/shotgun")
	max_combined_w_class = 16


/obj/item/weapon/storage/box/shotgun/slug
	name = "box of shotgun shell (slug)"
	icon_state = "shotgun_ammo_slug"

/obj/item/weapon/storage/box/shotgun/slug/New()
	..()
	for(var/i in 1 to 16)
		new /obj/item/ammo_casing/shotgun(src)


/obj/item/weapon/storage/box/shotgun/buckshot
	name = "box of shotgun shell (buckshot)"
	icon_state = "shotgun_ammo_buckshot"

/obj/item/weapon/storage/box/shotgun/buckshot/New()
	..()
	for(var/i in 1 to 16)
		new /obj/item/ammo_casing/shotgun/buckshot(src)


/obj/item/weapon/storage/box/shotgun/beanbag
	name = "box of shotgun shell (beanbag)"
	icon_state = "shotgun_ammo_beanbag"

/obj/item/weapon/storage/box/shotgun/beanbag/New()
	..()
	for(var/i in 1 to 16)
		new /obj/item/ammo_casing/shotgun/beanbag(src)

// Don't know where is original box itself, so just put it here.
/obj/item/weapon/storage/box/contraband
	name = "box"
	desc = "Strange box."
	icon_state = "box_of_doom"

/obj/item/weapon/storage/box/contraband/New()
	..()
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
