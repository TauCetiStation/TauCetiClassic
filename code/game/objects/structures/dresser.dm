/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = TRUE
	anchored = TRUE

	resistance_flags = CAN_BE_HIT

/obj/structure/dresser/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/wood(loc, 10)
	..()

/obj/structure/dresser/attack_hand(mob/user)
	if(!Adjacent(user))//no tele-grooming
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		var/choice = input(user, "Underwear, Undershirt, or Socks?", "Changing") as null|anything in list("Underwear","Undershirt","Socks")

		if(!Adjacent(user))
			return
		add_fingerprint(H)
		switch(choice)
			if("Underwear")
				if(!H.species.flags[HAS_UNDERWEAR])
					to_chat(H, "<span class='notice'>You can't find any suitable underwear for your species...</span>")
					return

				var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference", H.underwear ? underwear_t[H.underwear] : "None") as null|anything in list("None") + underwear_t
				if(new_underwear)
					if(new_underwear == "None")
						H.underwear = 0
					else
						H.underwear = underwear_t.Find(new_underwear)
					H.update_underwear()
			if("Undershirt")
				var/new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference", H.undershirt ? undershirt_t[H.undershirt] : "None") as null|anything in list("None") + undershirt_t
				if (new_undershirt)
					if(new_undershirt == "None")
						H.undershirt = 0
					else
						H.undershirt = undershirt_t.Find(new_undershirt)
					H.update_underwear()

					if(H.undershirt)
						var/new_undershirt_print = input(user, "Choose your undershirt print:", "Character Preference", H.undershirt_print ? H.undershirt_print : "None") as null|anything in list("None") + undershirt_prints_t
						if (new_undershirt_print)
							if(new_undershirt_print == "None")
								H.undershirt_print = null
							else
								H.undershirt_print = new_undershirt_print
							H.update_underwear()
			if("Socks")
				var/new_socks = input(user, "Choose your character's socks:", "Character Preference", H.socks ? socks_t[H.socks] : "None") as null|anything in list("None") + socks_t
				if(new_socks)
					if(new_socks == "None")
						H.socks = 0
					else
						H.socks = socks_t.Find(new_socks)
					H.update_underwear()
