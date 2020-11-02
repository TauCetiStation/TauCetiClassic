/mob/living/pbag
	name = "punching bag"
	desc = "It's made by some goons."

	icon = 'code/modules/sports/pbag.dmi'
	icon_state = "pbag"
	logs_combat = FALSE

	can_be_pulled = FALSE
	density = FALSE

	maxHealth = 100

	var/list/ghosts_were_here = list()
	// Used so after a swing we fall correctly in async calls.
	var/my_icon_state = "pbag"
	var/swinging = FALSE

/mob/living/pbag/atom_init()
	. = ..()
	color = random_color()
	alive_mob_list -= src

/mob/living/pbag/incapacitated()
	return resting

/mob/living/pbag/restrained()
	return FALSE

/mob/living/pbag/disarmReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	attacker.do_attack_animation(src)

	INVOKE_ASYNC(src, /mob/living/pbag.proc/swing, 0.2 SECONDS)

	playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	if(show_message)
		visible_message("<span class='warning'><B>[attacker] pushed [src]!</B></span>")

/mob/living/pbag/attack_ghost(mob/dead/observer/attacker)
	if(ckey)
		to_chat(attacker, "<span class='notice'>[src] is already possesed.</span>")
		return

	if(ghosts_were_here[attacker.ckey] > world.time)
		to_chat(attacker, "<span class='notice'>You were already exiled from [src]. Please wait [round(ghosts_were_here[attacker.ckey] * 0.1)] seconds to try possesing [src] again.</span>")
		return

	if(incapacitated())
		to_chat(attacker, "<span class='notice'>[src] seems to be too upbeat to be possesed.</span>")
		return

	ghostize(can_reenter_corpse = FALSE) // If there was a @ckey before or something.
	ckey = attacker.ckey
	ghosts_were_here[ckey] = world.time + 10 MINUTES
	qdel(attacker)

/mob/living/pbag/ghostize(can_reenter_corpse = TRUE, bancheck = FALSE)
	return ..(can_reenter_corpse = FALSE, bancheck = FALSE)

/mob/living/pbag/UnarmedAttack(atom/A)
	INVOKE_ASYNC(src, /mob/living/pbag.proc/swing)

/mob/living/pbag/on_lay_down()
	drop_down()
	return TRUE

/mob/living/pbag/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	if(ckey && !incapacitated())
		INVOKE_ASYNC(src, /mob/living/pbag.proc/swing)
		return
	return ..()

/mob/living/pbag/say(message, datum/language/speaking = null, verb="says", alt_name="", italics=FALSE, message_range = world.view, list/used_radios = list(), sound/speech_sound, sound_vol, sanitize = TRUE, message_mode = FALSE)
	if(ckey)
		. = ..(capitalize(message), verb = "whispers", message_range = 1) // why not all args?

/mob/living/pbag/emote(act, type, message, auto)
	if(ckey)
		visible_message("<span class='notice'>[bicon(src)] [src] swings ominously...</span>")
		INVOKE_ASYNC(src, /mob/living/pbag.proc/swing)

/mob/living/pbag/helpReaction(mob/living/attacker, show_message = TRUE)
	if(incapacitated())
		hang_up(attacker)

/mob/living/pbag/death(gibbed)
	if(gibbed)
		var/list/pos_turfs = RANGE_TURFS(3, src)
		for(var/i in 1 to 5)
			var/obj/item/stack/medical/bruise_pack/rags/R = new(get_turf(src), null, null, FALSE)
			R.color = color
			var/turf/target = pick(pos_turfs)
			R.throw_at(target, 3, 2)

/mob/living/pbag/gib()
	death()
	dead_mob_list -= src
	qdel(src)

/mob/living/pbag/update_canmove()
	return

/mob/living/pbag/Life()
	handle_combat()

