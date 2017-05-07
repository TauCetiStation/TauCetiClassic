//Monkey Overlays Indexes////////
#define M_MASK_LAYER			1
#define M_BACK_LAYER			2
#define M_HANDCUFF_LAYER		3
#define M_L_HAND_LAYER			4
#define M_R_HAND_LAYER			5
#define TARGETED_LAYER			6
#define M_FIRE_LAYER			7
#define M_TOTAL_LAYERS			7
/////////////////////////////////

//mob/living/carbon/monkey
//	var/list/overlays_standing[M_TOTAL_LAYERS]

/mob/living/carbon/monkey/regenerate_icons()
	..()
	update_icons()
	update_transform()
	//Hud Stuff
	update_hud()
	return

/mob/living/carbon/monkey/update_icons()
	..()
	update_hud()
	//lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	//overlays.Cut()
	//for(var/image/I in overlays_standing)
	//	overlays += I


/mob/living/carbon/monkey/update_hud()
	if (client)
		client.screen |= contents

//Call when target overlay should be added/removed
/mob/living/carbon/monkey/update_targeted(var/update_icons=1)
	if (targeted_by && target_locked)
		overlays_standing[TARGETED_LAYER]	= target_locked
	else if (!targeted_by && target_locked)
		qdel(target_locked)
	if (!targeted_by)
		overlays_standing[TARGETED_LAYER]	= null
	if(update_icons)		update_icons()

/mob/living/carbon/monkey/update_fire()
	overlays -= overlays_standing[M_FIRE_LAYER]
	if(on_fire)
		overlays_standing[M_FIRE_LAYER]		= image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing")
		overlays += overlays_standing[M_FIRE_LAYER]
		return
	else
		overlays_standing[M_FIRE_LAYER]		= null

//Monkey Overlays Indexes////////
#undef M_MASK_LAYER
#undef M_BACK_LAYER
#undef M_HANDCUFF_LAYER
#undef M_L_HAND_LAYER
#undef M_R_HAND_LAYER
#undef TARGETED_LAYER
#undef M_FIRE_LAYER
#undef M_TOTAL_LAYERS

