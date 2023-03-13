/obj/item/weapon/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats."
	icon_state = "ionrifle"
	item_state = null
	origin_tech = "combat=2;magnets=4"
	w_class = SIZE_NORMAL
	flags =  CONDUCT
	slot_flags = SLOT_FLAGS_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/ion)
	modifystate = 0

/obj/item/weapon/gun/energy/ionrifle/emp_act(severity)
	if(severity <= 2)
		power_supply.use(round(power_supply.maxcharge / severity))
		update_icon()
	else
		return

/obj/item/weapon/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	origin_tech = "combat=5;materials=4;powerstorage=3"
	can_be_holstered = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/declone)

/obj/item/weapon/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "flora"
	item_state = "gun"
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut)
	origin_tech = "materials=2;biotech=3;powerstorage=3"
	modifystate = 1
	can_be_holstered = TRUE
	var/charge_tick = 0
	var/mode = 0 //0 = mutate, 1 = yield boost

/obj/item/weapon/gun/energy/floragun/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/weapon/gun/energy/floragun/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/gun/energy/floragun/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)
	update_icon()
	return 1

/obj/item/weapon/gun/energy/floragun/attack_self(mob/living/user)
	..()
	update_icon()

/obj/item/weapon/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon_state = "riotgun"
	item_state = "c20r"
	w_class = SIZE_NORMAL
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	cell_type = /obj/item/weapon/stock_parts/cell/potato
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in ticks)

/obj/item/weapon/gun/energy/meteorgun/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/weapon/gun/energy/meteorgun/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/gun/energy/meteorgun/process()
	charge_tick++
	if(charge_tick < recharge_time)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)

/obj/item/weapon/gun/energy/meteorgun/update_icon()
	return

/obj/item/weapon/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	can_be_holstered = TRUE
	w_class = SIZE_MINUSCULE

/obj/item/weapon/gun/energy/mindflayer
	name = "mind flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "xray"
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)

/obj/item/weapon/gun/energy/toxgun
	name = "phoron pistol"
	desc = "A specialized firearm designed to fire lethal bolts of phoron."
	icon_state = "toxgun"
	w_class = SIZE_SMALL
	origin_tech = "combat=5;phorontech=4"
	can_be_holstered = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/toxin)

/obj/item/weapon/gun/energy/sniperrifle
	name = "sniper rifle"
	desc = "Designed by W&J Company, W2500-E sniper rifle constructed of lightweight materials, fitted with a SMART aiming-system scope."
	icon = 'icons/obj/gun.dmi'
	icon_state = "w2500e"
	item_state = "w2500e"
	origin_tech = "combat=6;materials=5;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/sniper)
	slot_flags = SLOT_FLAGS_BACK
	fire_delay = 20
	w_class = SIZE_NORMAL
	var/zoom = 0

/obj/item/weapon/gun/energy/sniperrifle/atom_init()
	. = ..()
	update_icon()
	AddComponent(/datum/component/zoom, 12)

/obj/item/weapon/gun/energy/sniperrifle/attack_self(mob/user)
	SEND_SIGNAL(src, COMSIG_ZOOM_TOGGLE, user)

/obj/item/weapon/gun/energy/sniperrifle/update_icon()
	var/ratio = power_supply.charge / power_supply.maxcharge
	ratio = CEIL(ratio * 4) * 25
	switch(modifystate)
		if (0)
			if(ratio > 100)
				icon_state = "[initial(icon_state)]100"
				item_state = "[initial(item_state)]100"
			else
				icon_state = "[initial(icon_state)][ratio]"
				item_state = "[initial(item_state)][ratio]"
	return

/obj/item/weapon/gun/energy/sniperrifle/rails
	name = "Rails rifle"
	desc = "With this weapon you'll be the boss at any Arena."
	icon = 'icons/obj/gun.dmi'
	icon_state = "relsotron"
	item_state = "relsotron"
	origin_tech = "combat=5;materials=4;powerstorage=4;magnets=4;engineering=4"
	ammo_type = list(/obj/item/ammo_casing/energy/rails)
	fire_delay = 20
	w_class = SIZE_SMALL

//Tesla Cannon
/obj/item/weapon/gun/tesla
	name = "Tesla Cannon"
	desc = "Cannon which uses electrical charge to damage multiple targets. Spin the generator handle to charge it up"
	icon = 'icons/obj/gun.dmi'
	icon_state = "tesla"
	item_state = "tesla"
	w_class = SIZE_NORMAL
	origin_tech = "combat=5;materials=5;powerstorage=5;magnets=5;engineering=5"
	can_be_holstered = FALSE
	var/charge = 0
	var/charging = FALSE
	var/cooldown = FALSE

