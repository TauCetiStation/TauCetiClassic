var/global/list/baked_smooth_icons = list()

SUBSYSTEM_DEF(icon_smooth)
	name = "Icon Smoothing"
	init_order = SS_INIT_ICON_SMOOTH
	wait = SS_WAIT_ICON_SMOOTH
	priority = SS_PRIOTITY_ICON_SMOOTH
	flags = SS_TICKER

	var/list/smooth_queue = list()
	var/list/deferred = list()

/datum/controller/subsystem/icon_smooth/fire()
	var/list/cached = smooth_queue
	while(cached.len)
		var/atom/A = cached[cached.len]
		cached.len--
		if (A.initialized)
			smooth_icon(A)
		else
			deferred += A
		if (MC_TICK_CHECK)
			return

	if (!cached.len)
		if (deferred.len)
			smooth_queue = deferred
			deferred = cached
		else
			can_fire = FALSE

/datum/controller/subsystem/icon_smooth/Initialize()
	for(var/zlevel in SSmapping.levels_by_any_trait(list(ZTRAIT_STATION, ZTRAIT_CENTCOM, ZTRAIT_MINING, ZTRAIT_SPACE_RUINS)))
		smooth_zlevel(zlevel, TRUE)
	var/queue = smooth_queue
	smooth_queue = list()
	for(var/V in queue)
		var/atom/A = V
		if(!A)
			continue
		smooth_icon(A)
		CHECK_TICK

	return ..()

#ifdef MANUAL_ICON_SMOOTH
/mob/verb/ChooseDMI(dmi as file)
	var/dmifile = file(dmi)
	if(isfile(dmifile) && (copytext("[dmifile]",-4) == ".dmi"))
		SliceNDice(dmifile)
	else
		to_chat(world, "<span class='warning'>Bad DMI file '[dmifile]'</span>")

/atom/proc/SliceNDice(dmifile as file)
	var/font_size = 32
#else
/atom/proc/SliceNDice(dmifile)
#endif

	var/STATE_COUNT_NORMAL = 4
	var/STATE_COUNT_DIAGONAL = 7

	if(!isfile(dmifile) || (copytext("[dmifile]",-4) != ".dmi"))
		CRASH("Bad DMI file '[dmifile]'")

	var/icon/sourceIcon = icon(dmifile)
	var/list/SourceIconStates = sourceIcon.IconStates()
	var/list/states = list("box", "line", "line_v", "line_h", "center_4", "center_8", "diag", "diag_corner_a", "diag_corner_b")
	var/list/ExcludedMiscIconStates = SourceIconStates - states // any states that are not related to smooth states, will be added as is in the end

	if(SourceIconStates.Find("line") && (SourceIconStates.Find("line_v") || SourceIconStates.Find("line_h")))
		CRASH("Conflict states found: 'line' state cannot be used at the same time with 'line_v' and 'line_h' states.")
	else if(SourceIconStates.Find("line_v") && SourceIconStates.Find("line_h")) // not all icons are symmetrical, thats why we need support for those states.
		STATE_COUNT_NORMAL = 5
		STATE_COUNT_DIAGONAL = 8

#ifdef MANUAL_ICON_SMOOTH
	var/create_false_wall_animations = alert(usr, "Generate false wall animation states?", "Confirmation", "Yes", "No") == "Yes" ? TRUE : FALSE
#else
	var/create_false_wall_animations = findtext("[dmifile]", "has_false_walls") ? TRUE : FALSE
#endif

	for(var/state in states) // exclude states that doesn't exist
		if(!(state in SourceIconStates))
			states -= state

#ifdef MANUAL_ICON_SMOOTH
	to_chat(world, "<B>[dmifile] - states: [states.len]</B>")
