//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos

ADD_TO_GLOBAL_LIST(/obj/structure/toilet, toilet_list)
/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = FALSE
	anchored = TRUE
	var/lid_open = FALSE      //if the lid is up
	var/cistern_open = FALSE  //if the cistern bit is open
	var/w_items = 0           //the combined w_class of all the items in the cistern
	var/broken = FALSE
	var/mob/living/swirlie = null	//the mob being given a swirlie

/obj/structure/toilet/atom_init()
	. = ..()
	lid_open = round(rand(0, 1))
	update_icon()
	AddComponent(/datum/component/fishing, list(/obj/item/weapon/reagent_containers/food/snacks/badrecipe = 10, /mob/living/simple_animal/mouse = 3, /mob/living/simple_animal/mouse/rat = 2, /mob/living/simple_animal/hostile/giant_spider = 1), 10 SECONDS, rand(1, 3) , 20)

/obj/structure/toilet/attack_hand(mob/living/user)
	user.SetNextMove(CLICK_CD_MELEE * 1.5)
	if(swirlie)
		user.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie.name]'s head!</span>", "<span class='notice'>You slam the toilet seat onto [swirlie.name]'s head!</span>", "You hear reverberating porcelain.")
		swirlie.adjustBruteLoss(8)
		return

	if(cistern_open && !lid_open)
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

	if(lid_open && user.loc == loc)
		if(!COOLDOWN_FINISHED(user, wc_use_cooldown))
			to_chat(user, "<span class='notice'>You don't feel like you want to use it yet.</span>")
			return

		user.set_dir(dir)
		to_chat(user, "<span class='notice'>You start doing your business...</span>")
		playsound(src, SOUNDIN_RUSTLE, VOL_EFFECTS_MASTER, vol = 50)

		if(do_after(user, rand(5, 20) SECONDS, needhand = FALSE, target = src))
			COOLDOWN_START(user, wc_use_cooldown, 30 MINUTES)
			playsound(src, 'sound/effects/toilet_flush.ogg', VOL_EFFECTS_MASTER)

			var/problem_chance = 0.5

			if(HAS_TRAIT(user, TRAIT_FAT))
				problem_chance += 5
			if(HAS_TRAIT(user, TRAIT_CLUMSY)) // clowns are known space assholes
				problem_chance += 10

				if(SSholiday.holidays[APRIL_FOOLS])
					problem_chance += 25

			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "wc_used", /datum/mood_event/wc_used)

			if(prob(problem_chance))
				broken = TRUE
				START_PROCESSING(SSobj, src)
				user.playsound_local_timed(2 SECOND, turf_source = null, soundin = 'sound/misc/s_asshole_short.ogg', volume_channel = VOL_EFFECTS_MASTER, vol = 100, vary = FALSE, ignore_environment = TRUE)

				if(HAS_TRAIT(user, TRAIT_CLUMSY))
					SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "clown_evil", /datum/mood_event/clown_evil)
					to_chat(user, "<span class='notice bold'>Oh yes!</span>")
				else
					to_chat(user, "<span class='notice bold'>Oh no!</span>")
		return

	// default action
	lid_open = !lid_open
	playsound(src, 'sound/effects/click_off.ogg', VOL_EFFECTS_MASTER)
	update_icon()

/obj/structure/toilet/process()
	if(!broken)
		STOP_PROCESSING(SSobj, src)
		return

	spawn_fluid(loc, 20)

/obj/structure/toilet/update_icon()
	icon_state = "toilet[lid_open][cistern_open]"

