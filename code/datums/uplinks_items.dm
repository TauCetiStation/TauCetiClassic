//var/list/uplink_items = list()

/proc/get_uplink_items(obj/item/device/uplink/uplink)
	// If not already initialized..
	if(!uplink.uplink_items.len)

		// Fill in the list	and order it like this:
		// A keyed list, acting as categories, which are lists to the datum.

		var/list/last = list()
		for(var/item in typesof(/datum/uplink_item))

			var/datum/uplink_item/I = new item()
			if(!I.item)
				continue
			if(I.uplink_types.len && !(uplink.uplink_type in I.uplink_types))
				continue
			if(I.last)
				last += I
				continue

			if(!uplink.uplink_items[I.category])
				uplink.uplink_items[I.category] = list()

			uplink.uplink_items[I.category] += I

		for(var/datum/uplink_item/I in last)

			if(!uplink.uplink_items[I.category])
				uplink.uplink_items[I.category] = list()

			uplink.uplink_items[I.category] += I

	return uplink.uplink_items

// You can change the order of the list by putting datums before/after one another OR
// you can use the last variable to make sure it appears last, well have the category appear last.

/datum/uplink_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "item description"
	var/item = null
	var/cost = 0
	var/last = 0 // Appear last
	var/list/uplink_types = list() //Empty list means that the object will be available in all types of uplinks. Alias you will need to state its type.


/datum/uplink_item/proc/spawn_item(turf/loc, obj/item/device/uplink/U, mob/user)
	if(item)
		U.uses -= max(cost, 0)
		feedback_add_details("traitor_uplink_items_bought", "[item]")
		return new item(loc)

/datum/uplink_item/proc/buy(obj/item/device/uplink/U, mob/user)
	if(!istype(U))
		return 0

	if (!user || user.incapacitated())
		return 0

	if (!( istype(user, /mob/living/carbon/human)))
		return 0

	// If the uplink's holder is in the user's contents
	if ((U.loc in user.contents || (in_range(U.loc, user) && istype(U.loc.loc, /turf))))
		user.set_machine(U)
		if(cost > U.uses)
			return 0

		var/obj/I = spawn_item(get_turf(user), U, user)
		if(!I)
			return 0
		var/icon/tempimage = icon(I.icon, I.icon_state)
		end_icons += tempimage
		var/tempstate = end_icons.len
		var/bundlename = name
		if(name == "Random Item" || name == "For showing that you are The Boss")
			bundlename = I.name
		if(I.tag)
			bundlename = "[I.tag] bundle"
			I.tag = null
		if(istype(I, /obj/item) && ishuman(user))
			var/mob/living/carbon/human/A = user
			A.put_in_any_hand_if_possible(I)
			U.purchase_log += {"[user] ([user.ckey]) bought <img src="logo_[tempstate].png"> [name] for [cost]."}
			if(user.mind)
				user.mind.uplink_items_bought += {"<img src="logo_[tempstate].png"> [bundlename]"}
				user.mind.spent_TC += cost
		U.interact(user)

		return 1
	return 0

/*
//
//	UPLINK ITEMS
//
*/

// DANGEROUS WEAPONS

/datum/uplink_item/dangerous
	category = "Conspicuous and Dangerous Weapons"

/datum/uplink_item/dangerous/revolver
	name = "TR-7 Revolver"
	desc = "The syndicate revolver is a traditional handgun that fires .357 Magnum cartridges and has 7 chambers."
	item = /obj/item/weapon/gun/projectile/revolver
	cost = 8
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/revolver/traitor
	name = "TR-8-R Revolver"
	desc = "The syndicate revolver is a traditional handgun that fires .357 Magnum cartridges and has 7 chambers. This one looks like toy."
	item = /obj/item/weapon/gun/projectile/revolver/traitor
	uplink_types = list("traitor")


/datum/uplink_item/dangerous/pistol
	name = "Stechkin Pistol"
	desc = "A small, easily concealable handgun that uses 9mm auto rounds in 8-round magazines and is compatible \
			with suppressors."
	item = /obj/item/weapon/gun/projectile/automatic/pistol
	cost = 6