#endif

	var/sourceIconWidth = sourceIcon.Width() // x
	var/sourceIconHeight = sourceIcon.Height() // y

	var/sourceIconWidthHalf = sourceIconWidth / 2
	var/sourceIconHeightHalf = sourceIconHeight / 2

	var/sourceIconWidthHalfStart = sourceIconWidthHalf + 1
	var/sourceIconHeightHalfStart = sourceIconHeightHalf + 1

	if(!IS_EVEN(sourceIconWidth / 2) || !IS_EVEN(sourceIconHeight / 2))
		CRASH("Unexpected dimension: Uneven icon width or height, expected each [sourceIconWidth]x[sourceIconHeight] to be divided by 2.")

	if(states.len < STATE_COUNT_NORMAL)
		CRASH("Unexpected Amount of States: Too few states: [states.len],  expected [STATE_COUNT_NORMAL] (Non-Diagonal) or [STATE_COUNT_DIAGONAL] (Diagonal)")
#ifdef MANUAL_ICON_SMOOTH
	else if(states.len == STATE_COUNT_NORMAL)
		to_chat(world, "[STATE_COUNT_NORMAL] States, running in Non-Diagonal mode")
	else if(states.len == STATE_COUNT_DIAGONAL)
		to_chat(world, "[STATE_COUNT_DIAGONAL] States, running in Diagonal mode")
#endif
	else if(states.len > STATE_COUNT_DIAGONAL)
		CRASH("Unexpected Amount of States: Too many states: [states.len],  expected [STATE_COUNT_NORMAL] (Non-Diagonal) or [STATE_COUNT_DIAGONAL] (Diagonal)")

	var/icon/outputIcon = new /icon()

	var/filename_temp = "[copytext("[dmifile]", 1, -4)]-smooth_temp.dmi"

	for(var/state in states)
		var/statename = lowertext(state)
		outputIcon = icon(filename_temp) //open the icon again each iteration, to work around byond memory limits

		switch(statename)
			if("box")
				var/icon/box = icon(sourceIcon, state)

				var/icon/corner1i = icon(box)
				corner1i.DrawBox(null, 1, 1, sourceIconWidth, sourceIconHeightHalf)
				corner1i.DrawBox(null, sourceIconWidthHalfStart, 1, sourceIconWidth, sourceIconHeight)
				outputIcon.Insert(corner1i, "1-i")

				var/icon/corner2i = icon(box)
				corner2i.DrawBox(null, 1, 1, sourceIconWidthHalf, sourceIconHeight)
				corner2i.DrawBox(null, sourceIconWidthHalfStart, 1, sourceIconWidth, sourceIconHeightHalf)
				outputIcon.Insert(corner2i, "2-i")

				var/icon/corner3i = icon(box)
				corner3i.DrawBox(null, 1, sourceIconHeight, sourceIconWidth, sourceIconHeightHalfStart)
				corner3i.DrawBox(null, sourceIconWidthHalfStart, sourceIconHeight, sourceIconWidth, 1)
				outputIcon.Insert(corner3i, "3-i")

				var/icon/corner4i = icon(box)
				corner4i.DrawBox(null, 1, 1, sourceIconWidthHalf, sourceIconHeight)
				corner4i.DrawBox(null, sourceIconWidthHalfStart, sourceIconHeightHalfStart, sourceIconWidth, sourceIconHeight)
				outputIcon.Insert(corner4i, "4-i")

#ifdef MANUAL_ICON_SMOOTH
				// blame bicon() if you get wrong previews (does not affect actual result).
				to_chat(world, "Box: <font size = [font_size]>[bicon(box)]</font> -> <font size = [font_size]>[bicon(corner1i)] [bicon(corner2i)] [bicon(corner3i)] [bicon(corner4i)]</font>")
