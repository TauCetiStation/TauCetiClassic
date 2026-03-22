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

/datum/bodytype/normal
	name = "normal"


/datum/bodytype/femine
	name = "femine"
	external_organs_suffix = "_femine"

	undershirts_path = 'icons/mob/human_undershirt_fem.dmi'
	undershirts_prints_path = 'icons/mob/human_undershirt_prints_fem.dmi'
	socks_path = 'icons/mob/human_socks_fem.dmi'
	underwear_path = 'icons/mob/human_underwear_fem.dmi'

	uniforms_path = 'icons/mob/uniform_fem.dmi'
	gloves_path = 'icons/mob/hands_fem.dmi'
	shoes_path = 'icons/mob/feet_fem.dmi'


/datum/bodytype/fat
	name = "fat"
	external_organs_suffix = "_fat"

	undershirts_path = 'icons/mob/human_undershirt_fat.dmi'
	undershirts_prints_path = 'icons/mob/human_undershirt_prints_fat.dmi'
	socks_path = 'icons/mob/human_socks_fat.dmi'
	underwear_path = 'icons/mob/human_underwear_fat.dmi'

	uniforms_path = 'icons/mob/uniform_fat.dmi'
	suits_path = 'icons/mob/suit_fat.dmi'
