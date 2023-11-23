// Hotkeys
/atom/movable/screen/pull
	name = "stop pulling"
	icon = 'icons/hud/screen1_Midnight.dmi'
	icon_state = "pull1"
	screen_loc = ui_pull_resist

	hud_slot = HUD_SLOT_HOTKEYS
	copy_flags = HUD_COPY_ICON

/atom/movable/screen/pull/action()
	usr.stop_pulling()

/atom/movable/screen/pull/update_icon(mob/mymob)
	icon_state = mymob.pulling ? "pull1" : "pull0"

/atom/movable/screen/pull/add_to_hud(datum/hud/hud)
	..()
	update_icon(hud.mymob)
	hud.mymob.pullin = src

/atom/movable/screen/equip
	name = "equip"
	icon_state = "act_equip"
	screen_loc = ui_equip
	plane = ABOVE_HUD_PLANE

	hud_slot = HUD_SLOT_HOTKEYS

/atom/movable/screen/equip/action()
	if(istype(usr.loc, /obj/mecha)) // stops inventory actions in a mech
		return
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.quick_equip()

/atom/movable/screen/resist
	name = "resist"
	icon_state = "act_resist"
	screen_loc = ui_pull_resist
	plane = HUD_PLANE

	hud_slot = HUD_SLOT_HOTKEYS

/atom/movable/screen/resist/action()
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()

/atom/movable/screen/throw
	name = "throw"
	icon_state = "act_throw_off"
	screen_loc = ui_drop_throw

	hud_slot = HUD_SLOT_HOTKEYS

/atom/movable/screen/throw/action()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/atom/movable/screen/throw/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.throw_icon = src

/atom/movable/screen/drop
	name = "drop"
	icon_state = "act_drop"
	screen_loc = ui_drop_throw
	plane = HUD_PLANE

	hud_slot = HUD_SLOT_HOTKEYS

/atom/movable/screen/drop/action()
	usr.drop_item()

// Status screens
/atom/movable/screen/health
	name = "health"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "health0"
	screen_loc = ui_health

	copy_flags = NONE

/atom/movable/screen/health/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.healths = src

/atom/movable/screen/health/living
	icon = 'icons/hud/living.dmi'

/atom/movable/screen/health/living/add_to_hud(datum/hud/hud)
	..()
	var/mob/mymob = hud.mymob
	var/icon/mob_mask = icon(mymob.icon, mymob.icon_state)
	if(mob_mask.Height() > world.icon_size || mob_mask.Width() > world.icon_size)
		if(mob_mask.Height() > mob_mask.Width())
			mob_mask.Scale(mob_mask.Width() * world.icon_size / mob_mask.Height(), world.icon_size)
		else
			mob_mask.Scale(world.icon_size, mob_mask.Height() * world.icon_size / mob_mask.Width())

	add_filter("mob_shape_mask", 1, alpha_mask_filter(icon = mob_mask))
	add_filter("inset_drop_shadow", 2, drop_shadow_filter(size = -1))

/atom/movable/screen/health/diona
	icon = 'icons/hud/screen_diona.dmi'

/atom/movable/screen/health_doll
	icon = 'icons/hud/screen_gen.dmi'
	name = "health doll"
	screen_loc = ui_healthdoll

	copy_flags = NONE

/atom/movable/screen/health_doll/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.healthdoll = src

/atom/movable/screen/nutrition
	name = "nutrition"
	icon_state = "starving"
	screen_loc = ui_nutrition

	copy_flags = NONE

/atom/movable/screen/nutrition/update_icon(mob/living/carbon/human/mymob)
	icon = mymob.species.flags[IS_SYNTHETIC] ? 'icons/hud/screen_alert.dmi' : 'icons/hud/screen_gen.dmi'

/atom/movable/screen/nutrition/add_to_hud(datum/hud/hud)
	..()
	update_icon(hud.mymob)
	hud.mymob.nutrition_icon = src

// Gun screens
/atom/movable/screen/gun
	name = "gun"
	icon = 'icons/hud/screen1.dmi'
	COOLDOWN_DECLARE(gun_click_time)

	copy_flags = NONE

/atom/movable/screen/gun/action()
	if(!COOLDOWN_FINISHED(src, gun_click_time))
		return FALSE
	if(!istype(usr.get_active_hand(), /obj/item/weapon/gun))
		to_chat(usr, "You need your gun in your active hand to do that!")
		return FALSE
	COOLDOWN_START(src, gun_click_time, 3 SECONDS) //give them 3 seconds between mode changes.
	return TRUE

/atom/movable/screen/gun/move
	name = "Allow Walking"
	icon_state = "no_walk0"
	screen_loc = ui_gun2

/atom/movable/screen/gun/move/update_icon(client/client)
	name = "[client.target_can_move ? "Disallow" : "Allow"] Walking"
	icon_state = "no_walk[client.target_can_move]"

/atom/movable/screen/gun/move/action()
	if(..())
		usr.client.AllowTargetMove()

/atom/movable/screen/gun/run
	name = "Allow Running"
	icon_state = "no_run0"
	screen_loc = ui_gun3

/atom/movable/screen/gun/run/update_icon(client/client)
	if(client.target_can_move)
		invisibility = INVISIBILITY_NONE
		name = "[client.target_can_run ? "Disallow" : "Allow"] Running"
		icon_state = "no_run[client.target_can_run]"
	else
		invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/gun/run/action()
	if(..())
		usr.client.AllowTargetRun()

