// All chameleon gear shares /datum/component/chameleon. The component adds the
// "Change Appearance" verb and handles EMP, so items only need to attach it.

//*****************
//**Cham Jumpsuit**
//*****************

/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	desc = "It's a plain jumpsuit. It seems to have a small dial on the wrist."
	origin_tech = "syndicate=3"

/obj/item/clothing/under/chameleon/atom_init()
	. = ..()
	AddComponent(/datum/component/chameleon, /obj/item/clothing/under, list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/golem, /obj/item/clothing/under/gimmick))

//*****************
//**Chameleon Hat**
//*****************

/obj/item/clothing/head/chameleon
	name = "grey cap"
	icon_state = "greysoft"
	item_state = "greysoft"
	desc = "It looks like a plain hat, but upon closer inspection, there's an advanced holographic array installed inside. It seems to have a small dial inside."
	origin_tech = "syndicate=3"
	body_parts_covered = 0

/obj/item/clothing/head/chameleon/atom_init()
	. = ..()
	AddComponent(/datum/component/chameleon, /obj/item/clothing/head, list(/obj/item/clothing/head/chameleon, /obj/item/clothing/head/helmet/space/golem, /obj/item/clothing/head/justice, /obj/item/clothing/head/collectable/tophat/badmin_magic_hat))

//******************
//**Chameleon Suit**
//******************

/obj/item/clothing/suit/chameleon
	name = "armor"
	icon_state = "armor"
	item_state = "armor"
	desc = "It appears to be a vest of standard armor, except this is embedded with a hidden holographic cloaker, allowing it to change it's appearance, but offering no protection.. It seems to have a small dial inside."
	origin_tech = "syndicate=3"

/obj/item/clothing/suit/chameleon/atom_init()
	. = ..()
	AddComponent(/datum/component/chameleon, /obj/item/clothing/suit, list(/obj/item/clothing/suit/chameleon, /obj/item/clothing/suit/space/space_ninja, /obj/item/clothing/suit/space/golem, /obj/item/clothing/suit/justice, /obj/item/clothing/suit/greatcoat))

//*******************
//**Chameleon Shoes**
//*******************
/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "black"
	item_state = "bl_shoes"
	desc = "They're comfy black shoes, with clever cloaking technology built in. It seems to have a small dial on the back of each shoe."
	origin_tech = "syndicate=3"

/obj/item/clothing/shoes/chameleon/atom_init()
	. = ..()
	AddComponent(/datum/component/chameleon, /obj/item/clothing/shoes, list(/obj/item/clothing/shoes/chameleon, /obj/item/clothing/shoes/golem, /obj/item/clothing/shoes/syndigaloshes, /obj/item/clothing/shoes/cyborg))

//**********************
//**Chameleon Backpack**
//**********************
/obj/item/weapon/storage/backpack/chameleon
	name = "backpack"
	icon_state = "backpack"
	item_state = "backpack"
	desc = "A backpack outfitted with cloaking tech. It seems to have a small dial inside, kept away from the storage."
	origin_tech = "syndicate=3"

/obj/item/weapon/storage/backpack/chameleon/atom_init()
	. = ..()
	AddComponent(/datum/component/chameleon, /obj/item/weapon/storage/backpack, list(/obj/item/weapon/storage/backpack/chameleon, /obj/item/weapon/storage/backpack/satchel/withwallet))

//********************
//**Chameleon Gloves**
//********************

/obj/item/clothing/gloves/chameleon
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	desc = "It looks like a pair of gloves, but it seems to have a small dial inside."
	origin_tech = "syndicate=3"

/obj/item/clothing/gloves/chameleon/atom_init()
	. = ..()
	AddComponent(/datum/component/chameleon, /obj/item/clothing/gloves, list(/obj/item/clothing/gloves/chameleon, /obj/item/clothing/gloves/black/strip, /obj/item/clothing/gloves/black/silence))

//******************
//**Chameleon Mask**
//******************

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	icon_state = "gas_mask_tc"
	item_state = "gas_mask_tc"
	desc = "It looks like a plain gask mask, but on closer inspection, it seems to have a small dial inside."
	origin_tech = "syndicate=3"

/obj/item/clothing/mask/chameleon/atom_init()
	. = ..()
	AddComponent(/datum/component/chameleon, /obj/item/clothing/mask, list(/obj/item/clothing/mask/chameleon))

//*********************
//**Chameleon Glasses**
//*********************

/obj/item/clothing/glasses/chameleon
	name = "optical meson scanner"
	icon_state = "meson"
	item_state = "glasses"
	item_state_world = "meson_w"
	desc = "It looks like a plain set of mesons, but on closer inspection, it seems to have a small dial inside."
	origin_tech = "syndicate=3"

/obj/item/clothing/glasses/chameleon/atom_init()
	. = ..()
	AddComponent(/datum/component/chameleon, /obj/item/clothing/glasses, list(/obj/item/clothing/glasses/chameleon))

//*****************
//**Chameleon Gun**
//*****************
/obj/item/weapon/gun/projectile/chameleon
	name = "desert eagle"
	desc = "A fake Desert Eagle with a dial on the side to change the gun's disguise."
	icon_state = "deagle"
	item_state = "deagle"
	w_class = SIZE_SMALL
	origin_tech = "combat=2;materials=2;syndicate=3"
	initial_mag = /obj/item/ammo_box/magazine/chameleon

/obj/item/weapon/gun/projectile/chameleon/atom_init()
	. = ..()
	AddComponent(/datum/component/chameleon, /obj/item/weapon/gun, list(/obj/item/weapon/gun/projectile/chameleon))
