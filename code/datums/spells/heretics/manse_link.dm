/obj/effect/proc_holder/spell/pointed/manse_link
	name = "Manse Link"
	desc = "This spell allows you to pierce through reality and connect minds to one another \
		via your Mansus Link. All minds connected to your Mansus Link will be able to communicate discreetly across great distances."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	icon = 'icons/hud/actions_ecult.dmi'
	action_icon_state = "mansus_link"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	charge_max = 20 SECONDS

	invocation = "PI'RC' TH' M'ND."
	invocation_type = "shout"

	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	range = 7

	/// The time it takes to link to a mob.
	var/link_time = 6 SECONDS

/obj/effect/proc_holder/spell/pointed/manse_link/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)

/obj/effect/proc_holder/spell/pointed/manse_link/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	return isliving(cast_on)

/obj/effect/proc_holder/spell/pointed/manse_link/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	// If we fail to link, cancel the spell.
	if(!do_linking(cast_on))
		return . | SPELL_CANCEL_CAST

/**
 * The actual process of linking [linkee] to our network.
 */
/obj/effect/proc_holder/spell/pointed/manse_link/proc/do_linking(mob/living/linkee)
	var/datum/component/mind_linker/linker = target
	if(linkee.stat == DEAD)
		to_chat(owner, span_warning("They're dead!"))
		return FALSE

	to_chat(owner, span_notice("You begin linking [linkee]'s mind to yours..."))
	to_chat(linkee, span_warning("You feel your mind being pulled somewhere... connected... intertwined with the very fabric of reality..."))

	if(!do_after(owner, link_time, linkee, hidden = TRUE))
		to_chat(owner, span_warning("You fail to link to [linkee]'s mind."))
		to_chat(linkee, span_warning("The foreign presence leaves your mind."))
		return FALSE

	if(QDELETED(src) || QDELETED(owner) || QDELETED(linkee))
		return FALSE

	if(!linker.link_mob(linkee))
		to_chat(owner, span_warning("You can't seem to link to [linkee]'s mind."))
		to_chat(linkee, span_warning("The foreign presence leaves your mind."))
		return FALSE

	return TRUE
