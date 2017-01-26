/obj/item/weapon/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats."
	icon_state = "ionrifle"
	item_state = "ionrifle"
	origin_tech = "combat=2;magnets=4"
	w_class = 4.0
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/ion)

/obj/item/weapon/gun/energy/ionrifle/isHandgun()
	return 0

/obj/item/weapon/gun/energy/ionrifle/update_icon()
	var/ratio = power_supply.charge / power_supply.maxcharge
	ratio = Ceiling(ratio*4) * 25
	switch(modifystate)
		if (0)
			if(ratio > 100)
				icon_state = "[initial(icon_state)]100"
				item_state = "[initial(item_state)]100"
			else
				icon_state = "[initial(icon_state)][ratio]"
				item_state = "[initial(item_state)][ratio]"
	return

/obj/item/weapon/gun/energy/ionrifle/emp_act(severity)
	if(severity <= 2)
		power_supply.use(round(power_supply.maxcharge / severity))
		update_icon()
	else
		return

/obj/item/weapon/gun/energy/ionrifle/classic
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats."
	icon_state = "oldion"
	item_state = "oldion"
	slot_flags = null

/obj/item/weapon/gun/energy/ionrifle/tactifool
	icon_state = "tfionrifle"
	item_state = "tfionrifle"

/obj/item/weapon/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	origin_tech = "combat=5;materials=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/declone)

/obj/item/weapon/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "flora"
	item_state = "gun"
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut)
	origin_tech = "materials=2;biotech=3;powerstorage=3"
	modifystate = 1
	var/charge_tick = 0
	var/mode = 0 //0 = mutate, 1 = yield boost

	New()
		..()
		SSobj.processing |= src


	Destroy()
		SSobj.processing.Remove(src)
		return ..()

	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(100)
		update_icon()
		return 1

	attack_self(mob/living/user)
		select_fire(user)
		update_icon()
		return

/obj/item/weapon/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon_state = "riotgun"
	item_state = "c20r"
	w_class = 4
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	cell_type = "/obj/item/weapon/stock_parts/cell/potato"
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in ticks)

	New()
		..()
		SSobj.processing |= src


	Destroy()
		SSobj.processing.Remove(src)
		return ..()

	process()
		charge_tick++
		if(charge_tick < recharge_time) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(100)

	update_icon()
		return

/obj/item/weapon/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = 1

/obj/item/weapon/gun/energy/mindflayer
	name = "mind flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "xray"
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)
/*
obj/item/weapon/gun/energy/staff/focus
	name = "mental focus"
	desc = "An artefact that channels the will of the user into destructive bolts of force. If you aren't careful with it, you might poke someone's brain out."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "focus"
	item_state = "focus"
	projectile_type = "/obj/item/projectile/forcebolt"

	attack_self(mob/living/user)
		if(projectile_type == "/obj/item/projectile/forcebolt")
			charge_cost = 200
			to_chat(user, "\red The [src.name] will now strike a small area.")
			projectile_type = "/obj/item/projectile/forcebolt/strong"
		else
			charge_cost = 100
			to_chat(user, "\red The [src.name] will now strike only a single person.")
			projectile_type = "/obj/item/projectile/forcebolt"
	*/

/obj/item/weapon/gun/energy/toxgun
	name = "phoron pistol"
	desc = "A specialized firearm designed to fire lethal bolts of phoron."
	icon_state = "toxgun"
	w_class = 3.0
	origin_tech = "combat=5;phorontech=4"
	ammo_type = list(/obj/item/ammo_casing/energy/toxin)

/obj/item/weapon/gun/energy/sniperrifle
	name = "sniper rifle"
	desc = "Designed by W&J Company, W2500-E sniper rifle constructed of lightweight materials, fitted with a SMART aiming-system scope."
	icon = 'icons/obj/gun.dmi'
	icon_state = "w2500e"
	item_state = "w2500e"
	origin_tech = "combat=6;materials=5;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/sniper)
	slot_flags = SLOT_BACK
	fire_delay = 35
	w_class = 4.0
	var/zoom = 0

/obj/item/weapon/gun/energy/sniperrifle/New()
	..()
	update_icon()
	return


/obj/item/weapon/gun/energy/sniperrifle/isHandgun()
	return 0

