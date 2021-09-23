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

//Adding canvases
/obj/structure/easel/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/canvas))
		var/obj/item/canvas/canvas = I
		user.drop_from_inventory(canvas)
		painting = canvas
		canvas.forceMove(get_turf(src))
		canvas.layer = layer+0.1
		user.visible_message("<span class='notice'>[user] puts \the [canvas] on \the [src].</span>", "<span class='notice'>You place \the [canvas] on \the [src].</span>")
	else
		return ..()


//Stick to the easel like glue
/obj/structure/easel/Move()
	var/turf/T = get_turf(src)
	. = ..()
	if(painting && painting.loc == T) //Only move if it's near us.
		painting.forceMove(get_turf(src))
	else
		painting = null

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
	var/finalized = FALSE //Blocks edits
	var/author_ckey
	var/icon_generated = FALSE
	var/icon/generated_icon

	// Painting overlay offset when framed
	var/framed_offset_x = 11
	var/framed_offset_y = 10

	pixel_x = 10
	pixel_y = 9

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
			if(!color)
				return FALSE
			var/x = text2num(params["x"])
			var/y = text2num(params["y"])
			if(!(x in 0 to width) || !(y in 0 to height))
				return

			grid[x][y] = color
			used = TRUE
			update_overlays()
			. = TRUE
		if("finalize")
			. = TRUE
			finalize(user)

/obj/item/canvas/proc/finalize(mob/user)
	finalized = TRUE
	author_ckey = user.ckey
	generate_proper_overlay()
	try_rename(user)

/obj/item/canvas/proc/update_overlays()
	cut_overlays()
	if(icon_generated)
		var/mutable_appearance/detail = mutable_appearance(generated_icon)
		detail.pixel_x = 1
		detail.pixel_y = 1
		add_overlay(detail)
		return
	if(!used)
		return

	var/mutable_appearance/detail = mutable_appearance(icon, "[icon_state]wip")
	detail.pixel_x = 1
	detail.pixel_y = 1
	add_overlay(detail)
	. += detail

/obj/item/canvas/proc/generate_proper_overlay()
	if(icon_generated)
		return
	var/data = get_data_string()
	var/png_filename = "cache/paintings/painting[md5(lowertext(data))].png"
	ASSERT(isnum(width))
	ASSERT(isnum(height))

	world.ext_python("create_png.py", "[png_filename] [width] [height] [data]")
	generated_icon = new(png_filename)
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
				return "##ffa500"
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
	else if(istype(I, /obj/item/weapon/soap) || istype(I, /obj/item/weapon/reagent_containers/glass/rag))
		return canvas_color

/obj/item/canvas/proc/try_rename(mob/user)
	var/new_name = sanitize(user, "What do you want to name the painting?")
	if(new_name != painting_name && new_name && Adjacent(user))
		painting_name = new_name
		SStgui.update_uis(src)

/obj/item/canvas/nineteen_nineteen
	icon_state = "19x19"
	width = 19
	height = 19
	pixel_x = 6
	pixel_y = 9
	framed_offset_x = 8
	framed_offset_y = 9

/obj/item/canvas/twentythree_nineteen
	icon_state = "23x19"
	width = 23
	height = 19
	pixel_x = 4
	pixel_y = 10
	framed_offset_x = 6
	framed_offset_y = 8

/obj/item/canvas/twentythree_twentythree
	icon_state = "23x23"
	width = 23
	height = 23
	pixel_x = 5
	pixel_y = 9
	framed_offset_x = 5
	framed_offset_y = 6

//TODO: refactor all frames to /obj/item/wallframe
/obj/item/painting_frame
	name = "painting frame"
	desc = "The perfect showcase for your favorite deathtrap memories."
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "frame-empty"

/obj/item/painting_frame/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		new /obj/item/stack/sheet/wood(get_turf(src.loc), 2)
		qdel(src)
	else
		return ..()

/obj/item/painting_frame/proc/try_build(turf/on_wall)
	if (!Adjacent(on_wall))
		return
	var/ndir = get_dir(on_wall, usr)
	if(!(ndir in cardinal))
		return
	var/turf/T = get_turf(usr)
	var/area/A = get_area(T)
	if(!istype(T, /turf/simulated/floor))
		to_chat(usr, "<span class='warning'>You cannot place [src] on this spot!</span>")
		return

	if(A.always_unpowered)
		to_chat(usr, "<span class='warning'>You cannot place [src] in this area!</span>")
		return

	if(gotwallitem(T, ndir))
		to_chat(usr, "<span class='warning'>There's already an item on this wall!</span>")
		return

	new /obj/structure/sign/painting(T, ndir, 1)
	qdel(src)

/obj/structure/sign/painting
	name = "Painting"
	desc = "Art or \"Art\"? You decide."
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "frame-empty"
	buildable_sign = FALSE
	///Canvas we're currently displaying.
	var/obj/item/canvas/current_canvas
	///Description set when canvas is added.
	var/desc_with_canvas
	// var/persistence_id

