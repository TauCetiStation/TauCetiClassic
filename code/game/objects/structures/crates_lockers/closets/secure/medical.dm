/obj/structure/closet/secure_closet/medical1
	name = "Medicine Closet"
	desc = "Filled with medical junk."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_medical)

/obj/structure/closet/secure_closet/medical1/PopulateContents()
	new /obj/item/weapon/storage/box/autoinjectors(src)
	new /obj/item/weapon/storage/box/syringes(src)

	for (var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/dropper(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/glass/bottle/inaprovaline(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/glass/bottle/antitoxin(src)

/obj/structure/closet/secure_closet/medical2
	name = "Anesthetic"
	desc = "Used to knock people out."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_surgery)

/obj/structure/closet/secure_closet/medical2/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/clothing/mask/breath/medical(src)

/obj/structure/closet/secure_closet/medical3
	name = "Medical Doctor's Locker"
	req_one_access = list(access_surgery, access_paramedic)
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemedoff"

/obj/structure/closet/secure_closet/medical3/PopulateContents()
	if(prob(50))
		new /obj/item/weapon/storage/backpack/medic(src)
	else
		new /obj/item/weapon/storage/backpack/satchel/med(src)

	for (var/i in 1 to 2)
		switch(pick("blue", "green", "purple"))
			if ("blue")
				new /obj/item/clothing/under/rank/medical/blue(src)
				new /obj/item/clothing/head/surgery/blue(src)
			if ("green")
				new /obj/item/clothing/under/rank/medical/green(src)
				new /obj/item/clothing/head/surgery/green(src)
			if ("purple")
				new /obj/item/clothing/under/rank/medical/purple(src)
				new /obj/item/clothing/head/surgery/purple(src)

	new /obj/item/clothing/under/rank/nursesuit (src)
	new /obj/item/clothing/head/nursehat (src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/under/rank/medical/skirt(src)
	new /obj/item/clothing/under/rank/nurse(src)
	new /obj/item/clothing/under/rank/orderly(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/suit/storage/fr_jacket(src)
	new /obj/item/clothing/shoes/white(src)
//	new /obj/item/weapon/cartridge/medical(src)
	new /obj/item/device/radio/headset/headset_med(src)
	new /obj/item/weapon/storage/belt/medical(src)
	new /obj/item/clothing/gloves/latex/nitrile(src)
	new /obj/item/clothing/suit/surgicalapron(src)
	new /obj/item/weapon/gun/energy/pyrometer/medical(src)

/obj/structure/closet/secure_closet/CMO
	name = "Chief Medical Officer's Locker"
	req_access = list(access_cmo)
	icon_state = "cmosecure1"
	icon_closed = "cmosecure"
	icon_locked = "cmosecure1"
	icon_opened = "cmosecureopen"
	icon_broken = "cmosecurebroken"
	icon_off = "cmosecureoff"

/obj/structure/closet/secure_closet/CMO/PopulateContents()
	if(prob(50))
		new /obj/item/weapon/storage/backpack/medic(src)
	else
		new /obj/item/weapon/storage/backpack/satchel/med(src)

	switch(pick("blue", "green", "purple"))
		if ("blue")
			new /obj/item/clothing/under/rank/medical/blue(src)
			new /obj/item/clothing/head/surgery/blue(src)
		if ("green")
			new /obj/item/clothing/under/rank/medical/green(src)
			new /obj/item/clothing/head/surgery/green(src)
		if ("purple")
			new /obj/item/clothing/under/rank/medical/purple(src)
			new /obj/item/clothing/head/surgery/purple(src)

	new /obj/item/clothing/suit/bio_suit/new_hazmat/cmo(src)
	new /obj/item/clothing/head/bio_hood/new_hazmat/cmo(src)
	new /obj/item/device/remote_device/chief_medical_officer(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/under/rank/chief_medical_officer(src)
	new /obj/item/clothing/under/rank/chief_medical_officer/skirt(src)
	new /obj/item/clothing/suit/storage/labcoat/cmo(src)
	new /obj/item/weapon/cartridge/cmo(src)
	new /obj/item/clothing/gloves/latex/nitrile(src)
	new /obj/item/clothing/shoes/brown	(src)
	new /obj/item/device/radio/headset/heads/cmo(src)
	new /obj/item/weapon/storage/belt/medical(src)
	new /obj/item/device/flash(src)
	new /obj/item/weapon/reagent_containers/hypospray/cmo(src)
	new /obj/item/clothing/suit/surgicalapron(src)
	new /obj/item/airbag(src)
	new /obj/item/weapon/storage/pouch/medical_supply(src)

/obj/structure/closet/secure_closet/animal
	name = "Animal Control"
	req_access = list(access_surgery)

/obj/structure/closet/secure_closet/animal/PopulateContents()
	new /obj/item/device/assembly/signaler(src)
	for (var/i in 1 to 3)
		new /obj/item/device/radio/electropack(src)

/obj/structure/closet/secure_closet/chemical
	name = "Chemical Closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "chemical1"
	icon_closed = "chemical"
	icon_locked = "chemical1"
	icon_opened = "medicalopen"
	icon_broken = "chemicalbroken"
	icon_off = "chemicaloff"
	req_access = list(access_chemistry)

/obj/structure/closet/secure_closet/chemical/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/weapon/storage/box/pillbottles(src)
	new /obj/item/weapon/storage/pouch/flare/vial(src)

/obj/structure/closet/secure_closet/medical_wall
	name = "First Aid Closet"
	desc = "It's a secure wall-mounted storage unit for first aid supplies."
	icon_state = "medical_wall_locked"
	icon_closed = "medical_wall_unlocked"
	icon_locked = "medical_wall_locked"
	icon_opened = "medical_wall_open"
	icon_broken = "medical_wall_spark"
	icon_off = "medical_wall_off"
	anchored = 1
	density = 0
	wall_mounted = 1
	req_access = list(access_medical)

/obj/structure/closet/secure_closet/medical_wall/update_icon()
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
