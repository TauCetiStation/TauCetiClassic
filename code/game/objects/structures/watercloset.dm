//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos

/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = 0
	anchored = 1
	var/open = 0			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie

/obj/structure/toilet/New()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/toilet/attack_hand(mob/living/user)
	if(swirlie)
		usr.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie.name]'s head!</span>", "<span class='notice'>You slam the toilet seat onto [swirlie.name]'s head!</span>", "You hear reverberating porcelain.")
		swirlie.adjustBruteLoss(8)
		return

	if(cistern && !open)
		if(!contents.len)
			to_chat(user, "<span class='notice'>The cistern is empty.</span>")
			return
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.loc = get_turf(src)
			to_chat(user, "<span class='notice'>You find \an [I] in the cistern.</span>")
			w_items -= I.w_class
			return

	open = !open
	update_icon()

/obj/structure/toilet/update_icon()
	icon_state = "toilet[open][cistern]"

/obj/structure/toilet/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/weapon/crowbar))
		to_chat(user, "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"].</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(do_after(user, 30, target = src))
			user.visible_message("<span class='notice'>[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!</span>", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "You hear grinding porcelain.")
			cistern = !cistern
			update_icon()
			return

	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I

		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting

			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on the toilet.</span>")
					return
				if(open && !swirlie)
					user.visible_message("<span class='danger'>[user] starts to give [GM.name] a swirlie!</span>", "<span class='notice'>You start to give [GM.name] a swirlie!</span>")
					swirlie = GM
					if(do_after(user, 30, 5, 0, target = src))
						user.visible_message("<span class='danger'>[user] gives [GM.name] a swirlie!</span>", "<span class='notice'>You give [GM.name] a swirlie!</span>", "You hear a toilet flushing.")
						if(!GM.internal)
							GM.adjustOxyLoss(5)
					swirlie = null
				else
					user.visible_message("<span class='danger'>[user] slams [GM.name] into the [src]!</span>", "<span class='notice'>You slam [GM.name] into the [src]!</span>")
					GM.adjustBruteLoss(8)
			else
				to_chat(user, "<span class='notice'>You need a tighter grip.</span>")

	if(cistern)
		if(I.w_class > 3)
			to_chat(user, "<span class='notice'>\The [I] does not fit.</span>")
			return
		if(w_items + I.w_class > 5)
			to_chat(user, "<span class='notice'>The cistern is full.</span>")
			return
		user.drop_item()
		I.loc = src
		w_items += I.w_class
		to_chat(user, "You carefully place \the [I] into the cistern.")
		return



/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = 0
	anchored = 1

/obj/structure/urinal/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on the urinal.</span>")
					return
				user.visible_message("<span class='danger'>[user] slams [GM.name] into the [src]!</span>", "<span class='notice'>You slam [GM.name] into the [src]!</span>")
				GM.adjustBruteLoss(8)
			else
				to_chat(user, "<span class='notice'>You need a tighter grip.</span>")

/obj/structure/dryer
	name = "hand dryer"
	desc = "The Breath Of Lizads-3000, an experimental dryer."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dryer"
	density = 0
	anchored = 1
	var/busy = 0
	var/emagged = 0

/obj/structure/dryer/attack_hand(mob/user)

	if(isrobot(user) || isAI(user))
		return

	if(!Adjacent(user))
		return

	if(busy)
		to_chat(user, "\red Someone's already drying here.")
		return

	to_chat(usr, "\blue You start drying your hands.")
	playsound(src, 'sound/items/drying.ogg', 30, 1, 1)
	add_fingerprint(user)
	busy = 1
	sleep(60)
	if(emagged)
		var/mob/living/carbon/C = user
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H.gloves)
				new /obj/effect/decal/cleanable/ash(H.loc)
				qdel(H.gloves)
				H.adjustFireLoss(5)
			else
				H.adjustFireLoss(20)
	busy = 0

	if(!Adjacent(user)) return		//Person has moved away from the dryer

	for(var/mob/V in viewers(src, null))
		V.show_message("\blue [user] dried their hands using \the [src].")