#endif

			if("line")
				var/icon/line = icon(sourceIcon, state)

				//Vertical
				var/icon/line1n = icon(line)
				line1n.DrawBox(null, 1, 1, sourceIconWidth, sourceIconHeightHalf)
				line1n.DrawBox(null, sourceIconWidthHalfStart, 1, sourceIconWidth, sourceIconHeight)
				outputIcon.Insert(line1n, "1-n")

				var/icon/line2n = icon(line)
				line2n.DrawBox(null, 1, 1, sourceIconWidthHalf, sourceIconHeight)
				line2n.DrawBox(null, sourceIconWidthHalfStart, 1, sourceIconWidth, sourceIconHeightHalf)
				outputIcon.Insert(line2n, "2-n")

				var/icon/line3s = icon(line)
				line3s.DrawBox(null, 1, sourceIconHeight, sourceIconWidth, sourceIconHeightHalfStart)
				line3s.DrawBox(null, sourceIconWidthHalfStart, sourceIconHeight, sourceIconWidth, 1)
				outputIcon.Insert(line3s, "3-s")

				var/icon/line4s = icon(line)
				line4s.DrawBox(null, 1, 1, sourceIconWidthHalf, sourceIconHeight)
				line4s.DrawBox(null, sourceIconWidthHalfStart, sourceIconHeightHalfStart, sourceIconWidth, sourceIconHeight)
				outputIcon.Insert(line4s, "4-s")

				//Horizontal
				var/icon/line1w = icon(line3s) //Correct
				line1w.Turn(90)
				outputIcon.Insert(line1w, "1-w")

				var/icon/line2e = icon(line1n)
				line2e.Turn(90)
				outputIcon.Insert(line2e, "2-e")

				var/icon/line3w = icon(line4s)
				line3w.Turn(90)
				outputIcon.Insert(line3w, "3-w")

				var/icon/line4e = icon(line2n)
				line4e.Turn(90)
				outputIcon.Insert(line4e, "4-e")

#ifdef MANUAL_ICON_SMOOTH
				to_chat(world, "Line: <font size = [font_size]>[bicon(line)]</font> -> <font size = [font_size]>[bicon(line1n)] [bicon(line2n)] [bicon(line3s)] [bicon(line4s)] [bicon(line1w)] [bicon(line2e)] [bicon(line3w)] [bicon(line4e)]</font>")
#endif

			if("line_v")
				var/icon/line = icon(sourceIcon, state)

				//Vertical
				var/icon/line1n = icon(line)
				line1n.DrawBox(null, 1, 1, sourceIconWidth, sourceIconHeightHalf)
				line1n.DrawBox(null, sourceIconWidthHalfStart, 1, sourceIconWidth, sourceIconHeight)
				outputIcon.Insert(line1n, "1-n")

				var/icon/line2n = icon(line)
				line2n.DrawBox(null, 1, 1, sourceIconWidthHalf, sourceIconHeight)
				line2n.DrawBox(null, sourceIconWidthHalfStart, 1, sourceIconWidth, sourceIconHeightHalf)
				outputIcon.Insert(line2n, "2-n")

				var/icon/line3s = icon(line)
				line3s.DrawBox(null, 1, sourceIconHeight, sourceIconWidth, sourceIconHeightHalfStart)
				line3s.DrawBox(null, sourceIconWidthHalfStart, sourceIconHeight, sourceIconWidth, 1)
				outputIcon.Insert(line3s, "3-s")

				var/icon/line4s = icon(line)
				line4s.DrawBox(null, 1, 1, sourceIconWidthHalf, sourceIconHeight)
				line4s.DrawBox(null, sourceIconWidthHalfStart, sourceIconHeightHalfStart, sourceIconWidth, sourceIconHeight)
				outputIcon.Insert(line4s, "4-s")

#ifdef MANUAL_ICON_SMOOTH
				to_chat(world, "Line Vertical: <font size = [font_size]>[bicon(line)]</font> -> <font size = [font_size]>[bicon(line1n)] [bicon(line2n)] [bicon(line3s)] [bicon(line4s)]</font>")
#endif

			if("line_h")
				var/icon/line = icon(sourceIcon, state)

				//Horizontal
				var/icon/line1w = icon(line)
				line1w.DrawBox(null, 1, 1, sourceIconWidth, sourceIconHeightHalf)
				line1w.DrawBox(null, sourceIconWidthHalfStart, 1, sourceIconWidth, sourceIconHeight)
				outputIcon.Insert(line1w, "1-w")

				var/icon/line2e = icon(line)
				line2e.DrawBox(null, 1, 1, sourceIconWidthHalf, sourceIconHeight)
				line2e.DrawBox(null, sourceIconWidthHalfStart, 1, sourceIconWidth, sourceIconHeightHalf)
				outputIcon.Insert(line2e, "2-e")

				var/icon/line3w = icon(line)
				line3w.DrawBox(null, 1, sourceIconHeight, sourceIconWidth, sourceIconHeightHalfStart)
				line3w.DrawBox(null, sourceIconWidthHalfStart, sourceIconHeight, sourceIconWidth, 1)
				outputIcon.Insert(line3w, "3-w")

				var/icon/line4e = icon(line)
				line4e.DrawBox(null, 1, 1, sourceIconWidthHalf, sourceIconHeight)
				line4e.DrawBox(null, sourceIconWidthHalfStart, sourceIconHeightHalfStart, sourceIconWidth, sourceIconHeight)
				outputIcon.Insert(line4e, "4-e")

