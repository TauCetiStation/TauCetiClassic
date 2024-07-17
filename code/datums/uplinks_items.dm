/// Selects a set number of unique items from the uplink, and deducts a percentage discount from them
/proc/create_uplink_sales(num, category = "Discounts", limited_stock, list/sale_items)
	var/list/sales = list()
	var/list/sale_items_copy = sale_items.Copy()
	for (var/i in 1 to num)
		var/picked_category = pick(sale_items_copy)
		var/datum/uplink_item/taken_item = pick_n_take(sale_items_copy[picked_category])
		if(taken_item.cant_discount || taken_item.cost < 2)
			continue
		var/datum/uplink_item/uplink_item = new taken_item.type()
		var/discount = uplink_item.get_discount()
		var/list/disclaimer = list("Void where prohibited.", "Not recommended for children.", "Contains small parts.", "Check local laws for legality in region.", "Do not taunt.", "Not responsible for direct, indirect, incidental or consequential damages resulting from any defect, error or failure to perform.", "Keep away from fire or flames.", "Product is provided \"as is\" without any implied or expressed warranties.", "As seen on TV.", "For recreational use only.", "Use only as directed.", "16% sales tax will be charged for orders originating within Space Nebraska.")
		uplink_item.limited_stock = limited_stock
		if(uplink_item.cost >= 20) //Tough love for nuke ops
			discount *= 0.5
		uplink_item.category = category
		uplink_item.cost = max(round(uplink_item.cost * (1 - discount)),1)
		uplink_item.name += " ([round(((initial(uplink_item.cost)-uplink_item.cost)/initial(uplink_item.cost))*100)]% off!)"
		uplink_item.desc += " Normally costs [initial(uplink_item.cost)] TC. All sales final. [pick(disclaimer)]"
		uplink_item.item = taken_item.item
		sales += uplink_item
	return sales

/// Returns by how much percentage do we reduce the price of the selected item
/datum/uplink_item/proc/get_discount()
	var/static/list/discount_types = list(
		"small" = 4,
		"medium" = 2,
		"big" = 1,
	)

	switch(pickweight(discount_types))
		if("big" )
			return 0.75
		if("medium")
			return 0.5
		else
			return 0.25

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
			if(uplink.uplink_type == "dealer" && I.need_wanted_level)
				var/datum/faction/cops/cops = find_faction_by_type(/datum/faction/cops)
				if(cops && I.need_wanted_level > cops.wanted_level)
					continue

			if(!uplink.uplink_items[I.category])
				uplink.uplink_items[I.category] = list()

			uplink.uplink_items[I.category] += I

		for(var/datum/uplink_item/I in last)

			if(!uplink.uplink_items[I.category])
				uplink.uplink_items[I.category] = list()

			uplink.uplink_items[I.category] += I

		for(var/datum/uplink_item/I in uplink.extra_purchasable)
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
	var/cant_discount = FALSE
	var/limited_stock = FALSE
	var/list/uplink_types = list() //Empty list means that the object will be available in all types of uplinks. Alias you will need to state its type.

	// used for dealer items
	var/need_wanted_level

/datum/uplink_item/proc/spawn_item(turf/loc, obj/item/device/uplink/U, mob/user)
	if(item)
		U.uses -= max(cost, 0)
		feedback_add_details("traitor_uplink_items_bought", "[item]")
		return new item(loc)

/datum/uplink_item/proc/buy(obj/item/device/uplink/U, mob/user)
	if(!istype(U))
		return FALSE

	if(!user || user.incapacitated())
		return FALSE

	if(!( ishuman(user)))
		return FALSE

	// If the uplink's holder is in the user's contents or near him
	if(U.Adjacent(user, recurse = 2))
		user.set_machine(U)
		if(cost > U.uses)
			return FALSE

		var/obj/I = spawn_item(get_turf(user), U, user)
		if(!I)
			return FALSE
		var/icon/tempimage = icon(I.icon, I.icon_state)
		end_icons += tempimage
		var/tempstate = end_icons.len
		var/bundlename = name
		if(name == "Random Item" || name == "For showing that you are The Boss")
			bundlename = I.name
		if(I.tag)
			bundlename = "[I.tag] bundle"
			I.tag = null
		if(isitem(I) && ishuman(user))
			var/mob/living/carbon/human/A = user
			A.put_in_any_hand_if_possible(I)
			loging(A, tempstate, bundlename)

		return TRUE
	return FALSE

