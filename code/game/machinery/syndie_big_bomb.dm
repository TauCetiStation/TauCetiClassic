/obj/item/device/radio/beacon/syndicate_bomb
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	origin_tech = "bluespace=1;syndicate=7"

/obj/item/device/radio/beacon/syndicate_bomb/attack_self(mob/user)
	if(user)
		to_chat(user, "\blue Locked In")
		new /obj/machinery/syndicatebomb( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return

/obj/machinery/syndicatebomb
	icon = 'icons/obj/syndie_bomb_big.dmi'
	name = "syndicate bomb"
	icon_state = "syndicate-bomb-inactive"
	desc = "A large and menacing device. Can be bolted down with a wrench."

	anchored = 0
	density = 0
	layer = MOB_LAYER - 0.1 //so people can't hide it and it's REALLY OBVIOUS
	unacidable = 1

	var/datum/wires/syndicatebomb/wires = null
	var/timer = 60
	var/open_panel = 0 	//are the wires exposed?
	var/active = 0		//is the bomb counting down?
	var/defused = 0		//is the bomb capable of exploding?
	var/degutted = 0	//is the bomb even a bomb anymore?

/obj/machinery/syndicatebomb/process()
	if(active && !defused && (timer > 0)) 	//Tick Tock
		playsound(loc, 'sound/items/timer.ogg', 5, 0)
		timer--
	if(active && !defused && (timer <= 0))	//Boom
		active = 0
		timer = 60
		SSobj.processing.Remove(src)
		explosion(src.loc,2,5,11)
		qdel(src)
		return
	if(!active || defused)					//Counter terrorists win
		SSobj.processing.Remove(src)
		return

/obj/machinery/syndicatebomb/New()
	wires = new(src)
	..()

/obj/machinery/syndicatebomb/examine(mob/user)
	..()
	to_chat(user, "A digital display on it reads \"[timer]\".")

/obj/machinery/syndicatebomb/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/wrench))
		if(!anchored)
			if(!isturf(src.loc) || istype(src.loc, /turf/space))
				to_chat(user, "<span class='notice'>The bomb must be placed on solid ground to attach it</span>")
			else
				to_chat(user, "<span class='notice'>You firmly wrench the bomb to the floor</span>")
				playsound(loc, 'sound/items/ratchet.ogg', 50, 1)
				anchored = 1
				if(active)
					to_chat(user, "<span class='notice'>The bolts lock in place</span>")
		else
			if(!active)
				to_chat(user, "<span class='notice'>You wrench the bomb from the floor</span>")
				playsound(loc, 'sound/items/ratchet.ogg', 50, 1)
				anchored = 0
			else
				to_chat(user, "<span class='warning'>The bolts are locked down!</span>")

	else if(istype(I, /obj/item/weapon/screwdriver))
		open_panel = !open_panel
		if(!active)
			icon_state = "syndicate-bomb-inactive[open_panel ? "-wires" : ""]"
		else
			icon_state = "syndicate-bomb-active[open_panel ? "-wires" : ""]"
		to_chat(user, "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>")

	else if(istype(I, /obj/item/weapon/wirecutters) || istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/assembly/signaler ))
		if(degutted)
			to_chat(user, "<span class='notice'>The wires aren't connected to anything!<span>")
		else if(open_panel)
			wires.Interact(user)

	else if(istype(I, /obj/item/weapon/crowbar))
		if(open_panel && !degutted && isWireCut(WIRE_BOOM) && isWireCut(WIRE_UNBOLT) && isWireCut(WIRE_DELAY) && isWireCut(WIRE_PROCEED) && isWireCut(WIRE_ACTIVATE))
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
	if(degutted)
		to_chat(user, "<span class='notice'>The bomb's explosives have been removed, the [open_panel ? "wires" : "buttons"] are useless now.</span>")
	else if(anchored)
		if(open_panel)
			wires.Interact(user)
		else if(!active)
			settings()
		else
			to_chat(user, "<span class='notice'>The bomb is bolted to the floor!</span>")
	else if(!active)
		settings()

/obj/machinery/syndicatebomb/proc/settings(mob/user)
	var/newtime = input(usr, "Please set the timer.", "Timer", "[timer]") as num
	newtime = Clamp(newtime, 60, 60000)
	if(in_range(src, usr) && isliving(usr)) //No running off and setting bombs from across the station
		timer = newtime
		src.loc.visible_message("\blue [bicon(src)] timer set for [timer] seconds.")
	if(alert(usr,"Would you like to start the countdown now?",,"Yes","No") == "Yes" && in_range(src, usr) && isliving(usr))
		if(defused || active || degutted)
			if(degutted)
				src.loc.visible_message("\blue [bicon(src)] Device error: Payload missing")
			else if(defused)
				src.loc.visible_message("\blue [bicon(src)] Device error: User intervention required")
			return
		else
			src.loc.visible_message("\red [bicon(src)] [timer] seconds until detonation, please clear the area.")
			playsound(loc, 'sound/machines/click.ogg', 30, 1)
			if(!open_panel)
				icon_state = "syndicate-bomb-active"
			else
				icon_state = "syndicate-bomb-active-wires"
			active = 1
			add_fingerprint(user)

			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			message_admins("[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")
			SSobj.processing |= src //Ticking down

/obj/machinery/syndicatebomb/proc/isWireCut(index)
	return wires.IsIndexCut(index)

/obj/item/weapon/syndicatebombcore
	name = "bomb payload"
	desc = "A powerful secondary explosive of syndicate design and unknown composition, it should be stable under normal conditions..."
	icon = 'icons/obj/syndie_bomb_big.dmi'
	icon_state = "bombcore"
	item_state = "eshield0"
	w_class = 3.0
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
	w_class = 1.0
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
		playsound(user, 'sound/machines/click.ogg', 20, 1)
		to_chat(user, "<span class='notice'>[existant] found, [detonated] triggered.</span>")
		if(detonated)
			var/turf/T = get_turf(src)
			var/area/A = get_area(T)
			detonated--
			var/log_str = "[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has remotely detonated [detonated ? "syndicate bombs" : "a syndicate bomb"] using a [name] at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[A.name] (JMP)</a>."
			bombers += log_str
			message_admins(log_str)
			log_game("[key_name(usr)] has remotely detonated [detonated ? "syndicate bombs" : "a syndicate bomb"] using a [name] at [A.name]([T.x],[T.y],[T.z])")
		detonated =	0
		existant =	0
		cooldown = 1
		spawn(30) cooldown = 0
