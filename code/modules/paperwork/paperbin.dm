/obj/item/weapon/paper_bin
	name = "paper bin"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"
	throwforce = 1
	w_class = SIZE_SMALL
	throw_speed = 3
	throw_range = 7
	var/amount = 30 // How much paper is in the bin.
	var/list/papers = list() // List of papers put in the bin for reference.


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

	var/response = ""
	if(!papers.len)
		response = tgui_alert(user, "Would you like to take Regular paper or Carbon copy paper?", "Paper type request", list("Regular", "Carbon-Copy", "Cancel"))
		if (response != "Regular" && response != "Carbon-Copy")
			add_fingerprint(user)
			return

	if(amount >= 1)
		amount--
		if(amount == 0)
			update_icon()

		var/obj/item/weapon/paper/P
		if(papers.len > 0) // If there's any custom paper on the stack, use that instead of creating a new paper.
			P = papers[papers.len]
			papers.Remove(P)
		else
			if(response == "Regular")
				P = new /obj/item/weapon/paper
				if(SSholiday.holidays[APRIL_FOOLS])
					if(prob(30))
						P.info = "<font face=\"[P.crayonfont]\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
						P.rigged = 1
						P.updateinfolinks()
			else if (response == "Carbon-Copy")
				P = new /obj/item/weapon/paper/carbon

		user.try_take(P, loc)
		to_chat(user, "<span class='notice'>You take [P] out of the [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty!</span>")

	add_fingerprint(user)
	return

/obj/item/weapon/paper_bin/attackby(obj/item/I, mob/user, params)
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
	if(amount < 1)
		icon_state = "paper_bin0"
	else
		icon_state = "paper_bin1"