/obj/structure/sign/painting/atom_init(mapload, dir, building)
	. = ..()
	// SSpersistence.painting_frames += src
	if(dir)
		set_dir(dir)
	if(building)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -30 : 30)
		pixel_y = (dir & 3)? (dir ==1 ? -30 : 30) : 0

// /obj/structure/sign/painting/Destroy()
// 	. = ..()
// 	SSpersistence.painting_frames -= src

/obj/structure/sign/painting/painting/attack_hand(mob/living/user)
	. = ..()
	if(current_canvas)
		current_canvas.ui_interact(user)
	else
		if(do_after(user, 8, target = src))
			user.visible_message("<span class='notice'>[user] takes off \the [src] from the wall.</span>",
								 "<span class='notice'>You take off \the [src] from the wall.</span>")
			var/turf/T = get_turf(user)
			var/obj/item/painting_frame/F = new /obj/item/painting_frame()
			if(current_canvas)
				var/obj/item/I = current_canvas
				current_canvas = null
				I.forceMove(T)
			if(!issilicon(user))
				user.put_in_hands(F)
			qdel(src)
		return

/obj/structure/sign/painting/attackby(obj/item/I, mob/user, params)
	if(!current_canvas && istype(I, /obj/item/canvas))
		frame_canvas(user, I)
	else if(iswirecutter(I))
		remove_canvas(user)
	else if(current_canvas && current_canvas.painting_name == initial(current_canvas.painting_name) && istype(I, /obj/item/weapon/pen))
		try_rename(user)
	else
		return ..()

/obj/structure/sign/painting/examine(mob/user)
	. = ..()
	// if(persistence_id)
	// 	. += "<span class='notice'>Any painting placed here will be archived at the end of the shift.</span>"
	if(current_canvas)
		current_canvas.ui_interact(user)
		. += "<span class='notice'>Use wirecutters to remove the painting.</span>"

/obj/structure/sign/painting/proc/remove_canvas(mob/living/user)
	if(!current_canvas)
		return
	current_canvas.forceMove(get_turf(src))
	current_canvas = null
	to_chat(user, "<span class='notice'>You remove the painting from the frame.</span>")
	update_appearance()

/obj/structure/sign/painting/proc/frame_canvas(mob/user, obj/item/canvas/new_canvas)
	to_chat(user, "1")
	if(user.drop_from_inventory(new_canvas, src))
		to_chat(user, "2")
		current_canvas = new_canvas
		if(!current_canvas.finalized)
			current_canvas.finalize(user)
		to_chat(user, "<span class='notice'>You frame [current_canvas].</span>")
	update_appearance()

/obj/structure/sign/painting/proc/try_rename(mob/user)
	if(current_canvas.painting_name == initial(current_canvas.painting_name))
		current_canvas.try_rename(user)

/obj/structure/sign/painting/proc/update_appearance()
	update_icon()
	update_name_and_desc()


/obj/structure/sign/painting/update_icon()
	. = ..()
	update_overlays()
	if(current_canvas?.generated_icon)
		icon_state = "frame-overlay"
	else
		icon_state = "frame-empty"


/obj/structure/sign/painting/proc/update_overlays()
	cut_overlays()
	if(current_canvas?.generated_icon)
		var/mutable_appearance/MA = mutable_appearance(current_canvas.generated_icon)
		MA.pixel_x = current_canvas.framed_offset_x
		MA.pixel_y = current_canvas.framed_offset_y
		add_overlay(MA)
		var/mutable_appearance/frame = mutable_appearance(current_canvas.icon, "[current_canvas.icon_state]frame")
		frame.pixel_x = current_canvas.framed_offset_x - 1
		frame.pixel_y = current_canvas.framed_offset_y - 1
		add_overlay(frame)

/obj/structure/sign/painting/proc/update_name_and_desc()
	if(current_canvas)
		name = "painting - [current_canvas.painting_name]"
		desc = desc_with_canvas
	else
		name = initial(name)
		desc = initial(desc)

/**
 * Loads a painting from SSpersistence. Called globally by said subsystem when it inits
 *
 * Deleting paintings leaves their json, so this proc will remove the json and try again if it finds one of those.
 */
