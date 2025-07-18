/obj/item/weapon/dart_cartridge
	name = "dart cartridge"
	desc = "A rack of hollow darts."
	icon = 'icons/obj/ammo/magazines.dmi'
	icon_state = "darts-5"
	item_state = "rcdammo"
	opacity = 0
	density = FALSE
	anchored = FALSE
	origin_tech = "materials=2"
	var/darts = 5

/obj/item/weapon/dart_cartridge/update_icon()
	if(!darts)
		icon_state = "darts-0"
	else if(darts > 5)
		icon_state = "darts-5"
	else
		icon_state = "darts-[darts]"
	return 1

/obj/item/weapon/gun/dartgun
	name = "dart gun"
	desc = "A small gas-powered dartgun, capable of delivering chemical cocktails swiftly across short distances."
	icon_state = "dartgun-empty"

	var/list/beakers = list() //All containers inside the gun.
	var/list/mixing = list() //Containers being used for mixing.
	var/obj/item/weapon/dart_cartridge/cartridge = null //Container of darts.
	var/max_beakers = 3
	var/dart_reagent_amount = 15
	var/container_type = /obj/item/weapon/reagent_containers/glass/beaker
	var/list/starting_chems = null

/obj/item/weapon/gun/dartgun/update_icon()

	if(!cartridge)
		icon_state = "dartgun-empty"
		return 1

	if(!cartridge.darts)
		icon_state = "dartgun-0"
	else if(cartridge.darts > 5)
		icon_state = "dartgun-5"
	else
		icon_state = "dartgun-[cartridge.darts]"
	return 1

/obj/item/weapon/gun/dartgun/atom_init()
	. = ..()
	if(starting_chems)
		for(var/chem in starting_chems)
			var/obj/B = new container_type(src)
			B.reagents.add_reagent(chem, 50)
			beakers += B
	cartridge = new /obj/item/weapon/dart_cartridge(src)
	update_icon()

/obj/item/weapon/gun/dartgun/examine(mob/user)
	..()
	if ((src in view(2, user)) && beakers.len)
		to_chat(user, "<span class='notice'>[src] contains:</span>")
		for(var/obj/item/weapon/reagent_containers/glass/beaker/B in beakers)
			if(B.reagents && B.reagents.reagent_list.len)
				for(var/datum/reagent/R in B.reagents.reagent_list)
					to_chat(user, "<span class='notice'>[R.volume] units of [R.name]</span>")

/obj/item/weapon/gun/dartgun/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/dart_cartridge))
		var/obj/item/weapon/dart_cartridge/D = I

		if(!D.darts)
			to_chat(user, "<span class='notice'>[D] is empty.</span>")
			return 0

		if(cartridge)
			if(cartridge.darts <= 0)
				remove_cartridge()
			else
				to_chat(user, "<span class='notice'>There's already a cartridge in [src].</span>")
				return 0

		user.drop_from_inventory(D, src)
		cartridge = D
		to_chat(user, "<span class='notice'>You slot [D] into [src].</span>")
		update_icon()
		return

	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(!istype(I, container_type))
			to_chat(user, "<span class='notice'>[I] doesn't seem to fit into [src].</span>")
			return
		if(beakers.len >= max_beakers)
			to_chat(user, "<span class='notice'>[src] already has [max_beakers] beakers in it - another one isn't going to fit!</span>")
			return
		var/obj/item/weapon/reagent_containers/glass/beaker/B = I
		user.drop_from_inventory(B, src)
		beakers += B
		to_chat(user, "<span class='notice'>You slot [B] into [src].</span>")
		updateUsrDialog()
		return

	return ..()

/obj/item/weapon/gun/dartgun/can_fire()
	if(!cartridge)
		return 0
	else
		return cartridge.darts

/obj/item/weapon/gun/dartgun/proc/has_selected_beaker_reagents()
	return 0

/obj/item/weapon/gun/dartgun/proc/remove_cartridge()
	if(cartridge)
		to_chat(usr, "<span class='notice'>You pop the cartridge out of [src].</span>")
		var/obj/item/weapon/dart_cartridge/C = cartridge
		C.loc = get_turf(src)
		C.update_icon()
		cartridge = null
		update_icon()

/obj/item/weapon/gun/dartgun/proc/get_mixed_syringe()
	if (!cartridge)
		return 0
	if(!cartridge.darts)
		return 0

	var/obj/item/weapon/reagent_containers/syringe/dart = new(src)

	if(mixing.len)
		var/mix_amount = dart_reagent_amount/mixing.len
		for(var/obj/item/weapon/reagent_containers/glass/beaker/B in mixing)
			B.reagents.trans_to(dart,mix_amount)

	return dart