/datum/uplink_item/proc/loging(mob/living/carbon/human/user, tempstate, bundlename)
	if(user.mind)
		for(var/role in user.mind.antag_roles)
			var/datum/role/R = user.mind.antag_roles[role]
			var/datum/component/gamemode/syndicate/S = R.GetComponent(/datum/component/gamemode/syndicate)
			if(!S)
				continue
			S.spent_TC += cost
			if(istype(R, /datum/role/operative))
				R.faction.faction_scoreboard_data += {"<img src="logo_[tempstate].png"> [bundlename] for [cost] TC."}
			else
				S.uplink_items_bought += {"<img src="logo_[tempstate].png"> [bundlename] for [cost] TC."}

			var/datum/stat/uplink_purchase/stat = new
			stat.bundlename = bundlename
			stat.cost = cost
			stat.item_type = item
			S.uplink_purchases += stat


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
	desc = "A small, easily concealable handgun that uses 9mm auto rounds in 7-round or 16-round magazines and is compatible \
			with suppressors."
	item = /obj/item/weapon/gun/projectile/automatic/pistol/stechkin
	cost = 6
	uplink_types = list("nuclear", "traitor", "dealer")

/datum/uplink_item/dangerous/deagle
	name = "Desert Eagle"
	desc = "A robust handgun that uses .50 AE ammo."
	item = /obj/item/weapon/gun/projectile/automatic/pistol/deagle/weakened
	cost = 8
	uplink_types = list("dealer")

	need_wanted_level = 3

/datum/uplink_item/dangerous/deagle_gold
	name = "Desert Eagle Gold"
	desc = "A gold plated gun folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	item = /obj/item/weapon/gun/projectile/automatic/pistol/deagle/weakened/gold
	cost = 9
	uplink_types = list("dealer")

	need_wanted_level = 3

/datum/uplink_item/dangerous/smg
	name = "C-20r Submachine Gun"
	desc = "A fully-loaded Scarborough Arms-developed submachine gun that fires .45 ACP automatic rounds with a 20-round magazine. Has large variety of ammunition."
	item = /obj/item/weapon/gun/projectile/automatic/c20r
	cost = 10
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/mini_uzi
	name = "Mac-10"
	desc = "A lightweight, fast firing gun, for when you want someone dead. Uses 9mm rounds."
	item = /obj/item/weapon/gun/projectile/automatic/mini_uzi
	cost = 12
	uplink_types = list("dealer")

	need_wanted_level = 3

/datum/uplink_item/dangerous/tommygun
	name = "Tommygun"
	desc = "Based on the classic 'Chicago Typewriter'. Uses .45 ACP rounds."
	item = /obj/item/weapon/gun/projectile/automatic/tommygun
	cost = 10
	uplink_types = list("dealer")

	need_wanted_level = 2

/datum/uplink_item/dangerous/bulldog
	name = "V15 Bulldog shotgun"
	desc = "A compact, mag-fed semi-automatic shotgun for combat in narrow corridors. Uses various 12g magazines."
	item = /obj/item/weapon/gun/projectile/automatic/bulldog
	cost = 15
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/machinegun
	name = "L6 Squad Automatic Weapon"
	desc = "A traditionally constructed machine gun made by AA-2531. This deadly weapon has a massive 50-round magazine of 7.62x51mm ammunition."
	item = /obj/item/weapon/gun/projectile/automatic/l6_saw
	cost = 30
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/heavyrifle
	name = "PTR-7 heavy rifle"
	desc = "A portable anti-armour bolt-action rifle. Originally designed to used against armoured exosuits. Fires armor piercing 14.5mm shells."
	item = /obj/item/weapon/gun/projectile/heavyrifle
	cost = 15
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/bazooka
	name = "Goliath missile launcher"
	desc = "The Goliath is a single-shot shoulder-fired multipurpose missile launcher."
	item = /obj/item/weapon/gun/projectile/revolver/rocketlauncher
	cost = 20
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/a74
	name = "A74 Assault Rifle"
	desc = "An automatic assault rifle. Great for ranged combat and fire suppresion. Uses 30-round magazine of 7.74mm ammunition."
	item = /obj/item/weapon/gun/projectile/automatic/a74
	cost = 20
	uplink_types = list("nuclear", "dealer")

	need_wanted_level = 5

