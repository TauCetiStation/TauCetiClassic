var/const/BORG_WIRE_LAWCHECK    = 1
var/const/BORG_WIRE_MAIN_POWER  = 2
var/const/BORG_WIRE_LOCKED_DOWN = 4
var/const/BORG_WIRE_AI_CONTROL  = 8
var/const/BORG_WIRE_CAMERA      = 16

/datum/wires/robot
	random = TRUE
	holder_type = /mob/living/silicon/robot
	wire_count = 5

/datum/wires/robot/get_interact_window()
	var/mob/living/silicon/robot/R = holder
	. = ..()
	. += "<br>[R.lawupdate ? "The LawSync light is on." : "The LawSync light is off."]"
	. += "<br>[R.connected_ai ? "The AI link light is on." : "The AI link light is off."]"
	. += "<br>[(!isnull(R.camera) && R.camera.status == 1) ? "The Camera light is on." : "The Camera light is off."]"
	. += "<br>[R.lockcharge ? "The lockdown light is on." : "The lockdown light is off."]"

/datum/wires/robot/can_use()
	var/mob/living/silicon/robot/R = holder
	return R.wiresexposed

/datum/wires/robot/update_cut(index, mended)
	var/mob/living/silicon/robot/R = holder

	switch(index)
		if(BORG_WIRE_LAWCHECK)
			if(mended)
				if(R.lawupdate == 0 && !R.emagged)
					R.lawupdate = 1
			else
				if(R.lawupdate == 1)
					to_chat(R, "<span class='notice'>LawSync protocol engaged.</span>")
					R.show_laws()

		if(BORG_WIRE_AI_CONTROL)
			if(!mended)
				if (R.connected_ai)
					R.connected_ai = null

		if(BORG_WIRE_CAMERA)
			if(!isnull(R.camera) && !R.scrambledcodes)
				R.camera.status = mended
				R.camera.toggle_cam(FALSE)

/datum/wires/robot/update_pulsed(index)
	var/mob/living/silicon/robot/R = holder

	switch(index)
		if(BORG_WIRE_AI_CONTROL)
			if(!R.emagged)
				R.connected_ai = select_active_ai()

		if(BORG_WIRE_CAMERA)
			if(!isnull(R.camera) && R.camera.status && !R.scrambledcodes)
				R.camera.disconnect_viewers()
				R.visible_message(
					"<span class='notice'>Your camera lens focuses loudly.</span>",
					"<span class='notice'>[R.name]'s camera lens focuses loudly.</span>"
				)

		if(BORG_WIRE_LAWCHECK)
			if(R.lawupdate)
				R.lawsync()
				R.photosync()