/datum/uplink_item/dangerous/smg
	name = "C-20r Submachine Gun"
	desc = "A fully-loaded Scarborough Arms-developed submachine gun that fires .45 ACP automatic rounds with a 20-round magazine. Has large variety of ammunition."
	item = /obj/item/weapon/gun/projectile/automatic/c20r
	cost = 12
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/bulldog
	name = "V15 Bulldog shotgun"
	desc = "A compact, mag-fed semi-automatic shotgun for combat in narrow corridors. Uses various 12g magazines."
	item = /obj/item/weapon/gun/projectile/automatic/bulldog
	cost = 16
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/machinegun
	name = "L6 Squad Automatic Weapon"
	desc = "A traditionally constructed machine gun made by AA-2531. This deadly weapon has a massive 50-round magazine of 7.62x51mm ammunition."
	item = /obj/item/weapon/gun/projectile/automatic/l6_saw
	cost = 45
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/heavyrifle
	name = "PTR-7 heavy rifle"
	desc = "A portable anti-armour bolt-action rifle. Originally designed to used against armoured exosuits. Fires armor piercing 14.5mm shells."
	item = /obj/item/weapon/gun/projectile/heavyrifle
	cost = 20
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/bazooka
	name = "Goliath missile launcher"
	desc = "The Goliath is a single-shot shoulder-fired multipurpose missile launcher."
	item = /obj/item/weapon/gun/projectile/revolver/rocketlauncher
	cost = 35
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/a74
	name = "A74 Assault Rifle"
	desc = "A bullpup automatic assault rifle. Great for range combat and fire suppresion. Uses 30-round magazine of 7.74mm ammunition."
	item = /obj/item/weapon/gun/projectile/automatic/a74
	cost = 20
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/crossbow
	name = "Miniature Energy Crossbow"
	desc = "A short bow mounted across a tiller in miniature. Small enough to fit into a pocket or slip into a bag unnoticed. It fires bolts tipped with toxin, a poison collected from an organism. \
	Its bolts stun enemies for short periods, and replenish automatically. This one looks like toy."
	item = /obj/item/weapon/gun/energy/crossbow
	cost = 7
	uplink_types = list("traitor")
/*
/datum/uplink_item/dangerous/flamethrower
	name = "Flamethrower"
	desc = "A flamethrower, fueled by a portion of highly flammable biotoxins stolen previously from Nanotrasen stations. Make a statement by roasting the filth in their own greed. Use with caution."
	item = /obj/item/weapon/flamethrower/full/tank
	cost = 6
	uplink_types = list("nuclear") */

/datum/uplink_item/dangerous/powerfist
	name = "Power Fist"
	desc = "The power-fist is a metal gauntlet with a built-in piston-ram powered by an external gas supply.\
		 Upon hitting a target, the piston-ram will extend foward to make contact for some serious damage. \
		 Using a wrench on the piston valve will allow you to tweak the amount of gas used per punch to \
		 deal extra damage and hit targets further. Use a screwdriver to take out any attached tanks."
	item = /obj/item/weapon/melee/powerfist
	cost = 8

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The energy sword is an edged weapon with a blade of pure energy. The sword is small enough to be pocketed when inactive. Activating it produces a loud, distinctive noise."
	item = /obj/item/weapon/melee/energy/sword
	cost = 7
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/sword/traitor
	desc = "The energy sword is an edged weapon with a blade of pure energy. The sword is small enough to be pocketed when inactive. Activating it produces a loud, distinctive noise. This one looks like toy."
	item = /obj/item/weapon/melee/energy/sword/traitor
	uplink_types = list("traitor")

/datum/uplink_item/dangerous/emp
	name = "EMP Grenades"
	desc = "A box that contains an EMP grenades. Useful to disrupt communication and silicon lifeforms."
	item = /obj/item/weapon/storage/box/emps
	cost = 5

