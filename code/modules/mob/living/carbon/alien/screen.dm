#define FONT_ASIZE "5pt"
//#define FONT_ACOLOR "#f0f"
#define FONT_ACOLOR "#3f0"
#define FONT_ASTYLE "Arial Black"

/obj/screen/zone_sel/alien/update_icon()
	overlays.Cut()
	overlays += selecting

/mob/living/carbon/alien/proc/updatePlasmaDisplay()
	if(visual_counter)
		if(alien_plasma_display) //clientless aliens
			//alien_plasma_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='magenta'>[storedPlasma]</font></div>"
			var/new_text = {"<div style="font-size:[FONT_ASIZE];color:[FONT_ACOLOR];font:'[FONT_ASTYLE]';text-align:center;" valign="middle">[max_plasma]<br>[storedPlasma]</div>"}
			if(alien_plasma_display.maptext != new_text)
				alien_plasma_display.maptext = new_text

/mob/living/carbon/alien/larva/updatePlasmaDisplay()
	return

/mob/living/carbon/alien/facehugger/updatePlasmaDisplay()
	return
