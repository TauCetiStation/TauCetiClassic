/datum/action/item_action/chameleon/change
	name = "Chameleon Change"
	var/chameleon_type = null
	var/chameleon_name = "Item"
	var/obj/item/broken = null //We don't have psych for all slots right now but still want a downside to EMP.  In this case your cover's blown.
	var/list/blacklist = list() //Prevent infinite loops and bad items.
	var/list/options_list = list()
	var/list/options_menu = list()


/datum/action/item_action/chameleon/change/Trigger()
	return select_option(owner)


/datum/action/item_action/chameleon/change/proc/initialize_disguises()
	var/static/list/standart_options_list
	var/static/list/standart_options_menu
	if(!standart_options_list || !standart_options_menu)
		standart_options_menu = list()
		standart_options_list = list()
	if(!standart_options_list[chameleon_name] || !standart_options_menu[chameleon_name])
		var/list/local_list = list()
		var/list/local_menu = list()
		for(var/U in typesof(chameleon_type)-blacklist)
			var/obj/item/V = new U
			if (!V.icon_state || !V.icon || !V)
				continue
			local_list[V.name] = U
			local_menu[V.name] = image(icon=V.icon, icon_state=V.icon_state)
		local_list = sortList(local_list)
		local_menu = sortList(local_menu)
		standart_options_list[chameleon_name] = local_list
		standart_options_menu[chameleon_name] = local_menu
	options_list = standart_options_list[chameleon_name]
	options_menu = standart_options_menu[chameleon_name]

/datum/action/item_action/chameleon/change/proc/select_option()
	if (!owner)
		return
	
	var/list/initial_menu = list(
		"Select from menu" = image(icon=target.icon, icon_state=target.icon_state),
		"Select from list" = image(icon='icons/obj/paper.dmi', icon_state="paper_words")
	)
	var/mode = show_radial_menu(owner, target, initial_menu, require_near=TRUE, tooltips=TRUE)
	if(mode == "Select from list")
		select_list()
	else if(mode == "Select from menu")
		select_radial()

/datum/action/item_action/chameleon/change/proc/select_list()
	var/picked = input("Select [chameleon_name] to change it to", "Chameleon [chameleon_name]") as null|anything in options_list
	if(!picked || !options_list[picked])
		return
	update_look(picked)

/datum/action/item_action/chameleon/change/proc/select_radial()
	var/picked = show_radial_menu(owner, target, options_menu, require_near=TRUE, tooltips=TRUE)
	if(!picked || !options_list[picked])
		return
	update_look(picked)

/datum/action/item_action/chameleon/change/proc/update_look(picked)
	var/newtype = options_list[picked]
	var/obj/item/I = new newtype
	var/obj/item/T = target
	T.desc = null

	if(I.icon_custom)  //Фикс для нашей одежды
		T.icon = I.icon_custom
		T.icon_custom = I.icon_custom
	else
		T.icon = I.icon
		T.icon_custom = null
	T.desc = I.desc
	T.name = I.name
	T.icon_state = I.icon_state
	T.item_state = I.item_state
	T.item_color = I.item_color
	T.body_parts_covered = I.body_parts_covered
	T.update_inv_mob()

/datum/action/item_action/chameleon/change/proc/emp()
	if (broken)
		var/obj/item/I = new broken
		var/obj/item/T = target
		T.name = I.name
		T.desc = I.desc
		T.icon_state = I.icon_state
		T.item_state = I.item_state
		T.item_color = I.item_color
		T.update_icon()
		T.update_inv_mob()

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
	var/datum/action/item_action/chameleon/change/chameleon_action = null

/obj/item/clothing/under/chameleon/atom_init()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/under
	chameleon_action.chameleon_name = "Jumpsuit"
	chameleon_action.broken = /obj/item/clothing/under/psyche
	chameleon_action.blacklist = list(
			/obj/item/clothing/under/chameleon, 
			/obj/item/clothing/under/golem, 
			/obj/item/clothing/under/gimmick,
			/obj/item/clothing/under/shadowling
		)
	chameleon_action.initialize_disguises()

/obj/item/clothing/under/chameleon/equipped(mob/user, slot)
	. = ..()
	chameleon_action.Grant(user)

/obj/item/clothing/under/chameleon/dropped(mob/user)
	. = ..()
	chameleon_action.Remove(user)

/obj/item/clothing/under/chameleon/emp_act(severity)
	chameleon_action.emp()

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
	var/datum/action/item_action/chameleon/change/chameleon_action = null

