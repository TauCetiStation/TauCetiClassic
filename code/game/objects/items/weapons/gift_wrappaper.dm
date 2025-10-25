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
	if(w_class < SIZE_NORMAL)
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

	if (!iscutter(W))
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
		/obj/item/weapon/reagent_containers/food/snacks/soap/deluxe,
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
		/obj/item/toy/dualsword,
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
		/obj/item/toy/foamblade,
		)

	if(!ispath(gift_type, /obj/item))
		return

	var/obj/item/I = new gift_type(M)
	M.remove_from_mob(src)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	qdel(src)
	return
