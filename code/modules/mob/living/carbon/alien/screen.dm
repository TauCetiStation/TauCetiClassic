#define FONT_ASIZE "5pt"
//#define FONT_ACOLOR "#f0f"
#define FONT_ACOLOR "#3f0"
#define FONT_ASTYLE "Arial Black"

/obj/screen/zone_sel/alien/update_icon()
	overlays.Cut()
	overlays += selecting

/mob/living/carbon/proc/updatePlasmaDisplay()
	var/obj/item/organ/xenos/plasmavessel/vessel = organs_by_name[BP_PLASMA]
	if(vessel && vessel.alien_plasma_display) // clientless aliens
		//alien_plasma_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='magenta'>[storedPlasma]</font></div>"
		var/new_text = {"<div style="font-size:[FONT_ASIZE];color:[FONT_ACOLOR];font:'[FONT_ASTYLE]';text-align:center;" valign="middle">[vessel.max_plasma]<br>[vessel.stored_plasma]</div>"}
		if(vessel.alien_plasma_display.maptext != new_text)
			vessel.alien_plasma_display.maptext = new_text
