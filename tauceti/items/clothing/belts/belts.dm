/obj/item/weapon/storage/belt/military
	name = "military belt"
	desc = "A syndicate belt designed to be used by boarding parties.  Its style is modeled after the hardsuits they wear."
	icon = 'tauceti/items/clothing/belts/nuke.dmi'
	tc_custom = 'tauceti/items/clothing/belts/nuke.dmi'
	icon_state = "militarybelt"
	can_hold = list()

/obj/item/weapon/storage/belt/security/improved
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes. Also can hold a weapon in drop leg holster attachment. Press alt-click to holster a weapon."
	icon = 'tauceti/items/clothing/belts/secbelt.dmi'
	tc_custom = 'tauceti/items/clothing/belts/secbelt.dmi'
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

/obj/item/weapon/storage/belt/security/improved/proc/updateicon(mob/user as mob)
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

/obj/item/weapon/storage/belt/security/improved/proc/holster(obj/item/I, mob/user as mob)
	if(holstered)
		user << "\red There is already a [holstered] holstered here!"
		return

	if (!istype(I, /obj/item/weapon/gun) && !istype(I, /obj/item/weapon/melee/baton))
		user << "\red Only handguns and stun batons can be holstered!"
		return

	if(istype(I, /obj/item/weapon/gun))
		var/obj/item/weapon/gun/W = I
		if (!W.isHandgun())
			user << "\red This [W] won't fit in the [src]!"
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

/obj/item/weapon/storage/belt/security/improved/proc/unholster(mob/user as mob)
	if(!holstered)
		return

	if(istype(user.get_active_hand(),/obj)) // && istype(user.get_inactive_hand(),/obj))
		user << "\red You need an empty hand to draw the [holstered]!"
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