/obj/structure/toilet/attackby(obj/item/I, mob/living/user)
	. = ..()
	if(.)
		return
	if(iswrenching(I) && broken) // we don't have any plunger around, so wrench is good
		to_chat(user, "<span class='notice'>You start fixing \the [src].</span>")
		if(I.use_tool(src, user, 60, volume = 100))
			broken = FALSE
			to_chat(user, "<span class='notice'>You fixed \the [src].</span>")
		return
	else if(isprying(I))
		if(user.is_busy()) return
		to_chat(user, "<span class='notice'>You start to [cistern_open ? "replace the lid on the cistern" : "lift the lid off the cistern"].</span>")
		playsound(src, 'sound/effects/stonedoor_openclose.ogg', VOL_EFFECTS_MASTER)
		if(I.use_tool(src, user, 30, volume = 0))
			user.visible_message("<span class='notice'>[user] [cistern_open ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!</span>", "<span class='notice'>You [cistern_open ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "You hear grinding porcelain.")
			cistern_open = !cistern_open
			update_icon()
			return

	else if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I

		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			user.SetNextMove(CLICK_CD_MELEE)

			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on the toilet.</span>")
					return
				if(lid_open && !swirlie)
					if(user.is_busy()) return
					user.visible_message("<span class='danger'>[user] starts to give [GM.name] a swirlie!</span>", "<span class='notice'>You start to give [GM.name] a swirlie!</span>")
					swirlie = GM
					if(do_after(user, 30, 5, 0, target = src))
						user.visible_message("<span class='danger'>[user] gives [GM.name] a swirlie!</span>", "<span class='notice'>You give [GM.name] a swirlie!</span>", "You hear a toilet flushing.")
						playsound(src, 'sound/effects/toilet_flush.ogg', VOL_EFFECTS_MASTER)
						if(!GM.internal)
							GM.adjustOxyLoss(5)
					swirlie = null
				else
					user.visible_message("<span class='danger'>[user] slams [GM.name] into the [src]!</span>", "<span class='notice'>You slam [GM.name] into the [src]!</span>")
					GM.adjustBruteLoss(8)
			else
				to_chat(user, "<span class='notice'>You need a tighter grip.</span>")

	if(cistern_open)
		if(I.w_class > SIZE_SMALL)
			to_chat(user, "<span class='notice'>\The [I] does not fit.</span>")
			return
		if(w_items + I.w_class > SIZE_BIG)
			to_chat(user, "<span class='notice'>The cistern is full.</span>")
			return
		user.drop_from_inventory(I, src)
		w_items += I.w_class
		user.SetNextMove(CLICK_CD_INTERACT)
		add_fingerprint(user)
		to_chat(user, "You carefully place \the [I] into the cistern.")
		return

/obj/structure/toilet/deconstruct()
	for(var/obj/toilet_item as anything in contents)
		toilet_item.forceMove(loc)
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/metal(loc, 1)
	..()

/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = FALSE
	anchored = TRUE

/obj/structure/urinal/attack_hand(mob/living/user)
	if(user.loc == loc) // no gender discrimination here!
		if(!COOLDOWN_FINISHED(user, wc_use_cooldown))
			to_chat(user, "<span class='notice'>You don't feel like you want to use it yet.</span>")
			return

		user.set_dir(turn(dir, 180))
		to_chat(user, "<span class='notice'>You start doing your business...</span>")
		playsound(src, SOUNDIN_RUSTLE, VOL_EFFECTS_MASTER, vol = 50)

		if(do_after(user, rand(5, 10) SECONDS, needhand = TRUE, target = src))
			COOLDOWN_START(user, wc_use_cooldown, 30 MINUTES)
			playsound(src, 'sound/effects/toilet_flush.ogg', VOL_EFFECTS_MASTER, vol = 50)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "wc_used", /datum/mood_event/wc_used)

/obj/structure/urinal/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(isliving(G.affecting))
			user.SetNextMove(CLICK_CD_MELEE)
			var/mob/living/GM = G.affecting
			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on the urinal.</span>")
					return
				user.visible_message("<span class='danger'>[user] slams [GM.name] into the [src]!</span>", "<span class='notice'>You slam [GM.name] into the [src]!</span>")
				GM.adjustBruteLoss(8)
			else
				to_chat(user, "<span class='notice'>You need a tighter grip.</span>")
	else
		..()

/obj/structure/dryer
	name = "hand dryer"
	desc = "The Breath Of Lizads-3000, an experimental dryer."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dryer"
	density = FALSE
	anchored = TRUE
	var/busy = FALSE
	var/emagged = FALSE

