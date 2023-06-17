/obj/structure/closet/secure_closet/captains
	name = "Captain's Locker"
	req_access = list(access_captain)
	icon_state = "capsecure1"
	icon_closed = "capsecure"
	icon_locked = "capsecure1"
	icon_opened = "capsecureopen"
	icon_broken = "capsecurebroken"
	icon_off = "capsecureoff"

/obj/structure/closet/secure_closet/captains/PopulateContents()
	if(prob(50))
		new /obj/item/weapon/storage/backpack/captain(src)
	else
		new /obj/item/weapon/storage/backpack/satchel/cap(src)
	new /obj/item/clothing/suit/captunic(src)
	new /obj/item/clothing/suit/captunic/capjacket(src)
	new /obj/item/clothing/head/helmet/cap(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/weapon/cartridge/captain(src)
	new /obj/item/clothing/head/helmet/swat(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/device/radio/headset/heads/captain(src)
	new /obj/item/clothing/gloves/captain(src)
	new /obj/item/weapon/gun/energy/gun/head(src)
	new /obj/item/clothing/accessory/holster/armpit(src)
	new /obj/item/weapon/melee/telebaton(src)
	new /obj/item/clothing/under/dress/dress_cap(src)
	new /obj/item/clothing/under/rank/capcamsole(src)
	new /obj/item/device/remote_device/captain(src)
	new /obj/item/airbag(src)
	new /obj/item/weapon/storage/pouch/pistol_holster(src)
	new /obj/item/weapon/storage/lockbox/medal/captain(src)
	if(SSenvironment.envtype[z] == ENV_TYPE_SNOW)
		new /obj/item/clothing/suit/hooded/wintercoat/captain(src)
		new /obj/item/clothing/head/santa(src)
		new /obj/item/clothing/shoes/winterboots(src)

/obj/structure/closet/secure_closet/iaa
	name = "Internal Affairs Agent's Locker"
	req_access = list(access_lawyer)
	icon_state = "iaasecure1"
	icon_closed = "iaasecure"
	icon_locked = "iaasecure1"
	icon_opened = "iaasecureopen"
	icon_broken = "iaasecurebroken"
	icon_off = "iaasecureoff"

/obj/structure/closet/secure_closet/iaa/PopulateContents()
	new /obj/item/weapon/storage/backpack/satchel(src)
	new /obj/item/clothing/under/suit_jacket/burgundy(src)
	new /obj/item/clothing/shoes/leather(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/under/lawyer/female(src)
	new /obj/item/clothing/under/lawyer/black(src)
	new /obj/item/clothing/under/lawyer/red(src)
	new /obj/item/clothing/under/lawyer/bluesuit(src)
	new /obj/item/clothing/suit/storage/lawyer/bluejacket(src)
	new /obj/item/clothing/under/lawyer/purpsuit(src)
	new /obj/item/clothing/suit/storage/lawyer/purpjacket(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/weapon/storage/briefcase/centcomm(src)
	new /obj/item/device/radio/headset/headset_int(src)

/obj/structure/closet/secure_closet/hop
	name = "Head of Personnel's Locker"
	req_access = list(access_hop)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"

/obj/structure/closet/secure_closet/hop/PopulateContents()
	new /obj/item/device/remote_device/head_of_personal(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/weapon/cartridge/hop(src)
	new /obj/item/device/radio/headset/heads/hop(src)

	for (var/i in 1 to 2)
		new /obj/item/weapon/storage/box/ids(src)

	new /obj/item/weapon/gun/energy/gun/head(src)
	new /obj/item/clothing/accessory/holster/armpit(src)
	new /obj/item/device/flash(src)
	new /obj/item/airbag(src)
	new /obj/item/weapon/storage/pouch/pistol_holster(src)
	new /obj/item/weapon/storage/lockbox/medal/hop(src)

/obj/structure/closet/secure_closet/hop2
	name = "Head of Personnel's Attire"
	req_access = list(access_hop)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"

/obj/structure/closet/secure_closet/hop2/PopulateContents()
	new /obj/item/clothing/head/fez(src)
	new /obj/item/clothing/under/rank/head_of_personnel(src)
	new /obj/item/clothing/under/dress/dress_hop(src)
	new /obj/item/clothing/under/dress/dress_hr(src)
	new /obj/item/clothing/under/lawyer/female(src)
	new /obj/item/clothing/under/lawyer/black(src)
	new /obj/item/clothing/under/lawyer/red(src)
	new /obj/item/clothing/under/lawyer/oldman(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/leather(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/under/rank/head_of_personnel_whimsy(src)
	new /obj/item/clothing/under/rank/goodman_shirt(src)
	new /obj/item/clothing/suit/goodman_jacket(src)

/obj/structure/closet/secure_closet/hos
	name = "Head of Security's Locker"
	req_access = list(access_hos)
	icon_state = "hossecure1"
	icon_closed = "hossecure"
	icon_locked = "hossecure1"
	icon_opened = "hossecureopen"
	icon_broken = "hossecurebroken"
	icon_off = "hossecureoff"

/obj/structure/closet/secure_closet/hos/PopulateContents()
	if(prob(50))
		new /obj/item/weapon/storage/backpack/security(src)
	else
		new /obj/item/weapon/storage/backpack/satchel/sec(src)

	new /obj/item/clothing/accessory/armor/dermal(src)
	new /obj/item/clothing/head/hos_peakedcap(src)
	new /obj/item/device/remote_device/head_of_security(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/under/rank/head_of_security(src)
	new /obj/item/weapon/storage/belt/security(src)
	new /obj/item/weapon/cartridge/hos(src)
	new /obj/item/device/radio/headset/heads/hos(src)
	new /obj/item/taperoll/police(src)
	new /obj/item/clothing/gloves/black/hos(src)
	new /obj/item/clothing/glasses/hud/hos_aug(src)
	new /obj/item/weapon/shield/riot/tele(src)
	new /obj/item/weapon/storage/lockbox/loyalty(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/device/flash(src)
	new /obj/item/weapon/reagent_containers/spray/pepper(src)
	new /obj/item/weapon/melee/baton(src)
	new /obj/item/clothing/accessory/holster/armpit(src)
	new /obj/item/weapon/melee/telebaton(src)
	new /obj/item/weapon/gun/energy/gun/hos(src)
	new /obj/item/device/flashlight/flare(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/airbag(src)
	new /obj/item/weapon/storage/pouch/pistol_holster(src)
	new /obj/item/weapon/storage/pouch/baton_holster(src)
	new /obj/item/weapon/gun/energy/taser(src)
	new /obj/item/weapon/storage/lockbox/medal/hos(src)
	if(SSenvironment.envtype[z] == ENV_TYPE_SNOW)
		new /obj/item/clothing/suit/hooded/wintercoat/security(src)
		new /obj/item/clothing/shoes/winterboots(src)
		new /obj/item/clothing/head/santa(src)

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
	new /obj/item/weapon/storage/belt/security(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/clothing/glasses/sunglasses/hud/sechud(src)
	new /obj/item/taperoll/police(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/device/flash(src)
	new /obj/item/weapon/reagent_containers/spray/pepper(src)
	new /obj/item/weapon/melee/baton(src)
	new /obj/item/weapon/storage/box/holobadge(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/clothing/shoes/boots(src)
	new /obj/item/device/hailer(src)
	new /obj/item/weapon/storage/pouch/pistol_holster(src)
	new /obj/item/weapon/storage/pouch/baton_holster(src)
	new /obj/item/weapon/gun/energy/taser(src)
	new /obj/item/weapon/storage/box/mines/shock(src)
	if(SSenvironment.envtype[z] == ENV_TYPE_SNOW)
		new /obj/item/clothing/suit/hooded/wintercoat/security(src)
		new /obj/item/clothing/shoes/winterboots(src)
		new /obj/item/clothing/head/santa(src)

ADD_TO_GLOBAL_LIST(/obj/structure/closet/secure_closet/security, sec_closets_list)
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
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/device/flash(src)
	new /obj/item/weapon/reagent_containers/spray/pepper(src)
	new /obj/item/weapon/grenade/flashbang(src)
	new /obj/item/weapon/melee/baton(src)
	new /obj/item/clothing/glasses/sunglasses/hud/sechud(src)
	new /obj/item/taperoll/police(src)
	new /obj/item/device/hailer(src)
	new /obj/item/device/flashlight/flare(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/weapon/storage/pouch/pistol_holster(src)
	new /obj/item/weapon/storage/pouch/baton_holster(src)
	new /obj/item/weapon/gun/energy/taser(src)
	if(SSenvironment.envtype[z] == ENV_TYPE_SNOW)
		new /obj/item/clothing/suit/hooded/wintercoat/security(src)
		new /obj/item/clothing/shoes/winterboots(src)
		new /obj/item/clothing/head/ushanka(src)


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
	if(prob(50))
		new /obj/item/weapon/gun/projectile/automatic/colt1911(src)
		for (var/i in 1 to 2)
			new /obj/item/ammo_box/magazine/colt/rubber(src)
	else
		new /obj/item/weapon/gun/projectile/revolver/detective(src)
		for (var/i in 1 to 2)
			new /obj/item/ammo_box/speedloader/c38(src)
	new /obj/item/taperoll/police(src)
	new /obj/item/toy/crayon/chalk(src)
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
	anchored = TRUE
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
	density = TRUE
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
	new /obj/item/clothing/under/rank/forensic_technician/black(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/forensics/blue(src)
	new /obj/item/clothing/suit/storage/forensics/red(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/weapon/storage/box/evidence(src)
	new /obj/item/device/radio/headset/headset_sec(src)
	new /obj/item/device/detective_scanner(src)
	new /obj/item/taperoll/police(src)
	new /obj/item/toy/crayon/chalk(src)

/obj/structure/closet/secure_closet/pistols
	name = "Pistol Secure Closet"
	req_access = list(access_armory)
	icon_state = "syndicatealtsecure1"
	icon_closed = "syndicatealtsecure"
	icon_locked = "syndicatealtsecure1"
	icon_opened = "syndicatealtsecureopen"
	icon_broken = "syndicatealtsecurebroken"
	icon_off = "syndicatealtsecureoff"

/obj/structure/closet/secure_closet/pistols/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/weapon/gun/projectile/automatic/glock(src)

/obj/structure/closet/secure_closet/usp_cartridges
	name = "USP cartridges Secure Closet"
	req_access = list(access_keycard_auth)

/obj/structure/closet/secure_closet/usp_cartridges/PopulateContents()
	new /obj/item/weapon/skill_cartridge/usp7(src)
	new /obj/item/weapon/skill_cartridge/usp7(src)
	new /obj/item/weapon/skill_cartridge/csp15(src)
	new /obj/item/weapon/skill_cartridge/usp5(src)
	new /obj/item/weapon/skill_cartridge/usp5(src)
	new /obj/item/weapon/skill_cartridge/usp5(src)

/obj/structure/closet/blueshield
	name = "Blueshield Officer's Wardrobe"
	req_access = list(access_blueshield)
	icon_state = "blueshield"
	icon_closed = "blueshield"
	icon_opened = "blueshieldopen"

/obj/structure/closet/blueshield/PopulateContents()
	new /obj/item/clothing/head/beret/blueshield(src)
	new /obj/item/clothing/head/soft/blueshield(src)
	new /obj/item/clothing/under/rank/blueshield(src)
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/clothing/suit/storage/flak(src)
	if(prob(50))
		new /obj/item/weapon/storage/backpack(src)
	else
		new /obj/item/weapon/storage/backpack/satchel/norm(src)

/obj/structure/closet/secure_closet/blueshield
	name = "Blueshield Officer's Equipment Locker"
	icon_state = "blueshieldsecure1"
	icon_closed = "blueshieldsecure"
	icon_locked = "blueshieldsecure1"
	icon_opened = "blueshieldsecureopen"
	icon_broken = "blueshieldsecurebroken"
	icon_off = "blueshieldsecureoff"

/obj/structure/closet/secure_closet/blueshield/PopulateContents()
	new /obj/item/clothing/head/helmet/blueshield(src)
	new /obj/item/clothing/suit/storage/flak/blueshield(src)

	new /obj/item/weapon/melee/baton(src)
	new /obj/item/weapon/gun/projectile/automatic/glock/spec(src)
	for (var/i in 1 to 4)
		new /obj/item/ammo_box/magazine/glock/extended/rubber(src)
	for (var/i in 1 to 2)
		new /obj/item/ammo_box/magazine/glock/extended(src)
	new /obj/item/weapon/shield/riot/tele(src)
	new /obj/item/weapon/storage/belt/security(src)

	new /obj/item/device/radio/headset/headset_int/blueshield(src)
	new /obj/item/clothing/accessory/holster/armpit(src)
	new /obj/item/device/flash(src)
	new /obj/item/clothing/glasses/sunglasses/hud/sechud/tactical(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/weapon/storage/pouch/baton_holster(src)