/atom/movable/screen/gun/item
	name = "Allow Item Use"
	icon_state = "no_item0"
	screen_loc = ui_gun1

/atom/movable/screen/gun/item/update_icon(client/client)
	name = "[client.target_can_click ? "Disallow" : "Allow"] Item Use"
	icon_state = "no_item[client.target_can_click]"

/atom/movable/screen/gun/item/action()
	if(..())
		usr.client.AllowTargetClick()

// Zone selecting
/atom/movable/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = BP_CHEST
	var/static/list/hover_overlays_cache = list()
	var/hovering

/atom/movable/screen/zone_sel/action(location, control, params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL[ICON_X])
	var/icon_y = text2num(PL[ICON_Y])
	var/choice = get_zone_at(icon_x, icon_y)
	if(!choice)
		return

	set_selected_zone(choice, usr)

/atom/movable/screen/zone_sel/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/atom/movable/screen/zone_sel/MouseMove(location, control, params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL[ICON_X])
	var/icon_y = text2num(PL[ICON_Y])
	var/choice = get_zone_at(icon_x, icon_y)

	if(hovering == choice)
		return
	vis_contents -= hover_overlays_cache[hovering]
	hovering = choice

	var/obj/effect/overlay/zone_sel/overlay_object = hover_overlays_cache[choice]
	if(!overlay_object)
		overlay_object = new
		overlay_object.icon_state = "[choice]"
		hover_overlays_cache[choice] = overlay_object
	vis_contents += overlay_object

/obj/effect/overlay/zone_sel
	icon = 'icons/hud/screen_gen.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 128
	anchored = TRUE
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/zone_sel/MouseExited(location, control, params)
	if(!isobserver(usr) && hovering)
		vis_contents -= hover_overlays_cache[hovering]
		hovering = null

/atom/movable/screen/zone_sel/proc/get_zone_at(icon_x, icon_y)
	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					return BP_R_LEG
				if(17 to 22)
					return BP_L_LEG
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					return BP_R_LEG
				if(17 to 22)
					return BP_L_LEG
		if(10 to 13) //Arms and groin
			switch(icon_x)
				if(8 to 11)
					return BP_R_ARM
				if(12 to 20)
					return BP_GROIN
				if(21 to 24)
					return BP_L_ARM
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					return BP_R_ARM
				if(12 to 20)
					return BP_CHEST
				if(21 to 24)
					return BP_L_ARM
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							return O_MOUTH
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							return O_EYES
					if(25 to 27)
						if(icon_x in 15 to 17)
							return O_EYES
				return BP_HEAD

/atom/movable/screen/zone_sel/proc/set_selected_zone(choice, mob/user)
	if(choice != selecting)
		selecting = choice
		var/mob/living/L = usr
		if(istype(L))
			L.update_combos()
		update_icon()

/atom/movable/screen/zone_sel/update_icon()
	cut_overlays()
	add_overlay(image('icons/hud/zone_sel.dmi', "[selecting]"))

/atom/movable/screen/zone_sel/add_to_hud(datum/hud/hud)
	..()
	update_icon()
	hud.mymob.zone_sel = src

// Move intent
/atom/movable/screen/move_intent
	name = "mov_intent"
	screen_loc = ui_movi
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/move_intent/action()
	var/mob/living/L = usr
	L.set_m_intent(L.m_intent == MOVE_INTENT_WALK ? MOVE_INTENT_RUN : MOVE_INTENT_WALK)

/atom/movable/screen/move_intent/update_icon(mob/mymob)
	icon_state = (mymob.m_intent == MOVE_INTENT_RUN ? "running" : "walking")

/atom/movable/screen/move_intent/add_to_hud(datum/hud/hud)
	..()
	update_icon(hud.mymob)
	hud.mymob.move_intent = src


// Transparent boxes for intent choosing
/atom/movable/screen/intent
	screen_loc = ui_acti
	plane = ABOVE_HUD_PLANE
	var/index

	copy_flags = NONE

/atom/movable/screen/intent/action()
	usr.set_a_intent(name)

/atom/movable/screen/intent/update_icon(atom/movable/screen/act_intent)
	var/icon/ico = new(act_intent.icon, act_intent.icon_state)
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	var/x1
	var/y1

	switch(index)
		if(1, 4)
			x1 = 1
		if(2, 3)
			x1 = ico.Width() / 2 + 1

	switch(index)
		if(1, 2)
			y1 = ico.Height() / 2 + 1
		if(3, 4)
			y1 = 1

	var/x2 = x1 + (ico.Width() / 2 - 1)
	var/y2 = y1 + (ico.Height() / 2 - 1)
	ico.DrawBox(rgb(255,255,255,1), x1, y1, x2, y2)
	icon = ico

/atom/movable/screen/intent/help
	name = INTENT_HELP
	index = 1

/atom/movable/screen/intent/push
	name = INTENT_PUSH
	index = 2

/atom/movable/screen/intent/grab
	name = INTENT_GRAB
	index = 3

/atom/movable/screen/intent/harm
	name = INTENT_HARM
	index = 4

// Holomap
/atom/movable/screen/holomap
	name = "holomap"
	icon = null
	icon_state = null
	screen_loc = ui_holomap
	plane = HUD_PLANE
	layer = HUD_LAYER
	copy_flags = HUD_COPY_ALPHA || HUD_COPY_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/holomap/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.holomap_obj = src
