/obj/item/weapon/lipstick
	gender = PLURAL
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items.dmi'
	icon_state = "lipstick"
	w_class = ITEM_SIZE_TINY
	var/colour = "red"
	var/open = 0


/obj/item/weapon/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/weapon/lipstick/jade
	name = "jade lipstick"
	colour = "jade"

/obj/item/weapon/lipstick/black
	name = "black lipstick"
	colour = "black"


/obj/item/weapon/lipstick/random
	name = "lipstick"

/obj/item/weapon/lipstick/random/atom_init()
	. = ..()
	colour = pick("red","purple","jade","black")
	name = "[colour] lipstick"


/obj/item/weapon/lipstick/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You twist \the [src] [open ? "closed" : "open"].</span>")
	open = !open
	if(open)
		icon_state = "[initial(icon_state)]_[colour]"
	else
		icon_state = initial(icon_state)

/obj/item/weapon/lipstick/attack(mob/M, mob/user)
	if(!open)	return

	if(!istype(M, /mob))	return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.lip_style)	//if they already have lipstick on
			to_chat(user, "<span class='notice'>You need to wipe off the old lipstick first!</span>")
			return
		if(H == user)
			user.visible_message("<span class='notice'>[user] does their lips with \the [src].</span>", \
								 "<span class='notice'>You take a moment to apply \the [src]. Perfect!</span>")
			H.lip_style = "lipstick"
			H.lip_color = colour
			H.update_body()
		else if(!user.is_busy())
			user.visible_message("<span class='warning'>[user] begins to do [H]'s lips with \the [src].</span>", \
								 "<span class='notice'>You begin to apply \the [src].</span>")
			if(do_after(user, 20, target = H))	//user needs to keep their active hand, H does not.
				user.visible_message("<span class='notice'>[user] does [H]'s lips with \the [src].</span>", \
									 "<span class='notice'>You apply \the [src].</span>")
				H.lip_style = "lipstick"
				H.lip_color = colour
				H.update_body()
	else
		to_chat(user, "<span class='notice'>Where are the lips on that?</span>")

//you can wipe off lipstick with paper!
/obj/item/weapon/paper/attack(mob/living/carbon/M, mob/living/carbon/user, def_zone)
	if(def_zone == O_MOUTH)
		if(!istype(M))
			return

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, "<span class='notice'>You wipe off the lipstick with [src].</span>")
				H.lip_style = null
				H.update_body()
			else if(!user.is_busy())
				user.visible_message("<span class='warning'>[user] begins to wipe [H]'s lipstick off with \the [src].</span>", \
								 	 "<span class='notice'>You begin to wipe off [H]'s lipstick.</span>")
				if(do_after(user, 10, target = H))	//user needs to keep their active hand, H does not.
					user.visible_message("<span class='notice'>[user] wipes [H]'s lipstick off with \the [src].</span>", \
										 "<span class='notice'>You wipe off [H]'s lipstick.</span>")
					H.lip_style = null
					H.update_body()
	else
		..()


/obj/item/weapon/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'icons/obj/items.dmi'
	icon_state = "razor"
	flags = CONDUCT
	w_class = ITEM_SIZE_TINY


/obj/item/weapon/razor/proc/shave(mob/living/carbon/human/H, location = O_MOUTH, mob/living/carbon/human/AH = null)
	if(location == O_MOUTH)
		H.f_style = "Shaved"
	else
		H.h_style = "Skinhead"
	if(AH)
		H.log_combat(AH, "shaved with [name]")
	H.update_hair()
	playsound(src, 'sound/items/Welder2.ogg', VOL_EFFECTS_MASTER, 20)