/datum/uplink_item/dangerous/drozd
	name = "Drozd OTs-114 Assault Carbine"
	desc = "Semiauto assault rifle equipped with an underslung grenade launcher. Has a small mag full of high power ammo. Uses 12-round magazine of 12.7 ammunition."
	item = /obj/item/weapon/gun/projectile/automatic/drozd
	cost = 15
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
	uplink_types = list("nuclear", "traitor")

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

/datum/uplink_item/dangerous/power_gloves
	name = "Power Gloves"
	desc = "A pair of combat power gloves, powered by power cells, work in two modes: stun and kill. \
	In KILL mode, increases the owner unarmed attack. \
	In STUN mode, the gloves inflict a very powerful electric shock on enemies. \
	When activated, gloves do not protect against electric shocks. \
	They are disguised as heavy padded black gloves."
	item = /obj/item/clothing/gloves/power
	cost = 4
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/dangerous/emp
	name = "EMP Grenades"
	desc = "A box that contains an EMP grenades. Useful to disrupt communication and silicon lifeforms."
	item = /obj/item/weapon/storage/box/emps
	cost = 5
	uplink_types = list("nuclear", "traitor")

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
	cost = 3
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
	cost = 40
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/mauler
	name = "Mauler Exosuit"
	desc = "A massive and incredibly deadly Syndicate exosuit. Features long-range targetting, thrust vectoring, and deployable smoke."
	item = /obj/mecha/combat/marauder/mauler
	cost = 60
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/syndieborg
	name = "Syndicate Robot"
	desc = "A robot designed for extermination and slaved to syndicate agents. Delivered through a single-use bluespace hand teleporter and comes pre-equipped with various weapons and equipment."
	item = /obj/item/weapon/antag_spawner/borg_tele
	cost = 25
	uplink_types = list("nuclear", "traitor")

//for refunding the syndieborg teleporter
/datum/uplink_item/dangerous/syndieborg/spawn_item()
	var/obj/item/weapon/antag_spawner/borg_tele/T = ..()
	if(istype(T))
		T.TC_cost = cost

/datum/uplink_item/dangerous/light_armor
	name = "Armor Set"
	desc = "A set of personal armor that includes armored vest and a helmet, designed to ensure survival of gone wild agent."
	item = /obj/item/weapon/storage/box/syndie_kit/light_armor
	cost = 4
	uplink_types = list("traitor")

/datum/uplink_item/dangerous/light_armor/dealer
	cost = 12
	uplink_types = list("dealer")
	need_wanted_level = 5

/datum/uplink_item/dangerous/cheap_armor
	name = "Standard Armor Set"
	desc = "A set of basic armor to protect against enemies"
	item = /obj/item/weapon/storage/box/syndie_kit/cheap_armor
	cost = 10
	uplink_types = list("dealer")

/datum/uplink_item/dangerous/mine
	name = "High Explosive Mine"
	desc = "A mine that explodes upon pressure. Use multitool to disarm it."
	item = /obj/item/mine
	cost = 3
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/dangerous/incendiary_mine
	name = "Incendiary Mine"
	desc = "A variation of many different mines, this one will set on fire anyone unfortunate to step on it."
	item = /obj/item/mine/incendiary
	cost = 2
	uplink_types = list("nuclear", "traitor")


// AMMUNITION

/datum/uplink_item/ammo
	category = "Ammunition"

/datum/uplink_item/ammo/borg
	name = "Robot Ammo Box"
	desc = "A 40-round .45 magazine for use in Robot submachine gun."
	item = /obj/item/ammo_box/magazine/borg45
	cost = 2
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/ammo/pistol
	name = "9mm Handgun Magazine"
	desc = "An additional 16-round 9mm magazine; compatible with the Stechkin Pistol. These subsonic rounds \
			are dirt cheap but are half as effective as .357 rounds."
	item = /obj/item/ammo_box/magazine/stechkin/extended
	cost = 1
	uplink_types = list("nuclear", "traitor", "dealer")