/datum/uplink_item/dangerous/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "The Minibomb is a grenade with a five-second fuse."
	item = /obj/item/weapon/grenade/syndieminibomb
	cost = 6
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/viscerators
	name = "Viscerator Delivery Grenade"
	desc = "A unique grenade that deploys a swarm of viscerators upon activation, which will chase down and shred any non-operatives in the area."
	item = /obj/item/weapon/grenade/spawnergrenade/manhacks
	cost = 7
	uplink_types = list("nuclear")
/*
/datum/uplink_item/dangerous/bioterror
	name = "Biohazardous Chemical Sprayer"
	desc = "A chemical sprayer that allows a wide dispersal of selected chemicals. Especially tailored by the Tiger Cooperative, the deadly blend it comes stocked with will disorient, damage, and disable your foes... \
	Use with extreme caution, to prevent exposure to yourself and your fellow operatives."
	item = /obj/item/weapon/reagent_containers/spray/chemsprayer/bioterror
	cost = 10
	uplink_types = list("nuclear") */

/datum/uplink_item/dangerous/gygax
	name = "Gygax Exosuit"
	desc = "A lightweight exosuit, painted in a dark scheme. Its speed and equipment selection make it excellent for hit-and-run style attacks. \
	This model lacks a method of space propulsion, and therefore it is advised to repair the mothership's teleporter if you wish to make use of it."
	item = /obj/mecha/combat/gygax/dark
	cost = 90
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/mauler
	name = "Mauler Exosuit"
	desc = "A massive and incredibly deadly Syndicate exosuit. Features long-range targetting, thrust vectoring, and deployable smoke."
	item = /obj/mecha/combat/marauder/mauler
	cost = 140
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/syndieborg
	name = "Syndicate Robot"
	desc = "A robot designed for extermination and slaved to syndicate agents. Delivered through a single-use bluespace hand teleporter and comes pre-equipped with various weapons and equipment."
	item = /obj/item/weapon/antag_spawner/borg_tele
	cost = 36

//for refunding the syndieborg teleporter
/datum/uplink_item/dangerous/syndieborg/spawn_item()
	var/obj/item/weapon/antag_spawner/borg_tele/T = ..()
	if(istype(T))
		T.TC_cost = cost

/datum/uplink_item/dangerous/light_armor
	name = "Armor Set"
	desc = "A set of personal armor that includes armored vest and a helmet, designed to ensure survival of gone wild agent."
	item = /obj/item/weapon/storage/box/syndie_kit/light_armor
	cost = 10
	uplink_types = list("traitor")

// AMMUNITION

/datum/uplink_item/ammo
	category = "Ammunition"

/datum/uplink_item/ammo/borg
	name = "Robot Ammo Box"
	desc = "A 40-round .45 magazine for use in Robot submachine gun."
	item = /obj/item/ammo_box/magazine/borg45
	cost = 3

/datum/uplink_item/ammo/pistol
	name = "9mm Handgun Magazine"
	desc = "An additional 8-round 9mm magazine; compatible with the Stechkin Pistol. These subsonic rounds \
			are dirt cheap but are half as effective as .357 rounds."
	item = /obj/item/ammo_box/magazine/m9mm
	cost = 2

/datum/uplink_item/ammo/revolver
	name = "Speedloader-.357"
	desc = "A speedloader that contains seven additional rounds for the revolver, made using an automatic lathe."
	item = /obj/item/ammo_box/a357
	cost = 3

