// Holographic Items!

/turf/simulated/floor/holofloor
	thermal_conductivity = 0

/turf/simulated/floor/holofloor/grass
	name = "Lush Grass"
	icon_state = "grass1"
	floor_type = /obj/item/stack/tile/grass

/turf/simulated/floor/holofloor/grass/atom_init()
	icon_state = "grass[pick("1","2","3","4")]"
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/simulated/floor/holofloor/grass/atom_init_late()
	update_icon()
	for(var/direction in cardinal)
		if(istype(get_step(src,direction),/turf/simulated/floor))
			var/turf/simulated/floor/FF = get_step(src,direction)
			FF.update_icon() //so siding get updated properly

/turf/simulated/floor/holofloor/update_icon()
	if(icon_state in icons_to_ignore_at_floor_init)
		return
	else
		..()

/turf/simulated/floor/holofloor/space
	icon = 'icons/turf/space.dmi'
	name = "space"
	icon_state = "0"

/turf/simulated/floor/holofloor/space/atom_init()
	. = ..()
	icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"

/turf/simulated/floor/holofloor/desert
	name = "desert sand"
	desc = "Uncomfortably gritty for a hologram."
	icon_state = "asteroid"

/turf/simulated/floor/holofloor/desert/atom_init()
	. = ..()
	if(prob(10))
		add_overlay("asteroid[rand(0,9)]")

/turf/simulated/floor/holofloor/attackby(obj/item/weapon/W, mob/user)
	return
	// HOLOFLOOR DOES NOT GIVE A FUCK

/obj/structure/table/holotable
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	density = 1
	anchored = 1.0
	layer = 2.8
	throwpass = 1	//You can throw objects over this, despite it's density.

/obj/structure/table/holotable/attack_hand(mob/user)
	return // HOLOTABLE DOES NOT GIVE A FUCK

/obj/structure/table/holotable/attack_tools(obj/item/I, mob/user)
	return

/obj/structure/table/holotable/wooden
	name = "table"
	desc = "A square piece of wood standing on four wooden legs. It can not move."
	icon = 'icons/obj/smooth_structures/wooden_table.dmi'

/obj/structure/holostool
	name = "stool"
	desc = "Apply butt."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	anchored = 1.0


/obj/item/clothing/gloves/boxing/hologlove
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	item_state = "boxing"

/obj/structure/window/reinforced/holowindow/attackby(obj/item/W, mob/user)
	if(!istype(W)) return//I really wish I did not need this
	user.SetNextMove(CLICK_CD_MELEE)
	if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(istype(G.affecting,/mob/living))
			var/mob/living/M = G.affecting
			var/state = G.state
			qdel(W)	//gotta delete it here because if window breaks, it won't get deleted
			switch (state)
				if(1)
					M.visible_message("<span class='warning'>[user] slams [M] against \the [src]!</span>")
					M.apply_damage(7)
					take_damage(10)
				if(2)
					M.visible_message("<span class='danger'>[user] bashes [M] against \the [src]!</span>")
					if (prob(50))
						M.Weaken(1)
					M.apply_damage(10)
					take_damage(25)
				if(3)
					M.visible_message("<span class='danger'><big>[user] crushes [M] against \the [src]!</big></span>")
					M.Weaken(5)
					M.apply_damage(20)
					take_damage(50)
			return

	if(W.flags & NOBLUDGEON) return

	if(isscrewdriver(W))
		to_chat(user, ("<span class='notice'>It's a holowindow, you can't unfasten it!</span>"))
	else if(iscrowbar(W) && reinf && state <= 1)
		to_chat(user, ("<span class='notice'>It's a holowindow, you can't pry it!</span>"))
	else if(iswrench(W) && !anchored && (!state || !reinf))
		to_chat(user, ("<span class='notice'>It's a holowindow, you can't dismantle it!</span>"))
	else if(user.a_intent == INTENT_HARM)
		if(W.damtype == BRUTE || W.damtype == BURN)
			take_damage(W.force)
			if(health <= 7)
				anchored = 0
				update_nearby_icons()
				step(src, get_dir(user, src))
		else
			playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
		return ..()

/obj/structure/window/reinforced/holowindow/shatter(display_message = 1)
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	if(display_message)
		visible_message("[src] fades away as it shatters!")
	qdel(src)
	return

/obj/structure/window/reinforced/holowindow/disappearing

/obj/machinery/door/window/holowindoor/attackby(obj/item/weapon/I, mob/user)

	if (src.operating == 1)
		return
	user.SetNextMove(CLICK_CD_MELEE)
	if(src.density && istype(I, /obj/item/weapon) && !istype(I, /obj/item/weapon/card))
		var/aforce = I.force
		playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)

		visible_message("<span class='warning'><B>[src] was hit by [I].</B></span>")
		if(I.damtype == BRUTE || I.damtype == BURN)
			take_damage(aforce)
		return

	src.add_fingerprint(user)
	if (!src.requiresID())
		user = null

	if (src.allowed(user))
		if (src.density)
			open()
		else
			close()

	else if (src.density)
		flick(text("[]deny", src.base_state), src)

	return

/obj/machinery/door/window/holowindoor/shatter(display_message = 1)
	src.density = 0
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	if(display_message)
		visible_message("[src] fades away as it shatters!")
	qdel(src)

/obj/structure/stool/bed/chair/holochair
	icon_state = "chair_gray"

/obj/structure/stool/bed/chair/holochair/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		to_chat(user, ("<span class='notice'>It's a holochair, you can't dismantle it!</span>"))
	return

/obj/item/weapon/holo
	damtype = HALLOSS

