//! Persistence code is commented out while porting
//! Because there were no Persistence when it was ported

///////////
// EASEL //
///////////

/obj/structure/easel
	name = "easel"
	cases = list("мольберт", "мольберта", "мольберту", "мольберт", "мольбертом", "мольберте")
	desc = "Что нам стоит отсек построить - нарисуем, будем жить!"
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "easel"
	density = TRUE
	var/obj/item/canvas/painting = null

/obj/structure/easel/Destroy()
	painting = null
	return ..()

//Adding canvases
/obj/structure/easel/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/canvas))
		var/obj/item/canvas/canvas = I
		user.drop_from_inventory(canvas)
		painting = canvas
		painting.easel = src
		canvas.forceMove(get_turf(src))
		canvas.layer = layer + 0.1
		user.visible_message("<span class='notice'>[user] ставит [CASE(canvas, ACCUSATIVE_CASE)] на [CASE(src, ACCUSATIVE_CASE)].</span>", "<span class='notice'>Вы ставите [CASE(canvas, ACCUSATIVE_CASE)] на [CASE(src, ACCUSATIVE_CASE)].</span>")
	else
		return ..()

/obj/item/canvas
	name = "canvas"
	cases = list("холст", "холста", "холсту", "холст", "холстом", "холсте")
	desc = "Излей всю душу на холст!"
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "11x11"
	w_class = SIZE_NORMAL

	var/width = 11
	var/height = 11
	var/list/grid
	var/canvas_color = "#ffffff" //empty canvas color
	var/used = FALSE
	var/painting_name = "Untitled Artwork" //Painting name, this is set after framing.
	var/finalized = FALSE //Blocks
	var/icon_generated = FALSE
	var/icon/generated_icon

	var/obj/structure/easel/easel

	// Painting overlay offset when framed
	var/framed_offset_x = 11
	var/framed_offset_y = 10

	var/painting = FALSE

	pixel_x = 10
	pixel_y = 9

	var/draw_size = 0


//Stick to the easel like glue
/obj/structure/easel/Moved(atom/OldLoc, Dir)
	. = ..()
	if(painting)
		painting.forceMove(loc)

/obj/item/canvas/Moved(atom/OldLoc, Dir)
	. = ..()
	if(easel && !Adjacent(get_turf(easel), 0)) // should not be in inventory
		easel.painting = null
		easel = null

/obj/item/canvas/atom_init()
	. = ..()
	reset_grid()

/obj/item/canvas/proc/reset_grid()
	grid = new/list(width, height)
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			grid[x][y] = canvas_color