/datum/uplink_item/ammo/smg
	name = "Ammo-.45 ACP"
	desc = "A 20-round .45 ACP magazine for use in the C-20r submachine gun."
	item = /obj/item/ammo_box/magazine/m12mm
	cost = 3
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/smg_hp
	name = "Ammo-.45 ACP High Power"
	desc = "A 15-round .45 ACP HP magazine for use in the C-20r submachine gun. These rounds have better overall damage."
	item = /obj/item/ammo_box/magazine/m12mm/hp
	cost = 5
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/smg_hv
	name = "Ammo-.45 ACP High Velocity"
	desc = "A 15-round .45 ACP HV magazine for use in the C-20r submachine gun. These rounds used to hit target almost instantly."
	item = /obj/item/ammo_box/magazine/m12mm/hv
	cost = 5
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/smg_imp
	name = "Ammo-.45 ACP Impact"
	desc = "A 15-round .45 ACP IMP magazine for use in the C-20r submachine gun. These rounds will push enemies back and shortly stun unarmored targets."
	item = /obj/item/ammo_box/magazine/m12mm/imp
	cost = 5
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/a74standart
	name = "Ammo-7.74mm"
	desc = "A 30-round 7.74 magazine for use in the A74 assault rifle."
	item = /obj/item/ammo_box/magazine/a74mm
	cost = 7
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/bullbuck
	name = "Ammo-12g Buckshot"
	desc = "An additional  8-round buckshot magazine for use in the Bulldog shotgun."
	item = /obj/item/ammo_box/magazine/m12g
	cost = 4
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/bullstun
	name = "Ammo-12g Stun Slug"
	desc = "An alternative 8-round stun slug magazine for use in the Bulldog shotgun. Accurate, reliable, powerful."
	item = /obj/item/ammo_box/magazine/m12g/stun
	cost = 4
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/bullincendiary
	name = "Ammo-12g Incendiary"
	desc = "An alternative 8-round incendiary magazine for use in the Bulldog shotgun."
	item = /obj/item/ammo_box/magazine/m12g/incendiary
	cost = 5
	uplink_types = list("nuclear")
/*
/datum/uplink_item/ammo/pistol
	name = "Ammo-10mm"
	desc = "An additional 8-round 10mm magazine for use in the Stetchkin pistol."
	item = /obj/item/ammo_box/magazine/m10mm
	cost = 1
	uplink_types = list("nuclear") */

/datum/uplink_item/ammo/machinegun
	name = "Ammo-7.62x51mm"
	desc = "A 50-round magazine of 7.62x51mm ammunition for use in the L6 SAW machinegun. By the time you need to use this, you'll already be on a pile of corpses."
	item = /obj/item/ammo_box/magazine/m762
	cost = 14
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/heavyrifle
	name = "A 14.5mm shell."
	desc = "A 14.5mm shell for use with PTR-7 heavy rifle. One shot, one kill, no luck, just skill."
	item = /obj/item/ammo_casing/a145
	cost = 2
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/rocket
	name = "HE missile"
	desc = "A high explosive missile for Goliath launcher."
	item = /obj/item/ammo_casing/caseless/rocket
	cost = 10
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/rocket_emp
	name = "EMP missile"
	desc = "A EMP missile for Goliath launcher."
	item = /obj/item/ammo_casing/caseless/rocket/emp
	cost = 10
	uplink_types = list("nuclear")

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/dart_pistol
	name = "Dart Pistol"
	desc = "A miniaturized version of a normal syringe gun. It is very quiet when fired and can fit into any \
			space a small item can."
	item = /obj/item/weapon/gun/syringe/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/cutouts
	name = "Adaptive Cardboard Cutouts"
	desc = "These cardboard cutouts are coated with a thin material that prevents discoloration and makes the images on them appear more lifelike. This pack contains three as well as a \
	crayon for changing their appearances."
	item = /obj/item/weapon/storage/box/syndie_kit/cutouts
	cost = 1

/datum/uplink_item/stealthy_weapons/strip_gloves
	name = "Strip gloves"
	desc = "A pair of black gloves which allow to stealthy strip off items from the victim."
	item = /obj/item/clothing/gloves/black/strip
	cost = 3

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking surfactant used to clean blood stains to hide murders and prevent DNA analysis. You can also drop it underfoot to slip people."
	item = /obj/item/weapon/soap/syndie
	cost = 1