/datum/uplink_item/ammo/revolver
	name = "Speedloader-.357"
	desc = "A speedloader that contains seven additional rounds for the revolver, made using an automatic lathe."
	item = /obj/item/ammo_box/speedloader/a357
	cost = 2
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/ammo/smg
	name = "Ammo-.45 ACP"
	desc = "A 30-round .45 ACP magazine for use in the C-20r submachine gun."
	item = /obj/item/ammo_box/magazine/c20r
	cost = 1
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/uzi
	name = "9mm Mac-10 Magazine"
	desc = "A 32-round 9mm magazine for use in the Mac-10."
	item = /obj/item/ammo_box/magazine/mac10
	cost = 3
	uplink_types = list("dealer")

/datum/uplink_item/ammo/tommygun
	name = ".45 ACP Tommygun Magazine"
	desc = "A 50-round .45 ACP magazine for use in the tommygun."
	item = /obj/item/ammo_box/magazine/tommygun
	cost = 4
	uplink_types = list("dealer")

/datum/uplink_item/ammo/deagle
	name = "Ammo-.50 AE Magazine"
	desc = "A 7-round .50 AE magazine for use in the desert eagle."
	item = /obj/item/ammo_box/magazine/deagle/weakened
	cost = 4
	uplink_types = list("dealer")

/datum/uplink_item/ammo/smg_hp
	name = "Ammo-.45 ACP High Power"
	desc = "A 20-round .45 ACP HP magazine for use in the C-20r submachine gun. These rounds have better overall damage."
	item = /obj/item/ammo_box/magazine/c20r/hp
	cost = 2
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/smg_hv
	name = "Ammo-.45 ACP High Velocity"
	desc = "A 20-round .45 ACP HV magazine for use in the C-20r submachine gun. These rounds used to hit target almost instantly."
	item = /obj/item/ammo_box/magazine/c20r/hv
	cost = 2
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/smg_imp
	name = "Ammo-.45 ACP Impact"
	desc = "A 20-round .45 ACP IMP magazine for use in the C-20r submachine gun. These rounds will push enemies back and shortly stun unarmored targets."
	item = /obj/item/ammo_box/magazine/c20r/imp
	cost = 2
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/a74standart
	name = "Ammo-7.74mm"
	desc = "A 30-round 7.74 magazine for use in the A74 assault rifle."
	item = /obj/item/ammo_box/magazine/a74
	cost = 5
	uplink_types = list("nuclear", "dealer")

/datum/uplink_item/ammo/bullbuck
	name = "Ammo-12g Buckshot"
	desc = "An additional  8-round buckshot magazine for use in the Bulldog shotgun."
	item = /obj/item/ammo_box/magazine/bulldog
	cost = 3
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/bullstun
	name = "Ammo-12g Stun Shot"
	desc = "An alternative 8-round stun shot magazine for use in the Bulldog shotgun. Accurate, reliable, powerful."
	item = /obj/item/ammo_box/magazine/bulldog/stun
	cost = 1
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/bullincendiary
	name = "Ammo-12g Incendiary"
	desc = "An alternative 8-round incendiary magazine for use in the Bulldog shotgun."
	item = /obj/item/ammo_box/magazine/bulldog/incendiary
	cost = 4
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/machinegun
	name = "Ammo-7.62x51mm"
	desc = "A 50-round magazine of 7.62x51mm ammunition for use in the L6 SAW machinegun. By the time you need to use this, you'll already be on a pile of corpses."
	item = /obj/item/ammo_box/magazine/saw
	cost = 10
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/drozd
	name = "Ammo-12.7mm"
	desc = "A 12-round magazine of 12.7 ammunition for use in the Drozd OTs-114 automatic rifle. Small and dangerous."
	item = /obj/item/ammo_box/magazine/drozd
	cost = 2
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/grenade_launcher
	name = "Ammo-40x46mm (explosive)"
	desc = "A single grenade for use in underslung grenade launcher. This one explodes."
	item = /obj/item/ammo_casing/r4046/explosive
	cost = 2
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/grenade_launcher_emp
	name = "Ammo-40x46mm (EMP)"
	desc = "A single grenade for use in underslung grenade launcher. This one creates EMP blast."
	item = /obj/item/ammo_casing/r4046/chem/EMP
	cost = 1
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/heavyrifle
	name = "A 14.5mm shell."
	desc = "A 14.5mm shell for use with PTR-7 heavy rifle. One shot, one kill, no luck, just skill."
	item = /obj/item/ammo_casing/a145
	cost = 1
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/rocket
	name = "HE missile"
	desc = "A high explosive missile for Goliath launcher."
	item = /obj/item/ammo_casing/caseless/rocket
	cost = 5
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/rocket_emp
	name = "EMP missile"
	desc = "A EMP missile for Goliath launcher."
	item = /obj/item/ammo_casing/caseless/rocket/emp
	cost = 2
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/chemicals
	name = "Chemical Warfare Tank"
	desc = "A tank of chemicals to refuel your urge to deliver slow and painful death to others."
	item = /obj/item/device/radio/beacon/syndicate_chemicals
	cost = 10
	uplink_types = list("nuclear")

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"
	uplink_types = list("nuclear", "traitor")

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