/obj/item/weapon/gun/energy/sniperrifle/update_icon()
	var/ratio = power_supply.charge / power_supply.maxcharge
	ratio = Ceiling(ratio*4) * 25
	switch(modifystate)
		if (0)
			if(ratio > 100)
				icon_state = "[initial(icon_state)]100"
				item_state = "[initial(item_state)]100"
			else
				icon_state = "[initial(icon_state)][ratio]"
				item_state = "[initial(item_state)][ratio]"
	return

/obj/item/weapon/gun/energy/sniperrifle/dropped(mob/user)
	user.client.view = world.view

/*
This is called from
modules/mob/mob_movement.dm if you move you will be zoomed out
modules/mob/living/carbon/human/life.dm if you die, you will be zoomed out.
*/

/obj/item/weapon/gun/energy/sniperrifle/attack_self()
	zoom()

/obj/item/weapon/gun/energy/sniperrifle/verb/zoom()
	set category = "Object"
	set name = "Use Sniper Scope"
	set popup_menu = 0
	if(usr.stat || !(istype(usr,/mob/living/carbon/human)))
		to_chat(usr, "You are unable to focus down the scope of the rifle.")
		return
	//if(!zoom && global_hud.darkMask[1] in usr.client.screen)
	//	usr << "Your welding equipment gets in the way of you looking down the scope"
	//	return
	if(!zoom && usr.get_active_hand() != src)
		to_chat(usr, "You are too distracted to look down the scope, perhaps if it was in your active hand this might work better")
		return

	if(usr.client.view == world.view)
		if(usr.hud_used)
			usr.hud_used.show_hud(HUD_STYLE_REDUCED)
		usr.client.view = 12
		zoom = 1
	else
		usr.client.view = world.view
		if(usr.hud_used)
			usr.hud_used.show_hud(HUD_STYLE_STANDARD)
		zoom = 0
	to_chat(usr, "<font color='[zoom?"blue":"red"]'>Zoom mode [zoom?"en":"dis"]abled.</font>")
	return

//Tesla Cannon
/obj/item/weapon/gun/tesla
	name = "Tesla Cannon"
	desc = "Cannon which uses electrical charge to damage multiple targets. Spin the generator handle to charge it up"
	icon = 'icons/obj/gun.dmi'
	icon_state = "tesla"
	item_state = "tesla"
	w_class = 4.0
	origin_tech = "combat=5;materials=5;powerstorage=5;magnets=5;engineering=5"
	var/charge = 0
	var/charging = FALSE
	var/cooldown = FALSE

/obj/item/weapon/gun/tesla/New()
	..()
	update_icon()

/obj/item/weapon/gun/tesla/proc/charge(mob/living/user)
	set waitfor = FALSE
	if(do_after(user, 40, target = src))
		if(charging && charge < 3)
			charge++
			playsound(loc, "sparks", 75, 1, -1)
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
	if(!charge)
		to_chat(user, "<span class='red'>Tesla Cannon is not charged!</span>")
	else if(!istype(target, /mob/living))
		to_chat(user, "<span class='red'>Tesla Cannon needs to be aimed directly at living target.</span>")
	else if(charging)
		to_chat(user, "<span class='red'>You can't shoot while charging!</span>")
	else if(!los_check(user, target))
		to_chat(user, "<span class='red'>Something is blocking our line of shot!</span>")
	else
		Bolt(user, target, user, charge)
		charge = 0

	update_icon()

	/*if(user.hand) with custom inhand sprites - yes, without - no.
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()*/

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
	playsound(target, 'sound/machines/defib_zap.ogg', 50, 1, -1)
	var/list/possible_targets = new
	for(var/mob/living/M in range(2, target))
		if(user == M || !los_check(target, M) || origin == M || target == M)
			continue
		possible_targets += M
	if(!possible_targets.len)
		return
	var/mob/living/next = pick(possible_targets)
	msg_admin_attack("[origin.name] ([origin.ckey]) shot [target.name] ([target.ckey]) with a tesla bolt [ADMIN_JMP(origin)] [ADMIN_FLW(origin)]")
	if(next && jumps > 0)
		Bolt(target, next, user, --jumps)

/obj/item/weapon/gun/tesla/update_icon()
	icon_state = "[initial(icon_state)][charge]"

/obj/item/weapon/gun/tesla/emp_act(severity)
	if(charge)
		if(istype(loc, /mob/living/carbon))
			var/mob/living/carbon/M = loc
			M.electrocute_act(5 * (4 - severity) * charge, src, , , 1)
		charge = 0
		update_icon()
