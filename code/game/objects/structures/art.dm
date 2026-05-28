//! Persistence code is commented out while porting
//! Because there were no Persistence when it was ported

///////////
// EASEL //
///////////

/obj/structure/easel
	name = "easel"
	desc = "Only for the finest of art!"
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
		user.visible_message("<span class='notice'>[user] puts \the [canvas] on \the [src].</span>", "<span class='notice'>You place \the [canvas] on \the [src].</span>")
	else
		return ..()

/obj/item/canvas
	name = "canvas"
	desc = "Draw out your soul on this canvas!"
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

	var/list/fill_mask = list(
							  				list(0, -1),
							  list(-1, 0),               list(1, 0),
							  				list(0, 1)
							)

	var/list/draw_mask = list(
							  list(-1, -1), list(0, -1), list(1, -1),
							  list(-1, 0),               list(1, 0),
							  list(-1, 1),  list(0, 1),  list(1, 1)
							)
	var/draw_size = 1


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

			var/button_type = params["button_type"]
			if(x < 1 || x > width || y < 1 || y > height)
				return

			if(!color)
				to_chat(user, "<span class='notice'>After looking at this particular dot on canvas, you can surely say it's color encoding is: [grid[x][y]].</span>")
				return FALSE

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
			draw_size = clamp(new_size, 1, 3)
			. = TRUE

		if("finalize")
			painting = FALSE
			. = TRUE
			finalize(user)

/obj/item/canvas/proc/draw_grid(x, y, color, iterator)
	iterator--
	grid[x][y] = color
	if(iterator <= 0)
		return

	for(var/mask in draw_mask)
		var/new_x = x + mask[1]
		var/new_y = y + mask[2]
		if(!check_in_grid(new_x, new_y)) continue

		draw_grid(new_x, new_y, color, iterator)

/obj/item/canvas/proc/fill_grid(x, y, color, background_color)
	var/list/cells_to_check = list(list(x, y))
	grid[x][y] = color

	for(var/i in 1 to 1000)
		if(!cells_to_check.len)
			break

		var/list/cell = pop(cells_to_check)

		var/iterate_x = cell[1]
		var/iterate_y = cell[2]

		for(var/mask in fill_mask)
			var/new_x = iterate_x + mask[1]
			var/new_y = iterate_y + mask[2]
			if(!check_in_grid(new_x, new_y)) continue
			if(grid[new_x][new_y] != background_color) continue
			grid[new_x][new_y] = color
			cells_to_check += list(list(new_x, new_y))

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

	world.ext_python("create_png.py", "'[png_filename]' '[width]' '[height]' '[data]' 'RGB'")
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



/obj/structure/statue
	name = "statue"
	cases = list("скульптура", "скульптуры", "скульптуре", "скульптуру", "скульптурой", "скульптуре")

	icon = 'icons/obj/artstuff.dmi'
	icon_state = "statue_empty"
	w_class = SIZE_HUMAN
	anchored = FALSE
	density = FALSE

	max_integrity = 50
	resistance_flags = CAN_BE_HIT

	var/list/grid
	var/finished = FALSE

	var/width = 16
	var/height = 28

	var/used = FALSE
	var/statue_name = "Untitled Artwork" //Painting name, this is set after framing.
	var/icon_generated = FALSE
	var/icon/generated_icon

	var/material_color
	var/brighter_color
	var/darker_color

/obj/structure/statue/examine(mob/user)
	. = ..()
	to_chat(user, "Подпись на пьедестале: '[statue_name]'")

/obj/structure/statue/proc/reset_grid(new_color)
	used = TRUE
	density = TRUE
	material_color = new_color
	brighter_color = color_shift_luminance(new_color, 30)
	darker_color = color_shift_luminance(new_color, -30)

	grid = new/list(width, height)
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			if(x == 1 || y == 1)
				grid[x][y] = brighter_color
			else if(x == width || y == height)
				grid[x][y] = darker_color
			else
				grid[x][y] = material_color

	update_overlays()

/obj/structure/statue/tgui_state(mob/user)
	if(finished)
		return global.physical_obscured_state
	else
		return global.tgui_default_state

/obj/structure/statue/ui_interact(mob/user, datum/tgui/ui)
	if(!finished)
		tgui_interact(user)