/obj/structure/dryer/attackby(obj/item/O, mob/user)

	if (istype(O, /obj/item/weapon/card/emag))
		if (emagged)
			to_chat(user, "\red [src] is already cracked.")
			return
		else
			add_fingerprint(user)
			emagged = 1
			flick("dryer-broken",src)
			playsound(src, 'sound/effects/sparks3.ogg', 50, 1, 1)
			icon_state = "dryer-emag"
			to_chat(user, "\red You swipe near [O] and crack it to be hot.")
			return

	if((istype(O, /obj/item/weapon/grab)) && !emagged)
		var/obj/item/weapon/grab/G = O
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on the urinal.</span>")
					return
				user.visible_message("<span class='danger'>[user] slams [GM.name] into the [src]!</span>", "<span class='notice'>You slam [GM.name] into the [src]!</span>")
				GM.apply_damage(8,BRUTE,"head")
				playsound(src, 'sound/weapons/smash.ogg', 50, 1, 1)
				return
			else
				to_chat(user, "<span class='notice'>You need a tighter grip.</span>")
				return

	if(busy)
		to_chat(user, "\red Someone's already drying here.")
		return

	var/turf/location = user.loc
	if(!isturf(location)) return

	var/obj/item/I = O
	if(!I || !istype(I,/obj/item)) return

	add_fingerprint(user)

	if(emagged)		//Let's make it a little bit dangerous

		if(istype(O, /obj/item/weapon/grab))	//Holding someone under dryer
			var/obj/item/weapon/grab/G = O
			if(isliving(G.affecting))
				var/mob/living/GM = G.affecting
				if(G.state>2)
					if(!GM.loc == get_turf(src))
						to_chat(user, "<span class='notice'>[GM.name] needs to be near the dryer.</span>")
						return
					busy = 1
					user.visible_message("<span class='danger'>[user] hold [GM.name] under the [src]!</span>", "<span class='notice'>You hold [GM.name] under the [src]!</span>")
					playsound(src, 'sound/items/drying.ogg', 30, 1, 1)
					GM.adjustFireLoss(10)
					sleep(60)
					busy = 0
					if(!Adjacent(user) || !Adjacent(GM)) return		//User or target has moved
					GM.adjustFireLoss(25)
					user.visible_message("<span class='danger'>[GM.name] skins are burning under the [src]!</span>")
					return
				else
					to_chat(user, "<span class='notice'>You need a tighter grip.</span>")
					return

		busy = 1
		to_chat(usr, "\blue You start drying \the [I].")
		playsound(src, 'sound/items/drying.ogg', 30, 1, 1)
		sleep(60)
		var/mob/living/carbon/C = user
		if(C.r_hand)
			C.apply_damage(25,BURN,"r_hand")
		if(C.l_hand)
			C.apply_damage(25,BURN,"l_hand")
		to_chat(C, "<span class='danger'>The dryer is burning!</span>")
		new /obj/effect/decal/cleanable/ash(C.loc)
		qdel(O)
		busy = 0
		return

	busy = 1
	to_chat(usr, "\blue You start drying \the [I].")
	playsound(src, 'sound/items/drying.ogg', 30, 1, 1)
	sleep(60)
	busy = 0

	if(user.loc != location) return				//User has moved
	if(!I) return 								//Item's been destroyed while drying
	if(user.get_active_hand() != I) return		//Person has switched hands or the item in their hands

	O.wet = 0
	user.visible_message( \
		"\blue [user] drying \a [I] using \the [src].", \
		"\blue You dry \a [I] using \the [src].")

