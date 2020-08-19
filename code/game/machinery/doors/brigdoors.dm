#define CHARS_PER_LINE 5
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Arial Black"
#define MAIN_SCREEN 0
#define ERROR_SCREEN 1

//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

///////////////////////////////////////////////////////////////////////////////////////////////
// Brig Door control displays.
//  Description: This is a controls the timer for the brig doors, displays the timer on itself and
//               has a popup window when used, allowing to set the timer.
//  Code Notes: Combination of old brigdoor.dm code from rev4407 and the status_display.dm code
//  Date: 01/September/2010
//  Programmer: Veryinky
/////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/door_timer
	name = "Door Timer"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	req_access = list(access_brig)
	anchored = 1.0    		// can't pick it up
	density = 0       		// can walk through it.
	var/screen = MAIN_SCREEN
	var/id = null     		// id of door it controls.
	var/releasetime = 0		// when world.timeofday reaches it - release the prisoner
	var/timing = 0    		// boolean, true/1 timer is on, false/0 means it's not timing
	var/picture_state		// icon_state of alert picture, if not displaying text/numbers
	var/list/obj/machinery/targets = list()
	var/timetoset = 0		// Used to set releasetime upon starting the timer
	var/timer_activator = ""	//Mob.name who activate timer
	var/flag30sec = 0	//30 seconds notification flag
	var/prisoner_name = ""
	var/prisoner_crimes = ""
	var/prisoner_details = ""
	var/obj/item/device/radio/intercom/radio // for /s announce


	maptext_height = 26
	maptext_width = 32

/obj/machinery/door_timer/atom_init()
	..()
	pixel_x = ((dir & 3)? (0) : (dir == 4 ? 32 : -32))
	pixel_y = ((dir & 3)? (dir == 1 ? 24 : -32) : (0))
	cell_open()
	radio = new (src)  // for /s announce
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door_timer/atom_init_late()
	for(var/obj/machinery/door/window/brigdoor/M in brigdoor_list)
		if (M.id == id)
			targets += M

	for(var/obj/machinery/flasher/F in flasher_list)
		if(F.id == id)
			targets += F

	for(var/obj/structure/closet/secure_closet/brig/C in closet_list)
		if(C.id == id)
			targets += C

	if(targets.len == 0)
		stat |= BROKEN
	update_icon()

//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
/obj/machinery/door_timer/process()

	if(stat & (NOPOWER|BROKEN))	return
	if(src.timing)

		// poorly done midnight rollover
		// (no seriously there's gotta be a better way to do this)
		var/timeleft = timeleft()
		if(timeleft > 1e5)
			src.releasetime = 0

		if(world.timeofday > (src.releasetime - 300)) //30 sec notification before release
			if (!flag30sec)
				flag30sec = 1
				broadcast_security_hud_message("<b>[src.name]</b> prisoner's sentence is ending in 30 seconds.", src)

		if(world.timeofday > src.releasetime)
			broadcast_security_hud_message("<b>[src.name]</b> prisoner has served issued sentence. <b>[timer_activator]</b> is requested for the release procedure.", src)
			src.timer_end() // open doors, reset timer, clear status screen
			cell_open()

		src.updateUsrDialog()
		src.update_icon()

	return


// has the door power situation changed, if so update icon.
/obj/machinery/door_timer/power_change()
	..()
	update_icon()
	return

/obj/machinery/door_timer/Destroy()
	QDEL_NULL(radio)
	return ..()


// open/closedoor checks if door_timer has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.

// power check and stop timer
/obj/machinery/door_timer/proc/timer_start(activator)
	if(stat & (NOPOWER|BROKEN))	return 0

	// Set releasetime
	releasetime = world.timeofday + timetoset
	if (activator)
		timer_activator = activator

	return

// Closes and locks doors
/obj/machinery/door_timer/proc/cell_close()
	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(door.density)	continue
		spawn(0)
			door.close()

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)	continue
		if(C.opened && !C.close())	continue
		C.locked = 1
		C.icon_state = C.icon_locked

	return

