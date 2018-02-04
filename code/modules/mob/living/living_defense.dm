/mob/living/proc/run_armor_check(def_zone = null, attack_flag = "melee", absorb_text = null, soften_text = null)
	var/armor = getarmor(def_zone, attack_flag)
	if(armor >= 100)
		if(absorb_text)
			to_chat(src, "<span class='userdanger'>[absorb_text]</span>")
		else
			to_chat(src, "<span class='userdanger'>Your armor absorbs the blow!</span>")
	else if(armor > 0)
		if(soften_text)
			to_chat(src, "<span class='userdanger'>[soften_text]</span>")
		else
			to_chat(src, "<span class='userdanger'>Your armor softens the blow!</span>")
	return armor

//if null is passed for def_zone, then this should return something appropriate for all zones (e.g. area effect damage)
/mob/living/proc/getarmor(def_zone, type)
	return 0


/mob/living/bullet_act(obj/item/projectile/P, def_zone)
	flash_weak_pain()

	//Being hit while using a deadman switch
	if(istype(get_active_hand(),/obj/item/device/assembly/signaler))
		var/obj/item/device/assembly/signaler/signaler = get_active_hand()
		if(signaler.deadman && prob(80))
			attack_log += "\[[time_stamp()]\]<font color='orange'>triggers their deadman's switch!</font>"
			message_admins("\blue [key_name_admin(src)] triggers their deadman's switch! ([ADMIN_JMP(src)])")
			log_game("\blue [key_name(src)] triggers their deadman's switch!")
			src.visible_message("\red [src] triggers their deadman's switch!")
			signaler.signal()

	//Armor
	var/damage = P.damage
	var/flags = P.damage_flags()
	var/absorb = run_armor_check(def_zone, P.flag)
	if (prob(absorb))
		if(flags & DAM_LASER)
			//the armour causes the heat energy to spread out, which reduces the damage (and the blood loss)
			//this is mostly so that armour doesn't cause people to lose MORE fluid from lasers than they would otherwise
			damage *= FLUIDLOSS_CONC_BURN / FLUIDLOSS_WIDE_BURN
		flags &= ~(DAM_SHARP | DAM_EDGE | DAM_LASER)

	if(!P.nodamage)
		apply_damage(damage, P.damage_type, def_zone, absorb, flags, P)
	P.on_hit(src, absorb, def_zone)

	return absorb

//this proc handles being hit by a thrown atom
/mob/living/hitby(atom/movable/AM)//Standardization and logging -Sieve
	if(istype(AM,/obj/))
		var/obj/O = AM
		var/dtype = BRUTE
		if(istype(O,/obj/item/weapon))
			var/obj/item/weapon/W = O
			dtype = W.damtype
		var/throw_damage = O.throwforce * (AM.fly_speed / 5)

		var/zone
		var/mob/living/L = isliving(O.thrower) ? O.thrower : null
		if(L)
			zone = check_zone(L.zone_sel.selecting)
		else
			zone = ran_zone(BP_CHEST, 75) // Hits a random part of the body, geared towards the chest

		//check if we hit
		if(O.throw_source)
			var/distance = get_dist(O.throw_source, loc)
			zone = get_zone_with_miss_chance(zone, src, min(15 * (distance - 2), 0))
		else
			zone = get_zone_with_miss_chance(zone, src, 15)

		if(!zone)
			visible_message("<span class='notice'>\The [O] misses [src] narrowly!</span>")
			return

		if(O.thrower != src && check_shields(throw_damage, "[O]", get_dir(O,src)))
			return

		resolve_thrown_attack(O, throw_damage, dtype, zone)

		if(L)
			var/client/assailant = L.client
			if(assailant)
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been hit with a [O], thrown by [L.name] ([assailant.ckey])</font>")
				L.attack_log += text("\[[time_stamp()]\] <font color='red'>Hit [src.name] ([src.ckey]) with a thrown [O]</font>")
				if(!ismouse(src))
					msg_admin_attack("[src.name] ([src.ckey]) was hit by a [O], thrown by [L.name] ([assailant.ckey]) [ADMIN_JMP(src)]")

		// Begin BS12 momentum-transfer code.
		if(O.throw_source && AM.fly_speed >= 15)
			var/obj/item/weapon/W = O

			visible_message("<span class='warning'>[src] staggers under the impact!</span>",
				"<span class='danger'>You stagger under the impact!</span>")

			var/atom/throw_target = get_edge_target_turf(src, get_dir(O.throw_source, src))
			throw_at(throw_target, 5, 1, O.thrower, FALSE, null, null, CALLBACK(src, .proc/pin_to_turf, W))


/mob/living/proc/resolve_thrown_attack(obj/O, throw_damage, dtype, zone, armor)

	if(isnull(armor)) // Armor arg passed by human
		armor = run_armor_check(null, "melee")
		visible_message("<span class='warning'>[src] has been hit by [O].</span>")

	var/damage_flags = O.damage_flags()

	if(prob(armor))
		damage_flags &= ~(DAM_SHARP | DAM_EDGE)

	var/created_wound = apply_damage(throw_damage, dtype, null, armor, damage_flags, O)

	//thrown weapon embedded object code.
	if(dtype == BRUTE && istype(O, /obj/item))
		var/obj/item/I = O
		if(!I.can_embed || I.is_robot_module())
			return

		var/sharp = is_sharp(I)

		var/damage = throw_damage //the effective damage used for embedding purposes, no actual damage is dealt here
		if (armor)
			damage *= blocked_mult(armor)

		//blunt objects should really not be embedding in things unless a huge amount of force is involved
		var/embed_chance = sharp ? (damage / (I.w_class / 2)) : (damage / (I.w_class * 3))
		var/embed_threshold = sharp ? 5 * I.w_class : 15 * I.w_class

		//Sharp objects will always embed if they do enough damage.
		//Thrown sharp objects have some momentum already and have a small chance to embed even if the damage is below the threshold
		if(sharp && prob(damage / (10 * I.w_class) * 100) || (damage > embed_threshold && prob(embed_chance)))
			embed(I, zone, created_wound)

