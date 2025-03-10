/obj/structure/closet/secure_closet/medical1
	name = "Medicine Closet"
	desc = "Filled with medical junk."
	req_access = list(access_medical)
	icon_state = "medical"
	icon_closed = "medical"
	icon_opened = "medical_open"

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
	req_access = list(access_surgery)
	icon_state = "medical"
	icon_closed = "medical"
	icon_opened = "medical_open"

/obj/structure/closet/secure_closet/medical2/PopulateContents()
	for (var/i in 1 to 4)
		new /obj/item/weapon/tank/anesthetic/small(src)
		new /obj/item/clothing/mask/breath/medical(src)

/obj/structure/closet/secure_closet/medical3
	name = "Medical Doctor's Locker"
	req_one_access = list(access_surgery, access_paramedic)
	icon_state = "securemed"
	icon_closed = "securemed"
	icon_opened = "securemed_open"

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
	icon_state = "cmosecure"
	icon_closed = "cmosecure"
	icon_opened = "cmosecure_open"

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
	new /obj/item/weapon/storage/lockbox/medal/cmo(src)

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
	req_access = list(access_chemistry)
	icon_state = "chemical"
	icon_closed = "chemical"
	icon_opened = "medical_open"

/obj/structure/closet/secure_closet/chemical/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/weapon/storage/box/pillbottles(src)
	new /obj/item/weapon/storage/pouch/flare/vial(src)

/obj/structure/closet/secure_closet/medical_wall
	name = "First Aid Closet"
	desc = "It's a secure wall-mounted storage unit for first aid supplies."
	req_access = list(access_medical)
	icon_state = "medicalwallsec"
	icon_closed = "medicalwallsec"
	icon_opened = "medicalwall_open"
	overlay_locked = "medicalwall_locked"
	overlay_unlocked = "medicalwall_unlocked"
	anchored = TRUE
	density = FALSE
	wall_mounted = 1