/datum/uplink_item/stealthy_weapons/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "When inserted into a personal digital assistant, this cartridge gives you five opportunities to detonate PDAs of crewmembers who have their message feature enabled. \
	The concussive effect from the explosion will knock the recipient out for a short period, and deafen them for longer. It has a chance to detonate your PDA."
	item = /obj/item/weapon/cartridge/syndicate
	cost = 2

/datum/uplink_item/stealthy_weapons/dehy_carp
	name = "Dehydrated Space Carp"
	desc = "Just add water to make your very own hostile to everything space carp. It looks just like a plushie."
	item = /obj/item/toy/carpplushie/dehy_carp
	cost = 2
	uplink_types = list("nuclear")
/*
/datum/uplink_item/stealthy_weapons/silencer
	name = "Stetchkin Silencer"
	desc = "Fitted for use on the Stetchkin pistol, this silencer will make its shots quieter when equipped onto it."
	item = /obj/item/weapon/silencer
	cost = 2
	uplink_types = list("nuclear") */

// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/chameleon_kit
	name = "Chameleon Kit"
	desc = "A set of clothes used to imitate the uniforms of Nanotrasen crewmembers."
	item = /obj/item/weapon/storage/box/syndie_kit/chameleon
	cost = 2

/datum/uplink_item/stealthy_tools/chameleon_penstamp
	name = "Fake Bureucracy Set"
	desc = "This set allows you to forge various documents at the station."
	item = /obj/item/weapon/storage/box/syndie_kit/fake
	cost = 4

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Smuggler's Satchel"
	desc = "This satchel is thin enough to be hidden in the gap between plating and tiling; great for stashing \
			your stolen goods. Comes with a crowbar and a floor tile inside. Properly hidden satchels have been \
			known to survive intact even beyond the current shift. "
	item = /obj/item/weapon/storage/backpack/satchel/flat
	cost = 1

/datum/uplink_item/stealthy_tools/syndigolashes
	name = "No-Slip Brown Shoes"
	desc = "These allow you to run on wet floors. They do not work on lubricated surfaces."
	item = /obj/item/clothing/shoes/syndigaloshes
	cost = 1
	uplink_types = list("traitor")

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent Identification card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and can copy access from other identification cards. The access is cumulative, so scanning one card does not erase the access gained from another."
	item = /obj/item/weapon/card/id/syndicate
	cost = 4

/datum/uplink_item/stealthy_tools/voice_changer
	name = "Voice Changer"
	item = /obj/item/clothing/mask/gas/voice
	desc = "A conspicuous gas mask that mimics the voice named on your identification card. When no identification is worn, the mask will render your voice unrecognizable."
	cost = 3

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't move the projector from their hand. The disguised user cannot run and rojectiles pass over them."
	item = /obj/item/device/chameleon
	cost = 5

/datum/uplink_item/stealthy_tools/camera_bug
	name = "Camera Bug"
	desc = "Enables you to view all cameras on the network and track a target. Bugging cameras allows you to disable them remotely"
	item = /obj/item/device/camera_bug
	cost = 2

/datum/uplink_item/stealthy_weapons/silencer
	name = "Syndicate Silencer"
	desc = "A universal small-arms silencer favored by stealth operatives, this will make shots quieter when equipped onto any low-caliber weapon."
	item = /obj/item/weapon/silencer
	cost = 2

/datum/uplink_item/stealthy_weapons/throwingweapons
	name = "Box of Throwing Weapons"
	desc = "A box of shurikens and reinforced bolas from ancient Earth martial arts. They are highly effective \
			 throwing weapons. The bolas can knock a target down and the shurikens will embed into limbs."
	item = /obj/item/weapon/storage/box/syndie_kit/throwing_weapon
	cost = 6

/datum/uplink_item/stealthy_weapons/edagger
	name = "Energy Dagger"
	desc = "A dagger made of energy that looks and functions as a pen when off."
	item = /obj/item/weapon/pen/edagger
	cost = 5