/obj/item/weapon/gun/tesla/atom_init()
	. = ..()
	update_icon()

/obj/item/weapon/gun/tesla/proc/charge(mob/living/user)
	set waitfor = FALSE
	if(do_after(user, 40 * toolspeed, target = src))
		if(charging && charge < 3)
			charge++
			playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
			if(charge < 3)
				charge(user)
			else
				charging = FALSE
		else
			charging = FALSE
	else
		to_chat(user, "<span class='danger'>Generator is too difficult to spin while moving! Charging aborted.</span>")
		charging = FALSE
	update_icon()

/obj/item/weapon/gun/tesla/attack_self(mob/living/user)
	if(charging)
		charging = FALSE
		user.visible_message("<span class='danger'>[user] stops spinning generator on Tesla Cannon!</span>",\
		                     "<span class='red'>You stop charging Tesla Cannon...</span>")
		cooldown = TRUE
		spawn(50)
			cooldown = FALSE
		return
	if(cooldown || charge == 3)
		return
	user.visible_message("<span class='danger'>[user] starts spinning generator on Tesla Cannon!</span>",\
	                     "<span class='red'>You start charging Tesla Cannon...</span>")
	charging = TRUE
	charge(user)

/obj/item/weapon/gun/tesla/special_check(mob/user, atom/target)
	if(!..())
		return FALSE
	if(!charge)
		to_chat(user, "<span class='red'>Tesla Cannon is not charged!</span>")
	else if(!isliving(target))
		to_chat(user, "<span class='red'>Tesla Cannon needs to be aimed directly at living target.</span>")
	else if(charging)
		to_chat(user, "<span class='red'>You can't shoot while charging!</span>")
	else if(!los_check(user, target))
		to_chat(user, "<span class='red'>Something is blocking our line of shot!</span>")
	else
		Bolt(user, target, user, charge)
		charge = 0

	update_icon()
	return 0

/obj/item/weapon/gun/tesla/proc/los_check(mob/A, mob/B)
	for(var/X in getline(A,B))
		var/turf/T = X
		if(T.density)
			return 0
	return 1

/obj/item/weapon/gun/tesla/proc/Bolt(mob/origin, mob/living/target, mob/user, jumps)
	origin.Beam(target, "lightning[rand(1,12)]", 'icons/effects/effects.dmi', time = 5)
	target.electrocute_act(15 * (jumps + 1), src, , , 1)
	playsound(target, 'sound/machines/defib_zap.ogg', VOL_EFFECTS_MASTER)
	var/list/possible_targets = new
	for(var/mob/living/M in range(2, target))
		if(user == M || !los_check(target, M) || origin == M || target == M)
			continue
		possible_targets += M
	if(!possible_targets.len)
		return
	var/mob/living/next = pick(possible_targets)
	msg_admin_attack("[origin.name] ([origin.ckey]) shot [target.name] ([target.ckey]) with a tesla bolt", origin)
	if(next && jumps > 0)
		Bolt(target, next, user, --jumps)

/obj/item/weapon/gun/tesla/update_icon()
	icon_state = "[initial(icon_state)][charge]"

/obj/item/weapon/gun/tesla/emp_act(severity)
	if(charge)
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.electrocute_act(5 * (4 - severity) * charge, src, , , 1)
		charge = 0
		update_icon()

/obj/item/weapon/gun/tesla/rifle
	name = "Tesla rifle"
	desc = "Rifle which uses electrical charge to damage multiple targets. Spin the generator handle to charge it up"
	icon = 'icons/obj/gun.dmi'
	icon_state = "arctesla"
	item_state = "arctesla"
	w_class = SIZE_SMALL
	origin_tech = null
	toolspeed = 0.5

/*
	Pyrometers and stuff.
*/
/obj/item/weapon/gun/energy/pyrometer
	name = "pyrometer"
	desc = "A tool used to quickly measure temperature without fear of harm due to direct user physical contact."

	w_class = SIZE_TINY
	icon = 'icons/obj/gun.dmi'
	icon_state = "pyrometer"
	item_state = "pyrometer"
	origin_tech = "engineering=3;magnets=3"

	ammo_type = list(/obj/item/ammo_casing/energy/pyrometer)

	var/emagged = FALSE

	var/panel_open = FALSE

	// ML means my laser.
	var/obj/item/weapon/stock_parts/micro_laser/ML
	var/my_laser_type = /obj/item/weapon/stock_parts/micro_laser

/obj/item/weapon/gun/energy/pyrometer/atom_init()
	. = ..()
	if(my_laser_type)
		ML = new my_laser_type(src)

