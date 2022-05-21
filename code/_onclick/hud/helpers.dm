/datum/hud/proc/add_intents(act_intent_type = /atom/movable/screen/complex/act_intent)
	mymob.action_intent = new act_intent_type
	mymob.action_intent.add_to_hud(src)

/datum/hud/proc/get_screen(screen_type, icon = null, color = null, alpha = null)
	var/atom/movable/screen/screen = new screen_type
	screen.add_to_hud(src)

/datum/hud/proc/init_screens(list/types)
	for(var/screen_type in types)
		get_screen(screen_type, ui_style, ui_color, ui_alpha)

/datum/hud/proc/add_move_intent(type = /atom/movable/screen/move_intent)
	mymob.move_intent = new type
	mymob.move_intent.add_to_hud(src)

/datum/hud/proc/add_hands(r_type = /atom/movable/screen/inventory/hand/r, l_type = /atom/movable/screen/inventory/hand/l)
	if(r_type)
		mymob.r_hand_hud_object = new r_type
		mymob.r_hand_hud_object.add_to_hud(src)

	if(l_type)
		mymob.l_hand_hud_object = new l_type
		mymob.l_hand_hud_object.add_to_hud(src)

/datum/hud/proc/add_throw_icon(type = /atom/movable/screen/throw)
	mymob.throw_icon = new type
	mymob.throw_icon.add_to_hud(src)

/datum/hud/proc/add_internals(type = /atom/movable/screen/internal)
	mymob.internals = new type
	mymob.internals.add_to_hud(src)

/datum/hud/proc/add_healths(type = /atom/movable/screen/health)
	mymob.healths = new type
	mymob.healths.add_to_hud(src)

/datum/hud/proc/add_health_doll(type = /atom/movable/screen/health_doll)
	mymob.healthdoll = new type
	mymob.healthdoll.add_to_hud(src)

/datum/hud/proc/add_nutrition_icon(type = /atom/movable/screen/nutrition)
	mymob.nutrition_icon = new  type
	mymob.nutrition_icon.add_to_hud(src)

/datum/hud/proc/add_pullin(type = /atom/movable/screen/pull)
	mymob.pullin = new type
	mymob.pullin.add_to_hud(src)

/datum/hud/proc/add_zone_sel(type = /atom/movable/screen/zone_sel)
	mymob.zone_sel = new type
	mymob.zone_sel.add_to_hud(src)

/datum/hud/proc/add_gun_setting(type = /atom/movable/screen/gun/mode)
	mymob.gun_setting_icon = new type
	mymob.gun_setting_icon.add_to_hud(src)

/datum/hud/proc/add_roles()
	var/list/antag_roles = mymob.mind.antag_roles

	for(var/id in antag_roles)
		var/datum/role/role = antag_roles[id]
		role.add_ui(src)

/datum/hud/proc/add_nightvision_icon()
	mymob.nightvisionicon = new /atom/movable/screen/xenomorph/nightvision
	mymob.nightvisionicon.add_to_hud(src)

/datum/hud/proc/add_leap_icon()
	mymob.leap_icon = new /atom/movable/screen/xenomorph/leap
	mymob.leap_icon.add_to_hud(src)

/datum/hud/proc/add_neurotoxin_icon()
	mymob.neurotoxin_icon = new /atom/movable/screen/xenomorph/neurotoxin
	mymob.neurotoxin_icon.add_to_hud(src)

/datum/hud/proc/add_pwr_display(type = /atom/movable/screen/xenomorph/plasma_display)
	mymob.pwr_display = new type
	mymob.pwr_display.add_to_hud(src)

/datum/hud/proc/add_stamina_display()
	mymob.staminadisplay = new /atom/movable/screen/corgi/stamina_bar
	mymob.staminadisplay.add_to_hud(src)

/datum/hud/proc/add_essence_voice()
	var/mob/living/parasite/essence/E = mymob
	E.voice = new /atom/movable/screen/essence/voice
	E.voice.add_to_hud(src)

/datum/hud/proc/add_phantom()
	var/mob/living/parasite/essence/E = mymob
	E.phantom_s = new /atom/movable/screen/essence/phantom()
	E.phantom_s.add_to_hud(src)

/datum/hud/proc/add_robot_hand_1()
	var/atom/movable/screen/robot_hands/first/using = new
	using.add_to_hud(src)
	mymob:inv1 = using

/datum/hud/proc/add_robot_hand_2()
	var/atom/movable/screen/robot_hands/second/using = new
	using.add_to_hud(src)
	mymob:inv2 = using

/datum/hud/proc/add_robot_hand_3()
	var/atom/movable/screen/robot_hands/third/using = new
	using.add_to_hud(src)
	mymob:inv3 = using

/datum/hud/proc/add_module_icon()
	mymob.module_icon = new /atom/movable/screen/module
	mymob.module_icon.add_to_hud(src)
