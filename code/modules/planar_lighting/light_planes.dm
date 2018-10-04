/obj/screen/plane
	name = ""
	screen_loc = "CENTER"
	blend_mode = BLEND_MULTIPLY
	layer = 1

/obj/screen/plane/New(client/C)
	..()
	if(istype(C))
		C.screen += src
	verbs.Cut()

	if(blend_mode == BLEND_MULTIPLY)
		//What is this? Read http://www.byond.com/forum/?post=2141928
		var/image/backdrop = image('icons/mob/screen_gen.dmi', "black")
		backdrop.transform = matrix(200, 0, 0, 0, 200, 0)
		backdrop.layer = BACKGROUND_LAYER
		backdrop.blend_mode = BLEND_OVERLAY
		overlays += backdrop

/obj/screen/plane/master
	appearance_flags = PLANE_MASTER | RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA
	color = list(null,null,null,"#0000","#000f")  // Completely black.
	plane = GAME_PLANE
	invisibility = INVISIBILITY_LIGHTING

/obj/screen/plane/master/Click(location, control, params)
	if(usr.client.void)
		usr.client.void.Click(location, control, params)

/obj/screen/plane/dark
	blend_mode = BLEND_ADD
	plane = DARK_PLANE // Just below the master plane.
	icon = 'icons/planar_lighting/over_dark.dmi'
	alpha = 20 // moodiness lowered, by popular demand // fuck popular demand
	appearance_flags = RESET_TRANSFORM | RESET_COLOR | RESET_ALPHA
	mouse_opacity = 0

/obj/screen/plane/dark/New()
	..()
	var/matrix/M = matrix()
	M.Scale(world.view*2.2)
	transform = M
