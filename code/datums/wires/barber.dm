var/const/COLOR_MIXER_POWER         = 1
var/const/COLOR_MIXER_TANK_1        = 2
var/const/COLOR_MIXER_TANK_2        = 4
var/const/COLOR_MIXER_TANK_3        = 8
var/const/COLOR_MIXER_TANK_OUTPUT   = 16
var/const/COLOR_MIXER_OUTPUT_SAFETY = 32

/datum/wires/color_mixer
	holder_type = /obj/machinery/color_mixer
	wire_count = 6

/datum/wires/color_mixer/can_use()
	var/obj/machinery/color_mixer/CM = holder
	return CM.panel_open

/datum/wires/color_mixer/get_interact_window()
	. += ..()
	. += "<br>The red light is [is_index_cut(COLOR_MIXER_TANK_1) ? "off" : "on"]"
	. += "<br>The green light is [is_index_cut(COLOR_MIXER_TANK_2) ? "off": "on"]"
	. += "<br>The blue light is [is_index_cut(COLOR_MIXER_TANK_3) ? "off" : "on"]"
	. += "<br>The light under output beaker is [is_index_cut(COLOR_MIXER_TANK_OUTPUT) ? "off" : "on"]"

/datum/wires/color_mixer/update_cut(index, mended)
	var/obj/machinery/color_mixer/CM = holder

	switch(index)
		if(COLOR_MIXER_POWER)
			if(!mended)
				CM.updateUsrDialog()
			CM.update_icon(beaker_update = FALSE)
		else
			CM.updateUsrDialog()

/datum/wires/color_mixer/update_pulsed(index)
	var/obj/machinery/color_mixer/CM = holder

	switch(index)
		if(COLOR_MIXER_OUTPUT_SAFETY)
			var/turf/T = get_turf(pick(viewers(2, src)))
			INVOKE_ASYNC(CM, /obj/machinery/color_mixer/proc/Spray_at, T)
			CM.update_icon()
			CM.updateUsrDialog()
