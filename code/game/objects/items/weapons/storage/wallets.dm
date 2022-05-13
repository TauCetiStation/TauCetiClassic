/obj/item/weapon/storage/wallet
	name = "wallet"
	desc = "It can hold a few small and personal things."
	max_storage_space = 10
	icon_state = "wallet"
	w_class = SIZE_TINY
	can_hold = list(
		/obj/item/weapon/spacecash,
		/obj/item/weapon/card,
		/obj/item/clothing/mask/cigarette,
		/obj/item/device/flashlight/pen,
		/obj/item/seeds,
		/obj/item/stack/medical,
		/obj/item/toy/crayon,
		/obj/item/weapon/coin,
		/obj/item/weapon/dice,
		/obj/item/weapon/disk,
		/obj/item/weapon/implanter,
		/obj/item/weapon/lighter,
		/obj/item/weapon/match,
		/obj/item/weapon/paper,
		/obj/item/weapon/pen,
		/obj/item/weapon/photo,
		/obj/item/weapon/reagent_containers/dropper,
		/obj/item/weapon/screwdriver,
		/obj/item/weapon/stamp)
	slot_flags = SLOT_FLAGS_ID

	var/obj/item/weapon/card/id/front_id = null
	var/list/cash_overlays = list()

	var/icon/Cut_cash = icon('icons/obj/economy.dmi', "spacecash500")


/obj/item/weapon/storage/wallet/remove_from_storage(obj/item/W, atom/new_location, NoUpdate = FALSE)
	. = ..(W, new_location)
	if(.)
		if(W == front_id)
			front_id = null
			name = initial(name)
			update_icon()

/obj/item/weapon/storage/wallet/handle_item_insertion(obj/item/W, prevent_warning = FALSE, NoUpdate = FALSE)
	. = ..(W, prevent_warning)
	if(.)
		if(!front_id && istype(W, /obj/item/weapon/card/id))
			front_id = W
			name = "[name] ([front_id])"
			update_icon()
			if(ishuman(loc))
				var/mob/living/carbon/human/H = loc
				if(H.wear_id == src)
					H.sec_hud_set_ID()

/obj/item/weapon/storage/wallet/update_icon()
	cut_overlay(cash_overlays)

	if(front_id)
		switch(front_id.icon_state)
			if("id")
				icon_state = "walletid"
			if("silver")
				icon_state = "walletid_silver"
			if("gold")
				icon_state = "walletid_gold"
			if("centcom")
				icon_state = "walletid_centcom"
	else
		icon_state = "wallet"

	var/list/bills = list()
	for(var/obj/item/weapon/spacecash/bill/B in contents)
		bills += B
	if(bills.len > 0)
		for(var/i in 1 to min(3, bills.len))
			var/obj/item/weapon/spacecash/bill/B = bills[i]
			var/image/I = image(icon=B.icon, icon_state="spacecash[B.worth]")
			I.color = COLOR_LUMINOSITY(1-(i%2)/2)
			I.add_filter(name="Cut Money", priority=1, params=alpha_mask_filter(x=0, y=7, icon=Cut_cash))
			I.pixel_y += 3+i
			I.appearance_flags = KEEP_TOGETHER
			cash_overlays += I
			add_overlay(I)


/obj/item/weapon/storage/wallet/GetID()
	return front_id

/obj/item/weapon/storage/wallet/GetAccess()
	var/obj/item/I = GetID()
	if(I)
		return I.GetAccess()
	else
		return ..()

/obj/item/weapon/storage/wallet/random/atom_init()
	. = ..()

	use_sound = SOUNDIN_VELCRO

	var/list/spawn_type1 = list(
		/obj/item/weapon/spacecash/bill/c10,
		/obj/item/weapon/spacecash/bill/c100,
		/obj/item/weapon/spacecash/bill/c20,
		/obj/item/weapon/spacecash/bill/c200,
		/obj/item/weapon/spacecash/bill/c50,
		/obj/item/weapon/spacecash/bill/c500
		)
	var/item1_type = pick(spawn_type1)

	var/item2_type
	if(prob(50))
		item2_type = pick(spawn_type1)

	var/list/spawn_type2 = list(
		/obj/item/weapon/coin/mercury,
		/obj/item/weapon/coin/copper,
		/obj/item/weapon/coin/plastic,
		/obj/item/weapon/coin/iron,
		/obj/item/weapon/coin/tin,
		/obj/item/weapon/coin/lead,
		/obj/item/weapon/coin/uranium,
		)
	var/item3_type = pick(spawn_type2)

	if(item1_type)
		new item1_type(src)
	if(item2_type)
		new item2_type(src)
	if(item3_type)
		new item3_type(src)