/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = 0
	anchored = 1
	use_power = 0
	var/on = 0
	var/obj/effect/mist/mymist = null
	var/ismist = 0				//needs a var so we can make it linger~
	var/watertemp = "normal"	//freezing, normal, or boiling
	var/mobpresent = 0		//true if there is a mob on the shower's loc, this is to ease process()
	var/is_payed = 0

//add heat controls? when emagged, you can freeze to death in it?

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = MOB_LAYER + 1
	anchored = 1
	mouse_opacity = 0

/obj/machinery/shower/attack_hand(mob/M)
	if(is_payed)
		on = !on
		update_icon()
		if(on)
			if (M.loc == loc)
				wash(M)
				check_heat(M)
			for (var/atom/movable/G in src.loc)
				G.clean_blood()
		else
			is_payed = 0 // Если игрок выключил раньше времени - принудительное аннулирование платы.
	else
		to_chat(M, "You didn't pay for that. Swipe a card against [src].")

/obj/machinery/shower/attackby(obj/item/I, mob/user)
	if(I.type == /obj/item/device/analyzer)
		to_chat(user, "<span class='notice'>The water temperature seems to be [watertemp].</span>")
	else if(istype(I, /obj/item/weapon/wrench))
		to_chat(user, "<span class='notice'>You begin to adjust the temperature valve with \the [I].</span>")
		if(do_after(user, 50, target = src))
			switch(watertemp)
				if("normal")
					watertemp = "freezing"
				if("freezing")
					watertemp = "boiling"
				if("boiling")
					watertemp = "normal"
			user.visible_message("<span class='notice'>[user] adjusts the shower with \the [I].</span>", "<span class='notice'>You adjust the shower with \the [I].</span>")
			add_fingerprint(user)
	else if(istype(I, /obj/item/weapon/card))
		if(!is_payed)
			if(!on)
				var/obj/item/weapon/card/C = I
				visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
				if(station_account)
					var/datum/money_account/D = get_account(C.associated_account_number)
					var/attempt_pin = 0
					if(D.security_level > 0)
						attempt_pin = input("Enter pin code", "Transaction") as num
					if(attempt_pin)
						D = attempt_account_access(C.associated_account_number, attempt_pin, 2)
					if(D)
						var/transaction_amount = 150
						if(transaction_amount <= D.money)
							//transfer the money
							D.money -= transaction_amount
							station_account.money += transaction_amount

							//create entries in the two account transaction logs
							var/datum/transaction/T = new()
							T.target_name = "[station_account.owner_name] (via [src.name])"
							T.purpose = "Purchase of shower use"
							if(transaction_amount > 0)
								T.amount = "([transaction_amount])"
							else
								T.amount = "[transaction_amount]"
							T.source_terminal = src.name
							T.date = current_date_string
							T.time = worldtime2text()
							D.transaction_log.Add(T)

							T = new()
							T.target_name = D.owner_name
							T.purpose = "Purchase of shower use"
							T.amount = "[transaction_amount]"
							T.source_terminal = src.name
							T.date = current_date_string
							T.time = worldtime2text()
							station_account.transaction_log.Add(T)

							is_payed = 60
							to_chat(usr, "[bicon(src)]Thank you, happy washing time and don't turn me off accidently or i will take your precious credits again! Teehee.</span>")
						else
							to_chat(usr, "[bicon(src)]<span class='warning'>You don't have that much money!</span>")
		else
			to_chat(usr, "[bicon(src)]Is payed, you may turn it on now.</span>")

/obj/machinery/shower/update_icon()	//this is terribly unreadable, but basically it makes the shower mist up
	overlays.Cut()					//once it's been on for a while, in addition to handling the water overlay.
	if(mymist)
		qdel(mymist)

	if(on)
		overlays += image('icons/obj/watercloset.dmi', src, "water", MOB_LAYER + 1, dir)
		if(watertemp == "freezing")
			return
		if(!ismist)
			spawn(50)
				if(src && on)
					ismist = 1
					mymist = PoolOrNew(/obj/effect/mist,loc)
		else
			ismist = 1
			mymist = PoolOrNew(/obj/effect/mist,loc)
	else if(ismist)
		ismist = 1
		mymist = PoolOrNew(/obj/effect/mist,loc)
		spawn(250)
			if(src && !on)
				qdel(mymist)
				ismist = 0