//power check, set vars as default
/obj/machinery/door_timer/proc/timer_end()
	if(stat & (NOPOWER|BROKEN))	return 0

	// Reset releasetime
	src.timing = 0
	flag30sec = 0
	releasetime = 0
	prisoner_name = ""
	prisoner_crimes = ""
	prisoner_details = ""
	timer_activator = ""

	return

//Opens and unlocks door, closet
/obj/machinery/door_timer/proc/cell_open()
	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(!door.density)	continue
		spawn(0)
			door.open()

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)	continue
		if(C.opened)	continue
		C.locked = 0
		C.icon_state = C.icon_closed

	return

// Check for releasetime timeleft
/obj/machinery/door_timer/proc/timeleft()
	. = (releasetime - world.timeofday)/10
	if(. < 0)
		. = 0

// Set timetoset
/obj/machinery/door_timer/proc/timeset(seconds)
	timetoset = seconds * 10

	if(timetoset <= 0)
		timetoset = 0

	return

//Allows humans to use door_timer
//Opens dialog window when someone clicks on door timer
// Allows altering timer and the timing boolean.
// Flasher activation limited to 150 seconds

/obj/machinery/door_timer/ui_interact(mob/user)
	// Used for the 'time left' display
	var/second = round(timeleft() % 60)
	var/minute = round((timeleft() - second) / 60)

	// Used for 'set timer'
	var/setsecond = round((timetoset / 10) % 60)
	var/setminute = round(((timetoset / 10) - setsecond) / 60)

	// dat
	var/dat = "<HTML><BODY><TT>"

	switch(screen)
		if(MAIN_SCREEN)
			dat += "<HR>Timer System:</hr>"
			dat += " <b>Door [id] controls</b><br/>"
			dat +={"
				<HR><B>All lines must be filled in correctly</B>
				<br/><B><A href='?src=\ref[src];set_prisoner_name=TRUE'>Name</A>:</B> [prisoner_name]
				<br/><B><A href='?src=\ref[src];set_prisoner_crimes=TRUE'>Crimes</A>:</B> [prisoner_crimes]
				<br/><B><A href='?src=\ref[src];set_prisoner_details=TRUE'>Details</A>:</B> [prisoner_details]<BR>
				<br/><B>Authorized by:</B> <FONT COLOR='green'>[timer_activator]</FONT><HR></hr>
			"}

			// Start/Stop timer
			if (src.timing)
				dat += "<a href='?src=\ref[src];timing=0'>Stop Timer and open door</a><br/>"
			else
				dat += "<a href='?src=\ref[src];timing=1'>Activate Timer and close door</a><br/>"

			// Time Left display (uses releasetime)
			dat += "Time Left: [(minute ? text("[minute]:") : null)][second] <br/>"
			dat += "<br/>"

			// Set Timer display (uses timetoset)
			if(src.timing)
				dat += "Set Timer: [(setminute ? text("[setminute]:") : null)][setsecond]  <a href='?src=\ref[src];change=1'>Set</a><br/>"
			else
				dat += "Set Timer: [(setminute ? text("[setminute]:") : null)][setsecond]<br/>"

			// Controls
			dat += "<a href='?src=\ref[src];tp=-60'>-</a> <a href='?src=\ref[src];tp=-1'>-</a> <a href='?src=\ref[src];tp=1'>+</a> <A href='?src=\ref[src];tp=60'>+</a><br/>"

			// Mounted flash controls
			for(var/obj/machinery/flasher/F in targets)
				if(F.last_flash && (F.last_flash + 150) > world.time)
					dat += "<br/><A href='?src=\ref[src];fc=1'>Flash Charging</A>"
				else
					dat += "<br/><A href='?src=\ref[src];fc=1'>Activate Flash</A>"

			dat += "<br/><br/><a href='?src=\ref[user];mach_close=computer'>Close</a>"
			dat += "</TT></BODY></HTML>"

		if(ERROR_SCREEN)
			dat+="<B><FONT COLOR='maroon'>ERROR: Invalid prisoner data</B></FONT><HR><BR>"
			if(prisoner_name == "")
				dat+="<FONT COLOR='maroon'>•Invalid prisoner name.</FONT><BR>"
			if(prisoner_crimes == "")
				dat+="<FONT COLOR='maroon'>•Invalid crimes number.</FONT><BR>"
			if(prisoner_details == "")
				dat+="<FONT COLOR='maroon'>•Invalid details text.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];setScreen=[MAIN_SCREEN]'>Return</A><BR>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")