// /obj/structure/sign/painting/proc/load_persistent()
// 	if(!persistence_id || !SSpersistence.paintings || !SSpersistence.paintings[persistence_id])
// 		return
// 	var/list/painting_category = SSpersistence.paintings[persistence_id]
// 	var/list/painting
// 	while(!painting)
// 		if(!length(SSpersistence.paintings[persistence_id]))
// 			return //aborts loading anything this category has no usable paintings
// 		var/list/chosen = pick(painting_category)
// 		if(!fexists("cache/paintings/[persistence_id]/[chosen["md5"]].png")) //shitmin deleted this art, lets remove json entry to avoid errors
// 			painting_category -= list(chosen)
// 			continue //and try again
// 		painting = chosen
// 	var/title = painting["title"]
// 	var/author = painting["ckey"]
// 	var/png = "cache/paintings/[persistence_id]/[painting["md5"]].png"
// 	if(!title)
// 		title = "Untitled Artwork" //legacy artwork allowed null names which was bad for the json, lets fix that
// 		painting["title"] = title
// 	var/icon/I = new(png)
// 	var/obj/item/canvas/new_canvas
// 	var/w = I.Width()
// 	var/h = I.Height()
// 	for(var/T in typesof(/obj/item/canvas))
// 		new_canvas = T
// 		if(initial(new_canvas.width) == w && initial(new_canvas.height) == h)
// 			new_canvas = new T(src)
// 			break
// 	new_canvas.fill_grid_from_icon(I)
// 	new_canvas.generated_icon = I
// 	new_canvas.icon_generated = TRUE
// 	new_canvas.finalized = TRUE
// 	new_canvas.painting_name = title
// 	new_canvas.author_ckey = author
// 	new_canvas.name = "painting - [title]"
// 	current_canvas = new_canvas
// 	update_icon()
// 	update_name_and_desc()

// /obj/structure/sign/painting/proc/save_persistent()
// 	if(!persistence_id || !current_canvas)
// 		return
// 	if(sanitize_filename(persistence_id) != persistence_id)
// 		stack_trace("Invalid persistence_id - [persistence_id]")
// 		return
// 	if(!current_canvas.painting_name)
// 		current_canvas.painting_name = "Untitled Artwork"
// 	var/data = current_canvas.get_data_string()
// 	var/md5 = md5(lowertext(data))
// 	var/list/current = SSpersistence.paintings[persistence_id]
// 	if(!current)
// 		current = list()
// 	for(var/list/entry in current)
// 		if(entry["md5"] == md5)
// 			return
// 	var/png_directory = "cache/paintings/[persistence_id]/"
// 	var/png_path = png_directory + "[md5].png"
// 	var/result = rustg_dmi_create_png(png_path, "[current_canvas.width]", "[current_canvas.height]", data)
// 	if(result)
// 		CRASH("Error saving persistent painting: [result]")
// 	current += list(list("title" = current_canvas.painting_name , "md5" = md5, "ckey" = current_canvas.author_ckey))
// 	SSpersistence.paintings[persistence_id] = current

// /obj/item/canvas/proc/fill_grid_from_icon(icon/I)
// 	var/h = I.Height() + 1
// 	for(var/x in 1 to width)
// 		for(var/y in 1 to height)
// 			grid[x][y] = I.GetPixel(x, h-y)

//Presets for art gallery mapping, for paintings to be shared across stations
// /obj/structure/sign/painting/library
// 	name = "\improper Public Painting Exhibit mounting"
// 	desc = "For art pieces hung by the public."
// 	desc_with_canvas = "A piece of art (or \"art\"). Anyone could've hung it."
	// persistence_id = "library"

// /obj/structure/sign/painting/library_secure
// 	name = "\improper Curated Painting Exhibit mounting"
// 	desc = "For masterpieces hand-picked by the curator."
// 	desc_with_canvas = "A masterpiece hand-picked by the curator, supposedly."
	// persistence_id = "library_secure"

// /obj/structure/sign/painting/library_private // keep your smut away from prying eyes, or non-librarians at least
// 	name = "\improper Private Painting Exhibit mounting"
// 	desc = "For art pieces deemed too subversive or too illegal to be shared outside of curators."
// 	desc_with_canvas = "A painting hung away from lesser minds."
	// persistence_id = "library_private"

// /obj/structure/sign/painting/vv_get_dropdown()
// 	. = ..()
// 	VV_DROPDOWN_OPTION(VV_HK_REMOVE_PAINTING, "Remove Persistent Painting")

// /obj/structure/sign/painting/vv_do_topic(list/href_list)
// 	. = ..()
// 	if(href_list[VV_HK_REMOVE_PAINTING])
// 		if(!check_rights(NONE))
// 			return
// 		var/mob/user = usr
// 		if(!persistence_id || !current_canvas)
// 			to_chat(user, "<span class='warning'>This is not a persistent painting.</span>")
// 			return
// 		var/md5 = md5(lowertext(current_canvas.get_data_string()))
// 		var/author = current_canvas.author_ckey
// 		var/list/current = SSpersistence.paintings[persistence_id]
// 		if(current)
// 			for(var/list/entry in current)
// 				if(entry["md5"] == md5)
// 					current -= entry
// 			var/png = "cache/paintings/[persistence_id]/[md5].png"
// 			fdel(png)
// 		for(var/obj/structure/sign/painting/P in SSpersistence.painting_frames)
// 			if(P.current_canvas && md5(P.current_canvas.get_data_string()) == md5)
// 				QDEL_NULL(P.current_canvas)
// 				P.update_icon()
// 				P.update_name_and_desc()
// 		log_admin("[key_name(user)] has deleted a persistent painting made by [author].")
// 		message_admins("<span class='notice'>[key_name_admin(user)] has deleted persistent painting made by [author].</span>")