/mob/living/pbag/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, damage_flags = 0, used_weapon = null)
	hit(damage, damagetype)

	var/flags_mes = ""
	if(damage_flags & (DAM_SHARP|DAM_EDGE))
		flags_mes = ", the attack was sharp"

	var/wep_mes = ""
	if(used_weapon)
		wep_mes = "with [used_weapon] "

	var/def_zone_txt = ""
	switch(def_zone)
		if(BP_HEAD, O_EYES, O_MOUTH)
			def_zone_txt = " in the upper part"
		if(BP_CHEST)
			def_zone_txt = " in the middle part"
		if(BP_GROIN)
			def_zone_txt = " in the lower part"
		if(BP_L_ARM)
			def_zone_txt = " in slightly to the left of the middle part"
		if(BP_R_ARM)
			def_zone_txt = " in slightly to the right of the middle part"
		if(BP_L_LEG)
			def_zone_txt = " in slightly to the left of the lower part"
		if(BP_R_LEG)
			def_zone_txt = " in slightly to the right of the lower part"

	var/mes = "[bicon(src)] [src] has been hit [wep_mes]for [damage] [damagetype] damage[def_zone_txt][flags_mes]."
	visible_message("<span class='notice'>[mes]</span>")

/mob/living/pbag/apply_effect(effect = 0, effecttype = STUN, blocked = 0)
	if(!incapacitated() && (effecttype == WEAKEN || effecttype == PARALYZE))
		drop_down()
	visible_message("<span class='notice'>[bicon(src)] [src] was [effecttype]ed for [effect] seconds.</span>")

/mob/living/pbag/proc/hit(damage, damagetype)
	if(damagetype != BRUTE)
		return

	if(incapacitated())
		return

	adjustBruteLoss(damage)
	if(bruteloss > maxHealth)
		drop_down()
	else
		INVOKE_ASYNC(src, .proc/swing, damage)

/mob/living/pbag/proc/drop_down()
	if(ckey)
		var/mob/dead/observer/ghost = ghostize(can_reenter_corpse = FALSE)
		if(ghost)
			to_chat(ghost, "<span class='warning'>You have been punched out of existence!</span>")
			var/dir_throw = pick(cardinal)
			var/turf/T = get_step(src, dir_throw)
			for(var/i in 1 to 5)
				T = get_step(T, dir_throw)
			ghost.throw_at(T, 7, 5, src) // It will say that the bad "thrown" the ghost out. Sounds fun.

	can_be_pulled = TRUE
	resting = TRUE
	icon_state = "pbagdown"
	my_icon_state = "pbagdown"
	playsound(src, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)

/mob/living/pbag/proc/swing(time = rand(0.5 SECONDS, 2 SECONDS))
	if(swinging || incapacitated())
		return

	time = min(time, 2 SECONDS)
	swinging = TRUE
	icon_state = "pbaghit"
	sleep(time)
	icon_state = my_icon_state
	swinging = FALSE

/mob/living/pbag/rejuvenate()
	..()
	if(pulledby)
		pulledby.stop_pulling()
	can_be_pulled = FALSE
	icon_state = "pbag"
	my_icon_state = "pbag"
	pixel_y = 0
	resting = FALSE

/mob/living/pbag/verb/user_hang()
	set name = "Hang Bag"
	set category = "Object"
	set src in view(1)

	hang_up(usr)

/mob/living/pbag/proc/hang_up(mob/living/user)
	if(isliving(user) && !is_bigger_than(user))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)

		if(!incapacitated())
			drop_down()
		else
			rejuvenate()

		user.visible_message("<span class='notice'>[user] [!resting ? "secures" : "unsecures"] \the [src].</span>",
			"<span class='notice'>You [!resting ? "secure" : "unsecure"] \the [src].</span>",
			"<span class='notice'>You hear a ratchet.</span>")

/mob/living/pbag/is_usable_eyes(targetzone = null)
	return TRUE

/mob/living/pbag/is_usable_head(targetzone = null)
	return TRUE

/mob/living/pbag/is_usable_arm(targetzone = null)
	return TRUE

/mob/living/pbag/is_usable_leg(targetzone = null)
	return TRUE