//Function for using door_timer dialog input, checks if user has permission
// href_list to
//  "timing" turns on timer
//  "tp" value to modify timer
//  "fc" activates flasher
// 	"change" resets the timer to the timetoset amount while the timer is counting down
// Also updates dialog window and timer icon
/obj/machinery/door_timer/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["set_prisoner_name"])
		prisoner_name = sanitize(input(usr, "Enter Name", "Prison Timer", input_default(prisoner_name)), MAX_LNAME_LEN)

	if(href_list["set_prisoner_crimes"])
		prisoner_crimes = sanitize(input(usr, "Enter Crimes", "Prison Timer", input_default(prisoner_crimes)), MAX_LNAME_LEN)

	if(href_list["set_prisoner_details"])
		prisoner_details = sanitize(input(usr, "Enter Details", "Prison Timer", input_default(prisoner_details)), MAX_LNAME_LEN)

	if(!src.allowed(usr))
		return

	if(href_list["timing"])
		if(prisoner_name == "" || prisoner_crimes == "" || prisoner_details == "" )
			src.screen = ERROR_SCREEN
		else
			src.timing = text2num(href_list["timing"])

			if(src.timing)
				src.timer_start(usr.name)
				var/prison_minute = round(timetoset / 600)
				radio.autosay("[timer_activator] placed [prisoner_name] into [id]. Crimes: [prisoner_crimes]. Details: [prisoner_details]. Prison term: [prison_minute] min.", "Prison Timer", freq = radiochannels["Security"])
				cell_close()
			else
				src.timer_end()
				cell_open()
	else
		if(href_list["tp"])  //adjust timer, close door if not already closed
			var/tp = text2num(href_list["tp"])
			var/addtime = (timetoset / 10)
			addtime += tp
			addtime = min(max(round(addtime), 0), 3600)

			timeset(addtime)

		if(href_list["fc"])
			for(var/obj/machinery/flasher/F in targets)
				F.flash()

		if(href_list["change"])
			src.timer_start(usr.name)
			cell_close()

	if(href_list["setScreen"])
		src.screen = text2num(href_list["setScreen"])

	src.updateUsrDialog()
	src.update_icon()

	/* if(src.timing)
		src.timer_start()

	else
		src.timer_end() */


//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
// if timing=true, run update display function
/obj/machinery/door_timer/update_icon()
	if(stat & (NOPOWER))
		icon_state = "frame"
		return
	if(stat & (BROKEN))
		set_picture("ai_bsod")
		return
	if(src.timing)
		var/disp1 = id
		var/timeleft = timeleft()
		var/disp2 = "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
		if(length(disp2) > CHARS_PER_LINE)
			disp2 = "Error"
		update_display(disp1, disp2)
	else
		if(maptext)	maptext = ""
	return


// Adds an icon in case the screen is broken/off, stolen from status_display.dm
/obj/machinery/door_timer/proc/set_picture(state)
	picture_state = state
	cut_overlays()
	add_overlay(image('icons/obj/status_display.dmi', icon_state=picture_state))


//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
/obj/machinery/door_timer/proc/update_display(line1, line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text


/obj/machinery/door_timer/cell_1
	name = "Cell 1"
	id = "Cell 1"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_2
	name = "Cell 2"
	id = "Cell 2"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_3
	name = "Cell 3"
	id = "Cell 3"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_4
	name = "Cell 4"
	id = "Cell 4"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_5
	name = "Cell 5"
	id = "Cell 5"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_6
	name = "Cell 6"
	id = "Cell 6"
	dir = 4
	pixel_x = 32

#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef CHARS_PER_LINE
#undef MAIN_SCREEN
#undef ERROR_SCREEN
