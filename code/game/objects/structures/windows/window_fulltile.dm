/**
 * Base fulltile window
 */

/obj/structure/window/fulltile
	name = "window"
	desc = "A window."
	icon = 'icons/obj/smooth_structures/windows/placeholder.dmi'
	icon_state = "window"

	smooth = SMOOTH_TRUE
	canSmoothWith = CAN_SMOOTH_WITH_WALLS
	smooth_adapters = SMOOTH_ADAPTERS_WALLS

	// has own smoothing algoritm
	var/smooth_icon_windowstill = 'icons/obj/smooth_structures/windows/window_sill.dmi'
	var/smooth_icon_window = 'icons/obj/smooth_structures/windows/window.dmi'
	var/smooth_icon_grille = 'icons/obj/smooth_structures/grille.dmi'

	var/grilled = FALSE
	var/glass_color
	var/glass_color_blend_to_color
	var/glass_color_blend_to_ratio

	var/image/crack_overlay

	max_integrity = 20
	damage_deflection = 2

	armor = list(melee = 50, fire = 70)

	var/disassemble_glass_type = /obj/item/stack/sheet/glass // any better ideas to handle drops and disassembles?

/obj/structure/window/fulltile/atom_init(mapload, grill)
	// need to prepare atom before icon smoothing in ..()
	if(grill)
		grilled = TRUE

	var/new_color = color || SSstation_coloring.get_default_color()
	color = null
	if(glass_color_blend_to_color && glass_color_blend_to_ratio)
		glass_color = BlendRGB(new_color, glass_color_blend_to_color, glass_color_blend_to_ratio)
	else
		glass_color = new_color

	. = ..()

/obj/structure/window/fulltile/change_color(new_color)
	if(glass_color_blend_to_color && glass_color_blend_to_ratio)
		glass_color = BlendRGB(new_color, glass_color_blend_to_color, glass_color_blend_to_ratio)
	else
		glass_color = new_color
	
	regenerate_smooth_icon()

/obj/structure/window/fulltile/attackby(obj/item/W, mob/user)
	if(isprying(W) && !(resistance_flags & DECONSTRUCT_IMMUNE)) // bad use of resistance_flags? we need some flag to prevent deconstructs
		if(!handle_fumbling(user, src, SKILL_TASK_EASY, list(/datum/skill/construction = SKILL_LEVEL_TRAINED), message_self = "<span class='notice'>You fumble around, figuring out how to pry the glass out of the frame.</span>"))
			return

		user.visible_message("<span class='warning'>[usr.name] starts to remove the glass from the [src].</span>", \
							"<span class='warning'>You start removing the glass from the [src]!</span>", \
							"<span class='warning'>You hear screwing.</span>")

		if(W.use_tool(src, user, 40))
			to_chat(user, "<span class='notice'>You have removed the glass from the frame.</span>")
			deconstruct(TRUE)

		return

	return ..()

/obj/structure/window/fulltile/update_icon()
	var/ratio = get_integrity() / max_integrity
	ratio = CEIL(ratio * 4) * 25

	cut_overlay(crack_overlay)
	if(ratio > 75)
		return
	crack_overlay = image('icons/obj/window.dmi',"damage[ratio]_[rand(1, 3)]",-(layer+0.1))
	add_overlay(crack_overlay)

// because of regenerate_smooth_icon this is not the cheapest method (if we don't have icon cached) and should not be used in mass
// currently we need this only for projectiles with PASSGLASS but not PASSGRILLE (replicators)
/obj/structure/window/fulltile/proc/break_grille()
	if(!grilled)
		return

	grilled = FALSE

	playsound(src, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)

	new /obj/item/stack/rods(loc, 1)

	regenerate_smooth_icon()

/obj/structure/window/fulltile/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS) && (!grilled || mover.checkpass(PASSGRILLE)))
		return TRUE
	return !density

#define GRILLE_MAX_INTEGRITY 20 // /obj/structure/grille/max_integrity

/obj/structure/window/fulltile/bullet_act(obj/item/projectile/Proj, def_zone)
	if(Proj.checkpass(PASSGLASS) && (!grilled || Proj.checkpass(PASSGRILLE)))
		return PROJECTILE_FORCE_MISS

	if(grilled && Proj.checkpass(PASSGLASS)) // replics should be happy (im crying because of how awful this is)
		if(prob((max_integrity - get_integrity()) * 100 / GRILLE_MAX_INTEGRITY))
			break_grille()

	return ..()

#undef GRILLE_MAX_INTEGRITY