/obj/item/weapon/razor/attack(mob/M, mob/user, def_zone)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(def_zone == O_MOUTH)
			if(!H.species.flags[HAS_HAIR])
				to_chat(user, "<span class='warning'>There is no hair!</span>")
				return
			if((H.head && (H.head.flags & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags & MASKCOVERSMOUTH)))
				to_chat(user, "<span class='warning'>The mask is in the way!</span>")
				return
			if(H.f_style == "Shaved")
				to_chat(user, "<span class='warning'>Already clean-shaven!</span>")
				return

			if(H == user) //shaving yourself
				if(user.is_busy()) return
				user.visible_message("[user] starts to shave their facial hair with [src].", \
									 "<span class='notice'>You take a moment to shave your facial hair with [src]...</span>")
				if(do_after(user, 50, target = H))
					user.visible_message("[user] shaves his facial hair clean with [src].", \
										 "<span class='notice'>You finish shaving with [src]. Fast and clean!</span>")
					shave(H, def_zone)
			else if(!user.is_busy())
				var/turf/H_loc = H.loc
				user.visible_message("<span class='warning'>[user] tries to shave [H]'s facial hair with [src].</span>", \
									 "<span class='notice'>You start shaving [H]'s facial hair...</span>")
				if(do_after(user, 50, target = H))
					if(H_loc == H.loc)
						user.visible_message("<span class='warning'>[user] shaves off [H]'s facial hair with [src].</span>", \
											 "<span class='notice'>You shave [H]'s facial hair clean off.</span>")
						shave(H, def_zone, user)

		else if(def_zone == BP_HEAD)
			if(!H.species.flags[HAS_HAIR])
				to_chat(user, "<span class='warning'>There is no hair!</span>")
				return
			if((H.head && (H.head.flags & BLOCKHAIR)) || (H.head && (H.head.flags & HIDEEARS)))
				to_chat(user, "<span class='warning'>The headgear is in the way!</span>")
				return
			if(H.h_style == "Bald" || H.h_style == "Balding Hair" || H.h_style == "Skinhead")
				to_chat(user, "<span class='warning'>There is not enough hair left to shave!</span>")
				return

			if(H == user) //shaving yourself
				if(user.is_busy()) return
				user.visible_message("[user] starts to shave their head with [src].", \
									 "<span class='notice'>You start to shave your head with [src]...</span>")
				if(do_after(user, 50, target = H))
					user.visible_message("[user] shaves his head with [src].", \
										 "<span class='notice'>You finish shaving with [src].</span>")
					shave(H, def_zone)
			else if(!user.is_busy())
				var/turf/H_loc = H.loc
				user.visible_message("<span class='warning'>[user] tries to shave [H]'s head with [src]!</span>", \
									 "<span class='notice'>You start shaving [H]'s head...</span>")
				if(do_after(user, 50, target = H))
					if(H_loc == H.loc)
						user.visible_message("<span class='warning'>[user] shaves [H]'s head bald with [src]!</span>", \
											 "<span class='notice'>You shave [H]'s head bald.</span>")
						shave(H, def_zone, user)
		else
			..()
	else
		..()

/obj/item/weapon/haircomb //sparklysheep's comb
	name = "purple comb"
	desc = "A pristine purple comb made from flexible plastic."
	w_class = ITEM_SIZE_TINY
	icon = 'icons/obj/items.dmi'
	icon_state = "purplecomb"
	item_state = "purplecomb"

/obj/item/weapon/haircomb/attack_self(mob/user)
	if(user.r_hand == src || user.l_hand == src)
		user.visible_message(text("<span class='warning'>[] uses [] to comb their hair with incredible style and sophistication. What a [].</span>", user, src, user.gender == FEMALE ? "lady" : "guy"))
	return

/obj/item/weapon/scissors
	name = "scissors"
	desc = "These can cut hair."
	icon = 'icons/obj/items.dmi'
	icon_state = "scissors"
	item_state = "scissors"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	force = 6.0
	throw_speed = 2
	throw_range = 9
	w_class = ITEM_SIZE_SMALL
	m_amt = 80
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("cut", "stabbed", "chipped")
	sharp = 1
	edge = 1
	var/list/bald_hair_styles_list = list("Bald", "Balding Hair", "Skinhead", "Unathi Horns", "Tajaran Ears")
	var/list/shaved_facial_hair_styles_list = list("Shaved")
	var/list/allowed_races = list(HUMAN, UNATHI, TAJARAN)
	var/mob/living/carbon/human/barber = null
	var/mob/living/carbon/human/barbertarget = null
	var/selectedhairstyle = null
	var/isfacehair = FALSE
	var/list/char_render_holders
	var/static/list/scissors_icon_cache

/obj/item/weapon/scissors/proc/calculate_hash(mob/living/carbon/human/H)
	var/hair_hash = H.hair_painted ? num2text(H.dyed_r_hair + H.dyed_g_hair * 256 + H.dyed_b_hair * 256 * 256, 9) : num2text(H.r_hair + H.g_hair * 256 + H.b_hair * 256 * 256, 9)
	var/facial_hash = H.facial_painted ? num2text(H.dyed_r_facial + H.dyed_g_facial * 256 + H.dyed_b_facial * 256 * 256, 9) : num2text(H.r_facial + H.g_facial * 256 + H.b_facial * 256 * 256, 9)
	var/hash = "" + H.species.name + H.gender + num2text(H.r_eyes + H.g_eyes*256 + H.b_eyes*256*256,9) + "_" + hair_hash + "_" + facial_hash + "_" + num2text(H.r_skin + H.g_skin*256 + H.b_skin*256*256,9) + "_" + num2text(H.s_tone)
	if(!isfacehair && selectedhairstyle)
		hash+="_" + selectedhairstyle
	else
		hash+="_" + H.h_style

	if(isfacehair && selectedhairstyle)
		hash+="_" + selectedhairstyle
	else
		hash+="_" + H.f_style
	hash+="_" + num2text(H.underwear) +"_" + num2text(H.undershirt) + "_" + num2text(H.socks)
	return hash

