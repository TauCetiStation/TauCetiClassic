/obj/item/weapon/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")

/obj/item/weapon/storage/belt/utility
	name = "tool-belt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Can hold various tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	can_hold = list(
		"/obj/item/weapon/crowbar",
		"/obj/item/weapon/screwdriver",
		"/obj/item/weapon/weldingtool",
		"/obj/item/weapon/wirecutters",
		"/obj/item/weapon/wrench",
		"/obj/item/device/multitool",
		"/obj/item/device/flashlight",
		"/obj/item/weapon/cable_coil",
		"/obj/item/device/t_scanner",
		"/obj/item/device/analyzer",
		"/obj/item/taperoll/engineering")


/obj/item/weapon/storage/belt/utility/full/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/weapon/cable_coil(src,30,pick("red","yellow","orange"))


/obj/item/weapon/storage/belt/utility/atmostech/New()
	..()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/crowbar(src)
	new /obj/item/weapon/wirecutters(src)
	new /obj/item/device/t_scanner(src)



/obj/item/weapon/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	can_hold = list(
		"/obj/item/device/healthanalyzer",
		"/obj/item/weapon/dnainjector",
		"/obj/item/weapon/reagent_containers/dropper",
		"/obj/item/weapon/reagent_containers/glass/beaker",
		"/obj/item/weapon/reagent_containers/glass/bottle",
		"/obj/item/weapon/reagent_containers/pill",
		"/obj/item/weapon/reagent_containers/syringe",
		"/obj/item/weapon/reagent_containers/glass/dispenser",
		"/obj/item/weapon/lighter/zippo",
		"/obj/item/weapon/storage/fancy/cigarettes",
		"/obj/item/weapon/storage/pill_bottle",
		"/obj/item/stack/medical",
		"/obj/item/device/flashlight/pen",
		"/obj/item/clothing/mask/surgical",
		"/obj/item/clothing/gloves/latex",
	    "/obj/item/weapon/reagent_containers/hypospray",
	    "/obj/item/device/sensor_device"
	    )
/obj/item/weapon/storage/belt/medical/surg
	name = "Surgery belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	storage_slots = 9
	max_w_class = 3
	max_combined_w_class = 21
	can_hold = list(
		"/obj/item/device/healthanalyzer",
		"/obj/item/weapon/reagent_containers/glass/beaker",
		"/obj/item/weapon/reagent_containers/glass/bottle",
		"/obj/item/weapon/reagent_containers/pill",
		"/obj/item/weapon/reagent_containers/syringe",
		"/obj/item/weapon/storage/fancy/cigarettes",
		"/obj/item/weapon/storage/pill_bottle",
		"/obj/item/stack/medical",
		"/obj/item/device/flashlight/pen",
		"/obj/item/clothing/mask/surgical",
		"/obj/item/clothing/gloves/latex",
	    "/obj/item/weapon/reagent_containers/hypospray",
	    "/obj/item/weapon/retractor",
	    "/obj/item/weapon/hemostat",
	    "/obj/item/weapon/cautery",
	    "/obj/item/weapon/surgicaldrill",
	    "/obj/item/weapon/scalpel",
	    "/obj/item/weapon/circular_saw",
	    "/obj/item/weapon/bonegel",
	    "/obj/item/weapon/FixOVein",
	    "/obj/item/weapon/bonesetter"
	)
/obj/item/weapon/storage/belt/medical/surg/full/New()
	..()
	new /obj/item/weapon/retractor(src)
	new /obj/item/weapon/hemostat(src)
	new /obj/item/weapon/cautery(src)
	new /obj/item/weapon/surgicaldrill(src)
	new /obj/item/weapon/scalpel(src)
	new /obj/item/weapon/circular_saw(src)
	new /obj/item/weapon/bonegel(src)
	new /obj/item/weapon/FixOVein(src)
	new /obj/item/weapon/bonesetter(src)

/obj/item/weapon/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 7
	max_w_class = 3
	max_combined_w_class = 21
	can_hold = list(
		"/obj/item/weapon/grenade/flashbang",
		"/obj/item/weapon/reagent_containers/spray/pepper",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/ammo_casing/shotgun",
		"/obj/item/ammo_magazine",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/normal",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/jelly",
		"/obj/item/weapon/melee/baton",
		"/obj/item/weapon/lighter/zippo",
		"/obj/item/weapon/cigpacket",
		"/obj/item/clothing/glasses/hud/security",
		"/obj/item/device/flashlight",
		"/obj/item/device/pda",
		"/obj/item/device/radio/headset",
		"/obj/item/weapon/melee",
		"/obj/item/taperoll/police",
		"/obj/item/weapon/gun/energy/taser",
		"/obj/item/weapon/shield/riot/tele"
		)