/obj/item/weapon/gun/energy/pyrometer/newshot()
	if(!ML)
		visible_message("<span class='warning'>[src] clings, as it heats up.</span>")
		return
	return ..()

/obj/item/weapon/gun/energy/pyrometer/attack_hand(mob/user)
	if(panel_open && power_supply)
		user.put_in_hands(power_supply)
		power_supply = null
		to_chat(user, "<span class='notice'>You take \the [power_supply] out of \the [src].</span>")
	else
		..()

/obj/item/weapon/gun/energy/pyrometer/attackby(obj/item/I, mob/user, params)
	if(isscrewing(I))
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		panel_open = !panel_open
		user.visible_message("<span class='notice'>[user] [panel_open ? "un" : ""]screws [src]'s panel [panel_open ? "open" : "shut"].</span>", "<span class='notice'>You [panel_open ? "un" : ""]screw [src]'s panel [panel_open ? "open" : "shut"].</span>")

	else if(panel_open)
		if(isprying(I))
			if(ML)
				playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
				user.put_in_hands(ML)
				ML = null
				to_chat(user, "<span class='notice'>You take \the [ML] out of \the [src].</span>")
		else if(istype(I, /obj/item/weapon/stock_parts/cell))
			user.drop_from_inventory(I, src)
			power_supply = I
			to_chat(user, "<span class='notice'>You install [I] into \the [src].</span>")
		else if(istype(I, /obj/item/weapon/stock_parts/micro_laser))
			user.drop_from_inventory(I, src)
			ML = I
			to_chat(user, "<span class='notice'>You install [I] into \the [src].</span>")

	else
		return ..()

/obj/item/weapon/gun/energy/pyrometer/emag_act(mob/user)
	if(emagged)
		return FALSE
	ammo_type += new /obj/item/ammo_casing/energy/pyrometer/emagged(src)
	fire_delay = 12
	origin_tech += ";syndicate=1"
	emagged = TRUE
	to_chat(user, "<span class='warning'>Ошибка: Обнаружен несовместимый модуль. Ошибкаошибкаошибка.</span>")
	return TRUE

/obj/item/weapon/gun/energy/pyrometer/update_icon()
	return

/obj/item/weapon/gun/energy/pyrometer/announce_shot(mob/living/user)
	return



/obj/item/weapon/gun/energy/pyrometer/universal
	name = "universal pyrometer"
	desc = "A tool used to quickly measure temperature without fear of harm due to direct use physical contact. Comes with built-in multi-color laser pointer. And all possible pyrometer modes!"
	icon_state = "pyrometer_robotics"
	item_state = "pyrometer_robotics"

	ammo_type = list(
		/obj/item/ammo_casing/energy/pyrometer/science_phoron,
		/obj/item/ammo_casing/energy/pyrometer/engineering,
		/obj/item/ammo_casing/energy/pyrometer/atmospherics,
		/obj/item/ammo_casing/energy/pyrometer/medical,
	)

	// Doesn't come with those built-in. Must be manually put.
	cell_type = null
	my_laser_type = null


/obj/item/weapon/gun/energy/pyrometer/ce
	name = "chief engineer's tactical pyrometer"
	desc = "A tool used to quickly measure temperature without fear of harm due to direct user physical contact. Comes with built-in multi-color laser pointer. Comes with a neat sniper-scope!"
	icon_state = "pyrometer_ce"
	item_state = "pyrometer_ce"

	ammo_type = list(
		/obj/item/ammo_casing/energy/pyrometer/science_phoron,
		/obj/item/ammo_casing/energy/pyrometer/engineering,
		/obj/item/ammo_casing/energy/pyrometer/atmospherics,
	)

	my_laser_type = /obj/item/weapon/stock_parts/micro_laser/high/ultra/quadultra

/obj/item/weapon/gun/energy/pyrometer/ce/atom_init()
	. = ..()
	AddComponent(/datum/component/zoom, 12, TRUE)

/obj/item/weapon/gun/energy/pyrometer/science_phoron
	name = "phoron-orienter pyrometer"
	desc = "A tool used to quickly measure temperature without fear of harm due to direct user physical contact. Comes with built-in multi-color laser pointer. Is fine-tuned for detecting when your pipe is about to burst."
	icon_state = "pyrometer_science_phoron"
	item_state = "pyrometer_science_phoron"

	ammo_type = list(/obj/item/ammo_casing/energy/pyrometer/science_phoron)



