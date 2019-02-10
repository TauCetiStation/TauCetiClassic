var/const/CAMERA_WIRE_FOCUS    = 1
var/const/CAMERA_WIRE_POWER    = 2
var/const/CAMERA_WIRE_LIGHT    = 4
var/const/CAMERA_WIRE_ALARM    = 8
var/const/CAMERA_WIRE_NOTHING1 = 16
var/const/CAMERA_WIRE_NOTHING2 = 32

/datum/wires/camera
	random = TRUE
	holder_type = /obj/machinery/camera
	wire_count = 6

/datum/wires/camera/get_interact_window()
	var/obj/machinery/camera/C = holder
	. = ..()
	. += "<br>[(C.view_range == initial(C.view_range) ? "The focus light is on." : "The focus light is off.")]"
	. += "<br>[(C.can_use(check_paint = FALSE) ? "The power link light is on." : "The power link light is off.")]"
	. += "<br>[(C.light_disabled ? "The camera light is off." : "The camera light is on.")]"
	. += "<br>[(C.alarm_on ? "The alarm light is on." : "The alarm light is off.")]"

/datum/wires/camera/can_use()
	var/obj/machinery/camera/C = holder
	return C.panel_open

/datum/wires/camera/update_cut(index, mended)
	var/obj/machinery/camera/C = holder

	switch(index)
		if(CAMERA_WIRE_FOCUS)
			var/range = (mended ? initial(C.view_range) : C.short_range)
			C.setViewRange(range)

		if(CAMERA_WIRE_POWER)
			C.toggle_cam(TRUE, usr)

		if(CAMERA_WIRE_LIGHT)
			C.light_disabled = !mended

		if(CAMERA_WIRE_ALARM)
			if(!mended)
				C.triggerCameraAlarm()
			else
				C.cancelCameraAlarm()

/datum/wires/camera/update_pulsed(index)
	var/obj/machinery/camera/C = holder

	switch(index)
		if(CAMERA_WIRE_FOCUS)
			var/new_range = (C.view_range == initial(C.view_range) ? C.short_range : initial(C.view_range))
			C.setViewRange(new_range)

		if(CAMERA_WIRE_POWER)
			C.disconnect_viewers()

		if(CAMERA_WIRE_LIGHT)
			C.light_disabled = !C.light_disabled

		if(CAMERA_WIRE_ALARM)
			C.audible_message("[bicon(C)] *beep*")

/datum/wires/camera/proc/is_deconstructable()
	return is_index_cut(CAMERA_WIRE_POWER) && is_index_cut(CAMERA_WIRE_FOCUS) && is_index_cut(CAMERA_WIRE_LIGHT) && is_index_cut(CAMERA_WIRE_NOTHING1) && is_index_cut(CAMERA_WIRE_NOTHING2)