#ifdef MANUAL_ICON_SMOOTH
				to_chat(world, "Line Horizontal: <font size = [font_size]>[bicon(line)]</font> -> <font size = [font_size]>[bicon(line1w)] [bicon(line2e)] [bicon(line3w)] [bicon(line4e)]</font>")
#endif

			if("center_4")
				var/icon/center4 = icon(sourceIcon, state)

				var/icon/corner1nw = icon(center4)
				corner1nw.DrawBox(null, 1, 1, sourceIconWidth, sourceIconHeightHalf)
				corner1nw.DrawBox(null, sourceIconWidthHalfStart, 1, sourceIconWidth, sourceIconHeight)
				outputIcon.Insert(corner1nw, "1-nw")

				var/icon/corner2ne = icon(center4)
				corner2ne.DrawBox(null, 1, 1, sourceIconWidthHalf, sourceIconHeight)
				corner2ne.DrawBox(null, sourceIconWidthHalfStart, 1, sourceIconWidth, sourceIconHeightHalf)
				outputIcon.Insert(corner2ne, "2-ne")

				var/icon/corner3sw = icon(center4)
				corner3sw.DrawBox(null, 1, sourceIconHeight, sourceIconWidth, sourceIconHeightHalfStart)
				corner3sw.DrawBox(null, sourceIconWidthHalfStart, sourceIconHeight, sourceIconWidth, 1)
				outputIcon.Insert(corner3sw, "3-sw")

				var/icon/corner4se = icon(center4)
				corner4se.DrawBox(null, 1, 1, sourceIconWidthHalf, sourceIconHeight)
				corner4se.DrawBox(null, sourceIconWidthHalfStart, sourceIconHeightHalfStart, sourceIconWidth, sourceIconHeight)
				outputIcon.Insert(corner4se, "4-se")

#ifdef MANUAL_ICON_SMOOTH
				to_chat(world, "Center4: <font size = [font_size]>[bicon(center4)]</font> -> <font size = [font_size]>[bicon(corner1nw)] [bicon(corner2ne)] [bicon(corner3sw)] [bicon(corner4se)]</font>")
#endif

			if("center_8")
				var/icon/center8 = icon(sourceIcon, state)

				var/icon/corner1f = icon(center8)
				corner1f.DrawBox(null, 1, 1, sourceIconWidth, sourceIconHeightHalf)
				corner1f.DrawBox(null, sourceIconWidthHalfStart, 1, sourceIconWidth, sourceIconHeight)
				outputIcon.Insert(corner1f, "1-f")

				var/icon/corner2f = icon(center8)
				corner2f.DrawBox(null, 1, 1, sourceIconWidthHalf, sourceIconHeight)
				corner2f.DrawBox(null, sourceIconWidthHalfStart, 1, sourceIconWidth, sourceIconHeightHalf)
				outputIcon.Insert(corner2f, "2-f")

				var/icon/corner3f = icon(center8)
				corner3f.DrawBox(null, 1, sourceIconHeight, sourceIconWidth, sourceIconHeightHalfStart)
				corner3f.DrawBox(null, sourceIconWidthHalfStart, sourceIconHeight, sourceIconWidth, 1)
				outputIcon.Insert(corner3f, "3-f")

				var/icon/corner4f = icon(center8)
				corner4f.DrawBox(null, 1, 1, sourceIconWidthHalf, sourceIconHeight)
				corner4f.DrawBox(null, sourceIconWidthHalfStart, sourceIconHeightHalfStart, sourceIconWidth, sourceIconHeight)
				outputIcon.Insert(corner4f, "4-f")

