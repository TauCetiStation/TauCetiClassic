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
	var/is_burning = FALSE
	var/can_burn = TRUE
	var/burning_timer

/obj/item/weapon/spacecash/atom_init()
	. = ..()
	price = worth

/obj/item/weapon/spacecash/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/P = I
		if(P.lit && can_burn && !is_burning)
			is_burning = TRUE
			var/span = worth >= 50 ? "warning" : "notice"
			user.visible_message("<span class='[span]'>[user] holds \the [P] up to \the [src] it looks like \he's trying to burn it.</span>", \
								"<span class='notice'>You hold \the [P] up to \the [src], burning it slowly.</span>")
			START_PROCESSING(SSobj, src)
			burning_timer = QDEL_IN(src, 10 SECONDS)
			var/image/fire = image(icon, icon_state = "on_fire_cash")
			add_overlay(fire)
			return
	return ..()

/obj/item/weapon/spacecash/process()
	var/turf/location = get_turf(src)
	if(location)
		location.hotspot_expose(700, 5, src)

/obj/item/weapon/spacecash/extinguish()
	cut_overlays()
	is_burning = FALSE
	STOP_PROCESSING(SSobj, src)
	deltimer(burning_timer)
	burning_timer = null

/obj/item/weapon/spacecash/Destroy()
	if(is_burning)
		new /obj/effect/decal/cleanable/ash(get_turf(src))
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/spacecash/c1
	name = "1 credit chip"
	icon_state = "spacecash"
	desc = "It's worth 1 credit."
	worth = 1

/obj/item/weapon/spacecash/c10
	name = "10 credit chip"
	icon_state = "spacecash10"
	desc = "It's worth 10 credits."
	worth = 10

/obj/item/weapon/spacecash/c20
	name = "20 credit chip"
	icon_state = "spacecash20"
	desc = "It's worth 20 credits."
	worth = 20

/obj/item/weapon/spacecash/c50
	name = "50 credit chip"
	icon_state = "spacecash50"
	desc = "It's worth 50 credits."
	worth = 50

/obj/item/weapon/spacecash/c100
	name = "100 credit chip"
	icon_state = "spacecash100"
	desc = "It's worth 100 credits."
	worth = 100

/obj/item/weapon/spacecash/c200
	name = "200 credit chip"
	icon_state = "spacecash200"
	desc = "It's worth 200 credits."
	worth = 200

/obj/item/weapon/spacecash/c500
	name = "500 credit chip"
	icon_state = "spacecash500"
	desc = "It's worth 500 credits."
	worth = 500

/obj/item/weapon/spacecash/c1000
	name = "1000 credit chip"
	icon_state = "spacecash1000"
	desc = "It's worth 1000 credits."
	worth = 1000

/proc/spawn_money(sum, spawnloc)
	var/cash_type
	for(var/i in list(1000,500,200,100,50,20,10,1))
		cash_type = text2path("/obj/item/weapon/spacecash/c[i]")
		while(sum >= i)
			sum -= i
			new cash_type(spawnloc)
	return

/obj/item/weapon/ewallet
	name = "charge card"
	icon_state = "efundcard"
	desc = "A card that links to an account and all it's assets."

	icon = 'icons/obj/economy.dmi'
	icon_state = "efundcard"
	opacity = 0
	density = FALSE
	anchored = FALSE
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 2
	w_class = SIZE_TINY

	//So the ATM can set it so the EFTPOS can put a valid name on transactions.
	var/issuer_name = ""
	var/issuer_account_number

	var/account_number

/obj/item/weapon/ewallet/atom_init()
	. = ..()
	name = "charge card ([rand(0, 999)])"
	var/datum/money_account/M = create_account(name, 0, null, 0)
	account_number = M.account_number

/obj/item/weapon/ewallet/Destroy()
	qdel(get_account(account_number))
	return ..()

/obj/item/weapon/ewallet/examine(mob/user)
	..()
	if(!(src in view(1, user)))
		return

	var/datum/money_account/MA = get_account(account_number)
	to_chat(user, "<span class='notice'>Charge card's account number: [account_number]. PIN: [MA.remote_access_pin]</span>")
	to_chat(user, "<span class='notice'>Charge card's issuer: [issuer_name] ([issuer_account_number]).</span>")

	if(MA.money > 0.0)
		to_chat(user, "<span class='notice'>Credits remaining: [MA.money].</span>")
	if(MA.stocks)
		to_chat(user, "<span class='notice'>Charge card's stocks: [get_stocks_string(MA.stocks)].</span>")

	to_chat(user, "<span class='notice'>You can try putting this card into the closest ATM to transfer everything from it onto your account!</span>")

/obj/item/weapon/ewallet/proc/get_money()
	var/datum/money_account/MA = get_account(account_number)
	return MA.money

/obj/item/weapon/ewallet/proc/get_stocks()
	var/datum/money_account/MA = get_account(account_number)
	return MA.stocks

/obj/item/weapon/ewallet/proc/remove_money(amount, source_name, purpose)
	charge_to_account(account_number, source_name, purpose, "E-Transaction", -amount)

/proc/get_stocks_string(list/stocks)
	. = ""
	var/first = TRUE
	for(var/department in stocks)
		if(first)
			first = FALSE
		else
			. += ", "
		. += "[department]: [stocks[department]]/[SSeconomy.total_department_stocks[department]]"
