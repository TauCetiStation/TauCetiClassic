/obj/item/device/radio/beacon/syndicate_bomb
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	origin_tech = "bluespace=1;syndicate=7"

/obj/item/device/radio/beacon/syndicate_bomb/attack_self(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In</span>")
		new /obj/machinery/syndicatebomb( user.loc )
		playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER)
		qdel(src)
	return

/obj/machinery/syndicatebomb
	icon = 'icons/obj/syndie_bomb_big.dmi'
	name = "syndicate bomb"
	icon_state = "syndicate-bomb-inactive"
	desc = "A large and menacing device. Can be bolted down with a wrench."

	anchored = FALSE
	density = FALSE
	layer = MOB_LAYER - 0.1 //so people can't hide it and it's REALLY OBVIOUS
	unacidable = TRUE
	use_power = NO_POWER_USE

	var/datum/wires/syndicatebomb/wires = null
	var/timer = 60
	var/open_panel = FALSE	//are the wires exposed?
	var/active = FALSE		//is the bomb counting down?
	var/defused = FALSE		//is the bomb capable of exploding?
	var/degutted = FALSE	//is the bomb even a bomb anymore?

/obj/machinery/syndicatebomb/process()
	if(active && !defused && (timer > 0)) 	//Tick Tock
		playsound(src, 'sound/items/timer.ogg', VOL_EFFECTS_MASTER, 5, FALSE)
		timer--
	if(active && !defused && (timer <= 0))	//Boom
		active = 0
		timer = 60
		STOP_PROCESSING(SSobj, src)
		explosion(src.loc,2,5,11)
		qdel(src)
		return
	if(!active || defused)					//Counter terrorists win
		STOP_PROCESSING(SSobj, src)
		return

/obj/machinery/syndicatebomb/atom_init()
	wires = new(src)
	. = ..()

/obj/machinery/syndicatebomb/examine(mob/user)
	..()
	to_chat(user, "A digital display on it reads \"[timer]\".")

/obj/machinery/syndicatebomb/attackby(obj/item/I, mob/user)
	if(iswrench(I))
		if(!anchored)
			if(!isturf(src.loc) || istype(src.loc, /turf/space))
				to_chat(user, "<span class='notice'>The bomb must be placed on solid ground to attach it</span>")
			else
				to_chat(user, "<span class='notice'>You firmly wrench the bomb to the floor</span>")
				anchored = TRUE
				if(active)
					to_chat(user, "<span class='notice'>The bolts lock in place</span>")
		else
			if(!active)
				to_chat(user, "<span class='notice'>You wrench the bomb from the floor</span>")
				anchored = FALSE
			else
				to_chat(user, "<span class='warning'>The bolts are locked down!</span>")

	else if(isscrewdriver(I))
		open_panel = !open_panel
		if(!active)
			icon_state = "syndicate-bomb-inactive[open_panel ? "-wires" : ""]"
		else
			icon_state = "syndicate-bomb-active[open_panel ? "-wires" : ""]"
		to_chat(user, "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>")

	else if(is_wire_tool(I) && open_panel)
		if(degutted)
			to_chat(user, "<span class='notice'>The wires aren't connected to anything!</span>")
		else
			wires.interact(user)

	else if(iscrowbar(I))
		if(open_panel && !degutted && isWireCut(SYNDIEBOMB_WIRE_BOOM) && isWireCut(SYNDIEBOMB_WIRE_UNBOLT) && isWireCut(SYNDIEBOMB_WIRE_DELAY) && isWireCut(SYNDIEBOMB_WIRE_PROCEED) && isWireCut(SYNDIEBOMB_WIRE_ACTIVATE))
			to_chat(user, "<span class='notice'>You carefully pry out the bomb's payload.</span>")
			degutted = 1
			new /obj/item/weapon/syndicatebombcore(user.loc)
		else if (open_panel)
			to_chat(user, "<span class='notice'>The wires conneting the shell to the explosives are holding it down!</span>")
		else if (degutted)
			to_chat(user, "<span class='notice'>The explosives have already been removed.</span>")
		else
			to_chat(user, "<span class='notice'>The cover is screwed on, it won't pry off!</span>")
	else if(istype(I, /obj/item/weapon/syndicatebombcore))
		if(degutted)
			to_chat(user, "<span class='notice'>You place the payload into the shell.</span>")
			degutted = 0
			user.drop_item()
			qdel(I)
		else
			to_chat(user, "<span class='notice'>While a double strength bomb would surely be a thing of terrible beauty, there's just no room for it.</span>")
	else
		..()

