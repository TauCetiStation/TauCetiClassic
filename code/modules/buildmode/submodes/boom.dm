#define BOOM_DEVASTATION "devastation"
#define BOOM_HEAVY "heavy"
#define BOOM_LIGHT "light"
#define BOOM_FLASH "flash"
#define BOOM_FLAMES "flames"

/datum/buildmode_mode/boom
	key = "boom"

	var/list/explosions = list(
		BOOM_DEVASTATION = 0,
		BOOM_HEAVY = 0,
		BOOM_LIGHT = 0,
		BOOM_FLASH = 0,
		)

/datum/buildmode_mode/boom/show_help(client/c)
	to_chat(c,
		"<span class='notice'>***********************************************************\n\
		Right Mouse Button on buildmode button = Set explosion parameters\n\
		Mouse Button on obj  = Kaboom\n\
		***********************************************************</span>")

/datum/buildmode_mode/boom/change_settings(client/c)
	for (var/explosion_level in explosions)
		explosions[explosion_level] = input(c, "Range of total [explosion_level]. 0 to none", text("Input")) as num|null
		if(explosions[explosion_level] == null || explosions[explosion_level] < 0)
			explosions[explosion_level] = 0

/datum/buildmode_mode/boom/handle_click(client/c, params, obj/object)
	var/list/modifiers = params2list(params)

	var/value_valid = FALSE
	for (var/explosion_type in explosions)
		if (explosions[explosion_type] > 0)
			value_valid = TRUE
			break
	if (!value_valid)
		to_chat(c, "<span class='warning'>You need to setup parameters first.</span>")
		return

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		log_admin("Build Mode: [key_name(c)] caused an explosion(dev=[explosions[BOOM_DEVASTATION]], hvy=[explosions[BOOM_HEAVY]], lgt=[explosions[BOOM_LIGHT]], flash=[explosions[BOOM_FLASH]], flames=[explosions[BOOM_FLAMES]]) at [AREACOORD(object)]")
		explosion(object, explosions[BOOM_DEVASTATION], explosions[BOOM_HEAVY], explosions[BOOM_LIGHT], explosions[BOOM_FLASH], adminlog = FALSE)

#undef BOOM_DEVASTATION
#undef BOOM_HEAVY
#undef BOOM_LIGHT
#undef BOOM_FLASH
#undef BOOM_FLAMES