/obj/item/weapon/gun/energy/pyrometer/engineering
	name = "machinery pyrometer"
	desc = "A tool used to quickly measure temperature without fear of harm due to direct user physical contact. Comes with built-in multi-color laser pointer. Detects overheated machinery."
	icon_state = "pyrometer_engineering"
	item_state = "pyrometer_engineering"

	ammo_type = list(/obj/item/ammo_casing/energy/pyrometer/engineering)

/obj/item/weapon/gun/energy/pyrometer/engineering/robotics
	icon_state = "pyrometer_robotics"
	item_state = "pyrometer_robotics"



/obj/item/weapon/gun/energy/pyrometer/atmospherics
	desc = "A tool used to quickly measure temperature without fear of harm due to direct user physical contact. Comes with built-in multi-color laser pointer. Is used to determine how much a living human would be screwed if he was to breath the air in the room you \"scan\"."
	icon_state = "pyrometer_atmospherics"
	item_state = "pyrometer_atmospherics"

	ammo_type = list(/obj/item/ammo_casing/energy/pyrometer/atmospherics)



/obj/item/weapon/gun/energy/pyrometer/medical
	name = "NC thermometer"
	desc = "A tool used to quickly measure temperature without fear of harm due to direct user physical contact. Comes with built-in multi-color laser pointer. Is used to determine the temperature of your skeleton in the closet."
	icon_state = "pyrometer_medical"
	item_state = "pyrometer_medical"

	ammo_type = list(/obj/item/ammo_casing/energy/pyrometer/medical)

	my_laser_type = /obj/item/weapon/stock_parts/micro_laser/high/ultra

/obj/item/weapon/gun/energy/gun/portal
	name = "bluespace wormhole projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams. Requires an anomaly core to function. Fits in a bag."
	ammo_type = list(/obj/item/ammo_casing/energy/wormhole, /obj/item/ammo_casing/energy/wormhole/orange)
	icon_state = "portal"
	modifystate = 0
	can_suicide_with = FALSE

	var/obj/effect/portal/p_blue
	var/obj/effect/portal/p_orange
	var/obj/item/device/assembly/signaler/anomaly/firing_core = null

/obj/item/weapon/gun/energy/gun/portal/Destroy()
	qdel(p_blue)
	qdel(p_orange)
	qdel(firing_core)
	return ..()

/obj/item/weapon/gun/energy/gun/portal/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(!prob(reliability))
		if(firing_core && !is_centcom_level(z))
			to_chat(user, "<span class='warning'>The wormhole projector malfunctions, teleporting away!</span>")
			user.drop_from_inventory(src)
			do_teleport(src, get_turf(src), 7, asoundin = 'sound/effects/phasein.ogg')
			return
	..()

/obj/item/weapon/gun/energy/gun/portal/special_check(mob/M, atom/target)
	if(!firing_core)
		return FALSE
	return TRUE