/obj/item/weapon/scissors/proc/make_mannequin(mob/living/carbon/human/H)
	var/mob/living/carbon/human/dummy/mannequin = new(null, H.species.name)
	mannequin.gender = H.gender
	mannequin.age = H.age
	mannequin.b_type = H.b_type

	mannequin.r_eyes = H.r_eyes
	mannequin.g_eyes = H.g_eyes
	mannequin.b_eyes = H.b_eyes

	if(!H.hair_painted)
		mannequin.r_hair = H.r_hair
		mannequin.g_hair = H.g_hair
		mannequin.b_hair = H.b_hair
		mannequin.r_grad = H.r_grad
		mannequin.g_grad = H.g_grad
		mannequin.b_grad = H.b_grad
	else
		mannequin.r_hair = H.dyed_r_hair
		mannequin.g_hair = H.dyed_g_hair
		mannequin.b_hair = H.dyed_b_hair
		mannequin.r_grad = H.dyed_r_hair
		mannequin.g_grad = H.dyed_g_hair
		mannequin.b_grad = H.dyed_b_hair

	if(!H.facial_painted)
		mannequin.r_facial = H.r_facial
		mannequin.g_facial = H.g_facial
		mannequin.b_facial = H.b_facial
	else
		mannequin.r_facial = H.dyed_r_facial
		mannequin.g_facial = H.dyed_g_facial
		mannequin.b_facial = H.dyed_b_facial

	mannequin.r_skin = H.r_skin
	mannequin.g_skin = H.g_skin
	mannequin.b_skin = H.b_skin

	mannequin.s_tone = H.s_tone

	if(!isfacehair && selectedhairstyle)
		mannequin.h_style = selectedhairstyle
	else
		mannequin.h_style = H.h_style

	mannequin.grad_style = H.grad_style

	if(isfacehair && selectedhairstyle)
		mannequin.f_style = selectedhairstyle
	else
		mannequin.f_style = H.f_style

	mannequin.underwear = H.underwear
	mannequin.undershirt = H.undershirt
	mannequin.socks = H.socks

	mannequin.update_body()
	mannequin.update_hair()
	COMPILE_OVERLAYS(mannequin)
	return mannequin

/obj/item/weapon/scissors/Topic(href, href_list)
	if(!barber || barber != usr || !barbertarget)
		return
	if(href_list["close"])
		clear_character_previews()
		return
	switch(href_list["choice"])
		if("selecthaircut")
			selectedhairstyle = href_list["haircut"]
			showui()
		if("start")
			INVOKE_ASYNC(src, .proc/dohaircut)
			clear_character_previews()

/obj/item/weapon/scissors/dropped(mob/user)
	clear_character_previews()
	..()

/obj/item/weapon/scissors/proc/create_character_previews()
	var/hash = calculate_hash(barbertarget)
	var/mutable_appearance/MA = LAZYACCESS(scissors_icon_cache, hash)

	if(!MA)
		var/mob/living/carbon/human/dummy/mannequin = make_mannequin(barbertarget)
		MA = new /mutable_appearance(mannequin)
		qdel(mannequin)
		LAZYSET(scissors_icon_cache, hash, MA)

	var/pos = 0
	for(var/D in cardinal)
		pos++
		var/obj/screen/O = LAZYACCESS(char_render_holders, "[D]")
		if(!O)
			O = new
			LAZYSET(char_render_holders, "[D]", O)
			barber.client.screen |= O
		O.appearance = MA
		O.dir = D
		O.screen_loc = "barber_preview_map:[pos],0"

/obj/item/weapon/scissors/proc/clear_character_previews()
	barber << browse(null, "window=barber_window")
	for(var/index in char_render_holders)
		var/obj/screen/S = char_render_holders[index]
		if(barber && barber.client)
			barber.client.screen -= S
		qdel(S)
	char_render_holders = null
	barber = null
	barbertarget = null