/datum/uplink_item/stealthy_weapons/soap_clusterbang
	name = "Slipocalypse Clusterbang"
	desc = "A traditional clusterbang grenade with a payload consisting entirely of Syndicate soap. Useful in any scenario!"
	item = /obj/item/weapon/grenade/clusterbuster/soap
	cost = 3

// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Devices and Tools"

/datum/uplink_item/device_tools/rad_laser
	name = "Radioactive Microlaser"
	desc = "A radioactive microlaser disguised as a standard Nanotrasen health analyzer. When used, it emits a \
			powerful burst of radiation, which, after a short delay, can incapitate all but the most protected \
			of humanoids. It has two settings: intensity, which controls the power of the radiation, \
			and wavelength, which controls how long the radiation delay is."
	item = /obj/item/device/healthanalyzer/rad_laser
	cost = 7

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "The emag is a small card that unlocks hidden functions in electronic devices, subverts intended functions and characteristically breaks security mechanisms."
	item = /obj/item/weapon/card/emag
	cost = 6

/datum/uplink_item/device_tools/toolbox
	name = "Full Syndicate Toolbox"
	desc = "The syndicate toolbox is a suspicious black and red. Aside from tools, it comes with cable and a multitool. Insulated gloves are not included."
	item = /obj/item/weapon/storage/toolbox/syndicate
	cost = 1

/datum/uplink_item/device_tools/surgerybag
	name = "Syndicate Surgery Dufflebag"
	desc = "The Syndicate surgery dufflebag is a toolkit containing all surgery tools, surgical drapes, \
			a MMI, a straitjacket, and a muzzle."
	item = /obj/item/weapon/storage/backpack/dufflebag/surgery
	cost = 4

/datum/uplink_item/device_tools/c4bag
	name = "Bag of C-4 explosives"
	desc = "Because sometimes quantity is quality. Contains 5 C-4 plastic explosives."
	item = /obj/item/weapon/storage/backpack/dufflebag/c4
	cost = 4 //10% discount!

/datum/uplink_item/device_tools/military_belt
	name = "Military Belt"
	desc = "A robust seven-slot red belt that is capable of holding all manner of tatical equipment."
	item = /obj/item/weapon/storage/belt/military
	cost = 1

/datum/uplink_item/device_tools/medkit
	name = "Syndicate Medical Supply Kit"
	desc = "The syndicate medkit is a suspicious black and red. Included is a combat stimulant injector for rapid healing, a medical hud for quick identification of injured comrades, \
	and other medical supplies helpful for a medical field operative.."
	item = /obj/item/weapon/storage/firstaid/tactical
	cost = 10

/datum/uplink_item/device_tools/medkit_small
	name = "Syndicate Medical Small Kit"
	desc = "The syndicate medkit. Included is a combat stimulant injector for rapid healing."
	item = /obj/item/weapon/storage/firstaid/small_firstaid_kit/combat
	cost = 5

/datum/uplink_item/device_tools/bonepen
	name = "Prototype Bone Repair Kit"
	desc = "Stolen prototype bone repair nanites. Contains three nanocalcium autoinjectors."
	item = /obj/item/weapon/storage/box/syndie_kit/bonepen
	cost = 4

/datum/uplink_item/stealthy_tools/mulligan
	name = "Mulligan"
	desc = "Screwed up and have security on your tail? This handy syringe will give you a completely new identity and appearance."
	item = /obj/item/weapon/reagent_containers/syringe/mulligan
	cost = 4

/datum/uplink_item/device_tools/space_suit
	name = "Syndicate Space Suit"
	desc = "The red syndicate space suit is less encumbering than Nanotrasen variants, fits inside bags, and has a weapon slot. Nanotrasen crewmembers are trained to report red space suit sightings."
	item = /obj/item/weapon/storage/box/syndie_kit/space
	cost = 4

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "These glasses are thermals disguised as engineers' optical meson scanners. \
	They allow you to see organisms through walls by capturing the upper portion of the infrared light spectrum, emitted as heat and light by objects. \
	Hotter objects, such as warm bodies, cybernetic organisms and artificial intelligence cores emit more of this light than cooler objects like walls and airlocks."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 5