/obj/structure/statue/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canvas", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/structure/statue/attackby(obj/item/I, mob/living/user, params)
	if(!grid && istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/sheet = I
		if(!sheet.use(10))
			return

		reset_grid("#a1a1a5")
		return

	if(!grid && istype(I, /obj/item/stack/sheet/mineral/gold))
		var/obj/item/stack/sheet/metal/sheet = I
		if(!sheet.use(10))
			return

		reset_grid("#ffc20e")
		return

	if(!grid && istype(I, /obj/item/stack/sheet/mineral/phoron))
		var/obj/item/stack/sheet/metal/sheet = I
		if(!sheet.use(10))
			return

		reset_grid("#da3999")
		return

	if(!grid && istype(I, /obj/item/stack/sheet/mineral/uranium))
		var/obj/item/stack/sheet/metal/sheet = I
		if(!sheet.use(10))
			return

		reset_grid("#4c7a43")
		return

	if(!grid && istype(I, /obj/item/stack/sheet/mineral/sandstone))
		var/obj/item/stack/sheet/metal/sheet = I
		if(!sheet.use(10))
			return

		reset_grid("#d0bfa0")
		return

	if(user.a_intent == INTENT_HELP)
		ui_interact(user)
	else
		return ..()

/obj/structure/statue/tgui_data(mob/user)
	. = ..()
	.["grid"] = grid
	.["name"] = statue_name
	.["finalized"] = finished

/obj/structure/statue/tgui_act(action, params)
	. = ..()
	if(. || finished)
		return
	var/mob/user = usr
	switch(action)
		if("paint")
			var/obj/item/I = user.get_active_hand()
			if(!I || !iscutter(I))
				return

			var/x = text2num(params["x"])
			var/y = text2num(params["y"])

			if(x < 1 || x > width || y < 1 || y > height)
				return

			chip_square(x, y)

			used = TRUE
			update_overlays()
			. = TRUE

		if("finalize")
			. = TRUE
			finish(user)

/obj/structure/statue/proc/chip_square(x, y)
	var/square_color = grid[x][y]

	if(square_color == "#000000")
		return

	if(square_color == darker_color)
		grid[x][y] = "#000000"

		if(check_in_grid(x - 1, y))
			if(grid[x - 1][y] == material_color)
				grid[x - 1][y] = darker_color

		if(check_in_grid(x, y - 1))
			if(grid[x][y - 1] == material_color)
				grid[x][y - 1] = darker_color

	if((square_color == material_color) || (square_color == brighter_color))
		grid[x][y] = darker_color

	if(check_in_grid(x + 1, y))
		if(grid[x + 1][y] == material_color)
			grid[x + 1][y] = brighter_color

	if(check_in_grid(x, y + 1))
		if(grid[x][y + 1] == material_color)
			grid[x][y + 1] = brighter_color

/obj/structure/statue/proc/check_in_grid(x, y)
	return (x >= 1) && (x <= width) && (y >= 1) && (y <= height)

/obj/structure/statue/proc/finish(mob/user)
	finished = TRUE
	generate_proper_overlay()
	try_rename(user)

/obj/structure/statue/proc/update_overlays()
	cut_overlays()
	if(icon_generated)
		var/mutable_appearance/detail = mutable_appearance(generated_icon)
		detail.appearance_flags = KEEP_TOGETHER
		detail.pixel_x = round((32 - width) / 2)
		detail.pixel_y = 5
		add_overlay(detail)
		return
	if(!used)
		return

	var/mutable_appearance/detail = mutable_appearance(icon, "statue_wip")
	detail.appearance_flags = KEEP_TOGETHER
	add_overlay(detail)
	. += detail

/obj/structure/statue/proc/generate_proper_overlay()
	if(icon_generated)
		return
	var/data = get_data_string()
	var/png_filename = "cache/paintings/painting[md5(lowertext(data))].png"
	ASSERT(isnum(width))
	ASSERT(isnum(height))

	var/static/regex/r = regex(@"^(?!.*#[0-9a-fA-F]{8}$).*$", "g")
	// checks that the data string does not contain anything besides the hex colors
	ASSERT(!r.Find(data))

	world.ext_python("create_png.py", "'[png_filename]' '[width]' '[height]' '[data]' 'RGBA'")
	generated_icon = new(png_filename)
	fdel(png_filename) // don't need this anymore
	icon_generated = TRUE
	update_overlays()

/obj/structure/statue/proc/get_data_string()
	var/list/data = list()
	for(var/y in 1 to height)
		for(var/x in 1 to width)
			data += (grid[x][y] + (grid[x][y] == "#000000" ? "00" : "ff"))
	return data.Join("")

/obj/structure/statue/proc/try_rename(mob/user)
	var/new_name = sanitize(input(user, "Как вы хотите назвать скульптуру?", "Скульптура", null) as text, MAX_NAME_LEN)
	if(new_name != statue_name && new_name && Adjacent(user))
		statue_name = new_name
		SStgui.update_uis(src)