/obj/item/weapon/storage/belt/security/wj
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "wjbelt"
	item_state = "wjbelt"//Could likely use a better one.

/obj/item/weapon/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away."
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	can_hold = list(
		"/obj/item/device/soulstone"
		)

/obj/item/weapon/storage/belt/soulstone/full/New()
	..()
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)


/obj/item/weapon/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	storage_slots = 1
	can_hold = list(
		"/obj/item/clothing/mask/luchador"
		)

/obj/item/weapon/storage/belt/security/tactical
	name = "combat belt"
	desc = "Can hold security gear like handcuffs and flashes, with more pouches for more storage."
	icon_state = "swatbelt"
	item_state = "swatbelt"
	storage_slots = 9
	max_w_class = 3
	max_combined_w_class = 21
	can_hold = list(
		"/obj/item/weapon/grenade/flashbang",
		"/obj/item/weapon/reagent_containers/spray/pepper",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/ammo_casing/shotgun",
		"/obj/item/ammo_magazine",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/normal",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/jelly",
		"/obj/item/weapon/melee/baton",
		"/obj/item/weapon/gun/energy/taser",
		"/obj/item/weapon/lighter/zippo",
		"/obj/item/weapon/cigpacket",
		"/obj/item/clothing/glasses/hud/security",
		"/obj/item/device/flashlight",
		"/obj/item/device/pda",
		"/obj/item/taperoll/police",
		"/obj/item/device/radio/headset",
		"/obj/item/weapon/melee"
		)

/obj/item/weapon/storage/belt/military
	name = "military belt"
	desc = "A syndicate belt designed to be used by boarding parties.  Its style is modeled after the hardsuits they wear."
	icon_state = "militarybelt"
	can_hold = list()

/obj/item/weapon/storage/belt/security/improved
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes. Also can hold a weapon in drop leg holster attachment. Press alt-click to holster a weapon."
	icon_state = "belt"
	item_state = "belt"
	var/obj/item/weapon/holstered = null
	//max_w_class = 2
	can_hold = list(
		"/obj/item/weapon/grenade/flashbang",
		"/obj/item/weapon/reagent_containers/spray/pepper",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/ammo_casing/shotgun",
		"/obj/item/ammo_magazine",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/normal",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/jelly",
		"/obj/item/weapon/lighter/zippo",
		"/obj/item/weapon/cigpacket",
		"/obj/item/clothing/glasses/hud/security",
		"/obj/item/device/flashlight",
		"/obj/item/device/pda",
		"/obj/item/device/radio/headset",
		"/obj/item/weapon/melee",
		"/obj/item/taperoll/police",
		"/obj/item/weapon/shield/riot/tele",
		"/obj/item/weapon/gun/energy/taser",
		"/obj/item/weapon/melee/baton"
		)

/obj/item/weapon/storage/belt/security/improved/New()
	..()
	updateicon()

/obj/item/weapon/storage/belt/security/improved/AltClick(mob/user)
	if(user.stat || user.incapacitated())
		return
	if(holstered)
		unholster(user)
	else
		holster(user.get_active_hand(),user)