/obj/item/weapon/gun/energy/gun/portal/attackby(obj/item/C, mob/user)
	if(istype(C, /obj/item/device/assembly/signaler/anomaly))
		if(firing_core)
			to_chat(user, "<span class='warning'>Wormhole projector already has an anomaly core installed!</span>")
			playsound(user, 'sound/machines/airlock/access_denied.ogg', VOL_EFFECTS_MASTER)
			return
		user.drop_from_inventory(C, src)
		to_chat(user, "<span class='notice'>You insert [C] into the wormhole projector and the weapon gently hums to life.</span>")
		playsound(user, 'sound/weapons/guns/plasma10_load.ogg', VOL_EFFECTS_MASTER)
		firing_core = C
		modifystate = 2
		update_icon()
		update_inv_mob()

	if(isscrewing(C))
		if(!firing_core)
			to_chat(user, "<span class='warning'>There is no firing core installed!</span>")
			return
		firing_core.forceMove(get_turf(user))
		firing_core = null
		to_chat(user, "<span class='notice'>You pop the anomaly core out of the projector.</span>")
		playsound(user, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		icon_state = "portal"
		modifystate = 0
		update_icon()
		update_inv_mob()

	return ..()

/obj/item/weapon/gun/energy/gun/portal/proc/on_portal_destroy(obj/effect/portal/P)
	SIGNAL_HANDLER
	if(P == p_blue)
		p_blue = null
	else if(P == p_orange)
		p_orange = null

/obj/item/weapon/gun/energy/gun/portal/proc/has_blue_portal()
	if(istype(p_blue) && !QDELETED(p_blue))
		return TRUE
	return FALSE

/obj/item/weapon/gun/energy/gun/portal/proc/has_orange_portal()
	if(istype(p_orange) && !QDELETED(p_orange))
		return TRUE
	return FALSE

/obj/item/weapon/gun/energy/gun/portal/proc/crosslink()
	if(!has_blue_portal() && !has_orange_portal())
		return
	if(!has_blue_portal() && has_orange_portal())
		p_orange.target = null
		return
	if(!has_orange_portal() && has_blue_portal())
		p_blue.target = null
		return
	p_orange.target = p_blue
	p_blue.target = p_orange

/obj/item/weapon/gun/energy/gun/portal/proc/create_portal(obj/item/projectile/beam/wormhole/W, turf/target)
	var/obj/effect/portal/P = new /obj/effect/portal/portalgun(target, null, 10)
	RegisterSignal(P, COMSIG_PARENT_QDELETING, .proc/on_portal_destroy)
	if(istype(W, /obj/item/projectile/beam/wormhole/orange))
		qdel(p_orange)
		p_orange = P
		P.icon_state = "portalorange"
	else
		qdel(p_blue)
		p_blue = P
	crosslink()

/obj/item/weapon/gun/energy/gun/portal/emp_act(severity)
	return

/obj/item/weapon/gun/energy/retro
	name ="retro phaser"
	icon_state = "retro"
	item_state = null
	desc = "An older model of the basic energy weapon, no longer used by Nanotrasen's security or military forces due to it's low projectile velocity. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	can_be_holstered = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/phaser)

/obj/item/weapon/gun/energy/retro/atom_init()
	. = ..()
	if(power_supply)
		power_supply.maxcharge = 1500
		power_supply.charge = 1500

/obj/item/weapon/gun/medbeam
	name = "prototype medical retrosynchronizer"
	desc = "A prototype healgun, which slowly reverts organic matter to it's previous state, 'healing' it. Don't cross the streams!"
	icon_state = "medigun"
	item_state = "medigun"
	var/mob/living/current_target
	var/last_check = 0
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	var/max_range = 8
	var/active = FALSE
	var/beam_state = "medbeam"
	var/datum/beam/current_beam = null

/obj/item/weapon/gun/medbeam/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/gun/medbeam/Destroy()
	LoseTarget()
	return ..()

/obj/item/weapon/gun/medbeam/dropped(mob/user)
	..()
	LoseTarget()

/obj/item/weapon/gun/medbeam/equipped(mob/user)
	..()
	LoseTarget()

/obj/item/weapon/gun/medbeam/attack(atom/target, mob/living/user)
	if(user.a_intent != INTENT_HARM)
		Fire(target, user)
		return
	return ..()

/obj/item/weapon/gun/medbeam/proc/LoseTarget()
	if(active)
		QDEL_NULL(current_beam)
		active = FALSE
	if(current_target)
		UnregisterSignal(current_target, COMSIG_PARENT_QDELETING)
	current_target = null

/obj/item/weapon/gun/medbeam/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(isliving(user))
		add_fingerprint(user)

	if(current_target)
		LoseTarget()
	if(!isliving(target))
		return

	current_target = target
	RegisterSignal(current_target, COMSIG_PARENT_QDELETING, .proc/LoseTarget)
	active = TRUE
	current_beam = new(user, current_target, time = 6000, beam_icon_state = beam_state, btype = /obj/effect/ebeam/medical)
	INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)
	user.visible_message("<span class='notice'>[user] aims their [src] at [target]!</span>")
	playsound(user, 'sound/weapons/guns/medbeam.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/gun/medbeam/process()
	var/source = loc
	if(!isliving(source))
		LoseTarget()
		return

	if(!current_target)
		LoseTarget()
		return

	if(world.time <= last_check + check_delay)
		return

	last_check = world.time

	if(get_dist(source, current_target) > max_range || !check_trajectory(source, current_target, pass_flags = PASSTABLE, flags = 0))
		LoseTarget()
		to_chat(source, "<span class='warning'>You lose control of the beam!</span>")
		return

	if(current_target)
		on_beam_tick(current_target)

/obj/item/weapon/gun/medbeam/proc/on_beam_tick()
	if(current_target.stat == DEAD)
		LoseTarget()
		return

	current_target.adjustBruteLoss(-5)
	current_target.adjustFireLoss(-5)
	current_target.adjustToxLoss(-2)
	current_target.adjustOxyLoss(-2)

/obj/item/weapon/gun/medbeam/syndi
	name = "ominous medical retrosynchronizer"
	desc = "This medigun has no difference from it's Nanotrasen counterpart apart from color scheme. Sounds familiar."
	icon_state = "medigun_syndi"
	item_state = "medigun_syndi"
	beam_state = "medbeam_syndi"

/obj/effect/ebeam/medical
	name = "medical beam"
	icon_state = "medbeam"