/mob/living/proc/embed(obj/item/I)
	I.loc = src
	embedded += I
	verbs += /mob/proc/yank_out_object

/mob/living/proc/pin_to_turf(obj/item/I)
	if(!I)
		return

	if(I.sharp && I.loc == src) // Projectile is suitable for pinning.

		var/turf/T = near_wall(I.dir, 2, TRUE)
		if(!T)
			return

		if(loc != T)
			return

		visible_message("<span class='warning'>[src] is pinned to the [T] by [I]!</span>",
			"<span class='danger'>You are pinned to the wall by [I]!</span>")
		anchored = TRUE
		pinned += I
		update_canmove() // instant update, no need to wait Life() tick

//This is called when the mob is thrown into a dense turf
/mob/living/proc/turf_collision(turf/T)
	visible_message("<span class='warning'>[src] crashed into \the [T]!</span>","<span class='danger'>You are crashed into \the [T]!</span>")
	take_bodypart_damage(fly_speed * 5)

/mob/living/proc/near_wall(direction, distance = 1, check_dense_objs = FALSE)
	var/turf/T = get_step(get_turf(src), direction)
	var/turf/last_turf = loc
	var/i = 1

	while(i > 0 && i <= distance)
		if(T.density) //Turf is a wall!
			return last_turf
		if(check_dense_objs)
			for(var/obj/O in T.contents)
				if(O.density)
					return last_turf
		i++
		last_turf = T
		T = get_step(T, direction)

	return FALSE

// End BS12 momentum-transfer code.

/mob/living/proc/check_shields(damage = 0, attack_text = "the attack", hit_dir = 0)
	return FALSE

//Mobs on Fire
/mob/living/proc/IgniteMob()
	if(fire_stacks > 0 && !on_fire)
		on_fire = 1
		set_light(light_range + 3)
		update_fire()

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
		set_light(max(0, light_range - 3))
		update_fire()

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
    fire_stacks = Clamp(fire_stacks + add_fire_stacks, -20, 20)

/mob/living/proc/handle_fire()
	if(fire_stacks < 0)
		fire_stacks++ //If we've doused ourselves in water to avoid fire, dry off slowly
		fire_stacks = min(0, fire_stacks)//So we dry ourselves back to default, nonflammable.
	if(!on_fire)
		return 1
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.get_by_flag(XGM_GAS_OXIDIZER) < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return
	for(var/obj/item/I in contents)
		if(I.wet)
			ExtinguishMob()
			break
	if(fire_stacks == 0)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return
	var/turf/location = get_turf(src)
	location.hotspot_expose(fire_burn_temperature(), 50)

/mob/living/fire_act()
	adjust_fire_stacks(0.5)
	IgniteMob()

//Finds the effective temperature that the mob is burning at.
/mob/living/proc/fire_burn_temperature()
	if (fire_stacks <= 0)
		return 0

	//Scale quadratically so that single digit numbers of fire stacks don't burn ridiculously hot.
	//lower limit of 700 K, same as matches and roughly the temperature of a cool flame.
	return max(2.25 * round(FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE * (fire_stacks / FIRE_MAX_FIRESUIT_STACKS) ** 2), 700)

//Mobs on Fire end

/mob/living/regular_hud_updates()
	..()
	update_action_buttons()

/mob/living/update_action_buttons()
	if(!hud_used) return
	if(!client) return

	if(hud_used.hud_shown != 1)	//Hud toggled to minimal
		return

	client.screen -= hud_used.hide_actions_toggle
	for(var/datum/action/A in actions)
		if(A.button)
			client.screen -= A.button

	if(hud_used.action_buttons_hidden)
		if(!hud_used.hide_actions_toggle)
			hud_used.hide_actions_toggle = new(hud_used)
			hud_used.hide_actions_toggle.UpdateIcon()

		if(!hud_used.hide_actions_toggle.moved)
			hud_used.hide_actions_toggle.screen_loc = hud_used.ButtonNumberToScreenCoords(1)
			//hud_used.SetButtonCoords(hud_used.hide_actions_toggle,1)

		client.screen += hud_used.hide_actions_toggle
		return

	var/button_number = 0
	for(var/datum/action/A in actions)
		button_number++
		if(A.button == null)
			var/obj/screen/movable/action_button/N = new(hud_used)
			N.owner = A
			A.button = N

		var/obj/screen/movable/action_button/B = A.button

		B.UpdateIcon()

		B.name = A.UpdateName()

		client.screen += B

		if(!B.moved)
			B.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number)
			//hud_used.SetButtonCoords(B,button_number)

	if(button_number > 0)
		if(!hud_used.hide_actions_toggle)
			hud_used.hide_actions_toggle = new(hud_used)
			hud_used.hide_actions_toggle.InitialiseIcon(src)
		if(!hud_used.hide_actions_toggle.moved)
			hud_used.hide_actions_toggle.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number+1)
			//hud_used.SetButtonCoords(hud_used.hide_actions_toggle,button_number+1)
		client.screen += hud_used.hide_actions_toggle

/mob/living/incapacitated(restrained_type = HANDS)
	if(stat || paralysis || stunned || weakened || restrained(restrained_type))
		return 1