/obj/structure/dryer/attack_hand(mob/user)

	if(isrobot(user) || isAI(user))
		return

	if(!Adjacent(user))
		return

	if(user.is_busy())
		return

	if(busy)
		to_chat(user, "<span class='warning'>Someone's already drying here.</span>")
		return
	user.SetNextMove(CLICK_CD_INTERACT)
	to_chat(user, "<span class='notice'>You start drying your hands.</span>")
	playsound(src, 'sound/items/drying.ogg', VOL_EFFECTS_MASTER)
	add_fingerprint(user)
	busy = TRUE
	if(do_after(user, 40, target = src))
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
		busy = FALSE
		user.visible_message("<span class='notice'>[user] dried their hands using \the [src].</span>")
		if(HAS_TRAIT_FROM(user, TRAIT_WET_HANDS, QUALITY_TRAIT))
			var/mob/living/carbon/human/H = user
			var/time_amount = rand(3000, 6000)
			H.apply_status_effect(STATUS_EFFECT_REMOVE_WET, time_amount)
	else
		busy = FALSE

/obj/structure/dryer/attackby(obj/item/O, mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)

	if(user.is_busy())
		return

	if((istype(O, /obj/item/weapon/grab)) && !emagged)
		var/obj/item/weapon/grab/G = O
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			user.SetNextMove(CLICK_CD_MELEE)
			if(G.state>1)
				if(!GM.loc == get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on the urinal.</span>")
					return
				user.visible_message("<span class='danger'>[user] slams [GM.name] into the [src]!</span>", "<span class='notice'>You slam [GM.name] into the [src]!</span>")
				GM.apply_damage(8, BRUTE, BP_HEAD)
				playsound(src, 'sound/weapons/smash.ogg', VOL_EFFECTS_MASTER)
				return
			else
				to_chat(user, "<span class='notice'>You need a tighter grip.</span>")
				return

	if(busy)
		to_chat(user, "<span class='warning'>Someone's already drying here.</span>")
		return

	var/turf/location = user.loc
	if(!isturf(location))
		return

	var/obj/item/I = O
	if(!I || !isitem(I))
		return

	add_fingerprint(user)

	if(emagged)		//Let's make it a little bit dangerous

		if(istype(O, /obj/item/weapon/grab))	//Holding someone under dryer
			var/obj/item/weapon/grab/G = O
			user.SetNextMove(CLICK_CD_MELEE)
			if(isliving(G.affecting))
				var/mob/living/GM = G.affecting
				if(G.state>2)
					if(!GM.loc == get_turf(src))
						to_chat(user, "<span class='notice'>[GM.name] needs to be near the dryer.</span>")
						return
					busy = TRUE
					user.visible_message("<span class='danger'>[user] hold [GM.name] under the [src]!</span>", "<span class='notice'>You hold [GM.name] under the [src]!</span>")
					playsound(src, 'sound/items/drying.ogg', VOL_EFFECTS_MASTER)
					GM.adjustFireLoss(10)
					if(do_after(user, 40, target = src))
						busy = FALSE
						if(!Adjacent(user) || !Adjacent(GM))
							return		//User or target has moved
						GM.adjustFireLoss(25)
						user.visible_message("<span class='danger'>[GM.name] skins are burning under the [src]!</span>")
						return
					else
						busy = FALSE
				else
					to_chat(user, "<span class='notice'>You need a tighter grip.</span>")
					return

		busy = TRUE
		to_chat(usr, "<span class='notice'>You start drying \the [I].</span>")
		playsound(src, 'sound/items/drying.ogg', VOL_EFFECTS_MASTER)
		if(do_after(user, 40, target = src))
			var/mob/living/carbon/C = user
			C.apply_damage(25, BURN, C.hand ? BP_L_ARM : BP_R_ARM)
			to_chat(C, "<span class='danger'>The dryer is burning!</span>")
			new /obj/effect/decal/cleanable/ash(C.loc)
			qdel(O)
			busy = FALSE
			return
		else
			busy = FALSE

	busy = TRUE
	to_chat(usr, "<span class='notice'>You start drying \the [I].</span>")
	playsound(src, 'sound/items/drying.ogg', VOL_EFFECTS_MASTER)
	if(do_after(user, 40, target = src))
		busy = FALSE

		if(user.loc != location)
			return //User has moved
		if(!I)
			return //Item's been destroyed while drying
		if(user.get_active_hand() != I)
			return //Person has switched hands or the item in their hands

		O.wet = 0
		user.visible_message( \
			"<span class='notice'>[user] drying \a [I] using \the [src].</span>", \
			"<span class='notice'>You dry \a [I] using \the [src].</span>")
	else
		busy = FALSE

/obj/structure/dryer/emag_act(mob/user)
	if(emagged)
		to_chat(user, "<span class='warning'>[src] is already cracked.</span>")
		return FALSE
	add_fingerprint(user)
	emagged = TRUE
	flick("dryer-broken",src)
	playsound(src, 'sound/effects/sparks3.ogg', VOL_EFFECTS_MASTER)
	icon_state = "dryer-emag"
	to_chat(user, "<span class='warning'>You swipe near card and crack it to be hot.</span>")
	return TRUE

/obj/machinery/shower
	name = "shower"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	anchored = TRUE
	use_power = NO_POWER_USE
	layer = MOB_LAYER + 1.1
	var/on = FALSE
	var/obj/effect/mist/mymist = null
	var/ismist = FALSE				//needs a var so we can make it linger~
	var/watertemp = "normal"	//freezing, normal, or boiling
	var/mobpresent = 0		//true if there is a mob on the shower's loc, this is to ease process()
	var/payed_time = 0
	var/cost_per_activation = 10

/obj/machinery/shower/atom_init()
  	. = ..()
  	desc = "The HS-451. Installed in the [round(global.gamestory_start_year, 10)]s by the Nanotrasen Hygiene Division."

//add heat controls? when emagged, you can freeze to death in it?

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = MOB_LAYER + 1
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/machinery/shower/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_RAPID)
	if(is_paid())
		on = !on
		update_icon()
		if(on)
			if(user.loc == loc)
				wash(user)
				check_heat(user)
			for(var/atom/movable/G in loc)
				G.clean_blood()
		else
			payed_time = 0 // If the player closes ahead of time - force cancel the fee
	else
		to_chat(user, "You didn't pay for that. Swipe a card against [src].")

