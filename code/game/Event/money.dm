/obj/item/stack/money
	var/denomination = 0

/obj/item/stack/money/gold
	name = "Золотой Эрафубль"
	desc = "Золотишко"
	singular_name = "Золотых Эрафублей"
	icon = 'icons/obj/Events/gold-coin.dmi'
	icon_state = "coin"
	w_class = SIZE_TINY
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	max_amount = 20
	denomination = 100
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/stack/money/New()
	..()
	update_icon()

/obj/item/stack/money/update_icon()
	if(!amount)//There's no more money here, so delete the handful.
		qdel(src)
		return
	icon_state = "[initial(icon_state)][amount]"//If there is money then we take our initial icon_state and add the ammount of money in the stack to it.



/obj/item/stack/money/use()
	. = ..()
	update_icon()

/obj/item/stack/money/add()
	. = ..()
	update_icon()

/obj/item/stack/money/silver
	name = "Серебряный Эрафубль"
	desc = "Из серебра"
	singular_name = "Серебрянных Эрафублей"
	icon = 'icons/obj/Events/silver-coin.dmi'
	icon_state = "coin"
	w_class = SIZE_TINY
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	max_amount = 20
	denomination = 10
	attack_verb = list("hit", "bludgeoned", "whacked")


/obj/item/stack/money/bronz
	name = "Бронзовый Эрафубль"
	desc = "Отлито из говна"
	singular_name = "Бронзовых Эрафублей"
	icon = 'icons/obj/Events/bronz-coin.dmi'
	icon_state = "coin"
	w_class = SIZE_TINY
	force = 1.0
	throwforce = 1.0
	throw_speed = 5
	throw_range = 20
	max_amount = 20
	denomination = 1
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/money
	name = "0 Эрафублей"
	desc = "Золотая монетка."
	gender = PLURAL
	icon = 'icons/obj/Events/gold-coin.dmi'
	icon_state = "coin"
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 2
	w_class = SIZE_TINY
	var/worth = 0
	var/global/denominations = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20)

/obj/item/money/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/money))
		var/obj/item/money/cash = W
		user.drop_from_inventory(cash)
		qdel(cash)
		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/h_user = user
			h_user.drop_from_inventory(src)
		to_chat(user, "<span class='notice'>[src.worth] монет было добавлено.<br></span>")
		qdel(src)


/obj/item/money/proc/getMoneyImages()
	if(icon_state)
		return list(icon_state)

/obj/item/stack/money/gold/fake
	name = "Золотой Эрафубль?"

/obj/item/stack/money/gold/fake/atom_init()
	..()
	denomination = rand(-100 , 100)

/obj/item/stack/money/silver/fake
	name = "Серебряный Эрафубль?"

/obj/item/stack/money/silver/fake/atom_init()
	..()
	denomination = rand(-10 , 10)