/obj/item/clothing/head/chameleon/atom_init()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/head
	chameleon_action.chameleon_name = "Hat"
	
	chameleon_action.broken = /obj/item/clothing/head/soft/grey
	chameleon_action.blacklist = list(
			/obj/item/clothing/head/chameleon,
			/obj/item/clothing/head/helmet/space/golem, 
			/obj/item/clothing/head/justice, 
			/obj/item/clothing/head/collectable/tophat/badmin_magic_hat,
			/obj/item/clothing/head/shadowling,
			/obj/item/clothing/head/feathertrilby 
		)
	chameleon_action.initialize_disguises()


/obj/item/clothing/head/chameleon/equipped(mob/user, slot)
	. = ..()
	chameleon_action.Grant(user)

/obj/item/clothing/head/chameleon/dropped(mob/user)
	. = ..()
	chameleon_action.Remove(user)

/obj/item/clothing/head/chameleon/emp_act(severity)
	chameleon_action.emp()

//******************
//**Chameleon Suit**
//******************

/obj/item/clothing/suit/chameleon
	name = "armor"
	icon_state = "armor"
	item_state = "armor"
	desc = "It appears to be a vest of standard armor, except this is embedded with a hidden holographic cloaker, allowing it to change it's appearance, but offering no protection.. It seems to have a small dial inside."
	origin_tech = "syndicate=3"
	var/datum/action/item_action/chameleon/change/chameleon_action = null

/obj/item/clothing/suit/chameleon/atom_init()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/suit
	chameleon_action.chameleon_name = "Suit"
	chameleon_action.broken = /obj/item/clothing/suit/armor/vest
	chameleon_action.blacklist = list(
			/obj/item/clothing/suit/chameleon, 
			/obj/item/clothing/suit/space/space_ninja,
			/obj/item/clothing/suit/space/golem, 
			/obj/item/clothing/suit/cyborg_suit, 
			/obj/item/clothing/suit/justice,
			/obj/item/clothing/suit/greatcoat,
			/obj/item/clothing/suit/space/shadowling,
			/obj/item/clothing/suit/gnome
		)
	chameleon_action.initialize_disguises()

/obj/item/clothing/suit/chameleon/equipped(mob/user, slot)
	. = ..()
	chameleon_action.Grant(user)

/obj/item/clothing/suit/chameleon/dropped(mob/user)
	. = ..()
	chameleon_action.Remove(user)

/obj/item/clothing/suit/chameleon/emp_act(severity)
	chameleon_action.emp()


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
	var/datum/action/item_action/chameleon/change/chameleon_action = null

/obj/item/clothing/shoes/chameleon/atom_init()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/shoes
	chameleon_action.chameleon_name = "Shoes"
	chameleon_action.broken = /obj/item/clothing/shoes/black
	chameleon_action.blacklist = list(
		/obj/item/clothing/shoes/chameleon,
		/obj/item/clothing/shoes/golem,
		/obj/item/clothing/shoes/syndigaloshes,
		/obj/item/clothing/shoes/cyborg,
		/obj/item/clothing/shoes/shadowling
	)
	chameleon_action.initialize_disguises()

/obj/item/clothing/shoes/chameleon/equipped(mob/user, slot)
	. = ..()
	chameleon_action.Grant(user)

/obj/item/clothing/shoes/chameleon/dropped(mob/user)
	. = ..()
	chameleon_action.Remove(user)

/obj/item/clothing/shoes/chameleon/emp_act(severity)
	chameleon_action.emp()

//**********************
//**Chameleon Backpack**
//**********************
/obj/item/weapon/storage/backpack/chameleon
	name = "backpack"
	icon_state = "backpack"
	item_state = "backpack"
	desc = "A backpack outfitted with cloaking tech. It seems to have a small dial inside, kept away from the storage."
	origin_tech = "syndicate=3"
	action_button_name = null
	var/datum/action/item_action/chameleon/change/chameleon_action = null

/obj/item/weapon/storage/backpack/chameleon/atom_init()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/weapon/storage/backpack
	chameleon_action.chameleon_name = "Backpack"
	chameleon_action.broken = /obj/item/weapon/storage/backpack
	chameleon_action.blacklist = list(
		/obj/item/weapon/storage/backpack/chameleon, 
		/obj/item/weapon/storage/backpack/satchel/withwallet
	)
	chameleon_action.initialize_disguises()

/obj/item/weapon/storage/backpack/chameleon/equipped(mob/user, slot)
	. = ..()
	chameleon_action.Grant(user)

