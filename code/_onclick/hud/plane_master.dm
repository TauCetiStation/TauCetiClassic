/obj/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY

/obj/screen/plane_master/atom_init()
	if(blend_mode == BLEND_MULTIPLY)
		//What is this? Read http://www.byond.com/forum/?post=2141928
		var/image/backdrop = image('icons/mob/screen_gen.dmi', "black")
		backdrop.transform = matrix(200, 0, 0, 0, 200, 0)
		backdrop.layer = BACKGROUND_LAYER
		backdrop.blend_mode = BLEND_OVERLAY
		overlays += backdrop
	. = ..()

/obj/screen/plane_master/master
	plane = BLACKNESS_PLANE

/obj/screen/plane_master/master/Click(location, control, params)
	if(usr.client.void)
		usr.client.void.Click(location, control, params)

/obj/screen/plane_master/parallax
	name = "parallax plane master"
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = FALSE

/obj/screen/plane_master/parallax_white
	name = "parallax whitifier plane master"
	plane = PLANE_SPACE
	color = list(
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		1, 1, 1, 1,
		0, 0, 0, 0
		)
/*
/obj/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	blend_mode = BLEND_OVERLAY

/obj/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	blend_mode = BLEND_MULTIPLY
//	color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,0, 0.1,0.1,0.1,0)
	mouse_opacity = 0
*/
