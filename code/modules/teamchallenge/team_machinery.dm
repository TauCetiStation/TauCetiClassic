//iVend-o-mat / iVent / Event-o-mat - Softheart wuz here.

/obj/machinery/vending/ivend
	name = "iVend-o-mat"
	desc = "A specialized Scrapheap Challenge construction materials and equipment vendor."
	icon = 'code/modules/teamchallenge/challenge.dmi'
	icon_state = "ivend"
	products = list(/obj/item/stack/sheet/metal/fifty = 4, /obj/item/stack/sheet/glass/fifty = 4, /obj/item/stack/sheet/wood/fifty = 4, /obj/item/stack/sheet/plasteel/fifty = 2,
					/obj/item/weapon/rcd_ammo = 20, /obj/item/weapon/airlock_electronics = 15, /obj/item/weapon/stock_parts/cell/high = 15,
					/obj/item/weapon/module/power_control = 10, /obj/item/stack/cable_coil/random = 10, /obj/item/device/assembly/signaler = 10,
					/obj/item/device/assembly/infra = 10, /obj/item/device/assembly/prox_sensor = 10, /obj/item/weapon/weldpack = 5,
					/obj/item/weapon/storage/box/lights/mixed = 4, /obj/item/weapon/soap/nanotrasen = 2, /obj/item/weapon/reagent_containers/hypospray/autoinjector/junkfood = 70)
	contraband = list(/obj/random/randomfigure = 1, /obj/random/plushie = 1)
	product_slogans = "It's iVend time!;iVend-o-mat - for all your iVend needs!;uBuild while iVend.;Hurry up, the time is running out!;Every iVend-o-mat unit is valuable - don't let anyone steal yours!;This iVend is sponsored by Tau Ceti branch of NanoTrasen Corporation!;iVend - a good way to get away from routine!;A new life awaits you in the Off-world colonies. The chance to begin again in a golden land of opportunity and adventure."
	product_ads = "It's iVend time!;iVend-o-mat - for all your iVend needs!;uBuild while iVend.;Don't be greedy - share with your teammates!"

//Colorful lights

/obj/machinery/light/small/green
	name = "green light fixture"
	desc = "A small green lighting fixture."
	brightness_range = 4
	brightness_power = 2
	brightness_color = "#00cc00"
	light_color = "#00cc00"
	nightshift_light_color = "#00cc00"

/obj/machinery/light/small/ultramarine
	name = "ultramarine light fixture"
	desc = "A small ultramarine lighting fixture... For the Emprah!"
	brightness_range = 4
	brightness_power = 2
	brightness_color = "#0000ff"
	light_color = "#0000ff"
	nightshift_light_color = "#0000ff"

/obj/machinery/light/small/purple
	name = "purple light fixture"
	desc = "A small purple lighting fixture."
	brightness_range = 4
	brightness_power = 2
	brightness_color = "#ff00ff"
	light_color = "#ff00ff"
	nightshift_light_color = "#ff00ff"

//A disposal pipe dispenser without bin and outlet: Can't put fueltank in a bin, also fueltank warheads get stuck in the outlet section often.

/obj/machinery/pipedispenser/disposal/teamchallenge