/obj/machinery/syndicatebomb/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(degutted)
		to_chat(user, "<span class='notice'>The bomb's explosives have been removed, the [open_panel ? "wires" : "buttons"] are useless now.</span>")
		return 1
	if(anchored)
		if(!active)
			settings(user)
		else
			to_chat(user, "<span class='notice'>The bomb is bolted to the floor!</span>")
			return 1
	else if(!active)
		settings(user)

/obj/machinery/syndicatebomb/proc/settings(mob/user)
	var/newtime = input(user, "Please set the timer.", "Timer", "[timer]") as num
	newtime = clamp(newtime, 60, 60000)
	if(in_range(src, user) && isliving(user) || isobserver(user)) //No running off and setting bombs from across the station
		timer = newtime
		src.loc.visible_message("<span class='notice'>[bicon(src)] timer set for [timer] seconds.</span>")
	if(tgui_alert(user, "Would you like to start the countdown now?",, list("Yes","No")) == "Yes" && in_range(src, user) && isliving(user))
		if(defused || active || degutted)
			if(degutted)
				src.loc.visible_message("<span class='notice'>[bicon(src)] Device error: Payload missing</span>")
			else if(defused)
				src.loc.visible_message("<span class='notice'>[bicon(src)] Device error: User intervention required</span>")
			return
		else
			src.loc.visible_message("<span class='warning'>[bicon(src)] [timer] seconds until detonation, please clear the area.</span>")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 30)
			if(!open_panel)
				icon_state = "syndicate-bomb-active"
			else
				icon_state = "syndicate-bomb-active-wires"
			active = 1
			add_fingerprint(user)

			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			message_admins("[key_name(user)]<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A> has primed a [name] for detonation at ([COORD(bombturf)] - [A.name]) [ADMIN_JMP(bombturf)].")
			log_game("[key_name(user)] has primed a [name] for detonation at [A.name][COORD(bombturf)]")
			START_PROCESSING(SSobj, src) //Ticking down

/obj/machinery/syndicatebomb/proc/isWireCut(index)
	return wires.is_index_cut(index)

/obj/item/weapon/syndicatebombcore
	name = "bomb payload"
	desc = "A powerful secondary explosive of syndicate design and unknown composition, it should be stable under normal conditions..."
	icon = 'icons/obj/syndie_bomb_big.dmi'
	icon_state = "bombcore"
	item_state = "eshield0"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "syndicate=6;combat=5"

/obj/item/weapon/syndicatebombcore/ex_act(severity) //Little boom can chain a big boom
	explosion(src.loc,2,5,11)
	qdel(src)

/obj/item/device/syndicatedetonator
	name = "big red button"
	desc = "Nothing good can come of pressing a button this garish..."
	icon = 'icons/obj/syndie_bomb_big.dmi'
	icon_state = "bigred"
	item_state = "electronic"
	w_class = ITEM_SIZE_TINY
	origin_tech = "syndicate=2"
	var/cooldown = 0
	var/detonated =	0
	var/existant =	0

/obj/item/device/syndicatedetonator/attack_self(mob/user)
	if(!cooldown)
		for(var/obj/machinery/syndicatebomb/B in machines)
			if(B.active)
				B.timer = 0
				detonated++
			existant++
		playsound(user, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 20)
		to_chat(user, "<span class='notice'>[existant] found, [detonated] triggered.</span>")
		if(detonated)
			var/turf/T = get_turf(src)
			var/area/A = get_area(T)
			detonated--
			var/log_str = "[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has remotely detonated [detonated ? "syndicate bombs" : "a syndicate bomb"] using a [name] at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[A.name] (JMP)</a>."
			bombers += log_str
			message_admins(log_str)
			log_game("[key_name(usr)] has remotely detonated [detonated ? "syndicate bombs" : "a syndicate bomb"] using a [name] at [A.name][COORD(T)]")
		detonated =	0
		existant =	0
		cooldown = 1
		spawn(30) cooldown = 0
