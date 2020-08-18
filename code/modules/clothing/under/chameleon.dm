//*****************
//**Cham Jumpsuit**
//*****************

/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	desc = "It's a plain jumpsuit. It seems to have a small dial on the wrist."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

/obj/item/clothing/under/chameleon/atom_init()
	. = ..()
	var/blocked = list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/golem, /obj/item/clothing/under/gimmick)//Prevent infinite loops and bad jumpsuits.
	for(var/U in typesof(/obj/item/clothing/under)-blocked)
		var/obj/item/clothing/under/V = new U
		clothing_choices[V.name] = U

/obj/item/clothing/under/chameleon/emp_act(severity)
	name = "psychedelic"
	desc = "Groovy!"
	icon_state = "psyche"
	item_state = "psyche"
	item_color = "psyche"
	update_icon()
	update_inv_mob()

/obj/item/clothing/under/chameleon/verb/change()
	set name = "Change Jumpsuit Appearance"
	set category = "Object"
	set src in usr

	var/picked = input("Select jumpsuit to change it to", "Chameleon Jumpsuit")as null|anything in clothing_choices
	if(!picked || !clothing_choices[picked])
		return
	var/newtype = clothing_choices[picked]
	var/obj/item/clothing/A = new newtype

	desc = null
	permeability_coefficient = 0.90


	if(A.icon_custom)  //Фикс для нашей одежды
		icon = A.icon_custom
		icon_custom = A.icon_custom
	else
		icon = A.icon
		icon_custom = null
	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	item_color = A.item_color
	body_parts_covered = A.body_parts_covered
	update_inv_mob()

//*****************
//**Chameleon Hat**
//*****************

/obj/item/clothing/head/chameleon
	name = "grey cap"
	icon_state = "greysoft"
	item_state = "greysoft"
	item_color = "grey"
	desc = "It looks like a plain hat, but upon closer inspection, there's an advanced holographic array installed inside. It seems to have a small dial inside."
	origin_tech = "syndicate=3"
	body_parts_covered = 0
	var/list/clothing_choices = list()

/obj/item/clothing/head/chameleon/atom_init()
	. = ..()
	var/blocked = list(/obj/item/clothing/head/chameleon,
		/obj/item/clothing/head/helmet/space/golem, 
		/obj/item/clothing/head/justice, 
		/obj/item/clothing/head/collectable/tophat/badmin_magic_hat, )//Prevent infinite loops and bad hats.
	for(var/U in typesof(/obj/item/clothing/head)-blocked)
		var/obj/item/clothing/head/V = new U
		clothing_choices[V.name] = U

/obj/item/clothing/head/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	item_state = "greysoft"
	item_color = "grey"
	update_icon()
	update_inv_mob()

/obj/item/clothing/head/chameleon/verb/change()
	set name = "Change Hat/Helmet Appearance"
	set category = "Object"
	set src in usr

	var/picked = input("Select headwear to change it to", "Chameleon Hat")as null|anything in clothing_choices
	if(!picked || !clothing_choices[picked])
		return
	var/newtype = clothing_choices[picked]
	var/obj/item/clothing/A = new newtype

	desc = null
	permeability_coefficient = 0.90

	if(A.icon_custom)
		icon = A.icon_custom
		icon_custom = A.icon_custom
	else
		icon = A.icon
		icon_custom = null
	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	item_color = A.item_color
	flags_inv = A.flags_inv
	body_parts_covered = A.body_parts_covered
	update_inv_mob()

//******************
//**Chameleon Suit**
//******************

/obj/item/clothing/suit/chameleon
	name = "armor"
	icon_state = "armor"
	item_state = "armor"
	desc = "It appears to be a vest of standard armor, except this is embedded with a hidden holographic cloaker, allowing it to change it's appearance, but offering no protection.. It seems to have a small dial inside."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

/obj/item/clothing/suit/chameleon/atom_init()
	. = ..()
	var/blocked = list(/obj/item/clothing/suit/chameleon, /obj/item/clothing/suit/space/space_ninja,
		/obj/item/clothing/suit/space/golem, /obj/item/clothing/suit/cyborg_suit, /obj/item/clothing/suit/justice,
		/obj/item/clothing/suit/greatcoat)//Prevent infinite loops and bad suits.
	for(var/U in typesof(/obj/item/clothing/suit)-blocked)
		var/obj/item/clothing/suit/V = new U
		clothing_choices[V.name] = U

/obj/item/clothing/suit/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	item_state = "armor"
	item_color = "armor"
	update_icon()
	update_inv_mob()

/obj/item/clothing/suit/chameleon/verb/change()
	set name = "Change Exosuit Appearance"
	set category = "Object"
	set src in usr

	var/picked = input("Select exosuit to change it to", "Chameleon Exosuit")as null|anything in clothing_choices
	if(!picked || !clothing_choices[picked])
		return
	var/newtype = clothing_choices[picked]
	var/obj/item/clothing/A = new newtype

	desc = null
	permeability_coefficient = 0.90

	if(A.icon_custom)
		icon = A.icon_custom
		icon_custom = A.icon_custom
	else
		icon = A.icon
		icon_custom = null
	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	item_color = A.item_color
	flags_inv = A.flags_inv
	body_parts_covered = A.body_parts_covered
	update_inv_mob()