/obj/item/weapon/storage/backpack/chameleon/dropped(mob/user)
	. = ..()
	chameleon_action.Remove(user)

/obj/item/weapon/storage/backpack/chameleon/emp_act(severity)
	chameleon_action.emp()

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
	var/datum/action/item_action/chameleon/change/chameleon_action = null

/obj/item/clothing/gloves/chameleon/atom_init()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/gloves
	chameleon_action.chameleon_name = "Gloves"
	chameleon_action.broken = /obj/item/clothing/gloves/black
	chameleon_action.blacklist = list(
		/obj/item/clothing/gloves/chameleon,
		/obj/item/clothing/gloves/golem,
		/obj/item/clothing/gloves/shadowling
	)
	chameleon_action.initialize_disguises()

/obj/item/clothing/gloves/chameleon/equipped(mob/user, slot)
	. = ..()
	chameleon_action.Grant(user)

/obj/item/clothing/gloves/chameleon/dropped(mob/user)
	. = ..()
	chameleon_action.Remove(user)

/obj/item/clothing/gloves/chameleon/emp_act(severity)
	chameleon_action.emp()

//******************
//**Chameleon Mask**
//******************

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	icon_state = "gas_mask_tc"
	item_state = "gas_mask_tc"
	desc = "It looks like a plain gask mask, but on closer inspection, it seems to have a small dial inside."
	origin_tech = "syndicate=3"
	var/datum/action/item_action/chameleon/change/chameleon_action = null

/obj/item/clothing/mask/chameleon/atom_init()
	. = ..()

	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/mask
	chameleon_action.chameleon_name = "Mask"
	chameleon_action.broken = /obj/item/clothing/mask/gas
	chameleon_action.blacklist = list(
		/obj/item/clothing/mask/chameleon,
		/obj/item/clothing/mask/gas/shadowling,
		/obj/item/clothing/mask/mara_kilpatrick_1,
		/obj/item/clothing/mask/gas/death_commando,
		/obj/item/clothing/mask/gas/golem,
		/obj/item/clothing/mask/scarf/ninja
	)
	chameleon_action.initialize_disguises()

/obj/item/clothing/mask/chameleon/equipped(mob/user, slot)
	. = ..()
	chameleon_action.Grant(user)

/obj/item/clothing/mask/chameleon/dropped(mob/user)
	. = ..()
	chameleon_action.Remove(user)

/obj/item/clothing/mask/chameleon/emp_act(severity)
	chameleon_action.emp()

//*********************
//**Chameleon Glasses**
//*********************

/obj/item/clothing/glasses/chameleon
	name = "optical meson scanner"
	icon_state = "meson"
	item_state = "glasses"
	desc = "It looks like a plain set of mesons, but on closer inspection, it seems to have a small dial inside."
	origin_tech = "syndicate=3"
	var/datum/action/item_action/chameleon/change/chameleon_action = null

/obj/item/clothing/glasses/chameleon/atom_init()
	. = ..()
	
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "Glasses"
	chameleon_action.broken = /obj/item/clothing/glasses/meson
	chameleon_action.blacklist = list(
		/obj/item/clothing/glasses/chameleon,
		/obj/item/clothing/glasses/hud/mining/ancient
	)
	chameleon_action.initialize_disguises()

/obj/item/clothing/glasses/chameleon/equipped(mob/user, slot)
	. = ..()
	chameleon_action.Grant(user)

/obj/item/clothing/glasses/chameleon/dropped(mob/user)
	. = ..()
	chameleon_action.Remove(user)

/obj/item/clothing/glasses/chameleon/emp_act(severity)
	chameleon_action.emp()

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
	action_button_name = null
	var/datum/action/item_action/chameleon/change/chameleon_action = null

/obj/item/weapon/gun/projectile/chameleon/atom_init()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/weapon/gun
	chameleon_action.chameleon_name = "Gun"
	chameleon_action.broken = /obj/item/weapon/gun/projectile/automatic/deagle
	chameleon_action.blacklist = list(
		/obj/item/weapon/gun/projectile/chameleon
	)
	chameleon_action.initialize_disguises()

/obj/item/weapon/gun/projectile/chameleon/equipped(mob/user, slot)
	. = ..()
	chameleon_action.Grant(user)

/obj/item/weapon/gun/projectile/chameleon/dropped(mob/user)
	. = ..()
	chameleon_action.Remove(user)

/obj/item/weapon/gun/projectile/chameleon/emp_act(severity)
	chameleon_action.emp()
