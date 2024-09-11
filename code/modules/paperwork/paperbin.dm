/obj/item/weapon/paper_bin
	name = "paper bin"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin_5"
	item_state = "sheet-metal"
	throwforce = 1
	w_class = SIZE_SMALL
	throw_speed = 3
	throw_range = 7
	var/amount = 15 // How much paper is in the bin.
	var/list/papers = list() // List of papers put in the bin for reference.
	var/static/list/paper_types

/obj/item/weapon/paper_bin/atom_init()
	. = ..()
	paper_types = list(
		"paper" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paper"),
		"carbon copy paper" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "cpaper"),
		)

/obj/item/weapon/paper_bin/MouseDrop(mob/user)
	. = ..()
	if(user == usr && !usr.incapacitated() && Adjacent(usr))
		var/prev_intent = user.a_intent
		user.set_a_intent(INTENT_GRAB)
		attack_hand(user)
		user.set_a_intent(prev_intent)

/obj/item/weapon/paper_bin/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/weapon/paper_bin/attack_hand(mob/living/user)
	if(user && user.a_intent == INTENT_GRAB)
		return ..()

	var/obj/item/weapon/paper/P

	if(papers.len > 0) // If there's any custom paper on the stack, use that instead of creating a new paper.
		P = papers[papers.len]
		papers.Remove(P)
		user.try_take(P, loc)
		add_fingerprint(user)
		update_icon()
		amount--
		return

	if(amount < 1)
		to_chat(user, "<span class='notice'>[src] is empty!</span>")
		return

	var/selection = show_radial_menu(user, src, paper_types, require_near = TRUE, tooltips = TRUE)

	if(!selection)
		add_fingerprint(user)
		return

	switch(selection)
		if("paper")
			P = new /obj/item/weapon/paper
			if(SSholiday.holidays[APRIL_FOOLS])
				if(prob(30))
					P.info = "<font face=\"[P.crayonfont]\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
					P.rigged = 1
					P.updateinfolinks()
		if("carbon copy paper")
			P = new /obj/item/weapon/paper/carbon


	if(ishuman(user))
		user.put_in_hands(P)
	else
		P.forceMove(get_turf(src))

	amount--
	to_chat(user, "<span class='notice'>You take [P] out of the [src].</span>")

	add_fingerprint(user)

	update_icon()

/obj/item/weapon/paper_bin/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/paper_refill))
		if(amount >= 15)
			to_chat(user, "<span class='notice'>Корзина для бумаг полна.</span>")
			return ..()
		amount = 15
		qdel(I)
		to_chat(user, "<span class='notice'>Корзина для бумаг пополнена.</span>")
		update_icon()
		return

	if(!istype(I, /obj/item/weapon/paper))
		return ..()

	user.drop_from_inventory(I, src)
	to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
	papers.Add(I)
	amount++

/obj/item/weapon/paper_bin/examine(mob/user)
	..()
	if(src in view(1, user))
		if(amount)
			to_chat(user, "<span class='notice'>There " + (amount > 1 ? "are [amount] papers" : "is one paper") + " in the bin.</span>")
		else
			to_chat(user, "<span class='notice'>There are no papers in the bin.</span>")

/obj/item/weapon/paper_bin/update_icon()
	var/icon_number = CEIL(amount/3)
	icon_state = "paper_bin_[icon_number]"

/obj/item/weapon/paper_refill
	name = "paper refill pack"
	desc = "Бумага только с завода Нового Гибсона!"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_pack"