//*******************
//**Chameleon Shoes**
//*******************
/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "black"
	item_state = "bl_shoes"
	item_color = "black"
	desc = "They're comfy black shoes, with clever cloaking technology built in. It seems to have a small dial on the back of each shoe."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

/obj/item/clothing/shoes/chameleon/atom_init()
	. = ..()
	var/blocked = list(/obj/item/clothing/shoes/chameleon,
		/obj/item/clothing/shoes/golem, /obj/item/clothing/shoes/syndigaloshes, /obj/item/clothing/shoes/cyborg)//prevent infinite loops and bad shoes.
	for(var/U in typesof(/obj/item/clothing/shoes)-blocked)
		var/obj/item/clothing/shoes/V = new U
		clothing_choices[V.name] = U

/obj/item/clothing/shoes/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "black shoes"
	desc = "A pair of black shoes."
	icon_state = "black"
	item_state = "bl_shoes"
	item_color = "black"
	update_icon()
	update_inv_mob()

/obj/item/clothing/shoes/chameleon/verb/change()
	set name = "Change Footwear Appearance"
	set category = "Object"
	set src in usr

	var/picked = input("Select shoes to change it to", "Chameleon Shoes")as null|anything in clothing_choices
	if(!picked || !clothing_choices[picked])
		return
	var/newtype = clothing_choices[picked]
	var/obj/item/clothing/A = new newtype

	desc = null
	permeability_coefficient = 0.90

	if(A.icon_custom)
		icon = A.icon_custom
		icon_custom = A.icon_custom
	else
		icon = A.icon
		icon_custom = null
	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	item_color = A.item_color
	update_inv_mob()

//**********************
//**Chameleon Backpack**
//**********************
/obj/item/weapon/storage/backpack/chameleon
	name = "backpack"
	icon_state = "backpack"
	item_state = "backpack"
	desc = "A backpack outfitted with cloaking tech. It seems to have a small dial inside, kept away from the storage."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

/obj/item/weapon/storage/backpack/chameleon/atom_init()
	. = ..()
	var/blocked = list(/obj/item/weapon/storage/backpack/chameleon, /obj/item/weapon/storage/backpack/satchel/withwallet)
	for(var/U in typesof(/obj/item/weapon/storage/backpack)-blocked)//Prevent infinite loops and bad backpacks.
		var/obj/item/weapon/storage/backpack/V = new U
		clothing_choices[V.name] = U

/obj/item/weapon/storage/backpack/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	item_state = "backpack"
	update_icon()
	update_inv_mob()

/obj/item/weapon/storage/backpack/chameleon/verb/change()
	set name = "Change Backpack Appearance"
	set category = "Object"
	set src in usr

	var/picked = input("Select backpack to change it to", "Chameleon Backpack")as null|anything in clothing_choices
	if(!picked || !clothing_choices[picked])
		return
	var/newtype = clothing_choices[picked]
	var/obj/item/weapon/storage/backpack/A = new newtype

	desc = null
	permeability_coefficient = 0.90

	if(A.icon_custom)
		icon = A.icon_custom
		icon_custom = A.icon_custom
	else
		icon = A.icon
		icon_custom = null
	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	item_color = A.item_color
	update_inv_mob()

//********************
//**Chameleon Gloves**
//********************

/obj/item/clothing/gloves/chameleon
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	item_color = "brown"
	desc = "It looks like a pair of gloves, but it seems to have a small dial inside."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

/obj/item/clothing/gloves/chameleon/atom_init()
	. = ..()
	var/blocked = list(/obj/item/clothing/gloves/chameleon)//Prevent infinite loops and bad hats.
	for(var/U in typesof(/obj/item/clothing/gloves)-blocked)
		var/obj/item/clothing/gloves/V = new U
		clothing_choices[V.name] = U

/obj/item/clothing/gloves/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "black gloves"
	desc = "It looks like a pair of gloves, but it seems to have a small dial inside."
	icon_state = "black"
	item_state = "bgloves"
	item_color = "brown"
	update_icon()
	update_inv_mob()

/obj/item/clothing/gloves/chameleon/verb/change()
	set name = "Change Gloves Appearance"
	set category = "Object"
	set src in usr

	var/picked = input("Select gloves to change it to", "Chameleon Gloves")as null|anything in clothing_choices
	if(!picked || !clothing_choices[picked])
		return
	var/newtype = clothing_choices[picked]
	var/obj/item/clothing/A = new newtype

	desc = null
	permeability_coefficient = 0.90

	if(A.icon_custom)
		icon = A.icon_custom
		icon_custom = A.icon_custom
	else
		icon = A.icon
		icon_custom = null
	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	item_color = A.item_color
	flags_inv = A.flags_inv
	update_inv_mob()