/obj/item/weapon/storage/belt/security/improved/proc/updateicon(mob/user)
	if(!holstered)
		icon_state = "[initial(icon_state)]"
		item_state = "[initial(item_state)]"
	else if(istype(holstered, /obj/item/weapon/melee/baton))
		icon_state = "[initial(icon_state)]-baton"
		item_state = "[initial(item_state)]-baton"
	else if(istype(holstered, /obj/item/weapon/gun/energy/taser))
		icon_state = "[initial(icon_state)]-taser"
		item_state = "[initial(item_state)]-taser"
	else if(istype(holstered, /obj/item/weapon/gun/energy/stunrevolver))
		icon_state = "[initial(icon_state)]-stun"
		item_state = "[initial(item_state)]-taser"
	else if(istype(holstered, /obj/item/weapon/gun/projectile/revolver/doublebarrel)) //?? ????????
		icon_state = "[initial(icon_state)]-sawnoff"
		item_state = "[initial(item_state)]-sawnoff"
	else if( istype(holstered, /obj/item/weapon/gun/projectile/automatic/colt1911) ||  istype(holstered, /obj/item/weapon/gun/energy/pulse_rifle/M1911))
		icon_state = "[initial(icon_state)]-colt"
		item_state = "[initial(item_state)]-gun"
	else if(istype(holstered, /obj/item/weapon/gun/projectile/automatic/pistol))
		var/obj/item/weapon/gun/projectile/automatic/pistol/P = holstered
		if(P.silenced)
			icon_state = "[initial(icon_state)]-stechkinsilencer"
		else
			icon_state = "[initial(icon_state)]-stechkin"
		item_state = "[initial(item_state)]-gun"
	else if(istype(holstered, /obj/item/weapon/gun/projectile/automatic/deagle/gold))
		icon_state = "[initial(icon_state)]-gdeagle"
		item_state = "[initial(item_state)]-gun"
//	else if(istype(holstered, /obj/item/weapon/gun/projectile/automatic/deagle/camo))
//		icon_state = "[initial(icon_state)]-cdeagle"
//		item_state = "[initial(item_state)]-gun"
	else if(istype(holstered, /obj/item/weapon/gun/projectile/automatic/deagle))
		icon_state = "[initial(icon_state)]-sdeagle"
		item_state = "[initial(item_state)]-gun"
	else if(istype(holstered, /obj/item/weapon/gun/projectile/automatic/gyropistol)) //?? ????????
		icon_state = "[initial(icon_state)]-gyro"
		item_state = "[initial(item_state)]-gun"
	else if(istype(holstered, /obj/item/weapon/gun/projectile/revolver/detective))
		icon_state = "[initial(icon_state)]-detgun"
		item_state = "[initial(item_state)]-gun"
	else if(istype(holstered, /obj/item/weapon/gun/projectile/automatic/silenced))
		icon_state = "[initial(icon_state)]-silence"
		item_state = "[initial(item_state)]-gun"
	else if(istype(holstered, /obj/item/weapon/gun/projectile/revolver/mateba))
		icon_state = "[initial(icon_state)]-mateba"
		item_state = "[initial(item_state)]-gun"
	else if(istype(holstered, /obj/item/weapon/gun/projectile/revolver/syndie))
		icon_state = "[initial(icon_state)]-sdeagle"
		item_state = "[initial(item_state)]-gun"
	else
		icon_state = "[initial(icon_state)]-stechkin"
		item_state = "[initial(item_state)]-gun"



	if(user)
		user.update_inv_belt()

/obj/item/weapon/storage/belt/security/improved/proc/holster(obj/item/I, mob/user)
	if(holstered)
		to_chat(user, "\red There is already a [holstered] holstered here!")
		return

	if (!istype(I, /obj/item/weapon/gun) && !istype(I, /obj/item/weapon/melee/baton))
		to_chat(user, "\red Only handguns and stun batons can be holstered!")
		return

	if(istype(I, /obj/item/weapon/gun))
		var/obj/item/weapon/gun/W = I
		if (!W.isHandgun())
			to_chat(user, "\red This [W] won't fit in the [src]!")
			return

	holstered = I
	user.drop_from_inventory(holstered)
//	holstered.loc = src
	holstered.x = 1
	holstered.y = 171
	holstered.z = 2
	holstered.add_fingerprint(user)
	user.visible_message("\blue [user] holsters the [holstered].", "You holster the [holstered].")
	updateicon(user)

/obj/item/weapon/storage/belt/security/improved/proc/unholster(mob/user)
	if(!holstered)
		return

	if(istype(user.get_active_hand(),/obj)) // && istype(user.get_inactive_hand(),/obj))
		to_chat(user, "\red You need an empty hand to draw the [holstered]!")
	else
		if(user.a_intent == "hurt")
			usr.visible_message("\red [user] draws the [holstered], ready to shoot!", \
			"\red You draw the [holstered], ready to shoot!")
		else
			user.visible_message("\blue [user] draws the [holstered], pointing it at the ground.", \
			"\blue You draw the [holstered], pointing it at the ground.")
		user.put_in_hands(holstered)
		holstered.add_fingerprint(user)
		holstered = null
	updateicon(user)