/obj/machinery/shower/Crossed(atom/movable/O)
	..()
	wash(O)
	if(ismob(O))
		mobpresent += 1
		check_heat(O)

/obj/machinery/shower/Uncrossed(atom/movable/O)
	if(ismob(O))
		mobpresent -= 1
	..()

//Yes, showers are super powerful as far as washing goes.
/obj/machinery/shower/proc/wash(atom/movable/O)
	if(!on) return

	if(isliving(O))
		var/mob/living/L = O
		L.ExtinguishMob()
		L.fire_stacks = -20 //Douse ourselves with water to avoid fire more easily
		to_chat(L, "<span class='warning'>You've been drenched in water!</span>")
	if(iscarbon(O))
		var/mob/living/carbon/M = O
		if(M.r_hand)
			M.r_hand.make_wet(1) //<= wet
			M.r_hand.clean_blood()
		if(M.l_hand)
			M.l_hand.make_wet(1) //<= wet
			M.l_hand.clean_blood()
		if(M.back)
			M.back.make_wet(1) //<= wet
			if(M.back.clean_blood())
				M.update_inv_back()
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/washgloves = 1
			var/washshoes = 1
			var/washmask = 1
			var/washears = 1
			var/washglasses = 1

			if(H.wear_suit)
				washgloves = !(H.wear_suit.flags_inv & HIDEGLOVES)
				washshoes = !(H.wear_suit.flags_inv & HIDESHOES)

			if(H.head)
				washmask = !(H.head.flags_inv & HIDEMASK)
				washglasses = !(H.head.flags_inv & HIDEEYES)
				washears = !(H.head.flags_inv & HIDEEARS)

			if(H.wear_mask)
				if (washears)
					washears = !(H.wear_mask.flags_inv & HIDEEARS)
				if (washglasses)
					washglasses = !(H.wear_mask.flags_inv & HIDEEYES)
			else
				H.lip_style = null
				H.update_body()

			if(H.head)
				H.head.make_wet(1) //<= wet
				if(H.head.clean_blood())
					H.update_inv_head()
			if(H.wear_suit)
				H.wear_suit.make_wet(1) //<= wet
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit()
			else if(H.w_uniform)
				H.w_uniform.make_wet(1) //<= wet
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform()
			if(H.gloves && washgloves)
				H.gloves.make_wet(1) //<= wet
				if(H.gloves.clean_blood())
					H.update_inv_gloves()
			if(H.shoes && washshoes)
				H.shoes.make_wet(1) //<= wet
				if(H.shoes.clean_blood())
					H.update_inv_shoes()
			if(H.wear_mask && washmask)
				H.wear_mask.make_wet(1) //<= wet
				if(H.wear_mask.clean_blood())
					H.update_inv_wear_mask()
			if(H.glasses && washglasses)
				H.glasses.make_wet(1) //<= wet
				if(H.glasses.clean_blood())
					H.update_inv_glasses()
			if(H.l_ear && washears)
				if(H.l_ear.clean_blood())
					H.update_inv_ears()
			if(H.r_ear && washears)
				if(H.r_ear.clean_blood())
					H.update_inv_ears()
			if(H.belt)
				H.belt.make_wet(1) //<= wet
				if(H.belt.clean_blood())
					H.update_inv_belt()
			H.clean_blood(washshoes)
		else
			if(M.wear_mask)						//if the mob is not human, it cleans the mask without asking for bitflags
				if(M.wear_mask.clean_blood())
					M.update_inv_wear_mask()
			M.clean_blood()
	else
		O.clean_blood()

	if(isturf(loc))
		var/turf/tile = loc
		loc.clean_blood()
		for(var/obj/effect/E in tile)
			if((istype(E,/obj/effect/rune) || istype(E,/obj/effect/decal/cleanable) || istype(E,/obj/effect/overlay)) && !istype(E, /obj/effect/decal/cleanable/water))
				qdel(E)