/obj/machinery/shower/proc/is_paid()
	if(payed_time)
		return TRUE
	return FALSE

/obj/machinery/shower/attackby(obj/item/I, mob/user)
	if(I.type == /obj/item/device/analyzer) // istype?
		to_chat(user, "<span class='notice'>The water temperature seems to be [watertemp].</span>")
	else if(iswrenching(I))
		if(user.is_busy()) return
		to_chat(user, "<span class='notice'>You begin to adjust the temperature valve with \the [I].</span>")
		if(I.use_tool(src, user, 50, volume = 100))
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
		user.SetNextMove(CLICK_CD_INTERACT)
		if(!payed_time && cost_per_activation)
			if(!on)
				var/obj/item/weapon/card/C = I
				visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
				if(station_account)
					var/datum/money_account/D = attempt_account_access_with_user_input(C.associated_account_number, ACCOUNT_SECURITY_LEVEL_MAXIMUM, user)
					if(user.incapacitated() || !Adjacent(user))
						return
					if(D)
						var/transaction_amount = cost_per_activation
						if(transaction_amount <= D.money)
							//transfer the money
							D.adjust_money(-transaction_amount)
							station_account.adjust_money(transaction_amount)

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

							payed_time = 60
							to_chat(usr, "[bicon(src)]<span class='notice'>Thank you, happy washing time and don't turn me off accidently or i will take your precious credits again! Teehee.</span>")
						else
							to_chat(usr, "[bicon(src)]<span class='warning'>You don't have that much money!</span>")
		else
			to_chat(usr, "[bicon(src)]<span class='notice'>Is payed, you may turn it on now.</span>")

/obj/machinery/shower/deconstruct(disassembled)
	new /obj/item/stack/sheet/metal(loc, 2)
	..()

