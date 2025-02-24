/obj/effect/proc_holder/spell/pointed/burglar_finesse
	name = "Burglar's Finesse"
	desc = "Steal a random item from the victim's backpack."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	icon = 'icons/hud/actions_ecult.dmi'
	action_icon_state = "burglarsfinesse"

	school = SCHOOL_FORBIDDEN
	charge_max = 40 SECONDS

	invocation = "Y'O'K!"
	invocation_type = "whisper"


	range = 6

/obj/effect/proc_holder/spell/pointed/burglar_finesse/is_valid_target(mob/living/carbon/human/cast_on)
	if(!istype(cast_on))
		return FALSE
	var/obj/item/back_item = cast_on.get_item_by_slot(SLOT_FLAGS_BACK)
	#warn Missmatched slots? ^^^
	return ..() && back_item?.atom_storage

/obj/effect/proc_holder/spell/pointed/burglar_finesse/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_danger("You feel a light tug, but are otherwise fine, you were protected by holiness!"))
		to_chat(owner, span_danger("[cast_on] is protected by holy forces!"))
		return FALSE

	var/obj/storage_item = cast_on.get_item_by_slot(SLOT_FLAGS_BACK)
	#warn Missmatched slots? ^^^

	if(isnull(storage_item))
		return FALSE

	var/item = pick(storage_item.atom_storage.return_inv(recursive = FALSE))
	if(isnull(item))
		return FALSE

	to_chat(cast_on, span_warning("Your [storage_item] feels lighter..."))
	to_chat(owner, span_notice("With a blink, you pull [item] out of [cast_on][p_s()] [storage_item]."))
	owner.put_in_active_hand(item)