/obj/item/canvas/attack_self(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/canvas/tgui_state(mob/user)
	if(finalized)
		return global.physical_obscured_state
	else
		return global.tgui_default_state

/obj/item/canvas/ui_interact(mob/user, datum/tgui/ui)
	tgui_interact(user)

/obj/item/canvas/proc/show(mob/user)
	ui_interact(user)

/obj/item/canvas/proc/get_framed_picture()
	var/mutable_appearance/MA = mutable_appearance(generated_icon)
	MA.pixel_x = framed_offset_x
	MA.pixel_y = framed_offset_y

	return MA

/obj/item/canvas/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canvas", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/canvas/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HELP)
		ui_interact(user)
	else
		return ..()

/obj/item/canvas/tgui_data(mob/user)
	. = ..()
	.["grid"] = grid
	.["name"] = painting_name
	.["finalized"] = finalized
	.["draw_size"] = draw_size

/obj/item/canvas/examine(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/canvas/tgui_act(action, params)
	. = ..()
	if(. || finalized)
		return
	var/mob/user = usr
	switch(action)
		if("paint")
			var/obj/item/I = user.get_active_hand()
			var/color = get_paint_tool_color(I)

			var/x = text2num(params["x"])
			var/y = text2num(params["y"])
			if(x < 1 || x > width || y < 1 || y > height)
				return

			if(!color)
				to_chat(user, "<span class='notice'>После долгого рассматривания этой точки на [CASE(src, PREPOSITIONAL_CASE)], вы с точностью можете сказать, что её цвет: [grid[x][y]].</span>")
				return FALSE

			var/button_type = params["button_type"]

			switch(button_type)
				if("draw")
					draw_grid(x, y, color, draw_size)
				if("fill")
					if(color == grid[x][y])
						return

					fill_grid(x, y, color, grid[x][y])
				else
					return

			used = TRUE
			painting = TRUE
			update_overlays()
			. = TRUE

		if("change_size")
			var/new_size = text2num(params["size"])
			draw_size = clamp(new_size, 0, 2)
			. = TRUE

		if("finalize")
			painting = FALSE
			. = TRUE
			finalize(user)

/obj/item/canvas/proc/draw_grid(x, y, color, pen_size)
	for(var/x_offset in -pen_size to pen_size)
		for(var/y_offset in -pen_size to pen_size)
			if(!check_in_grid(x + x_offset, y + y_offset))
				continue

			grid[x + x_offset][y + y_offset] = color

/obj/item/canvas/proc/fill_grid(x, y, color, background_color)
	var/list/cells_to_check = list(list(x, y, null))
	grid[x][y] = color

	for(var/i in 1 to 1000)
		if(!cells_to_check.len)
			break

		var/list/cell = pop(cells_to_check)

		var/iterate_x = cell[1]
		var/iterate_y = cell[2]
		var/bad_dir = cell[3]

		for(var/check_dir in (global.cardinal - bad_dir))
			var/new_x = iterate_x + X_OFFSET(1, check_dir)
			var/new_y = iterate_y + Y_OFFSET(1, check_dir)

			if(!check_in_grid(new_x, new_y))
				continue
			if(grid[new_x][new_y] != background_color)
				continue

			grid[new_x][new_y] = color
			cells_to_check += list(list(new_x, new_y, reverse_dir[check_dir]))

		CHECK_TICK

/obj/item/canvas/proc/check_in_grid(x, y)
	return (x >= 1) && (x <= width) && (y >= 1) && (y <= height)

/obj/item/canvas/tgui_close(mob/user)
	painting = FALSE
	update_overlays()

/obj/item/canvas/proc/finalize(mob/user)
	finalized = TRUE
	generate_proper_overlay()
	try_rename(user)

/obj/item/canvas/proc/update_overlays()
	cut_overlays()
	if(icon_generated)
		var/mutable_appearance/detail = mutable_appearance(generated_icon)
		detail.appearance_flags = KEEP_TOGETHER
		detail.pixel_x = 1
		detail.pixel_y = 1
		add_overlay(detail)
		return
	if(!used)
		return

	var/mutable_appearance/detail = mutable_appearance(icon, "[icon_state]-wip")
	detail.appearance_flags = KEEP_TOGETHER
	add_overlay(detail)
	. += detail

	if(painting)
		var/mutable_appearance/painting = mutable_appearance(icon, "[icon_state]-anim")
		painting.appearance_flags = KEEP_TOGETHER
		add_overlay(painting)
	else
		cut_overlay(painting)

/obj/item/canvas/proc/generate_proper_overlay()
	if(icon_generated)
		return
	var/data = get_data_string()
	var/png_filename = "cache/paintings/painting[md5(lowertext(data))].png"
	ASSERT(isnum(width))
	ASSERT(isnum(height))

	var/static/regex/r = regex(@"^(?!.*#[0-9a-fA-F]{6}$).*$", "g")
	// checks that the data string does not contain anything besides the hex colors
	ASSERT(!r.Find(data))

	world.ext_python("create_png.py", "'[png_filename]' '[width]' '[height]' '[data]'")
	generated_icon = new(png_filename)
	fdel(png_filename) // don't need this anymore
	icon_generated = TRUE
	update_overlays()

/obj/item/canvas/proc/get_data_string()
	var/list/data = list()
	for(var/y in 1 to height)
		for(var/x in 1 to width)
			data += grid[x][y]
	return data.Join("")

//Todo make this as element ?
/obj/item/canvas/proc/get_paint_tool_color(obj/item/I)
	if(!I)
		return
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon = I
		return crayon.colour
	else if(istype(I, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/P = I
		switch(P.colour) // maybe pens can always hold this color as hex to not care about this?
			if("yellow")
				return "#ffff00"
			if("lime")
				return "#00ff00"
			if("pink")
				return "#ffc0cb"
			if("orange")
				return "#ffa500"
			if("cyan")
				return "#00ffff"
			if("white")
				return "#ffffff"
			if("black")
				return "#000000"
			if("blue")
				return "#0000ff"
			if("purple")
				return "#800080"
			if("red")
				return "#ff0000"
		return P.colour
	else if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/soap) || istype(I, /obj/item/weapon/reagent_containers/glass/rag))
		return canvas_color

/obj/item/canvas/proc/try_rename(mob/user)
	var/new_name = sanitize(input(user, "Как вы хотите назвать картину?", "Картина", null) as text, MAX_NAME_LEN)
	if(new_name != painting_name && new_name && Adjacent(user))
		painting_name = new_name
		SStgui.update_uis(src)

/obj/item/canvas/nineteen_nineteen
	icon_state = "19x19"
	width = 19
	height = 19
	pixel_x = 6
	pixel_y = 9
	framed_offset_x = 7
	framed_offset_y = 4

/obj/item/canvas/twentythree_nineteen
	icon_state = "23x19"
	width = 23
	height = 19
	pixel_x = 4
	pixel_y = 10
	framed_offset_x = 5
	framed_offset_y = 4

/obj/item/canvas/twentythree_twentythree
	icon_state = "23x23"
	width = 23
	height = 23
	pixel_x = 5
	pixel_y = 9
	framed_offset_x = 5
	framed_offset_y = 3
