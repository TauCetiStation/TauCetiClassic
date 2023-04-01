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

	var/damage_threshold = 5   // this will be deducted from any physical damage source. Main difference in sturdiness between fulltiles and thin windows
	var/image/crack_overlay

	var/disassemble_glass_type = /obj/item/stack/sheet/glass // any better ideas to handle drops and disassembles?

/obj/structure/window/fulltile/atom_init(mapload, grill)
	// need to prepare atom before icon smoothing in ..()
	if(grill)
		grilled = TRUE

	var/new_color = SSstation_coloring.get_default_color()
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

/obj/structure/window/fulltile/run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir)
	if(damage_threshold)
		switch(damage_type)
			if(BRUTE)
				return max(0, damage_amount - damage_threshold)
			if(BURN)
				return damage_amount * 0.3
	return ..()

/obj/structure/window/fulltile/attackby(obj/item/W, mob/user)
	if(isprying(W) && !(resistance_flags & DECONSTRUCT_IMMUNE)) // bad use of resistance_flags? we need some flag to prevent deconstructs
		if(!handle_fumbling(user, src, SKILL_TASK_EASY, list(/datum/skill/construction = SKILL_LEVEL_TRAINED), message_self = "<span class='notice'>You fumble around, figuring out how to pry the glass out of the frame.</span>"))
			return

		user.visible_message("<span class='warning'>[usr.name] starts to remove the glass from the [src].</span>", \
							"<span class='warning'>You start removing the glass from the [src]!</span>", \
							"<span class='warning'>You hear screwing.</span>")

		W.use_tool(src, user, 40)
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

/obj/structure/window/fulltile/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS) && (!grilled || mover.checkpass(PASSGRILLE)))
		return TRUE
	return !density

/obj/structure/window/fulltile/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()

	if(disassembled)
		new disassemble_glass_type(loc, 2)

	new /obj/structure/windowsill(loc)

	if(grilled)
		new /obj/structure/grille(loc)

	return ..()

/**
 * Fulltile phoron
 */

/obj/structure/window/fulltile/phoron
	name = "phoron window"
	desc = "A phoron-glass alloy window. It looks insanely tough to break. It appears it's also insanely tough to burn through."

	icon_state = "window_phoron"

	max_integrity = 120

	glass_color_blend_to_color = "#8000ff"
	glass_color_blend_to_ratio = 0.5

	disassemble_glass_type = /obj/item/stack/sheet/glass/phoronglass

/obj/structure/window/fulltile/phoron/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 32000)
		take_damage(round(exposed_volume / 1000), BURN, FIRE, FALSE)

/**
 * Fulltile reinforced
 */

/obj/structure/window/fulltile/reinforced
	name = "reinforced window"
	desc = "It looks rather strong. Might take a few good hits to shatter it."

	smooth_icon_window = 'icons/obj/smooth_structures/windows/window_reinforced.dmi'
	icon_state = "window_reinforced"

	max_integrity = 100
	damage_threshold = 10

	disassemble_glass_type = /obj/item/stack/sheet/rglass

/**
 * Fulltile reinforced phoron
 */

/obj/structure/window/fulltile/reinforced/phoron
	name = "reinforced phoron window"
	desc = "A phoron-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic phoron windows are insanely fireproof."

	icon_state = "window_reinforced_phoron"

	max_integrity = 160

	glass_color_blend_to_color = "#8000ff"
	glass_color_blend_to_ratio = 0.5

	disassemble_glass_type = /obj/item/stack/sheet/glass/phoronrglass

/obj/structure/window/fulltile/reinforced/phoron/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

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
	name = "electrochromic window"
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
