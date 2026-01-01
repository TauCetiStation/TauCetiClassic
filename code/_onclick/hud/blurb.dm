/obj/effect/overlay/blurb
	maptext_height = 64
	maptext_width = 512
	layer = FLOAT_LAYER
	plane = HUD_PLANE
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "LEFT+1,BOTTOM+2"

/proc/show_location_blurb(client/C)
	set waitfor = FALSE

	if(!C)
		return

	var/style = "font-family: 'Fixedsys'; -dm-text-outline: 1 black; font-size: 11px;"
	var/obj/effect/overlay/blurb/B = new()

	var/list/style_for_line[4]
	var/list/lines[4]

	var/age
	if(ishuman(C.mob))
		var/mob/living/carbon/human/H = C.mob
		age += ", [H.age] years old"

	lines[1] = "[C.mob.real_name][age]"

	if(length(C.mob.mind.antag_roles))
		lines[2] = C.mob.mind.antag_roles[1]
		style_for_line[2] = "color:red;"
	else
		lines[2] = C.mob.mind.role_alt_title

	var/station_name
	if(is_station_level(C.mob.z))
		station_name = "[station_name()], "

	var/area/A = get_area(C.mob)
	lines[3] = "[station_name][A.name]"

	lines[4] = "[current_date_string], [worldtime2text()]"

	C.screen += B

	var/newline_flag = TRUE
	for(var/j in 1 to lines.len)
		var/new_line = uppertext(lines[j])
		var/old_line = j > 1 ? "<span style=\"[style_for_line[j - 1]]\">[uppertext(lines[j - 1])]</span>" : null
		animate(B, alpha = 255, time = 10)
		newline_flag = !newline_flag
		for(var/i = 2 to length_char(new_line) + 1)
			var/cur_line = "<span style=\"[style_for_line[j]]\">[copytext_char(new_line, 1, i)]</span>"
			if(newline_flag)
				B.maptext = "<div style=\"[style]\">[old_line]<br>[cur_line]</div>"
			else
				B.maptext = "<div style=\"line-height: 0.9;[style]\">[cur_line]</div><br><br></br>"
			sleep(1)
		if(newline_flag || j == lines.len)
			sleep(15)
			animate(B, alpha = 0, time = 15)
			sleep(15)

	if(C)
		C.screen -= B
	qdel(B)
