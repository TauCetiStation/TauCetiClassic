/obj/item/weapon/spacecash
	name = "0 credit chip"
	desc = "It's worth 0 credits."
	gender = PLURAL
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash"
	opacity = 0
	density = FALSE
	anchored = FALSE
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 2
	w_class = SIZE_TINY
	var/access = list()
	access = access_crate_cash
	var/worth = 0

/obj/item/weapon/spacecash/atom_init()
	. = ..()
	price = worth

/obj/item/weapon/spacecash/bill/c1
	name = "1 credit chip"
	icon_state = "spacecash1"
	desc = "It's worth 1 credit."
	worth = 1

/obj/item/weapon/spacecash/bill/c5
	name = "5 credit chip"
	icon_state = "spacecash5"
	desc = "It's worth 5 credits."
	worth = 5

/obj/item/weapon/spacecash/bill/c10
	name = "10 credit chip"
	icon_state = "spacecash10"
	desc = "It's worth 10 credits."
	worth = 10

/obj/item/weapon/spacecash/bill/c20
	name = "20 credit chip"
	icon_state = "spacecash20"
	desc = "It's worth 20 credits."
	worth = 20

/obj/item/weapon/spacecash/bill/c50
	name = "50 credit chip"
	icon_state = "spacecash50"
	desc = "It's worth 50 credits."
	worth = 50

/obj/item/weapon/spacecash/bill/c100
	name = "100 credit chip"
	icon_state = "spacecash100"
	desc = "It's worth 100 credits."
	worth = 100

/obj/item/weapon/spacecash/bill/c200
	name = "200 credit chip"
	icon_state = "spacecash200"
	desc = "It's worth 200 credits."
	worth = 200

/obj/item/weapon/spacecash/bill/c500
	name = "500 credit chip"
	icon_state = "spacecash500"
	desc = "It's worth 500 credits."
	worth = 500

/obj/item/weapon/spacecash/bill/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/weapon/spacecash/bill) && !istype(src.loc, /obj/item/weapon/storage/bill_bundle))
		var/obj/item/weapon/spacecash/bill/B = I
		var/obj/item/weapon/storage/bill_bundle/Bundle = new/obj/item/weapon/storage/bill_bundle(user.loc)
		Bundle.handle_item_insertion(B)
		Bundle.handle_item_insertion(src)
		Bundle.pickup(user)
		user.put_in_hands(Bundle)
		to_chat(user, "<span class='notice'>You combine the [B.name] and the [src.name] into a bundle.</span>")

/obj/item/weapon/storage/bill_bundle
	name = "wad of cash"
	desc = "Here comes the money"
	max_storage_space = 20
	display_contents_with_number = TRUE
	use_to_pickup = TRUE
	collection_mode = 0
	icon = 'icons/obj/economy.dmi'
	icon_state = "rubberband"
	w_class = SIZE_SMALL
	can_hold = list(/obj/item/weapon/spacecash/bill)
	slot_flags = SLOT_FLAGS_BELT
	var/list/bundle_overlays = list()
	var/worth = 0

/obj/item/weapon/storage/bill_bundle/atom_init()
	. = ..()

	use_sound = list('sound/items/cash.ogg')

/obj/item/weapon/storage/bill_bundle/remove_from_storage(obj/item/W, atom/new_location, NoUpdate = FALSE)
	. = ..(W, new_location)
	if(.)
		update_icon()
		var/obj/item/weapon/storage/bill_bundle/B = W
		worth -= B.worth
		if(contents.len <= 1)
			for(var/obj/item/I in contents)
				remove_from_storage(I, src.loc)
				if(ismob(src.loc))
					var/mob/M = src.loc
					M.put_in_hands(I)
				qdel(src)

/obj/item/weapon/storage/bill_bundle/handle_item_insertion(obj/item/W, prevent_warning = FALSE, NoUpdate = FALSE)
	. = ..(W, prevent_warning)
	if(.)
		update_icon()
		var/obj/item/weapon/storage/bill_bundle/B = W
		worth += B.worth

/obj/item/weapon/storage/bill_bundle/update_icon()
	cut_overlay(bundle_overlays)
	for(var/i in 1 to contents.len)
		var/obj/item/weapon/spacecash/bill/B = contents[i]
		var/image/I = image(icon=B.icon, icon_state="[B.icon_state]")
		var/luminocity = 0
		if(contents.len % 2)
			luminocity = 1-(abs(i-1)%2)/2
		else
			luminocity = 1-(i%2)/2
		I.color = COLOR_LUMINOSITY(luminocity)
		I.pixel_x += rand(-1,1)
		I.pixel_y -= 1-i
		I.appearance_flags = KEEP_TOGETHER
		bundle_overlays += I
		add_overlay(I)
	var/band_type = "3x"
	switch(contents.len)
		if(1,2,3)
			band_type = "3x"
		if(4,5)
			band_type = "5x"
		if(6,7)
			band_type = "7x"
		if(8,9,10)
			band_type = "10x"
	var/image/Band = image(icon=icon, icon_state="[icon_state][band_type]")
	bundle_overlays += Band
	add_overlay(Band)

/obj/item/weapon/storage/bill_bundle/examine(mob/user)
	..()
	if(src in view(1, user))
		to_chat(user, "<span class='notice'>A bundle is [src.worth] credits worth.</span>")

/proc/spawn_money(sum, spawnloc)
	var/cash_type
	for(var/i in list(500,200,100,50,20,10,5, 1))
		if(sum >= i)
			cash_type = text2path("/obj/item/weapon/spacecash/bill/c[i]")
		else
			continue
		while(sum >= i)
			sum -= i
			new cash_type(spawnloc)
	return

/obj/item/weapon/spacecash/ewallet
	name = "Charge card"
	icon_state = "efundcard"
	desc = "A card that holds an amount of money."
	var/owner_name = "" //So the ATM can set it so the EFTPOS can put a valid name on transactions.

/obj/item/weapon/spacecash/ewallet/examine(mob/user)
	..()
	if(src in view(1, user))
		to_chat(user, "<span class='notice'>Charge card's owner: [src.owner_name]. Credits remaining: [src.worth].</span>")