#ifdef MANUAL_ICON_SMOOTH
				to_chat(world, "Center8: <font size = [font_size]>[bicon(center8)]</font> -> <font size = [font_size]>[bicon(corner1f)] [bicon(corner2f)] [bicon(corner3f)] [bicon(corner4f)]</font>")
#endif

			if("diag")
				var/icon/diag = icon(sourceIcon, state)

				var/icon/diagse = icon(diag) //No work
				outputIcon.Insert(diagse, "d-se")

				var/icon/diagsw = icon(diag)
				diagsw.Turn(90)
				outputIcon.Insert(diagsw, "d-sw")

				var/icon/diagne = icon(diag)
				diagne.Turn(-90)
				outputIcon.Insert(diagne, "d-ne")

				var/icon/diagnw = icon(diag)
				diagnw.Turn(180)
				outputIcon.Insert(diagnw, "d-nw")

#ifdef MANUAL_ICON_SMOOTH
				to_chat(world, "Diag: <font size = [font_size]>[bicon(diag)]</font> -> <font size = [font_size]>[bicon(diagse)] [bicon(diagsw)] [bicon(diagne)] [bicon(diagnw)]</font>")
#endif

			if("diag_corner_a")
				var/icon/diag_corner_a = icon(sourceIcon, state)

				var/icon/diagse0 = icon(diag_corner_a) //No work
				outputIcon.Insert(diagse0, "d-se-0")

				var/icon/diagsw0 = icon(diag_corner_a)
				diagsw0.Turn(90)
				outputIcon.Insert(diagsw0, "d-sw-0")

				var/icon/diagne0 = icon(diag_corner_a)
				diagne0.Turn(-90)
				outputIcon.Insert(diagne0, "d-ne-0")

				var/icon/diagnw0 = icon(diag_corner_a)
				diagnw0.Turn(180)
				outputIcon.Insert(diagnw0, "d-nw-0")

#ifdef MANUAL_ICON_SMOOTH
				to_chat(world, "Diag_Corner_A: <font size = [font_size]>[bicon(diag_corner_a)]</font> -> <font size = [font_size]>[bicon(diagse0)] [bicon(diagsw0)] [bicon(diagne0)] [bicon(diagnw0)]</font>")
#endif

			if("diag_corner_b")
				var/icon/diag_corner_b = icon(sourceIcon, state)

				var/icon/diagse1 = icon(diag_corner_b) //No work
				outputIcon.Insert(diagse1, "d-se-1")

				var/icon/diagsw1 = icon(diag_corner_b)
				diagsw1.Turn(90)
				outputIcon.Insert(diagsw1, "d-sw-1")

				var/icon/diagne1 = icon(diag_corner_b)
				diagne1.Turn(-90)
				outputIcon.Insert(diagne1, "d-ne-1")

				var/icon/diagnw1 = icon(diag_corner_b)
				diagnw1.Turn(180)
				outputIcon.Insert(diagnw1, "d-nw-1")

#ifdef MANUAL_ICON_SMOOTH
				to_chat(world, "Diag_Corner_B: <font size = [font_size]>[bicon(diag_corner_b)]</font> -> <font size = [font_size]>[bicon(diagse1)] [bicon(diagsw1)] [bicon(diagne1)] [bicon(diagnw1)]</font>")
