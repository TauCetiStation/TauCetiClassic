// Used only for sprites

/datum/bodytype
	var/name = ""
	var/external_organs_suffix = ""

	var/undershirts_path = 'icons/mob/human_undershirt.dmi'
	var/undershirts_prints_path = 'icons/mob/human_undershirt_prints.dmi'
	var/socks_path = 'icons/mob/human_socks.dmi'
	var/underwear_path = 'icons/mob/human_underwear.dmi'

	var/uniforms_path = 'icons/mob/uniform.dmi'
	var/suits_path = 'icons/mob/suit.dmi'
	var/gloves_path = 'icons/mob/hands.dmi'
	var/shoes_path = 'icons/mob/feet.dmi'

	//in case if sprite in "main" .dmi hasnt exist, will be used sprite from "spare" .dmi
	var/uniforms_spare_path = 'icons/mob/uniform.dmi'
	var/gloves_spare_path = 'icons/mob/hands.dmi'
	var/shoes_spare_path = 'icons/mob/feet.dmi'

/datum/bodytype/average
	name = AVERAGE_BODYTYPE


/datum/bodytype/slim
	name = SLIM_BODYTYPE
	external_organs_suffix = "_femine"

	// undershirts/prints are shared with average for females (slim sheets are unfinished)
	socks_path = 'icons/mob/human_socks_slim.dmi'
	underwear_path = 'icons/mob/human_underwear_slim.dmi'

	uniforms_path = 'icons/mob/uniform_slim.dmi'
	gloves_path = 'icons/mob/hands_slim.dmi'
	shoes_path = 'icons/mob/feet_slim.dmi'


/datum/bodytype/fat
	name = FAT_BODYTYPE
	external_organs_suffix = "_fat"

	undershirts_path = 'icons/mob/human_undershirt_fat.dmi'
	undershirts_prints_path = 'icons/mob/human_undershirt_prints_fat.dmi'
	socks_path = 'icons/mob/human_socks_fat.dmi'
	underwear_path = 'icons/mob/human_underwear_fat.dmi'

	uniforms_path = 'icons/mob/uniform_fat.dmi'
	suits_path = 'icons/mob/suit_fat.dmi'
