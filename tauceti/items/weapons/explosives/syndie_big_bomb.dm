/obj/item/device/radio/beacon/syndicate_bomb
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	origin_tech = "bluespace=1;syndicate=7"

/obj/item/device/radio/beacon/syndicate_bomb/attack_self(mob/user as mob)
	if(user)
		user << "\blue Locked In"
		new /obj/machinery/syndicatebomb( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		del(src)
	return

/obj/machinery/syndicatebomb
	icon = 'tauceti/items/weapons/explosives/syndie_bomb_big.dmi'
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
		playsound(loc, 'tauceti/sounds/items/timer.ogg', 5, 0)
		timer--
	if(active && !defused && (timer <= 0))	//Boom
		active = 0
		timer = 60
		processing_objects.Remove(src)
		explosion(src.loc,2,5,11)
		del(src)
		return
	if(!active || defused)					//Counter terrorists win
		processing_objects.Remove(src)
		return

/obj/machinery/syndicatebomb/New()
	wires = new(src)
	..()

/obj/machinery/syndicatebomb/examine()
	..()
	usr << "A digital display on it reads \"[timer]\"."

/obj/machinery/syndicatebomb/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/weapon/wrench))
		if(!anchored)
			if(!isturf(src.loc) || istype(src.loc, /turf/space))
				user << "<span class='notice'>The bomb must be placed on solid ground to attach it</span>"
			else
				user << "<span class='notice'>You firmly wrench the bomb to the floor</span>"
				playsound(loc, 'sound/items/ratchet.ogg', 50, 1)
				anchored = 1
				if(active)
					user << "<span class='notice'>The bolts lock in place</span>"
		else
			if(!active)
				user << "<span class='notice'>You wrench the bomb from the floor</span>"
				playsound(loc, 'sound/items/ratchet.ogg', 50, 1)
				anchored = 0
			else
				user << "<span class='warning'>The bolts are locked down!</span>"

	else if(istype(I, /obj/item/weapon/screwdriver))
		open_panel = !open_panel
		if(!active)
			icon_state = "syndicate-bomb-inactive[open_panel ? "-wires" : ""]"
		else
			icon_state = "syndicate-bomb-active[open_panel ? "-wires" : ""]"
		user << "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>"

	else if(istype(I, /obj/item/weapon/wirecutters) || istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/assembly/signaler ))
		if(degutted)
			user << "<span class='notice'>The wires aren't connected to anything!<span>"
		else if(open_panel)
			wires.Interact(user)

	else if(istype(I, /obj/item/weapon/crowbar))
		if(open_panel && !degutted && isWireCut(WIRE_BOOM) && isWireCut(WIRE_UNBOLT) && isWireCut(WIRE_DELAY) && isWireCut(WIRE_PROCEED) && isWireCut(WIRE_ACTIVATE))
			user << "<span class='notice'>You carefully pry out the bomb's payload.</span>"
			degutted = 1
			new /obj/item/weapon/syndicatebombcore(user.loc)
		else if (open_panel)
			user << "<span class='notice'>The wires conneting the shell to the explosives are holding it down!</span>"
		else if (degutted)
			user << "<span class='notice'>The explosives have already been removed.</span>"
		else
			user << "<span class='notice'>The cover is screwed on, it won't pry off!</span>"
	else if(istype(I, /obj/item/weapon/syndicatebombcore))
		if(degutted)
			user << "<span class='notice'>You place the payload into the shell.</span>"
			degutted = 0
			user.drop_item()
			del(I)
		else
			user << "<span class='notice'>While a double strength bomb would surely be a thing of terrible beauty, there's just no room for it.</span>"
	else
		..()

/obj/machinery/syndicatebomb/attack_hand(var/mob/user)
	if(degutted)
		user << "<span class='notice'>The bomb's explosives have been removed, the [open_panel ? "wires" : "buttons"] are useless now.</span>"
	else if(anchored)
		if(open_panel)
			wires.Interact(user)
		else if(!active)
			settings()
		else
			user << "<span class='notice'>The bomb is bolted to the floor!</span>"
	else if(!active)
		settings()

/obj/machinery/syndicatebomb/proc/settings(var/mob/user)
	var/newtime = input(usr, "Please set the timer.", "Timer", "[timer]") as num
	newtime = Clamp(newtime, 60, 60000)
	if(in_range(src, usr) && isliving(usr)) //No running off and setting bombs from across the station
		timer = newtime
		src.loc.visible_message("\blue \icon[src] timer set for [timer] seconds.")
	if(alert(usr,"Would you like to start the countdown now?",,"Yes","No") == "Yes" && in_range(src, usr) && isliving(usr))
		if(defused || active || degutted)
			if(degutted)
				src.loc.visible_message("\blue \icon[src] Device error: Payload missing")
			else if(defused)
				src.loc.visible_message("\blue \icon[src] Device error: User intervention required")
			return
		else
			src.loc.visible_message("\red \icon[src] [timer] seconds until detonation, please clear the area.")
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
			processing_objects.Add(src) //Ticking down

/obj/machinery/syndicatebomb/proc/isWireCut(var/index)
	return wires.IsIndexCut(index)