/obj/item/weapon/scissors/proc/showui()
	if(!barber || !barbertarget)
		return

	create_character_previews()

	var/list/selected_styles_list = hairs_cache["[barbertarget.get_species()][PLURAL]"]
	if(isfacehair)
		selected_styles_list = facial_hairs_cache["[barbertarget.get_species()][PLURAL]"]

	var/haircutlist = "<table style='width:100%'><tr>"
	var/tablei = 0
	for(var/i in selected_styles_list)
		var/styles = ""
		if(i == selectedhairstyle || (!selectedhairstyle && ((barbertarget.f_style == i && isfacehair) || (barbertarget.h_style == i && !isfacehair))))
			styles = "color: rgb(255,0,0)"
		haircutlist += "<td><a style='[styles]' href='byond://?src=\ref[src];choice=selecthaircut;haircut=[i]'><b>[i]</b></a><br></td>"
		if(++tablei >= 5)
			tablei = 0
			haircutlist+="</tr><tr>"
	haircutlist+="</tr></table>"

	winshow(barber, "barber_window", TRUE)
	barber << browse("<html><head><title>Grooming</title></head>" \
		+ "<body style='margin:0;text-align:center'>" \
		+ "<a href='byond://?src=\ref[src];choice=start'><b>CONFIRM</b></a><br><br>" \
		+ haircutlist \
		+ "</body></html>", "window=barber_window")
	onclose(barber, "barber_window", src)
	return

/obj/item/weapon/scissors/proc/dohaircut()
	// saving those refs, it will be cleaned before do_after proc ends
	var/mob/living/carbon/human/barber = src.barber
	var/mob/living/carbon/human/barbertarget = src.barbertarget

	if(!barber || !barbertarget || !selectedhairstyle)
		return
	if(!in_range(barbertarget, barber) || barber.get_active_hand() != src)
		return

	if(isfacehair)
		barber.visible_message("<span class='notice'>[barber] starts cutting [barbertarget]'s facial hair with [src]!</span>", \
							   "<span class='notice'>You start cutting [barbertarget]'s facial hair with [src], this might take a minute...</span>")
		if(do_after(barber, 100, target = barbertarget))
			barbertarget.f_style = selectedhairstyle
			barbertarget.update_hair()
			barber.visible_message("<span class='notice'>[barber] finished cutting [barbertarget]'s facial hair</span>", \
								   "<span class='notice'>You finished cutting [barbertarget]'s facial hair</span>")
	else
		barber.visible_message("<span class='notice'>[barber] starts cutting [barbertarget]'s hair with [src]!</span>", \
							   "<span class='notice'>You start cutting [barbertarget]'s hair with [src], this might take a minute...</span>")
		if(do_after(barber, 100, target = barbertarget))
			barbertarget.h_style = selectedhairstyle
			barbertarget.update_hair()
			barber.visible_message("<span class='notice'>[barber] finished cutting [barbertarget]'s hair</span>", \
								   "<span class='notice'>You finished cutting [barbertarget]'s hair</span>")


/obj/item/weapon/scissors/attack(mob/M, mob/user, def_zone)
	if(user.a_intent == INTENT_HARM)
		..()
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(user.is_busy()) return

		if(def_zone == O_MOUTH)
			if(H == user)
				to_chat(user, "<span class='notice'>You can't cut your facial hair</span>")
				return

			if(H.species.name in allowed_races)
				if((H.head && (H.head.flags & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags & MASKCOVERSMOUTH)))
					to_chat(user, "<span class='warning'>The mask is in the way!</span>")
					return

				if(H.f_style in shaved_facial_hair_styles_list)
					to_chat(user, "<span class='notice'>There are not enough hair to change facial hair style</span>")
					return

				selectedhairstyle = null
				isfacehair = TRUE
				barber = user
				barbertarget = M
				showui()
				return
			else
				to_chat(user, "<span class='notice'>You don't know how to cut the hair of this race!</span>")
				return

		else if(def_zone == BP_HEAD)
			if(H == user)
				to_chat(user, "<span class='notice'>You can't cut your hair</span>")
				return

			if(H.species.name in allowed_races)
				if(H.head && ((H.head.flags & BLOCKHAIR) || (H.head.flags & HIDEEARS)))
					to_chat(user, "<span class='warning'>The headgear is in the way!</span>")
					return

				if(H.h_style in bald_hair_styles_list)
					to_chat(user, "<span class='notice'>There are not enough hair to make a haircut</span>")
					return

				selectedhairstyle = null
				isfacehair = FALSE
				barber = user
				barbertarget = M
				showui()
				return
			else
				to_chat(user, "<span class='notice'>You don't know how to cut the hair of this race!</span>")
				return
	..()