/obj/machinery/shower/process()
	if(!on) return
	if(is_payed < 1)
		on = 0
		update_icon()
		return
	else
		is_payed--

	create_water(src)

	if(!mobpresent) return

	for(var/mob/living/carbon/C in loc)
		check_heat(C)

/obj/machinery/shower/proc/check_heat(mob/M)
	if(!on || watertemp == "normal") return
	if(iscarbon(M))
		var/mob/living/carbon/C = M

		if(watertemp == "freezing")
			C.bodytemperature = max(80, C.bodytemperature - 80)
			to_chat(C, "<span class='warning'>The water is freezing!</span>")
			return
		if(watertemp == "boiling")
			C.bodytemperature = min(500, C.bodytemperature + 35)
			C.adjustFireLoss(5)
			to_chat(C, "<span class='danger'>The water is searing!</span>")
			return



/obj/item/weapon/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"



/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = 1
	var/busy = 0 	//Something's being washed at the moment

/obj/structure/sink/attack_hand(mob/user)
	if (hasorgans(user))
		var/datum/organ/external/temp = user:organs_by_name["r_hand"]
		if (user.hand)
			temp = user:organs_by_name["l_hand"]
		if(temp && !temp.is_usable())
			to_chat(user, "<span class='notice'>You try to move your [temp.display_name], but cannot!")
			return

	if(isrobot(user) || isAI(user))
		return

	if(!Adjacent(user))
		return

	if(busy)
		to_chat(user, "\red Someone's already washing here.")
		return

	playsound(src, 'sound/items/wash.ogg', 50, 1, 1)

	to_chat(usr, "\blue You start washing your hands.")

	busy = 1
	sleep(40)
	busy = 0

	if(!Adjacent(user)) return		//Person has moved away from the sink

	user.clean_blood()
	if(ishuman(user))
		user:update_inv_gloves()
	for(var/mob/V in viewers(src, null))
		V.show_message("\blue [user] washes their hands using \the [src].")

/obj/structure/sink/attackby(obj/item/O, mob/user)
	if(busy)
		to_chat(user, "\red Someone's already washing here.")
		return

	if (istype(O, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RG = O
		RG.reagents.add_reagent("water", min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user.visible_message("\blue [user] fills \the [RG] using \the [src].","\blue You fill \the [RG] using \the [src].")
		return

	else if (istype(O, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = O
		if (B.charges > 0 && B.status == 1)
			flick("baton_active", src)
			user.Stun(10)
			user.stuttering = 10
			user.Weaken(10)
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.charge -= 20
			else
				B.charges--
			user.visible_message( \
				"[user] was stunned by his wet [O].", \
				"\red You have wet \the [O], it shocks you!")
			return

	var/turf/location = user.loc
	if(!isturf(location)) return

	var/obj/item/I = O
	if(!I || !istype(I,/obj/item)) return

	to_chat(usr, "\blue You start washing \the [I].")

	playsound(src, 'sound/items/wash.ogg', 50, 1, 1)
	busy = 1
	sleep(40)
	busy = 0

	if(user.loc != location) return				//User has moved
	if(!I) return 								//Item's been destroyed while washing
	if(user.get_active_hand() != I) return		//Person has switched hands or the item in their hands

	O.clean_blood()
	O.make_wet()
	user.visible_message( \
		"\blue [user] washes \a [I] using \the [src].", \
		"\blue You wash \a [I] using \the [src].")


/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"


/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	icon_state = "puddle"

/obj/structure/sink/puddle/attack_hand(mob/M)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/O, mob/user)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"