/obj/machinery/pipedispenser/disposal/teamchallenge/ui_interact(user)
	var/dat = {"<b>Disposal Pipes</b><br><br>
		<A href='?src=\ref[src];dmake=0'>Pipe</A><BR>
		<A href='?src=\ref[src];dmake=1'>Bent Pipe</A><BR>
		<A href='?src=\ref[src];dmake=2'>Junction</A><BR>
		<A href='?src=\ref[src];dmake=3'>Y-Junction</A><BR>
		<A href='?src=\ref[src];dmake=4'>Trunk</A><BR>
		<A href='?src=\ref[src];dmake=7'>Chute</A><BR>
		"}

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[entity_ja(dat)]</TT>", "window=pipedispenser")

//Ammunition teleporter - spawns the warhead and c4 detonator when activated through admin panel. - VoLas and Luduk were here.

var/list/bomb_spawners = list()

/obj/structure/bomb_telepad
	name = "warhead transporter"
	desc = "A bluespace telepad used for teleporting objects to and from a location."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle-o"
	anchored = 0

	var/list/spawntypes = list(/obj/structure/reagent_dispensers/fueltank/warhead/red, /obj/item/weapon/plastique)

/obj/structure/bomb_telepad/red
	name = "red warhead transporter"
	spawntypes = list(/obj/structure/reagent_dispensers/fueltank/warhead/red, /obj/item/weapon/plastique)

/obj/structure/bomb_telepad/yellow
	name = "yellow warhead transporter"
	spawntypes = list(/obj/structure/reagent_dispensers/fueltank/warhead/yellow, /obj/item/weapon/plastique)

/obj/structure/bomb_telepad/blue
	name = "blue warhead transporter"
	spawntypes = list(/obj/structure/reagent_dispensers/fueltank/warhead/blue, /obj/item/weapon/plastique)

/obj/structure/bomb_telepad/green
	name = "green warhead transporter"
	spawntypes = list(/obj/structure/reagent_dispensers/fueltank/warhead/green, /obj/item/weapon/plastique)

/obj/structure/bomb_telepad/atom_init()
	bomb_spawners += src

/obj/structure/bomb_telepad/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		to_chat(user, "<span class='notice'>You [anchored ? "unattached" : "attached"] the [src].</span>")
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		anchored = !anchored
		icon_state = anchored ? "pad-idle" : "pad-idle-o"

/obj/structure/bomb_telepad/proc/do_spawn()
	for(var/spawntype in spawntypes)
		new spawntype(loc)

//Fake shield barrier preventing teams from attacking each other during construction and bombardment phases. Can be toggled via admin panel. - VoLas and Luduk were here too.

var/event_field_stage = 1 //1 - nothing, 2 - objects, 3 - all

var/list/team_shields = list()

/proc/set_event_field_stage(value)
	event_field_stage = value

	for(var/obj/effect/decal/teamchallenge/shield in team_shields)
		shield.update_icon()

/obj/effect/decal/teamchallenge
	name = "force field"
	desc = "It prevents teams from attacking each other too early. Nothing can pass through the field."
	density = 0
	anchored = 1
	layer = 2
	light_range = 3
	icon = 'code/modules/teamchallenge/challenge.dmi'
	icon_state = "energyshield"
	color = "#66ccff"

/obj/effect/decal/teamchallenge/atom_init()
	. = ..()
	team_shields += src
	update_icon()

/obj/effect/decal/teamchallenge/Destroy()
	team_shields -= src
	return ..()

/obj/effect/decal/teamchallenge/ex_act()
	return

/obj/effect/decal/teamchallenge/CanPass(atom/movable/mover)
	if(event_field_stage==3)
		return 1
	else if(isobj(mover) && event_field_stage==2)
		return 1
	else
		return 0

/obj/effect/decal/teamchallenge/update_icon()
	switch(event_field_stage)
		if(1)
			desc = "It prevents teams from attacking each other too early. Nothing can pass through the field."
			icon_state = "energyshield"
			color = "#66ccff"
		if(2)
			desc = "Looks like this field is less dense than usual. Only inanimate objects can pass through the field."
			icon_state = "energyshield"
			color = "#ffcc66"
		if(3)
			desc = "Robust at last! Anything can pass through the field when it's green."
			icon_state = "energyshield"
			color = "#00ff00"

//Admin verb toggles

var/list/event_verbs = list(/client/proc/toggle_fields, /client/proc/spawn_bomb)

//1 - nothing, 2 - objects, 3 - all

/client/proc/toggle_fields()
	set category = "Event"
	set name = "Toggle Event Fields"

	var/msg
	if(event_field_stage==1)
		event_field_stage=2
		msg = "OBJECTS may pass"
	else if(event_field_stage==2)
		event_field_stage=3
		msg = "OBJECTS and MOBS may pass"
	else if(event_field_stage==3)
		event_field_stage=1
		msg = "NOTHING may pass"

	log_admin("[usr.key] has toggled event force field, now [msg].")
	message_admins("[key_name_admin(usr)] has toggled event force field, now [msg].")

	for(var/obj/effect/decal/teamchallenge/shield in team_shields)
		shield.update_icon()

/client/proc/spawn_bomb()
	set category = "Event"
	set name = "Spawn Bomb"

	log_admin("[usr.key] has spawned event bombs.")
	message_admins("[key_name_admin(usr)] has spawned event bombs.")

	for(var/obj/structure/bomb_telepad/T in bomb_spawners)
		if(T.anchored)
			T.do_spawn()