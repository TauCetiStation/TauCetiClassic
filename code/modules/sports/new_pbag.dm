/mob/living/pbag
	name = "punching bag"
	desc = "It's made by some goons."

	icon = 'code/modules/sports/pbag.dmi'
	icon_state = "pbag"
	var/my_icon_state = "pbag" // Used so after a swing we fall correctly in async calls.

	density = FALSE
	anchored = TRUE

	maxHealth = 100

	var/turf/def_position

/mob/living/pbag/atom_init()
	. = ..()

	color = random_color()
	alive_mob_list -= src
	if(isturf(loc))
		def_position = loc

/mob/living/pbag/death()
	return

/mob/living/pbag/Life()
	handle_combat()

	if(anchored && def_position)
		step_to(src, def_position)

/mob/living/pbag/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, damage_flags = 0, used_weapon = null)
	hit(damage, damagetype)

	var/flags_mes = " "
	if(damage_flags & (DAM_SHARP|DAM_EDGE))
		flags_mes = ", the attack was sharp"

	var/wep_mes = ""
	if(used_weapon)
		wep_mes = "with [used_weapon] "

	var/def_zone_txt = ""
	switch(def_zone)
		if(BP_HEAD)
			def_zone_txt = "the upper part"
		if(BP_CHEST)
			def_zone_txt = "the middle part"
		if(BP_GROIN)
			def_zone_txt = "the lower part"
		if(BP_L_ARM)
			def_zone_txt = "slightly to the left of the middle part"
		if(BP_R_ARM)
			def_zone_txt = "slightly to the right of the middle part"
		if(BP_L_LEG)
			def_zone_txt = "slightly to the left of the lower part"
		if(BP_R_LEG)
			def_zone_txt = "slightly to the right of the lower part"
		if(O_EYES)
			def_zone_txt = "the upper part"
		if(O_MOUTH)
			def_zone_txt = "the upper part"

	var/mes = "[bicon(src)] has been hit [wep_mes]for [damage] [damagetype] damage in [def_zone_txt][flags_mes]."
	visible_message("<span class='notice'>[mes]</span>")

/mob/living/pbag/apply_effect(effect = 0,effecttype = STUN, blocked = 0)
	if(effecttype == WEAKEN || effecttype == PARALYZE)
		drop_down()
	visible_message("<span class='notice'>[bicon(src)] was [effecttype]ed for [effect] seconds.</span>")

/mob/living/pbag/proc/hit(damage, damagetype)
	if(damagetype != BRUTE)
		return

	if(!anchored)
		return

	adjustBruteLoss(damage)
	if(bruteloss > maxHealth)
		drop_down()
	else
		INVOKE_ASYNC(src, .proc/swing, damage)

/mob/living/pbag/proc/drop_down()
	anchored = FALSE
	icon_state = "pbagdown"
	my_icon_state = "pbagdown"
	playsound(src, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
	bruteloss = 0
	animate(src, pixel_y = pixel_y - 4, time = 1)

/mob/living/pbag/proc/swing(time = rand(5, 20))
	icon_state = "pbaghit"
	sleep(time)
	icon_state = my_icon_state

/mob/living/pbag/verb/hang()
	set name = "Hang Bag"
	set category = "Object"
	set src in view(1)

	var/mob/living/user = usr

	if(isliving(user))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		anchored = !anchored
		user.visible_message("[user] [anchored ? "secures" : "unsecures"] \the [src].",
			"You [anchored? "secure":"undo"] \the [src].",
			"You hear a ratchet.")

		if(anchored)
			icon_state = "pbag"
			my_icon_state = "pbag"
			pixel_y = 0
		else
			drop_down()

/mob/living/pbag/has_head(targetzone = null)
	return TRUE

/mob/living/pbag/has_arm(targetzone = null)
	return TRUE

/mob/living/pbag/has_leg(targetzone = null)
	return TRUE