/datum/uplink_item/stealthy_tools/emplight
	name = "EMP Flashlight"
	desc = "A small, self-charging, short-ranged EMP device disguised as a flashlight. \
		Useful for disrupting headsets, cameras, and borgs during stealth operations."
	item = /obj/item/device/flashlight/emp
	cost = 4

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to and talk with artificial intelligences and cybernetic organisms in binary. "
	item = /obj/item/device/encryptionkey/binary
	cost = 3

/datum/uplink_item/device_tools/encryptionkey
	name = "Syndicate Encryption Key"
	desc = "A key that, when inserted into a radio headset, allows you to listen to all station department channels \
			as well as talk on an encrypted Syndicate channel with other agents that have the same key."
	item = /obj/item/device/encryptionkey/syndicate
	cost = 2

/datum/uplink_item/device_tools/poster_kit
	name = "Poster kit"
	desc = "Box of illegal posters"
	item = /obj/item/weapon/storage/box/syndie_kit/posters
	cost = 1

/datum/uplink_item/device_tools/headcan
	name = "Biogel can"
	desc = "Sophisticated device for sustaining life in head for a long period"
	item = /obj/item/device/biocan
	cost = 1

/datum/uplink_item/device_tools/ai_detector
	name = "Artificial Intelligence Detector" // changed name in case newfriends thought it detected disguised ai's
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it or its holder. Knowing when an artificial intelligence is watching you is useful for knowing when to maintain cover."
	item = /obj/item/device/multitool/ai_detect
	cost = 2

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Law Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. Be careful with their wording, as artificial intelligences may look for loopholes to exploit."
	item = /obj/item/weapon/aiModule/freeform/syndicate
	cost = 12

/datum/uplink_item/device_tools/plastic_explosives
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls, attach it to organisms to destroy them, or connect a signaler to its wiring to make it remotely detonable. \
	It has a modifiable timer with a minimum setting of 10 seconds."
	item = /obj/item/weapon/plastique
	cost = 1

/datum/uplink_item/device_tools/powersink
	name = "Power sink"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device places excessive load on the grid, causing a stationwide blackout. The sink cannot be carried because of its excessive size. \
	Ordering this sends you a small beacon that will teleport the power sink to your location on activation."
	item = /obj/item/device/powersink
	cost = 12

/datum/uplink_item/device_tools/syndcodebook
	name = "Sy-Code Book"
	desc = "Syndicate agents can be trained to use a series of codewords to convey complex information, which sounds like random letters and drinks to anyone listening. \
	This manual teaches you Sy-Code. Limited uses. Use :0 before saying something to speak in Sy-Code."
	item = /obj/item/weapon/syndcodebook
	cost = 1
	uplink_types = list("traitor")

/datum/uplink_item/device_tools/singularity_beacon
	name = "Singularity Beacon"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device pulls the singularity towards it. \
	Does not work when the singularity is still in containment. A singularity beacon can cause catastrophic damage to a space station, \
	leading to an emergency evacuation. Because of its size, it cannot be carried. Ordering this sends you a small beacon that will teleport the larger beacon to your location on activation."
	item = /obj/item/device/radio/beacon/syndicate
	cost = 14
	uplink_types = list("nuclear")

/datum/uplink_item/device_tools/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "The Syndicate Bomb has an adjustable timer with a minimum setting of 60 seconds. Ordering the bomb sends you a small beacon, which will teleport the explosive to your location when you activate it. \
	You can wrench the bomb down to prevent removal. The crew may attempt to defuse the bomb."
	item = /obj/item/device/radio/beacon/syndicate_bomb
	cost = 12
	uplink_types = list("nuclear")

/datum/uplink_item/device_tools/syndicate_detonator
	name = "Syndicate Detonator"
	desc = "The Syndicate Detonator is a companion device to the Syndicate Bomb. Simply press the included button and an encrypted radio frequency will instruct all live syndicate bombs to detonate. \
	Useful for when speed matters or you wish to synchronize multiple bomb blasts. Be sure to stand clear of the blast radius before using the detonator."
	item = /obj/item/device/syndicatedetonator
	cost = 2
	uplink_types = list("nuclear")