/datum/uplink_item/stealthy_weapons/silence_gloves
	name = "Silence gloves"
	desc = "A pair of black gloves which silences all sounds around you."
	item = /obj/item/clothing/gloves/black/silence
	cost = 8

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking surfactant used to clean blood stains to hide murders and prevent DNA analysis. You can also drop it underfoot to slip people."
	item = /obj/item/weapon/reagent_containers/food/snacks/soap/syndie
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
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/stealthy_tools/switchblade
	name = "Switchblade"
	desc = "A sharp, concealable, spring-loaded knife."
	item = /obj/item/weapon/switchblade
	cost = 2
	uplink_types = list("dealer")

/datum/uplink_item/stealthy_tools/throwingknives
	name = "Throwing Knives"
	desc = "Belt with a bunch of deadly sharp throwing knives."
	item = /obj/item/weapon/storage/belt/security/tactical/throwing
	cost = 9
	uplink_types = list("dealer")

/datum/uplink_item/stealthy_tools/icepick
	name = "Ice Pick"
	desc = "Used for chopping ice. Also excellent for mafia esque murders."
	item = /obj/item/weapon/melee/icepick
	cost = 1
	uplink_types = list("dealer")

/datum/uplink_item/stealthy_tools/spraycan
	name = "Spray Can"
	desc = "It's like crayons, but better."
	item = /obj/item/toy/crayon/spraycan
	cost = 1
	uplink_types = list("dealer")

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
	uplink_types = list("nuclear", "traitor", "dealer")

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
	cost = 1

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

/datum/uplink_item/device_tools/disk
	name = "Diskette With Virus"
	desc = "A floppy disk containing a virus to sabotage R&D systems. Insert this diskette into the R&D Server Controller to destroy scientific data."
	item = /obj/item/weapon/disk/data/syndi
	cost = 10
	uplink_types = list("traitor")

/datum/uplink_item/device_tools/rad_laser
	name = "Radioactive Microlaser"
	desc = "A radioactive microlaser disguised as a standard Nanotrasen health analyzer. When used, it emits a \
			powerful burst of radiation, which, after a short delay, can incapitate all but the most protected \
			of humanoids. It has two settings: intensity, which controls the power of the radiation, \
			and wavelength, which controls how long the radiation delay is."
	item = /obj/item/device/healthanalyzer/rad_laser
	cost = 7
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "The emag is a small card that unlocks hidden functions in electronic devices, subverts intended functions and characteristically breaks security mechanisms."
	item = /obj/item/weapon/card/emag
	cost = 6
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/toolbox
	name = "Full Syndicate Toolbox"
	desc = "The syndicate toolbox is a suspicious black and red. Aside from tools, it comes with cable and a multitool. Insulated gloves are not included."
	item = /obj/item/weapon/storage/toolbox/syndicate
	cost = 1
	uplink_types = list("nuclear", "traitor", "dealer")

/datum/uplink_item/device_tools/surgerybag
	name = "Syndicate Surgery Dufflebag"
	desc = "The Syndicate surgery dufflebag is a toolkit containing all surgery tools, surgical drapes, \
			a MMI, a straitjacket, and a muzzle."
	item = /obj/item/weapon/storage/backpack/dufflebag/surgery
	cost = 4
	uplink_types = list("nuclear", "traitor", "dealer")

/datum/uplink_item/device_tools/c4bag
	name = "Bag of C-4 explosives"
	desc = "Because sometimes quantity is quality. Contains 5 C-4 plastic explosives."
	item = /obj/item/weapon/storage/backpack/dufflebag/c4
	cost = 4 //10% discount!
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/military_belt
	name = "Military Belt"
	desc = "A robust seven-slot red belt that is capable of holding all manner of tatical equipment."
	item = /obj/item/weapon/storage/belt/military
	cost = 1
	uplink_types = list("nuclear", "traitor", "dealer")

