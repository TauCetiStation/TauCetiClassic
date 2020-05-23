/obj/structure/closet/secure_closet/warden
	name = "Warden's Locker"
	req_access = list(access_armory)
	icon_state = "wardensecure1"
	icon_closed = "wardensecure"
	icon_locked = "wardensecure1"
	icon_opened = "wardensecureopen"
	icon_broken = "wardensecurebroken"
	icon_off = "wardensecureoff"

/obj/structure/closet/secure_closet/warden/PopulateContents()
	if(prob(50))
		new /obj/item/weapon/storage/backpack/security(src)
	else
		new /obj/item/weapon/storage/backpack/satchel/sec(src)

	new /obj/item/clothing/head/helmet/warden(src)
	new /obj/item/clothing/head/beret/sec/warden(src)
	new /obj/item/clothing/under/rank/warden(src)
	new /obj/item/clothing/under/rank/warden_fem(src)
	new /obj/item/clothing/suit/storage/flak(src)
	new /obj/item/clothing/suit/storage/flak/warden(src)
	new /obj/item/clothing/accessory/holster/armpit(src)
	new /obj/item/weapon/gun/energy/taser(src)
	new /obj/item/weapon/storage/belt/security(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/clothing/glasses/sunglasses/sechud(src)
	new /obj/item/taperoll/police(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/device/flash(src)
	new /obj/item/weapon/reagent_containers/spray/pepper(src)
	new /obj/item/weapon/melee/baton(src)
	new /obj/item/weapon/storage/box/holobadge(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/device/hailer(src)
	new /obj/item/weapon/storage/pouch/pistol_holster(src)
	new /obj/item/weapon/storage/pouch/baton_holster(src)
	new /obj/item/weapon/gun/projectile/wjpp(src)
	#ifdef NEWYEARCONTENT
	new /obj/item/clothing/suit/wintercoat/security(src)
	new /obj/item/clothing/shoes/winterboots(src)
	new /obj/item/clothing/head/santa(src)
	#endif

/obj/structure/closet/secure_closet/security
	name = "Security Officer's Locker"
	req_access = list(access_brig)
	icon_state = "sec1"
	icon_closed = "sec"
	icon_locked = "sec1"
	icon_opened = "secopen"
	icon_broken = "secbroken"
	icon_off = "secoff"

/obj/structure/closet/secure_closet/security/PopulateContents()
	if(prob(50))
		new /obj/item/weapon/storage/backpack/security(src)
	else
		new /obj/item/weapon/storage/backpack/satchel/sec(src)

	new /obj/item/clothing/gloves/security(src)
	new /obj/item/clothing/suit/storage/flak(src)
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/weapon/storage/belt/security(src)
	new /obj/item/clothing/accessory/holster/armpit(src)
	new /obj/item/weapon/gun/energy/taser(src)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/device/flash(src)
	new /obj/item/weapon/reagent_containers/spray/pepper(src)
	new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/weapon/melee/baton(src)
	new /obj/item/clothing/glasses/sunglasses/sechud(src)
	new /obj/item/taperoll/police(src)
	new /obj/item/device/hailer(src)
	new /obj/item/device/flashlight/flare(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/weapon/storage/pouch/pistol_holster(src)
	new /obj/item/weapon/storage/pouch/baton_holster(src)
	new /obj/item/weapon/gun/projectile/wjpp(src)
	#ifdef NEWYEARCONTENT
	new /obj/item/clothing/suit/wintercoat/security(src)
	new /obj/item/clothing/shoes/winterboots(src)
	new /obj/item/clothing/head/ushanka(src)
	#endif

/obj/structure/closet/secure_closet/security/cargo

/obj/structure/closet/secure_closet/security/cargo/PopulateContents()
	new /obj/item/clothing/accessory/armband/cargo(src)
	new /obj/item/device/encryptionkey/headset_cargo(src)

/obj/structure/closet/secure_closet/security/engine

/obj/structure/closet/secure_closet/security/engine/PopulateContents()
	new /obj/item/clothing/accessory/armband/engine(src)
	new /obj/item/device/encryptionkey/headset_eng(src)

/obj/structure/closet/secure_closet/security/science

/obj/structure/closet/secure_closet/security/science/PopulateContents()
	new /obj/item/clothing/accessory/armband/science(src)
	new /obj/item/device/encryptionkey/headset_sci(src)

/obj/structure/closet/secure_closet/security/med

/obj/structure/closet/secure_closet/security/med/PopulateContents()
	new /obj/item/clothing/accessory/armband/medgreen(src)
	new /obj/item/device/encryptionkey/headset_med(src)

/obj/structure/closet/secure_closet/detective
	name = "Detective's Cabinet"
	req_access = list(access_detective)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

/obj/structure/closet/secure_closet/detective/PopulateContents()
	new /obj/item/clothing/under/det(src)
	new /obj/item/weapon/storage/box/evidence(src)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/device/detective_scanner(src)
	new /obj/item/clothing/suit/armor/det_suit(src)
	for (var/i in 1 to 2)
		new /obj/item/ammo_box/magazine/c45r(src)
	new /obj/item/taperoll/police(src)
	new /obj/item/toy/crayon/chalk(src)
	new /obj/item/weapon/gun/projectile/automatic/colt1911(src)
	new /obj/item/clothing/accessory/holster/armpit(src)
	new /obj/item/weapon/storage/pouch/pistol_holster(src)

/obj/structure/closet/secure_closet/detective/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/injection
	name = "Lethal Injections"
	req_access = list(access_captain)

/obj/structure/closet/secure_closet/injection/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/ld50_syringe/choral(src)

/obj/structure/closet/secure_closet/brig
	name = "Brig Locker"
	req_access = list(access_brig)
	anchored = 1
	var/id = null

/obj/structure/closet/secure_closet/brig/PopulateContents()
	new /obj/item/clothing/under/color/orange(src)
	new /obj/item/clothing/shoes/orange(src)

/obj/structure/closet/secure_closet/courtroom
	name = "Courtroom Locker"
	req_access = list(access_security)

/obj/structure/closet/secure_closet/courtroom/PopulateContents()
	new /obj/item/clothing/shoes/brown(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/paper/Court(src)
	new /obj/item/weapon/pen(src)
	new /obj/item/clothing/suit/judgerobe(src)
	new /obj/item/clothing/head/powdered_wig(src)
	new /obj/item/weapon/storage/briefcase(src)

/obj/structure/closet/secure_closet/wall
	name = "wall locker"
	req_access = list(access_brig)
	icon_state = "wall-locker1"
	density = 1
	icon_closed = "wall-locker"
	icon_locked = "wall-locker1"
	icon_opened = "wall-lockeropen"
	icon_broken = "wall-lockerbroken"
	icon_off = "wall-lockeroff"

	//too small to put a man in
	large = 0

/obj/structure/closet/secure_closet/wall/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/forensics
	name = "Forensics's Cabinet"
	req_access = list(access_forensics_lockers)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

/obj/structure/closet/secure_closet/forensics/PopulateContents()
	new /obj/item/clothing/under/rank/forensic_technician(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/forensics/blue(src)
	new /obj/item/clothing/suit/storage/forensics/red(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/shoes/red(src)
	new /obj/item/weapon/storage/box/evidence(src)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/device/detective_scanner(src)
	new /obj/item/taperoll/police(src)
	new /obj/item/toy/crayon/chalk(src)
