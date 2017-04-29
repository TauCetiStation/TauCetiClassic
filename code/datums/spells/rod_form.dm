/obj/effect/proc_holder/spell/targeted/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path."
	clothes_req = 1
	charge_max = 600
	centcomm_cancast = FALSE
	range = -1
	include_user = 1
	invocation = "CLANG!"
	invocation_type = "shout"
	action_icon_state = "immrod"

/obj/effect/proc_holder/spell/targeted/rod_form/cast(list/targets)
	for(var/mob/living/M in targets)
		new /obj/effect/immovablerod/wizard(get_turf(M), get_ranged_target_turf(M, M.dir, 13), M)

//Wizard Version of the Immovable Rod

/obj/effect/immovablerod/wizard
	var/mob/living/wizard

/obj/effect/immovablerod/wizard/New(turf/start, turf/end, mob/living/wiz)
	..()
	if(wiz)
		wizard = wiz
		wizard.forceMove(src)
		wizard.status_flags |= GODMODE

/obj/effect/immovablerod/wizard/Destroy()
	if(wizard)
		wizard.status_flags &= ~GODMODE
		wizard.forceMove(get_turf(src))
	return ..()