/obj/machinery/shower/update_icon()	//this is terribly unreadable, but basically it makes the shower mist up
	cut_overlays()					//once it's been on for a while, in addition to handling the water overlay.
	if(mymist)
		qdel(mymist)
	if(on)
		add_overlay(image('icons/obj/watercloset.dmi', src, "water", MOB_LAYER + 1, dir))
		if(watertemp == "freezing")
			return
		if(!ismist)
			if(on)
				addtimer(CALLBACK(src, PROC_REF(create_mist)), 50)
		else
			create_mist()
	else if(ismist)
		create_mist()
		addtimer(CALLBACK(src, PROC_REF(del_mist)), 250)
		if(!on)
			del_mist()

/obj/machinery/shower/proc/create_mist()
	ismist = TRUE
	mymist = new /obj/effect/mist(loc)

/obj/machinery/shower/proc/del_mist()
	ismist = FALSE
	if(mymist)
		qdel(mymist)

/obj/machinery/shower/Crossed(atom/movable/AM)
	. = ..()
	wash(AM)
	if(ismob(AM))
		mobpresent += 1
		check_heat(AM)

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
			M.back.clean_blood()
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
				H.head.clean_blood()
			if(H.wear_suit)
				H.wear_suit.make_wet(1) //<= wet
				H.wear_suit.clean_blood()
			else if(H.w_uniform)
				H.w_uniform.make_wet(1) //<= wet
				H.w_uniform.clean_blood()
			if(H.gloves && washgloves)
				H.gloves.make_wet(1) //<= wet
				H.gloves.clean_blood()
			if(H.shoes && washshoes)
				H.shoes.make_wet(1) //<= wet
				H.shoes.clean_blood()
			else
				var/obj/item/organ/external/l_foot = H.bodyparts_by_name[BP_L_LEG]
				var/obj/item/organ/external/r_foot = H.bodyparts_by_name[BP_R_LEG]
				var/no_legs = FALSE
				if((!l_foot || (l_foot && (l_foot.is_stump))) && (!r_foot || (r_foot && (r_foot.is_stump))))
					no_legs = TRUE
				if(!no_legs)
					H.feet_blood_DNA = null
					H.feet_dirt_color = null
					H.update_inv_slot(SLOT_SHOES)
			if(H.wear_mask && washmask)
				H.wear_mask.make_wet(1) //<= wet
				H.wear_mask.clean_blood()
			if(H.glasses && washglasses)
				H.glasses.make_wet(1) //<= wet
				H.glasses.clean_blood()
			if(H.l_ear && washears)
				H.l_ear.clean_blood()
			if(H.r_ear && washears)
				H.r_ear.clean_blood()
			if(H.belt)
				H.belt.make_wet(1) //<= wet
				H.belt.clean_blood()
			H.clean_blood()
		else
			if(M.wear_mask)						//if the mob is not human, it cleans the mask without asking for bitflags
				M.wear_mask.clean_blood()
			M.clean_blood()
	else
		O.clean_blood()

	if(isturf(loc))
		var/turf/tile = loc
		loc.clean_blood()
		for(var/obj/effect/E in tile)
			if((istype(E,/obj/effect/rune) || istype(E,/obj/effect/decal/cleanable) || istype(E,/obj/effect/overlay)) && !istype(E, /obj/effect/fluid))
				qdel(E)

/obj/machinery/shower/process()
	if(!on) return
	if(payed_time < 1)
		on = 0
		update_icon()
		return
	else
		payed_time--

	spawn_fluid(loc, 15)

	if(!mobpresent) return

	for(var/mob/living/carbon/C in loc)
		check_heat(C)

/obj/machinery/shower/proc/check_heat(mob/M)
	if(!on) return
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		switch(watertemp)
			if("normal")
				C.adjustHalLoss(-1)
				C.AdjustStunned(-1)
				C.AdjustWeakened(-1)
				SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "shower-time", /datum/mood_event/shower)
				return
			if("freezing")
				C.adjust_bodytemperature(-80, min_temp = 80)
				C.adjustHalLoss(1)
				C.AdjustStunned(-1)
				C.AdjustWeakened(1)
				to_chat(C, "<span class='warning'>The water is freezing!</span>")
				return
			if("boiling")
				C.adjust_bodytemperature(35, max_temp = 500)
				C.adjustFireLoss(5)
				C.adjustHalLoss(1)
				C.AdjustStunned(-1)
				C.AdjustWeakened(1)
				to_chat(C, "<span class='danger'>The water is searing!</span>")
				return