/obj/structure/window/fulltile/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()

	if(disassembled)
		new disassemble_glass_type(loc, 2)

	new /obj/structure/windowsill(loc)

	if(grilled)
		new /obj/structure/grille(loc)

	return ..()

/obj/structure/window/fulltile/atom_destruction(damage_flag)
	switch(damage_flag)
		if(BOMB, FIRE, ACID)
			grilled = FALSE

	return ..()

/**
 * Fulltile phoron
 */

/obj/structure/window/fulltile/phoron
	name = "phoron window"
	desc = "A phoron-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."

	icon_state = "window_phoron"

	max_integrity = 120
	armor = list(melee = 50, fire = 99)

	glass_color_blend_to_color = "#8000ff"
	glass_color_blend_to_ratio = 0.5

	disassemble_glass_type = /obj/item/stack/sheet/glass/phoronglass

/**
 * Fulltile tinted
 */

/obj/structure/window/fulltile/tinted
	name = "tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	opacity = 1

	icon_state = "window_tinted"

	glass_color_blend_to_color = "#000000"
	glass_color_blend_to_ratio = 0.7

/**
 * Fulltile polarized
 */

/obj/structure/window/fulltile/polarized
	name = "electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."

	icon_state = "window_polarized"

	glass_color_blend_to_color = "#bebebe"
	glass_color_blend_to_ratio = 0.7

	var/id

/obj/structure/window/fulltile/polarized/proc/toggle()
	if(opacity) // todo: color change?
		set_opacity(0)
	else
		set_opacity(1)

/obj/structure/window/fulltile/polarized/attackby(obj/item/W as obj, mob/user as mob)
	if(ispulsing(W)) // todo: maybe need something for access unlocking. For now we assume that this access == access to multitool
		var/t = sanitize(input(user, "Enter the ID for the window.", src.name, null), MAX_NAME_LEN)
		src.id = t
		to_chat(user, "<span class='notice'>The new ID of \the [src] is [id]</span>")
		return TRUE
	return ..()

/**
 * Fulltile reinforced
 */

/obj/structure/window/fulltile/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."

	smooth_icon_window = 'icons/obj/smooth_structures/windows/window_reinforced.dmi'
	icon_state = "window_reinforced"

	max_integrity = 100
	damage_deflection = 5
	armor = list(melee = 80, fire = 70, bomb = 25)
	explosive_resistance = 0.5

	disassemble_glass_type = /obj/item/stack/sheet/rglass

/**
 * Fulltile reinforced phoron
 */

/obj/structure/window/fulltile/reinforced/phoron
	name = "reinforced phoron window"
	desc = "A phoron-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic phoron windows are insanely fireproof."

	icon_state = "window_reinforced_phoron"

	max_integrity = 200
	armor = list(melee = 80, fire = 100, bomb = 50)
	explosive_resistance = 1

	glass_color_blend_to_color = "#8000ff"
	glass_color_blend_to_ratio = 0.5

	disassemble_glass_type = /obj/item/stack/sheet/glass/phoronrglass

/**
 * Fulltile reinforced tinted
 */

/obj/structure/window/fulltile/reinforced/tinted
	name = "reinforced tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	opacity = 1

	icon_state = "window_reinforced_tinted"

	glass_color_blend_to_color = "#000000"
	glass_color_blend_to_ratio = 0.7

/**
 * Fulltile reinforced polarized
 */

/obj/structure/window/fulltile/reinforced/polarized
	name = "reinforced electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."

	icon_state = "window_reinforced_polarized"

	glass_color_blend_to_color = "#bebebe"
	glass_color_blend_to_ratio = 0.7

	var/id

/obj/structure/window/fulltile/reinforced/polarized/proc/toggle()
	if(opacity) // todo: color change?
		set_opacity(0)
	else
		set_opacity(1)

/obj/structure/window/fulltile/reinforced/polarized/attackby(obj/item/W as obj, mob/user as mob)
	if(ispulsing(W)) // todo: maybe need something for access unlocking. For now we assume that this access == access to multitool
		var/t = sanitize(input(user, "Enter the ID for the window.", src.name, null), MAX_NAME_LEN)
		src.id = t
		to_chat(user, "<span class='notice'>The new ID of \the [src] is [id]</span>")
		return TRUE
	return ..()

/**
 * Fulltile reinforced indestructible
 */

/obj/structure/window/fulltile/reinforced/indestructible
	flags = NODECONSTRUCT
	resistance_flags = FULL_INDESTRUCTIBLE

	grilled = TRUE