#endif

		fcopy(outputIcon, filename_temp)	//Update output icon each iteration
		CHECK_TICK

	fdel(filename_temp) // we dont need it anymore.

	var/list/smooth_dirs = list(
		N_NORTH,
		N_SOUTH,
		N_EAST,
		N_WEST,

		N_NORTH|N_SOUTH,
		N_EAST|N_WEST,

		N_NORTH|N_EAST,
		N_NORTH|N_WEST,
		N_SOUTH|N_EAST,
		N_SOUTH|N_WEST,

		N_NORTH|N_SOUTH|N_WEST,
		N_SOUTH|N_EAST|N_WEST,
		N_NORTH|N_SOUTH|N_EAST,
		N_NORTH|N_EAST|N_WEST,

		N_NORTH|N_SOUTH|N_EAST|N_WEST,

		N_NORTH|N_EAST|N_NORTHEAST,
		N_NORTH|N_WEST|N_NORTHWEST,
		N_SOUTH|N_EAST|N_SOUTHEAST,
		N_SOUTH|N_WEST|N_SOUTHWEST,

		N_NORTH|N_SOUTH|N_EAST|N_SOUTHEAST,
		N_NORTH|N_SOUTH|N_WEST|N_SOUTHWEST,
		N_NORTH|N_SOUTH|N_EAST|N_NORTHEAST,
		N_NORTH|N_SOUTH|N_WEST|N_NORTHWEST,

		N_NORTH|N_EAST|N_WEST|N_NORTHWEST,
		N_NORTH|N_EAST|N_WEST|N_NORTHEAST,
		N_SOUTH|N_EAST|N_WEST|N_SOUTHWEST,
		N_SOUTH|N_EAST|N_WEST|N_SOUTHEAST,

		N_NORTH|N_SOUTH|N_EAST|N_NORTHEAST|N_SOUTHEAST,
		N_NORTH|N_SOUTH|N_WEST|N_NORTHWEST|N_SOUTHWEST,
		N_SOUTH|N_EAST|N_WEST|N_SOUTHEAST|N_SOUTHWEST,
		N_NORTH|N_EAST|N_WEST|N_NORTHEAST|N_NORTHWEST,

		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_NORTHEAST,
		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_NORTHWEST,
		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_SOUTHEAST,
		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_SOUTHWEST,

		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_NORTHEAST|N_SOUTHEAST,
		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_NORTHWEST|N_SOUTHWEST,
		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_NORTHEAST|N_NORTHWEST,
		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_SOUTHEAST|N_SOUTHWEST,

		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_NORTHEAST|N_SOUTHWEST,
		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_NORTHWEST|N_SOUTHEAST,

		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_NORTHWEST|N_SOUTHWEST|N_SOUTHEAST,
		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_NORTHEAST|N_SOUTHEAST|N_SOUTHWEST,
		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_NORTHWEST|N_SOUTHWEST|N_NORTHEAST,
		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_NORTHEAST|N_SOUTHEAST|N_NORTHWEST,

		N_NORTH|N_SOUTH|N_EAST|N_WEST|N_NORTHEAST|N_NORTHWEST|N_SOUTHEAST|N_SOUTHWEST,
		)

	var/icon/master = new()

	master.Insert(icon(sourceIcon, "box"), "box")
	master.Insert(icon(sourceIcon, "box"), "0")

	for(var/dir_bits in smooth_dirs)

		var/list/parts

		if(states.len == STATE_COUNT_DIAGONAL)
			parts = diagonal_smooth(dir_bits, TRUE)
		else
			parts = cardinal_smooth(null, dir_bits)

		var/icon/I = icon(icon(sourceIcon, "box"))
		I.DrawBox(null, 1, 1, sourceIconWidth, sourceIconHeight)
		for(var/i in parts)
			I.Blend(icon(outputIcon, i), ICON_OVERLAY)
		master.Insert(I, "[dir_bits]")
		CHECK_TICK

	if(create_false_wall_animations)
		var/icon/I = icon(icon(sourceIcon, "box"))
		for (var/frame in 1 to 5)
			if(frame > 1)
				var/list/frame_shifts = list(0, 10, 4, 7, 2) // those shifts are what it was when states were handmade.
				I.Shift(WEST, frame_shifts[frame])
				if(frame == 5)
					master.Insert(I, "fwall_open")
			master.Insert(I, "fwall_closing", null, 6 - frame, FALSE, 1)
			master.Insert(I, "fwall_opening", null, frame, FALSE, 1)
			CHECK_TICK

	if(ExcludedMiscIconStates.len)
		for(var/state in ExcludedMiscIconStates)
			master.Insert(icon(sourceIcon, state), state)

#ifdef MANUAL_ICON_SMOOTH
	world << ftp(master, "[copytext("[dmifile]", 1, -4)]-smooth.dmi")
#else
	return master
#endif
