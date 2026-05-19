// QUARTERMASTER OUTFIT
/datum/outfit/job/qm
	name = OUTFIT_JOB_NAME("Quartermaster")

	uniform = /obj/item/clothing/under/rank/cargo
	shoes =  /obj/item/clothing/shoes/brown
	glasses = /obj/item/clothing/glasses/sunglasses

	l_ear =  /obj/item/device/radio/headset/headset_cargo
	belt = /obj/item/device/pda/quartermaster

// CARGOTECH OUTFIT
/datum/outfit/job/cargo_tech
	name = OUTFIT_JOB_NAME("Cargo Technician")

	uniform = /obj/item/clothing/under/rank/cargotech
	shoes = /obj/item/clothing/shoes/black

	l_ear = /obj/item/device/radio/headset/headset_cargo
	belt = /obj/item/device/pda/cargo

// CARGOGUARD OUTFIT
/datum/outfit/job/cargo_guard
	name = OUTFIT_JOB_NAME("Cargo Guard")

	head = /obj/item/clothing/head/beret/centcomofficer/cargoguard
	uniform = /obj/item/clothing/under/rank/cargoguard
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/boots

	l_ear = /obj/item/device/radio/headset/headset_sec/nt_pmc/cargo
	gloves = /obj/item/clothing/gloves/security
	belt = /obj/item/device/pda/cargo

	backpack_contents = list(/obj/item/weapon/paper/psc)


// MINER OUTFIT
/datum/outfit/job/mining
	name = OUTFIT_JOB_NAME("Shaft Miner")

	uniform = /obj/item/clothing/under/rank/miner
	shoes = /obj/item/clothing/shoes/black

	l_ear = /obj/item/device/radio/headset/headset_cargo
	belt = /obj/item/device/pda/shaftminer

	backpack_contents = list(
		/obj/item/weapon/mining_voucher,
		/obj/item/weapon/survivalcapsule
		)

	back_style = BACKPACK_STYLE_ENGINEERING

// RECYCLER OUTFIT
/datum/outfit/job/recycler
	name = OUTFIT_JOB_NAME("Recycler")

	uniform = /obj/item/clothing/under/rank/recycler
	shoes = /obj/item/clothing/shoes/black

	l_ear = /obj/item/device/radio/headset/headset_cargo
	belt = /obj/item/device/pda/cargo
