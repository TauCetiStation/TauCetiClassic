/obj/item/weapon/needle
	name = "needle"
	desc = "And it threads, threads, threads, and keeps threading on..."
	icon_state = "needle"
	force = 1
	throwforce = 2
	throw_speed = 6
	flags = CONDUCT
	w_class = ITEM_SIZE_TINY
	sharp = TRUE
	attack_verb = list("needled", "threaded")
	materials = list(MAT_METAL = 100)

/obj/item/weapon/needle/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/string))
		var/obj/item/stack/string/S = I
		var/obj/item/stack/stringed_needle/SN = new(user, S.amount)
		S.use(S.get_amount())
		user.put_in_hands(SN)
		qdel(src)
	else
		..()

/obj/item/stack/stringed_needle // We need these to be seperate for tailoring recipes to work properly.
	name = "needle with string"
	desc = "And it threads, threads, threads, and keeps threading on..."
	icon_state = "needle_string"
	force = 1
	throwforce = 2
	throw_speed = 6
	flags = CONDUCT
	w_class = ITEM_SIZE_TINY
	sharp = TRUE
	attack_verb = list("weaved", "threaded")
	materials = list(MAT_METAL = 100)

/obj/item/stack/stringed_needle/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/string))
		var/obj/item/stack/string/S = I
		add(S.get_amount())
		S.use(S.get_amount())
		user.visible_message("<span class='notice>Your [src] now contains [get_amount()] pieces of string.</span>")
	else
		..()

/obj/item/stack/stringed_needle/proc/seperate(mob/living/user)
	var/obj/item/weapon/needle/N = new(get_turf(src))
	var/obj/item/stack/string/S
	if(amount)
		S = new(get_turf(src), amount)
	qdel(src)
	if(user)
		user.put_in_hands(N)
		if(amount)
			user.put_in_hands(S)

/obj/item/stack/stringed_needle/zero_amount()
	if(amount < 1)
		seperate()
		return TRUE
	return FALSE

/obj/item/stack/stringed_needle/attack_self(mob/living/user)
	seperate(user)

/obj/item/weapon/knitting_needle
	name = "knitting needle"
	desc = "Used to roll, but if combined could even knit! Oh wonders."
	icon_state = "knitting_needle"
	force = 2
	throwforce = 3
	throw_speed = 6
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("knitted", "rolled")

/obj/item/weapon/knitting_needle/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/knitting_needle))
		var/obj/item/weapon/knitting_needles/KN = new(user)
		qdel(I)
		qdel(src)
		user.put_in_hands(KN)
	else
		..()

/obj/item/weapon/knitting_needles
	name = "knitting needles"
	desc = "Used to knit, but when seperated could even roll! Oh wonders."
	icon_state = "knitting_needles"
	force = 3
	throwforce = 4
	throw_speed = 5
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("knitted", "rolled")

/obj/item/weapon/knitting_needles/proc/seperate(mob/living/user)
	var/obj/item/weapon/knitting_needle/KN1 = new(user)
	var/obj/item/weapon/knitting_needle/KN2 = new(user)
	qdel(src)
	user.put_in_hands(KN1)
	user.put_in_hands(KN2)

/obj/item/weapon/knitting_needles/attack_self(mob/living/user)
	seperate(user)

/obj/item/stack/string
	singular_name = "piece of string"
	name = "string"
	desc = "We made stuff, no strings attached."
	icon_state = "string"
	max_amount = 100
	full_w_class = ITEM_SIZE_SMALL

/obj/item/stack/string/update_icon()
	if(amount <= (max_amount * (1 / 3)))
		icon_state = "string1"
	else if (amount <= (max_amount * (2 / 3)))
		icon_state = "string2"
	else
		icon_state = "string3"
