/obj/effect/proc_holder/spell/no_target/cybernetic_nightvision
	name =  "Toggle cybernetic nightvision"
	panel = "Cybernetic"
	clothes_req = FALSE
	charge_max = 5 SECONDS
	action_icon_state = "cybernetic_nv"

/obj/effect/proc_holder/spell/no_target/cybernetic_nightvision/cast(list/targets, mob/living/carbon/human/user = usr)
	var/obj/item/organ/internal/eyes/BP = user.organs_by_name[O_EYES]
	if(!HAS_TRAIT(user, TRAIT_CYBER_NIGHT_EYES))
		ADD_TRAIT(user, TRAIT_CYBER_NIGHT_EYES, GENERIC_TRAIT)
		BP.darksight = 8
		user.overlay_fullscreen("cy_impaired", /atom/movable/screen/fullscreen/cybereyes_impaired)
		user.update_body(BP_HEAD)
	else
		REMOVE_TRAIT(user, TRAIT_CYBER_NIGHT_EYES, GENERIC_TRAIT)
		BP.darksight = 2
		user.clear_fullscreen("cy_impaired")
		user.update_body(BP_HEAD)