/obj/item/weapon/syndicatebombcore
	name = "bomb payload"
	desc = "A powerful secondary explosive of syndicate design and unknown composition, it should be stable under normal conditions..."
	icon = 'tauceti/items/weapons/explosives/syndie_bomb_big.dmi'
	icon_state = "bombcore"
	item_state = "eshield0"
	w_class = 3.0
	origin_tech = "syndicate=6;combat=5"

/obj/item/weapon/syndicatebombcore/ex_act(severity) //Little boom can chain a big boom
	explosion(src.loc,2,5,11)
	del(src)

/obj/item/device/syndicatedetonator
	name = "big red button"
	desc = "Nothing good can come of pressing a button this garish..."
	icon = 'tauceti/items/weapons/explosives/syndie_bomb_big.dmi'
	icon_state = "bigred"
	item_state = "electronic"
	w_class = 1.0
	origin_tech = "syndicate=2"
	var/cooldown = 0
	var/detonated =	0
	var/existant =	0

/obj/item/device/syndicatedetonator/attack_self(mob/user as mob)
	if(!cooldown)
		for(var/obj/machinery/syndicatebomb/B in machines)
			if(B.active)
				B.timer = 0
				detonated++
			existant++
		playsound(user, 'sound/machines/click.ogg', 20, 1)
		user << "<span class='notice'>[existant] found, [detonated] triggered.</span>"
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

/*
//Datum
/datum/wires/syndicatebomb
	random = 1
	holder_type = /obj/machinery/syndicatebomb
	wire_count = 5

var/const/WIRE_BOOM = 1			// Explodes if pulsed or cut while active, defuses a bomb that isn't active on cut
var/const/WIRE_UNBOLT = 2		// Unbolts the bomb if cut, hint on pulsed
var/const/WIRE_DELAY = 4		// Raises the timer on pulse, does nothing on cut
var/const/WIRE_PROCEED = 8		// Lowers the timer, explodes if cut while the bomb is active
var/const/WIRE_ACTIVATE = 16	// Will start a bombs timer if pulsed, will hint if pulsed while already active, will stop a timer a bomb on cut

/datum/wires/syndicatebomb/UpdatePulsed(var/index)
	var/obj/machinery/syndicatebomb/P = holder
	if(P.degutted)
		return
	switch(index)
		if(WIRE_BOOM)
			if (P.active)
				P.loc.visible_message("\red \icon[holder] An alarm sounds! It's go-")
				P.timer = 0
		if(WIRE_UNBOLT)
			P.loc.visible_message("\blue \icon[holder] The bolts spin in place for a moment.")
		if(WIRE_DELAY)
			playsound(P.loc, 'sound/machines/chime.ogg', 30, 1)
			P.loc.visible_message("\blue \icon[holder] The bomb chirps.")
			P.timer += 10
		if(WIRE_PROCEED)
			playsound(P.loc, 'sound/machines/buzz-sigh.ogg', 30, 1)
			P.loc.visible_message("\red \icon[holder] The bomb buzzes ominously!")
			if (P.timer >= 61) //Long fuse bombs can suddenly become more dangerous if you tinker with them
				P.timer = 60
			if (P.timer >= 21)
				P.timer -= 10
			else if (P.timer >= 11) //both to prevent negative timers and to have a little mercy
				P.timer = 10
		if(WIRE_ACTIVATE)
			if(!P.active && !P.defused)
				playsound(P.loc, 'sound/machines/click.ogg', 30, 1)
				P.loc.visible_message("\red \icon[holder] You hear the bomb start ticking!")
				P.active = 1
				if(!P.open_panel) //Needs to exist in case the wire is pulsed with a signaler while the panel is closed
					P.icon_state = "syndicate-bomb-active"
				else
					P.icon_state = "syndicate-bomb-active-wires"
				processing_objects.Add(P)
			else
				P.loc.visible_message("\blue \icon[holder] The bomb seems to hesitate for a moment.")
				P.timer += 5

/datum/wires/syndicatebomb/UpdateCut(var/index, var/mended)
	var/obj/machinery/syndicatebomb/P = holder
	if(P.degutted)
		return
	switch(index)
		if(WIRE_EXPLODE)
			if(!mended)
				if(P.active)
					P.loc.visible_message("\red \icon[holder] An alarm sounds! It's go-")
					P.timer = 0
				else
					P.defused = 1
			if(mended)
				P.defused = 0 //cutting and mending all the wires of an inactive bomb will thus cure any sabotage
		if(WIRE_UNBOLT)
			if (!mended && P.anchored)
				playsound(P.loc, 'sound/effects/stealthoff.ogg', 30, 1)
				P.loc.visible_message("\blue \icon[holder] The bolts lift out of the ground!")
				P.anchored = 0
		if(WIRE_PROCEED)
			if(!mended && P.active)
				P.loc.visible_message("\red \icon[holder] An alarm sounds! It's go-")
				P.timer = 0
		if(WIRE_ACTIVATE)
			if (!mended && P.active)
				P.loc.visible_message("\blue \icon[holder] The timer stops! The bomb has been defused!")
				P.icon_state = "syndicate-bomb-inactive-wires" //no cutting possible with the panel closed
				P.active = 0
				P.defused = 1
*/