/obj/item/weapon/holo/esword
	desc = "May the force be within you. Sorta."
	icon_state = "sword0"
	force = 3.0
	throw_speed = 1
	throw_range = 5
	throwforce = 0
	w_class = ITEM_SIZE_SMALL
	flags = NOSHIELD | NOBLOODY
	var/active = 0

/obj/item/weapon/holo/esword/green

/obj/item/weapon/holo/esword/green/atom_init()
	. = ..()
	item_color = "green"

/obj/item/weapon/holo/esword/red

/obj/item/weapon/holo/esword/red/atom_init()
	. = ..()
	item_color = "red"

/obj/item/weapon/holo/esword/Get_shield_chance()
	if(active)
		return 50
	return 0

/obj/item/weapon/holo/esword/attack(target, mob/user)
	..()

/obj/item/weapon/holo/esword/atom_init()
	. = ..()
	item_color = pick("red","blue","green","purple")

/obj/item/weapon/holo/esword/attack_self(mob/living/user)
	active = !active
	if (active)
		force = 30
		icon_state = "sword[item_color]"
		w_class = ITEM_SIZE_LARGE
		playsound(user, 'sound/weapons/saberon.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = 3
		icon_state = "sword0"
		w_class = ITEM_SIZE_SMALL
		playsound(user, 'sound/weapons/saberoff.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()

	add_fingerprint(user)
	return

//BASKETBALL OBJECTS

/obj/item/weapon/beach_ball/holoball
	icon = 'icons/obj/basketball.dmi'
	icon_state = "basketball"
	name = "basketball"
	item_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = ITEM_SIZE_LARGE //Stops people from hiding it in their bags/pockets

/obj/structure/holohoop
	name = "basketball hoop"
	desc = "Boom, Shakalaka!"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "hoop"
	anchored = 1
	density = 1
	throwpass = 1

/obj/structure/holohoop/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(G.state<2)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return
		G.affecting.loc = src.loc
		G.affecting.Weaken(5)
		user.SetNextMove(CLICK_CD_MELEE)
		visible_message("<span class='warning'>[G.assailant] dunks [G.affecting] into the [src]!</span>", 3)
		qdel(W)
		return
	else if (istype(W, /obj/item) && get_dist(src,user)<2)
		user.drop_item(src.loc)
		visible_message("<span class='notice'>[user] dunks [W] into the [src]!</span>", 3)
		return

/obj/structure/holohoop/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/projectile))
			return
		if(prob(50))
			I.loc = src.loc
			visible_message("<span class='notice'>Swish! \the [I] lands in \the [src].</span>", 3)
		else
			visible_message("<span class='warning'>\The [I] bounces off of \the [src]'s rim!</span>", 3)
		return 0
	else
		return ..(mover, target, height, air_group)


/obj/machinery/readybutton
	name = "Ready Declaration Device"
	desc = "This device is used to declare ready. If all devices in an area are ready, the event will begin!"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = STATIC_ENVIRON
	var/ready = 0
	var/area/currentarea = null
	var/eventstarted = 0


/obj/machinery/readybutton/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()
	to_chat(user, "The station AI is not to interact with these devices!")

/obj/machinery/readybutton/attackby(obj/item/weapon/W, mob/user)
	to_chat(user, "The device is a solid button, there's nothing you can do with it!")

/obj/machinery/readybutton/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(!user.IsAdvancedToolUser())
		return 1

	currentarea = get_area(loc)
	if(!currentarea)
		qdel(src)
		return 1

	if(eventstarted)
		to_chat(usr, "The event has already begun!")
		return 1

	ready = !ready
	user.SetNextMove(CLICK_CD_RAPID)
	update_icon()

	var/numbuttons = 0
	var/numready = 0
	for(var/obj/machinery/readybutton/button in currentarea)
		numbuttons++
		if (button.ready)
			numready++

	if(numbuttons == numready)
		begin_event()

/obj/machinery/readybutton/update_icon()
	if(ready)
		icon_state = "auth_on"
	else
		icon_state = "auth_off"

/obj/machinery/readybutton/proc/begin_event()

	eventstarted = 1

	for(var/obj/structure/window/reinforced/holowindow/disappearing/W in currentarea)
		qdel(W)

	for(var/mob/M in currentarea)
		to_chat(M, "FIGHT!")

//Holorack
/obj/structure/rack/holorack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"

/obj/structure/rack/holorack/attack_hand(mob/user)
	return

/obj/structure/rack/holorack/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W))
		to_chat(user, "It's a holorack!  You can't unwrench it!")
		return

//Holocarp

/mob/living/simple_animal/hostile/carp/holodeck
	icon = 'icons/mob/AI.dmi'
	icon_state = "holo4"
	icon_living = "holo4"
	icon_dead = "holo4"
	alpha = 127
	icon_gib = null
	butcher_results = null //we can't butcher it
	randomify = FALSE

/mob/living/simple_animal/hostile/carp/holodeck/atom_init()
	. = ..()
	set_light(2) //hologram lighting

/mob/living/simple_animal/hostile/carp/holodeck/proc/set_safety(safe)
	if (safe)
		faction = "neutral"
		melee_damage = 0
		//wall_smash = 0
		destroy_surroundings = 0
	else
		faction = "carp"
		melee_damage = initial(melee_damage)
		//wall_smash = initial(wall_smash)
		destroy_surroundings = initial(destroy_surroundings)

/mob/living/simple_animal/hostile/carp/holodeck/gib()
	derez() //holograms can't gib

/mob/living/simple_animal/hostile/carp/holodeck/death()
	..()
	derez()

/mob/living/simple_animal/hostile/carp/holodeck/proc/derez()
	visible_message("<span class='notice'>\The [src] fades away!</span>")
	qdel(src)
