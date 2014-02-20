/obj/item/weapon/twohanded/spear
		icon = 'tauceti/items/makeshift_items_TG/makeshift_tg.dmi'
		tc_custom = 'tauceti/items/makeshift_items_TG/makeshift_tg.dmi'
		icon_state = "spearglass0"
		name = "spear"
		desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
		force = 10
		w_class = 4.0
		slot_flags = SLOT_BACK
		force_unwielded = 10
		force_wielded = 18 // Was 13, Buffed - RR
		throwforce = 15
		flags = NOSHIELD
		hitsound = 'sound/weapons/bladeslice.ogg'
		attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")

/obj/item/clothing/head/helmet/battlebucket
	icon = 'tauceti/items/makeshift_items_TG/makeshift_tg.dmi'
	tc_custom = 'tauceti/items/makeshift_items_TG/makeshift_tg.dmi'
	name = "Battle Bucket"
	desc = "This one protects your head and makes your enemies tremble."
	icon_state = "battle_bucket"
	item_state = "bucket"
	armor = list(melee = 20, bullet = 5, laser = 5,energy = 3, bomb = 5, bio = 0, rad = 0)

/obj/item/weapon/handcuffs/cable/attackby(var/obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		var/obj/item/weapon/wirerod/W = new /obj/item/weapon/wirerod
		R.use(1)

		user.before_take_item(src)

		user.put_in_hands(W)
		user << "<span class='notice'>You wrap the cable restraint around the top of the rod.</span>"

		del(src)


/obj/item/weapon/unfinished_prod
		icon = 'tauceti/items/makeshift_items_TG/makeshift_tg.dmi'
		tc_custom = 'tauceti/items/makeshift_items_TG/makeshift_tg.dmi'
		name = "unfinished prod"
		desc = "A rod with wirecutters on top."
		icon_state = "stunprod_nocell"
		item_state = "prod"

/obj/item/weapon/unfinished_prod/attackby(var/obj/item/I, mob/user as mob)
	if(istype(I,/obj/item/weapon/cell))
		var/obj/item/weapon/cell/C = I
		var/Charges = round(C.charge/2500 + 0.49)

		var/obj/item/weapon/melee/baton/cattleprod/P = new /obj/item/weapon/melee/baton/cattleprod
		P.charges = Charges

		user.before_take_item(I)
		user.before_take_item(src)

		user.put_in_hands(P)
		user << "<span class='notice'>You fasten the battery to rod and connect it to the wires.</span>"
		del(I)
		del(src)

/obj/item/weapon/melee/baton/cattleprod
		icon = 'tauceti/items/makeshift_items_TG/makeshift_tg.dmi'
		tc_custom = 'tauceti/items/makeshift_items_TG/makeshift_tg.dmi'
		name = "stunprod"
		desc = "An improvised stun baton."
		icon_state = "stunprod"
		item_state = "prod"
		charges = 0

/obj/item/weapon/melee/baton/cattleprod/update_icon()
	if(status)
		icon_state = "stunprod_active"
	else
		icon_state = "stunprod"

/obj/item/weapon/wirerod
		icon = 'tauceti/items/makeshift_items_TG/makeshift_tg.dmi'
		tc_custom = 'tauceti/items/makeshift_items_TG/makeshift_tg.dmi'
		icon_state = "wirerod"
		name = "wired rod"
		desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
		item_state = "rods"
		flags = CONDUCT
		force = 9
		throwforce = 10
		w_class = 3
		m_amt = 1875
		attack_verb = list("hit", "bludgeoned", "whacked", "bonked")


/obj/item/weapon/wirerod/attackby(var/obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/weapon/shard))
		var/obj/item/weapon/twohanded/spear/S = new /obj/item/weapon/twohanded/spear

		user.before_take_item(I)
		user.before_take_item(src)

		user.put_in_hands(S)
		user << "<span class='notice'>You fasten the glass shard to the top of the rod with the cable.</span>"
		del(I)
		del(src)

	else if(istype(I, /obj/item/weapon/wirecutters))

		var/obj/item/weapon/unfinished_prod/P = new /obj/item/weapon/unfinished_prod

		user.before_take_item(I)
		user.before_take_item(src)

		user.put_in_hands(P)
		user << "<span class='notice'>You fasten the wirecutters to the top of the rod with the cable, prongs outward.</span>"
		del(I)
		del(src)