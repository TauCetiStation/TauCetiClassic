/*!
 * Custom rendering solution to allow for advanced effects
 * We (ab)use plane masters and render source/target to cheaply render 2+ planes as 1
 * if you want to read more read the _render_readme.md
 */


/**
 * ## Rendering plate
 *
 * Acts like a plane master, but for plane masters
 * Renders other planes onto this plane, through the use of render objects
 * Any effects applied onto this plane will act on the unified plane
 * IE a bulge filter will apply as if the world was one object
 * remember that once planes are unified on a render plate you cant change the layering of them!
 */
/atom/movable/screen/plane_master/rendering_plate
	name = "default rendering plate"

///this plate renders the final screen to show to the player
/atom/movable/screen/plane_master/rendering_plate/master
	name = "master rendering plate"
	plane = RENDER_PLANE_MASTER
	render_relay_planes = null
	no_render_target = TRUE

///renders general in charachter game objects
/atom/movable/screen/plane_master/rendering_plate/game_world
	name = "game rendering plate"
	plane = RENDER_PLANE_GAME
	render_relay_planes = list(RENDER_PLANE_MASTER)

#define SINGULO_RENDER_TARGET_0 PM_RENDER_NAME(/atom/movable/screen/plane_master/singularity_0)
#define SINGULO_RENDER_TARGET_1 PM_RENDER_NAME(/atom/movable/screen/plane_master/singularity_1)
#define SINGULO_RENDER_TARGET_2 PM_RENDER_NAME(/atom/movable/screen/plane_master/singularity_2)
#define SINGULO_RENDER_TARGET_3 PM_RENDER_NAME(/atom/movable/screen/plane_master/singularity_3)
#define DISTORTION_RENDER_TARGET PM_RENDER_NAME(/atom/movable/screen/plane_master/distortion)

/atom/movable/screen/plane_master/rendering_plate/game_world/update_effects(client/client, map_view)
	if(!..())
		return

	// todo: i don't like that we always use 4 singularity planes and 4 displacement filters, even if there is no singularity
	// can we combine them in one at least? and vary based on singularity overlays
	add_filter("singularity_0", 1, displacement_map_filter(render_source = SINGULO_RENDER_TARGET_0, size = -40))
	add_filter("singularity_1", 2, displacement_map_filter(render_source = SINGULO_RENDER_TARGET_1, size = 75))
	add_filter("singularity_2", 3, displacement_map_filter(render_source = SINGULO_RENDER_TARGET_2, size = 400))
	add_filter("singularity_3", 4, displacement_map_filter(render_source = SINGULO_RENDER_TARGET_3, size = 700))

	animate(get_filter("singularity_0"), size = -20, time = 10, easing = LINEAR_EASING, loop = -1, flags = ANIMATION_PARALLEL)
	animate(size = -30, time = 10, easing = LINEAR_EASING, loop = -1)

	animate(get_filter("singularity_1"), size = 50, time = 10, easing = LINEAR_EASING, loop = -1, flags = ANIMATION_PARALLEL)
	animate(size = 100, time = 10, easing = LINEAR_EASING, loop = -1)

	animate(get_filter("singularity_2"), size = 400, time = 10, easing = LINEAR_EASING, loop = -1, flags = ANIMATION_PARALLEL)
	animate(size = 300, time = 10, easing = LINEAR_EASING, loop = -1)

	animate(get_filter("singularity_3"), size = 750, time = 10, easing = LINEAR_EASING, loop = -1, flags = ANIMATION_PARALLEL)
	animate(size = 600, time = 10, easing = LINEAR_EASING, loop = -1)

	// basic distortion filter for anomaly like gravity pulse, heat, maybe something else
	add_filter("distortion", 5, displacement_map_filter(render_source = DISTORTION_RENDER_TARGET, size = 10))

#undef SINGULO_RENDER_TARGET_0
#undef SINGULO_RENDER_TARGET_1
#undef SINGULO_RENDER_TARGET_2
#undef SINGULO_RENDER_TARGET_3
#undef DISTORTION_RENDER_TARGET

///everything that should be above game world. (for example, singularity, nar-si)
/atom/movable/screen/plane_master/rendering_plate/above_game_world
	name = "above game rendering plate"
	plane = RENDER_PLANE_ABOVE_GAME
	render_relay_planes = list(RENDER_PLANE_MASTER)

///render plate for OOC stuff like ghosts, hud-screen effects, etc
/atom/movable/screen/plane_master/rendering_plate/non_game
	name = "non-game rendering plate"
	plane = RENDER_PLANE_NON_GAME
	render_relay_planes = list(RENDER_PLANE_MASTER)