/datum/uplink_item/device_tools/medkit
	name = "Syndicate Medical Supply Kit"
	desc = "The syndicate medkit is a suspicious black and red. Included is a combat stimulant injector for rapid healing, a medical hud for quick identification of injured comrades, \
	and other medical supplies helpful for a medical field operative.."
	item = /obj/item/weapon/storage/firstaid/tactical
	cost = 10
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/medkit_small
	name = "Syndicate Medical Small Kit"
	desc = "The syndicate medkit. Included is a combat stimulant injector for rapid healing."
	item = /obj/item/weapon/storage/firstaid/small_firstaid_kit/combat
	cost = 2
	uplink_types = list("nuclear", "traitor", "dealer")

/datum/uplink_item/device_tools/bonepen
	name = "Prototype Bone Repair Kit"
	desc = "Stolen prototype bone repair nanites. Contains three nanocalcium autoinjectors."
	item = /obj/item/weapon/storage/box/syndie_kit/bonepen
	cost = 4
	uplink_types = list("nuclear", "traitor")

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
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "These glasses are thermals disguised as engineers' optical meson scanners. \
	They allow you to see organisms through walls by capturing the upper portion of the infrared light spectrum, emitted as heat and light by objects. \
	Hotter objects, such as warm bodies, cybernetic organisms and artificial intelligence cores emit more of this light than cooler objects like walls and airlocks."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 5
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/thermal/dealer
	item = /obj/item/clothing/glasses/thermal/dealer
	cost = 8
	uplink_types = list("dealer")

	need_wanted_level = 3

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
	cost = 1
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/encryptionkey
	name = "Syndicate Encryption Key"
	desc = "A key that, when inserted into a radio headset, allows you to listen to all station department channels \
			as well as talk on an encrypted Syndicate channel with other agents that have the same key."
	item = /obj/item/device/encryptionkey/syndicate
	cost = 2
	uplink_types = list("nuclear", "traitor", "dealer")

/datum/uplink_item/device_tools/poster_kit
	name = "Poster kit"
	desc = "Box of illegal posters"
	item = /obj/item/weapon/storage/box/syndie_kit/posters
	cost = 1
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/headcan
	name = "Biogel can"
	desc = "Sophisticated device for sustaining life in head for a long period"
	item = /obj/item/device/biocan
	cost = 1
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/ai_detector
	name = "Artificial Intelligence Detector" // changed name in case newfriends thought it detected disguised ai's
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it or its holder. Knowing when an artificial intelligence is watching you is useful for knowing when to maintain cover."
	item = /obj/item/device/multitool/ai_detect
	cost = 2
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Law Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. Be careful with their wording, as artificial intelligences may look for loopholes to exploit."
	item = /obj/item/weapon/aiModule/freeform/syndicate
	cost = 12
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/plastic_explosives
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls, attach it to organisms to destroy them, or connect a signaler to its wiring to make it remotely detonable. \
	It has a modifiable timer with a minimum setting of 10 seconds."
	item = /obj/item/weapon/plastique
	cost = 1
	uplink_types = list("nuclear", "traitor", "dealer")

/datum/uplink_item/device_tools/powersink
	name = "Power sink"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device places excessive load on the grid, causing a stationwide blackout. The sink cannot be carried because of its excessive size. \
	Ordering this sends you a small beacon that will teleport the power sink to your location on activation."
	item = /obj/item/device/powersink
	cost = 12
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/syndcodebook
	name = "Sy-Code Book"
	desc = "Syndicate agents can be trained to use a series of codewords to convey complex information, which sounds like random letters and drinks to anyone listening. \
	This manual teaches you Sy-Code. Limited uses. Use :0 before saying something to speak in Sy-Code."
	item = /obj/item/weapon/syndcodebook
	cost = 1
	uplink_types = list("traitor", "dealer")

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
	cost = 10
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
	cost = 12
	uplink_types = list("nuclear")

/datum/uplink_item/device_tools/traitor_caller
	name = "Traitor Caller"
	desc = "Allows you to request an additional agent selected from the stealthy traitors."
	item = /obj/item/device/traitor_caller
	cost = 35
	uplink_types = list("nuclear")