//******************
//**Chameleon Mask**
//******************

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	icon_state = "gas_mask_tc"
	item_state = "gas_mask_tc"
	desc = "It looks like a plain gask mask, but on closer inspection, it seems to have a small dial inside."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

/obj/item/clothing/mask/chameleon/atom_init()
	. = ..()
	var/blocked = list(/obj/item/clothing/mask/chameleon)//Prevent infinite loops and bad hats.
	for(var/U in typesof(/obj/item/clothing/mask)-blocked)
		var/obj/item/clothing/mask/V = new U
		if(V)
			clothing_choices[V.name] = U

/obj/item/clothing/mask/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "gas mask"
	desc = "It's a gas mask."
	item_state = "gas_mask_tc"
	icon_state = "gas_mask_tc"
	update_icon()
	update_inv_mob()

/obj/item/clothing/mask/chameleon/verb/change()
	set name = "Change Mask Appearance"
	set category = "Object"
	set src in usr

	var/picked = input("Select mask to change it to", "Chameleon Mask")as null|anything in clothing_choices
	if(!picked || !clothing_choices[picked])
		return
	var/newtype = clothing_choices[picked]
	var/obj/item/clothing/A = new newtype

	desc = null
	permeability_coefficient = 0.90

	if(A.icon_custom)
		icon = A.icon_custom
		icon_custom = A.icon_custom
	else
		icon = A.icon
		icon_custom = null
	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	flags_inv = A.flags_inv
	body_parts_covered = A.body_parts_covered
	update_inv_mob()

//*********************
//**Chameleon Glasses**
//*********************

/obj/item/clothing/glasses/chameleon
	name = "optical meson scanner"
	icon_state = "meson"
	item_state = "glasses"
	desc = "It looks like a plain set of mesons, but on closer inspection, it seems to have a small dial inside."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()

/obj/item/clothing/glasses/chameleon/atom_init()
	. = ..()
	var/blocked = list(/obj/item/clothing/glasses/chameleon)//Prevent infinite loops and bad hats.
	for(var/U in typesof(/obj/item/clothing/glasses)-blocked)
		var/obj/item/clothing/glasses/V = new U
		clothing_choices[V.name] = U

/obj/item/clothing/glasses/chameleon/emp_act(severity) //Because we don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	name = "optical meson scanner"
	desc = "It's a set of mesons."
	icon_state = "meson"
	item_state = "glasses"
	update_icon()
	update_inv_mob()

/obj/item/clothing/glasses/chameleon/verb/change()
	set name = "Change Glasses Appearance"
	set category = "Object"
	set src in usr

	var/picked = input("Select glasses to change it to", "Chameleon Glasses")as null|anything in clothing_choices
	if(!picked || !clothing_choices[picked])
		return
	var/newtype = clothing_choices[picked]
	var/obj/item/clothing/A = new newtype

	desc = null
	permeability_coefficient = 0.90

	if(A.icon_custom)
		icon = A.icon_custom
		icon_custom = A.icon_custom
	else
		icon = A.icon
		icon_custom = null
	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	flags_inv = A.flags_inv
	update_inv_mob()

//*****************
//**Chameleon Gun**
//*****************
/obj/item/weapon/gun/projectile/chameleon
	name = "desert eagle"
	desc = "A fake Desert Eagle with a dial on the side to change the gun's disguise."
	icon_state = "deagle"
	item_state = "deagle"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "combat=2;materials=2;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/chameleon
	var/list/gun_choices = list()

/obj/item/weapon/gun/projectile/chameleon/atom_init()
	. = ..()
	var/blocked = list(/obj/item/weapon/gun/projectile/chameleon)
	for(var/U in typesof(/obj/item/weapon/gun)-blocked)
		var/obj/item/weapon/gun/V = new U
		gun_choices[V.name] = U

/obj/item/weapon/gun/projectile/chameleon/emp_act(severity)
	name = "desert eagle"
	desc = "It's a desert eagle."
	icon_state = "deagle"
	item_state = "deagle"
	update_icon()
	update_inv_mob()

/obj/item/weapon/gun/projectile/chameleon/verb/change()
	set name = "Change Gun Appearance"
	set category = "Object"
	set src in usr

	var/picked = input("Select gun to change it to", "Chameleon Gun")as null|anything in gun_choices
	if(!picked || !gun_choices[picked])
		return
	var/newtype = gun_choices[picked]
	var/obj/item/weapon/gun/A = new newtype

	desc = null
	permeability_coefficient = 0.90

	if(A.icon_custom)
		icon = A.icon_custom
		icon_custom = A.icon_custom
	else
		icon = A.icon
		icon_custom = null
	desc = A.desc
	name = A.name
	icon_state = A.icon_state
	item_state = A.item_state
	flags_inv = A.flags_inv
	update_inv_mob()