/obj/item/weapon/gun/dartgun/proc/fire_dart(atom/target, mob/user)
	if (locate (/obj/structure/table, src.loc))
		return
	else
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
				var/obj/item/clothing/suit/V = H.wear_suit
				V.attack_reaction(H, REACTION_GUN_FIRE)

		var/turf/trg = get_turf(target)
		var/obj/effect/syringe_gun_dummy/D = new/obj/effect/syringe_gun_dummy(get_turf(src))
		var/obj/item/weapon/reagent_containers/syringe/S = get_mixed_syringe()
		if(!S)
			to_chat(user, "<span class='warning'>There are no darts in [src]!</span>")
			return
		if(!S.reagents)
			to_chat(user, "<span class='warning'>There are no reagents available!</span>")
			return
		cartridge.darts--
		update_icon()
		S.reagents.trans_to(D, S.reagents.total_volume)
		qdel(S)
		D.icon_state = "syringeproj"
		D.name = "syringe"
		D.flags |= NOREACT
		playsound(user, 'sound/items/syringeproj.ogg', VOL_EFFECTS_MASTER)

		for(var/i=0, i<6, i++)
			if(!D) break
			if(D.loc == trg) break
			step_towards(D,trg)

			if(D)
				for(var/mob/living/carbon/M in D.loc)
					if(!iscarbon(M)) continue
					if(M == user) continue
					//Syringe gun attack logging by Yvarov
					var/R
					if(D.reagents)
						for(var/datum/reagent/A in D.reagents.reagent_list)
							R += A.id + " ("
							R += num2text(A.volume) + "),"
					if (istype(M, /mob))
						M.log_combat(user, "shot with a dartgun")

					else
						M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[M]/[M.ckey]</b> with a <b>dartgun</b> ([R])"
						msg_admin_attack("UNKNOWN shot [M.name] ([M.ckey]) with a <b>dartgun</b> ([R])", M)

					if(D.reagents)
						D.reagents.trans_to(M, 15)
					to_chat(M, "<span class='danger'>You feel a slight prick.</span>")

					qdel(D)
					break
			if(D)
				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density) qdel(D)

			sleep(1)

		if (D) spawn(10) qdel(D)

		return

/obj/item/weapon/gun/dartgun/afterattack(atom/target, mob/user, proximity, params)
	if(!isturf(target.loc) || target == user) return
	..()

/obj/item/weapon/gun/dartgun/can_hit(mob/living/target, mob/living/user)
	return 1

/obj/item/weapon/gun/dartgun/attack_self(mob/user)

	user.set_machine(src)
	var/dat = "<b>[src] mixing control:</b><br><br>"

	if (beakers.len)
		var/i = 1
		for(var/obj/item/weapon/reagent_containers/glass/beaker/B in beakers)
			dat += "Beaker [i] contains: "
			if(B.reagents && B.reagents.reagent_list.len)
				for(var/datum/reagent/R in B.reagents.reagent_list)
					dat += "<br>    [R.volume] units of [R.name], "
				if (check_beaker_mixing(B))
					dat += text("<A class='green' href='byond://?src=\ref[src];stop_mix=[i]'>Mixing</A> ")
				else
					dat += text("<A class='red' href='byond://?src=\ref[src];mix=[i]'>Not mixing</A> ")
			else
				dat += "nothing."
			dat += " <A href='byond://?src=\ref[src];eject=[i]'>Eject</A><br>"
			i++
	else
		dat += "There are no beakers inserted!<br><br>"

	if(cartridge)
		if(cartridge.darts)
			dat += "The dart cartridge has [cartridge.darts] shots remaining."
		else
			dat += "<span class='red'>The dart cartridge is empty!</span>"
		dat += " <A href='byond://?src=\ref[src];eject_cart=1'>Eject</A>"

	var/datum/browser/popup = new(user, "dartgun", nref = src)
	popup.set_content(dat)
	popup.open()


/obj/item/weapon/gun/dartgun/proc/check_beaker_mixing(obj/item/B)
	if(!mixing || !beakers)
		return 0
	for(var/obj/item/M in mixing)
		if(M == B)
			return 1
	return 0

/obj/item/weapon/gun/dartgun/Topic(href, href_list)
	add_fingerprint(usr)
	if(href_list["stop_mix"])
		var/index = text2num(href_list["stop_mix"])
		if(index <= beakers.len)
			for(var/obj/item/M in mixing)
				if(M == beakers[index])
					mixing -= M
					break
	else if (href_list["mix"])
		var/index = text2num(href_list["mix"])
		if(index <= beakers.len)
			mixing += beakers[index]
	else if (href_list["eject"])
		var/index = text2num(href_list["eject"])
		if(index <= beakers.len)
			if(beakers[index])
				var/obj/item/weapon/reagent_containers/glass/beaker/B = beakers[index]
				to_chat(usr, "You remove [B] from [src].")
				mixing -= B
				beakers -= B
				B.loc = get_turf(src)
	else if (href_list["eject_cart"])
		remove_cartridge()
	updateUsrDialog()
	return

/obj/item/weapon/gun/dartgun/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(cartridge)
		spawn(0) fire_dart(target,user)
	else
		to_chat(usr, "<span class='warning'>[src] is empty.</span>")


/obj/item/weapon/gun/dartgun/vox
	name = "alien dart gun"
	desc = "A small gas-powered dartgun, fitted for nonhuman hands."

/obj/item/weapon/gun/dartgun/vox/medical
	starting_chems = list("kelotane","bicaridine","anti_toxin")

/obj/item/weapon/gun/dartgun/vox/raider
	starting_chems = list("space_drugs","stoxin","impedrezene")