/datum/uplink_item/device_tools/syndidrone
	name = "Syndicate drone"
	desc = "A remote control drone disguised as a NT maintenance drone. Comes with a RC interface."
	item = /obj/item/weapon/storage/box/syndie_kit/drone
	cost = 14
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/fake_nuke
	name = "Fake Nuke"
	desc = "The most common nuclear bomb. With one but: it doesn't explode. You can <activate> it by double deploying."
	item = /obj/machinery/nuclearbomb/fake
	cost = 6
	uplink_types = list("nuclear")

/datum/uplink_item/device_tools/nuke_teleporter
	name = "Nuke Recaller"
	desc = "A device that can teleport a nuclear bomb directly to the user. It takes a lot of time to activate. There will be an announce upon activation."
	item = /obj/item/nuke_teleporter
	cost = 17
	uplink_types = list("nuclear")

// IMPLANTS

/datum/uplink_item/implants
	category = "Implants"
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant injected into the body and later activated using a bodily gesture to attempt to slip restraints."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_freedom
	cost = 5

/datum/uplink_item/implants/freedom/dealer
	cost = 10
	uplink_types = list("dealer")

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant injected into the body, and later activated using a bodily gesture to open an uplink with 10 telecrystals. \
	The ability for an agent to open an uplink after their posessions have been stripped from them makes this implant excellent for escaping confinement."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_uplink
	cost = 13
	cant_discount = TRUE
	uplink_types = list("traitor")

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

/datum/uplink_item/implants/adrenaline/dealer
	cost = 20
	uplink_types = list("dealer")

/datum/uplink_item/implants/emp
	name = "EMP Implant"
	desc = "An implant, that contains power of three emp grenades, can be activated at the user's will."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_emp
	cost = 3

/datum/uplink_item/implants/emp/dealer
	cost = 14
	uplink_types = list("dealer")
	need_wanted_level = 2

/datum/uplink_item/implants/explosive
	name = "Explosive Implant"
	desc = "An implant, that explodes with different power when activated by a code word."
	item = /obj/item/weapon/implanter/explosive
	cost = 3

// TELECRYSTALS

/datum/uplink_item/telecrystals
	category = "Telecrystals"
	cant_discount = TRUE

/datum/uplink_item/telecrystals/one
	name = "1 Telecrystal"
	desc = "Withdraws one raw telecrystal to share with your killing buddies."
	item = /obj/item/stack/telecrystal
	cost = 1

/datum/uplink_item/telecrystals/five
	name = "5 Telecrystals"
	desc = "Withdraws five raw telecrystals to gift to your lovely crime partner."
	item = /obj/item/stack/telecrystal/five
	cost = 5

/datum/uplink_item/telecrystals/twenty
	name = "20 Telecrystals"
	desc = "Withdraws twenty raw telecrystals to wholly give yourself into hands of your accomplices."
	item = /obj/item/stack/telecrystal/twenty
	cost = 20

// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "(Pointless) Badassery"
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/badass/bundle
	name = "Syndicate Bundle"
	desc = "Syndicate Bundles are specialised groups of items that arrive in a plain box. These items are collectively worth more than 10 telecrystals, but you do not know which specialisation you will receive."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 20
	cant_discount = TRUE

/datum/uplink_item/badass/merch
	name = "Syndicate Merchandise"
	desc = "To show your loalty to the Syndicate! Contains new red t-shirt with Syndicate logo, red cap and a fancy baloon!"
	item = /obj/item/weapon/storage/box/syndie_kit/merch
	cost = 20
	cant_discount = TRUE

/datum/uplink_item/badass/syndiecigs
	name = "Syndicate Smokes"
	desc = "Strong flavor, dense smoke, infused with tricordazine."
	item = /obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate
	cost = 2

/datum/uplink_item/badass/syndiedonuts
	name = "Syndicate Donuts"
	desc = "Special offer from Waffle Co., the box of 6 delicious donuts! But be careful, some of them are posioned!"
	item = /obj/item/weapon/storage/fancy/donut_box/traitor
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
	cant_discount = TRUE

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

/datum/uplink_item/badass/surplus_crate
	name = "Syndicate Surplus Crate"
	desc = "A crate containing 40 telecrystals worth of random syndicate leftovers."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 20
	cant_discount = TRUE
	uplink_types = list("traitor")
	var/crate_value = 40

