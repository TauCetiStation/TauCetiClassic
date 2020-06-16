/* Gifts and wrapping paper
 * Contains:
 *		Gifts
 *		Wrapping Paper
 */

/*
 * Gifts
 */
/obj/item/weapon/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/items.dmi'
	icon_state = "gift1"
	item_state = "gift1"

/obj/item/weapon/a_gift/atom_init()
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	if(w_class < ITEM_SIZE_LARGE)
		icon_state = "gift[w_class]"
	else
		icon_state = "gift[pick(1, 2, 3)]"

/obj/item/weapon/gift/attack_self(mob/user)
	user.drop_from_inventory(src)
	var/atom/movable/AM = locate() in contents
	if(AM) //sometimes items can disappear. For example, bombs. --rastaf0
		user.put_in_active_hand(AM)
		AM.add_fingerprint(user)
	else
		to_chat(user, "<span class='warning'>The gift was empty!</span>")
	playsound(src, 'sound/items/poster_ripped.ogg', VOL_EFFECTS_MASTER)
	if(sender)
		to_chat(user, "<span class='notice'>Looks like it was from [sender]!</span>")
	qdel(src)
	return

/obj/item/weapon/a_gift/ex_act()
	qdel(src)
	return

/obj/effect/spresent/relaymove(mob/user)
	if (user.incapacitated())
		return
	to_chat(user, "<span class='notice'>You cant move.</span>")

/obj/effect/spresent/attackby(obj/item/weapon/W, mob/user)
	..()

	if (!iswirecutter(W))
		to_chat(user, "<span class='notice'>I need wirecutters for that.</span>")
		return

	to_chat(user, "<span class='notice'>You cut open the present.</span>")

	for(var/mob/M in src) //Should only be one but whatever.
		M.loc = src.loc
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

	qdel(src)

/obj/item/weapon/a_gift/attack_self(mob/M)
	var/gift_type = pick(
		/obj/item/weapon/storage/wallet,
		/obj/item/weapon/storage/photo_album,
		/obj/item/weapon/storage/box/snappops,
		/obj/item/weapon/storage/fancy/crayons,
		/obj/item/weapon/storage/backpack/holding,
		/obj/item/weapon/storage/belt/champion,
		/obj/item/weapon/soap/deluxe,
		/obj/item/weapon/pickaxe/silver,
		/obj/item/weapon/pen/invisible,
		/obj/item/weapon/lipstick/random,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/corncob,
		/obj/item/weapon/poster/contraband,
		/obj/item/weapon/poster/legit,
		/obj/item/weapon/book/manual/wiki/barman_recipes,
		/obj/item/weapon/book/manual/wiki/chefs_recipes,
		/obj/item/weapon/bikehorn,
		/obj/item/weapon/beach_ball,
		/obj/item/weapon/beach_ball/holoball,
		/obj/item/weapon/banhammer,
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/toy/crossbow,
		/obj/item/toy/gun,
		/obj/item/toy/katana,
		/obj/item/toy/prize/deathripley,
		/obj/item/toy/prize/durand,
		/obj/item/toy/prize/fireripley,
		/obj/item/toy/prize/gygax,
		/obj/item/toy/prize/honk,
		/obj/item/toy/prize/marauder,
		/obj/item/toy/prize/mauler,
		/obj/item/toy/prize/odysseus,
		/obj/item/toy/prize/phazon,
		/obj/item/toy/prize/ripley,
		/obj/item/toy/prize/seraph,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/device/paicard,
		/obj/item/device/violin,
		/obj/item/weapon/storage/belt/utility/full,
		/obj/item/clothing/accessory/tie/horrible,
		/obj/item/clothing/suit/jacket/leather,
		/obj/item/clothing/suit/jacket/leather/overcoat,
		/obj/item/toy/carpplushie,
		/obj/random/plushie,
		/obj/item/toy/eight_ball,
		/obj/item/toy/eight_ball/conch,
		)

	if(!ispath(gift_type, /obj/item))
		return

	var/obj/item/I = new gift_type(M)
	M.remove_from_mob(src)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	qdel(src)
	return

/*
 * Wrapping Paper
 */
/obj/item/weapon/wrapping_paper
	name = "wrapping paper"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/items.dmi'
	icon_state = "wrap_paper"
	var/amount = 20.0

/obj/item/weapon/wrapping_paper/attackby(obj/item/I, mob/user, params)
	if(!locate(/obj/structure/table, loc))
		to_chat(user, "<span class='notice'>You MUST put the paper on a table!</span>")
		return

	if(I.w_class < ITEM_SIZE_LARGE)
		if(iswirecutter(user.l_hand) || iswirecutter(user.r_hand) || istype(user.l_hand, /obj/item/weapon/scissors) || istype(user.r_hand, /obj/item/weapon/scissors))
			var/a_used = 2 ** (src.w_class - 1)
			if (src.amount < a_used)
				to_chat(user, "<span class='notice'>You need more paper!</span>")
				return
			else
				if(istype(I, /obj/item/smallDelivery) || istype(I, /obj/item/weapon/gift)) //No gift wrapping gifts!
					return

				src.amount -= a_used
				user.drop_item()
				var/obj/item/weapon/gift/G = new /obj/item/weapon/gift( src.loc )
				G.size = I.w_class
				G.w_class = G.size + 1
				G.icon_state = text("gift[]", G.size)
				I.forceMove(G)
				G.add_fingerprint(user)
				I.add_fingerprint(user)
				src.add_fingerprint(user)
				#ifdef NEWYEARCONTENT
				to_chat(user, "<span class='notice'>You feel like you could put that under a christmas tree.</span>")
				#endif
			if (src.amount <= 0)
				new /obj/item/weapon/c_tube( src.loc )
				qdel(src)
				return
		else
			to_chat(user, "<span class='notice'>You need scissors!</span>")
	else
		to_chat(user, "<span class='notice'>The object is FAR too large!</span>")


/obj/item/weapon/wrapping_paper/examine(mob/user)
	..()
	if(src in view(1, user))
		to_chat(user, "<span class='notice'>There is about [amount] square units of paper left!</span>")

/obj/item/weapon/wrapping_paper/attack(mob/target, mob/user)
	if (!istype(target, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/H = target

	if (H.incapacitated())
		if (src.amount > 2)
			var/obj/effect/spresent/present = new /obj/effect/spresent (H.loc)
			src.amount -= 2

			if (H.client)
				H.client.perspective = EYE_PERSPECTIVE
				H.client.eye = present

			H.loc = present

			H.log_combat(user, "wrapped with [name]")

		else
			to_chat(user, "<span class='notice'>You need more paper.</span>")
	else
		to_chat(user, "They are moving around too much. A straightjacket would help.")
