/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = 1
	anchored = 1

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
				var/list/underwear_options
				if(gender == MALE)
					underwear_options = underwear_m
				else
					underwear_options = underwear_f
				var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_options
				if(new_underwear && Adjacent(user))
					H.underwear = underwear_options.Find(new_underwear)
					H.update_body()
			if("Undershirt")
				var/list/undershirt_options
				undershirt_options = undershirt_t
				var/new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in undershirt_options
				if(new_undershirt && Adjacent(user))
					H.undershirt = undershirt_options.Find(new_undershirt)
					H.update_body()
			if("Socks")
				var/list/socks_options
				socks_options = socks_t
				var/new_socks = input(user, "Choose your character's socks:", "Character Preference") as null|anything in socks_options
				if(new_socks && Adjacent(user))
					H.socks = socks_options.Find(new_socks)
					H.update_body()