/datum/uplink_item/badass/surplus_crate/team
	name = "Syndicate Team Surplus Crate"
	desc = "A crate containing 80 telecrystals worth of random syndicate leftovers. Don't fight with your partner!"
	cost = 30
	crate_value = 80

/datum/uplink_item/badass/surplus_crate/super
	name = "Syndicate Super Surplus Crate"
	desc = "A crate containing 160 telecrystals worth of random syndicate leftovers. For badass coopers!"
	cost = 50
	crate_value = 160

/datum/uplink_item/badass/surplus_crate/spawn_item(turf/loc, obj/item/device/uplink/U)
	var/list/temp_uplink_list = get_uplink_items(U)
	var/list/buyable_items = list()
	for(var/category in temp_uplink_list)
		buyable_items += temp_uplink_list[category]

	var/list/bought_items = list()
	var/remaining_TC = crate_value
	while(remaining_TC > 0)
		var/datum/uplink_item/I = pick(buyable_items)
		if(I.cost > remaining_TC)
			continue
		if((I.item in bought_items) && prob(33)) //To prevent people from being flooded with the same thing over and over again.
			continue
		bought_items += I.item
		remaining_TC -= I.cost

	var/obj/structure/closet/crate/C = new(loc)
	for(var/item in bought_items)
		new item(C)

	U.uses -= cost

/datum/uplink_item/revolution
	category = "Revolution!"
	uplink_types = list("rev")

/datum/uplink_item/revolution/derringer
	name = "Derringer Pistol"
	desc = "A double-barelled pistol, small enough to fit in a pocket. That's how it got so close to Lincoln. Chambered in .38, go get them from cargo."
	item = /obj/item/weapon/gun/projectile/revolver/doublebarrel/derringer
	cost = 2

/datum/uplink_item/revolution/mosin
	name = "Mosin-Nagant Rifle"
	desc = "A simple yet powerful bolt-action rifle chambered in 7.74."
	item = /obj/item/weapon/gun/projectile/shotgun/bolt_action
	cost = 4

/datum/uplink_item/revolution/mosin_ammo
	name = "Mosin-Nagant Clip"
	desc = "A simple clip of 7.74 ammo for a simple rifle."
	item = /obj/item/ammo_box/magazine/a774clip
	cost = 1

/datum/uplink_item/revolution/stechkin
	name = "Stechkin Pistol"
	desc = "A small, easily concealable handgun that uses 9mm auto rounds in 7-round magazines."
	item = /obj/item/weapon/gun/projectile/automatic/pistol/stechkin
	cost = 5

/datum/uplink_item/revolution/stechkin_ammo
	name = "9mm Handgun Magazine"
	desc = "An additional 7-round 9mm magazine; compatible with the Stechkin Pistol."
	item = /obj/item/ammo_box/magazine/stechkin
	cost = 1

/datum/uplink_item/revolution/double_barrel
	name = "Double-Barrel Shotgun"
	desc = "Twice the barrels - twice the fun."
	item = /obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon
	cost = 5

/datum/uplink_item/revolution/krinkov
	name = "A74U Assault Rifle"
	desc = "Also known as Krinkov. Nowadays mainly used by lower grade security forces on mining or prison facilites. Uses smaller 7.74 mags."
	item = /obj/item/weapon/gun/projectile/automatic/a74/krinkov
	cost = 12

/datum/uplink_item/revolution/krinkov_ammo
	name = "A74U Magazine"
	desc = "Lower-capacity A74 mag for use in Krinkov."
	item = /obj/item/ammo_box/magazine/a74/krinkov
	cost = 2

/datum/uplink_item/revolution/emp
	name = "EMP Grenade"
	desc = "Classic EMP grenade. Throw it at those pesky cyborgs."
	item = /obj/item/weapon/grenade/empgrenade
	cost = 2

/datum/uplink_item/revolution/armor
	name = "Surplus Armor Set"
	desc = "Set of cheap armor stolen from forgotten military warehouses."
	item = /obj/item/weapon/storage/box/syndie_kit/revolution/armor
	cost = 1

/datum/uplink_item/revolution/posters
	name = "Revolutionary Posters"
	desc = "These posters expose NT lies and promote violence towards monopolists, allowing to convert spacemen remotely."
	item = /obj/item/weapon/storage/box/syndie_kit/revolution/posters
	cost = 1
