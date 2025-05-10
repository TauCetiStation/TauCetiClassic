// Used in human/electrocution_animation()
// Turns a mob black, flashes a skeleton overlay
// Just like a cartoon!

// todo: should rewrite it as component, or status effect
/obj/effect/electrocute
	layer = MOB_ELECTROCUTION_LAYER
	color = COLOR_MATRIX_CONTRAST(2)
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	appearance_flags = RESET_COLOR | KEEP_APART

	var/timer

/obj/effect/electrocute/atom_init(mapload, mob/living/carbon/human/H, duration)
	. = ..()

	appearance = H.get_skeleton_appearance()
	vis_flags = initial(vis_flags) // setting appearance resets them
	appearance_flags = initial(appearance_flags)
	animate(src, alpha = 0, time = 0.08 SECONDS, loop = -1, easing = JUMP_EASING)
	animate(alpha = 255, time = 0.08 SECONDS)
	H.color = "#000" // consider porting atom_colours from tg if this overwrite breaks something (or add it as another overlay/vis_content)
	H.vis_contents += src

	RegisterSignal(H, COMSIG_ATOM_ELECTROCUTE_ACT, PROC_REF(stop)) // quick and ugly fix to effect stacking
	timer = addtimer(CALLBACK(src, PROC_REF(stop), H), duration)

/obj/effect/electrocute/proc/stop(mob/living/carbon/human/H)
	if(timer)
		deltimer(timer)
	H.color = null
	qdel(src)