/obj/machinery/shower/free/is_paid()
	if(!payed_time)
		payed_time = 60
	return TRUE

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
	anchored = TRUE
	var/busy = FALSE 	//Something's being washed at the moment

/obj/structure/sink/attack_hand(mob/user)
	if(isrobot(user) || isAI(user))
		return

	if(!Adjacent(user))
		return

	if(user.is_busy())
		return
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here.</span>")
		return
	user.SetNextMove(CLICK_CD_INTERACT)
	playsound(src, 'sound/items/wash.ogg', VOL_EFFECTS_MASTER)
	to_chat(user, "<span class='notice'>You start washing your hands.</span>")
	busy = TRUE
	if(do_after(user, 30, target = src))
		busy = FALSE
		user.clean_blood()
		user.visible_message("<span class='notice'>[user] washes their hands using \the [src].</span>")
		if(HAS_TRAIT_FROM(user, TRAIT_GREASY_FINGERS, QUALITY_TRAIT))
			var/mob/living/carbon/human/H = user
			var/time_amount = rand(3000, 6000)
			H.apply_status_effect(STATUS_EFFECT_REMOVE_GREASY, time_amount)
	else
		busy = FALSE

/obj/structure/sink/attackby(obj/item/O, mob/user)
	. = ..()
	if(.)
		return
	if(user.is_busy())
		return
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here.</span>")
		return
	user.SetNextMove(CLICK_CD_INTERACT)

	if (istype(O, /obj/item/weapon/reagent_containers) && O.is_open_container())
		var/obj/item/weapon/reagent_containers/RG = O
		RG.reagents.add_reagent("water", min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		user.visible_message("<span class='notice'>[user] fills \the [RG] using \the [src].</span>","<span class='notice'>You fill \the [RG] using \the [src].</span>")
		return

	else if (istype(O, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = O
		if (B.charges > 0 && B.status == 1)
			flick("baton_active", src)
			user.Stun(10)
			user.setStuttering(10)
			user.Weaken(10)
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.charge -= 20
			else
				B.charges--
			user.visible_message( \
				"<span class='warning'>[user] was stunned by his wet [O].</span>", \
				"<span class='warning'>You have wet \the [O], it shocks you!</span>")
			return

	var/turf/location = user.loc
	if(!isturf(location))
		return

	var/obj/item/I = O
	if(!I || !isitem(I))
		return

	to_chat(usr, "<span class='notice'>You start washing \the [I].</span>")

	playsound(src, 'sound/items/wash.ogg', VOL_EFFECTS_MASTER)
	busy = TRUE
	if(do_after(user, 30, target = src))
		busy = FALSE

		if(user.loc != location)
			return //User has moved
		if(!I)
			return //Item's been destroyed while washing
		if(user.get_active_hand() != I)
			return //Person has switched hands or the item in their hands

		O.clean_blood()
		O.make_wet()
		user.visible_message( \
			"<span class='notice'>[user] washes \a [I] using \the [src].</span>", \
			"<span class='notice'>You wash \a [I] using \the [src].</span>")
	else
		busy = FALSE

/obj/structure/sink/deconstruct()
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/metal(loc, 1)
	..()

/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"


/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	desc = "The puddle looks infinitely deep and infinitely lonely on the space station."
	icon_state = "puddle"

/obj/structure/sink/puddle/atom_init()
	. = ..()
	AddComponent(/datum/component/fishing, list(/obj/item/fish_carp = 10, /obj/item/fish_carp/mega = 2), 10 SECONDS, rand(1, 30) , 20)

/obj/structure/sink/puddle/attack_hand(mob/M)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/O, mob/user)
	. = ..()
	icon_state = "puddle-splash"
	icon_state = "puddle"