/datum/uplink_item/device_tools/shield
	name = "Energy Shield"
	desc = "An incredibly useful personal shield projector, capable of reflecting energy projectiles and defending against other attacks."
	item = /obj/item/weapon/shield/energy
	cost = 16
	uplink_types = list("nuclear")

/datum/uplink_item/device_tools/traitor_caller
	name = "Traitor Caller"
	desc = "Allows you to request an additional agent selected from the stealthy traitors."
	item = /obj/item/device/traitor_caller
	cost = 55
	uplink_types = list("nuclear")

// IMPLANTS

/datum/uplink_item/implants
	category = "Implants"

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant injected into the body and later activated using a bodily gesture to attempt to slip restraints."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_freedom
	cost = 5

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant injected into the body, and later activated using a bodily gesture to open an uplink with 5 telecrystals. \
	The ability for an agent to open an uplink after their posessions have been stripped from them makes this implant excellent for escaping confinement."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_uplink
	cost = 20

/datum/uplink_item/implants/storage
	name = "Compressed Implant"
	desc = "An implant, that can compress items and later activated at the user's will."
	item = /obj/item/weapon/implanter/storage
	cost = 7

/datum/uplink_item/implants/adrenaline
	name = "Adrenaline Implant"
	desc = "An implant, that will inject a chemical cocktail, which has a mild healing effect along with removing all stuns and increasing his speed can be activated at the user's will."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_adrenaline
	cost = 6

/datum/uplink_item/implants/emp
	name = "EMP Implant"
	desc = "An implant, that contains power of three emp grenades, can be activated at the user's will."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_emp
	cost = 3

// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "(Pointless) Badassery"

/datum/uplink_item/badass/bundle
	name = "Syndicate Bundle"
	desc = "Syndicate Bundles are specialised groups of items that arrive in a plain box. These items are collectively worth more than 10 telecrystals, but you do not know which specialisation you will receive."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 20

/datum/uplink_item/badass/merch
	name = "Syndicate Merchandise"
	desc = "To show your loalty to the Syndicate! Contains new red t-shirt with Syndicate logo, red cap and a fancy baloon!"
	item = /obj/item/weapon/storage/box/syndie_kit/merch
	cost = 20

/datum/uplink_item/badass/syndiecigs
	name = "Syndicate Smokes"
	desc = "Strong flavor, dense smoke, infused with tricordazine."
	item = /obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate
	cost = 2

/datum/uplink_item/badass/syndiecash
	name = "Syndicate Briefcase Full of Cash"
	desc = "A secure briefcase containing 5000 space credits. Useful for bribing personnel, or purchasing goods and services at lucrative prices. \
	The briefcase also feels a little heavier to hold; it has been manufactured to pack a little bit more of a punch if your client needs some convincing."
	item = /obj/item/weapon/storage/secure/briefcase/syndie
	cost = 1

/datum/uplink_item/badass/random
	name = "Random Item"
	desc = "Picking this choice will send you a random item from the list. Useful for when you cannot think of a strategy to finish your objectives with."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 0

/datum/uplink_item/badass/random/spawn_item(turf/loc, obj/item/device/uplink/U, mob/user)

	var/list/buyable_items = get_uplink_items(U)
	var/list/possible_items = list()

	for(var/category in buyable_items)
		for(var/datum/uplink_item/I in buyable_items[category])
			if(I == src)
				continue
			if(I.cost > U.uses)
				continue
			possible_items += I

	if(possible_items.len)
		var/datum/uplink_item/I = pick(possible_items)
		U.uses -= max(0, I.cost)
		feedback_add_details("traitor_uplink_items_bought","RN")
		return new I.item(loc)
	else
		to_chat(user, "<span class='warning'>There is no available items you could buy for [U.uses] TK.</span>")
