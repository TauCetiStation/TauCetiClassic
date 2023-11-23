/// What typepath of the hallucination
#define HALLUCINATION_ARG_TYPE 1
/// Where the hallucination came from, for logging
#define HALLUCINATION_ARG_SOURCE 2

/// Onwards from this index, it's the arglist that gets passed into the hallucination created.
#define HALLUCINATION_ARGLIST 3

/// Biotypes which cannot hallucinate for balance and logic reasons (not code)
#define NO_HALLUCINATION_BIOTYPES (MOB_ROBOTIC|MOB_SPIRIT|MOB_SPECIAL)

// Macro wrapper for _cause_hallucination so we can cheat in named arguments, like AddComponent.
/**
 * Causes a hallucination of a certain type to the mob.
 *
 * First argument is always the type of halllucination, a /datum/hallucination, required.
 * second argument is always the key source of the hallucination, used for admin logging, required.
 *
 * Additionally, named arguments are supported for passing them forward to the created hallucination's new().
 */
#define cause_hallucination(arguments...) _cause_hallucination(list(##arguments))

/// Unless you need this for an explicit reason, use the cause_hallucination wrapper.
/mob/living/proc/_cause_hallucination(list/raw_args)
	if(!length(raw_args))
		CRASH("cause_hallucination called with no arguments.")

	var/datum/hallucination/hallucination_type = raw_args[HALLUCINATION_ARG_TYPE] // first arg is the type always
	if(!ispath(hallucination_type))
		CRASH("cause_hallucination was given a non-hallucination type.")

	var/hallucination_source = raw_args[HALLUCINATION_ARG_SOURCE] // and second arg, the source
	var/datum/hallucination/new_hallucination

	if(length(raw_args) >= HALLUCINATION_ARGLIST)
		var/list/passed_args = raw_args.Copy(HALLUCINATION_ARGLIST)
		passed_args.Insert(HALLUCINATION_ARG_TYPE, src)

		new_hallucination = new hallucination_type(arglist(passed_args))
	else
		new_hallucination = new hallucination_type(src)

	// For some reason, we qdel'd in New, maybe something went wrong.
	if(QDELETED(new_hallucination))
		return
	// It's not guaranteed that the hallucination passed can successfully be initiated.
	// This means there may be cases where someone should have a hallucination but nothing happens,
	// notably if you pass a randomly picked hallucination type into this.
	// Maybe there should be a separate proc to reroll on failure?
	if(!new_hallucination.start())
		qdel(new_hallucination)
		return

	log_debug("[key_name(usr)] was afflicted with a hallucination of type [hallucination_type] by: [hallucination_source]. \
		([new_hallucination.feedback_details])", INVESTIGATE_HALLUCINATIONS)
	return new_hallucination

/**
 * # Hallucination datum.
 *
 * Handles effects of a hallucination on a living mob.
 * Created and triggered via the [cause hallucination proc][/mob/living/proc/cause_hallucination].
 *
 * See also: [the hallucination status effect][/datum/status_effect/hallucination].
 */
/datum/hallucination
	/// Who's our next highest abstract parent type?
	var/abstract_hallucination_parent = /datum/hallucination
	/// Extra info about the hallucination displayed in the log.
	var/feedback_details = ""
	/// The mob we're targeting with the hallucination.
	var/mob/living/hallucinator

/datum/hallucination/New(mob/living/hallucinator)
	if(!isliving(hallucinator))
		stack_trace("[type] was created without a hallucinating mob.")
		qdel(src)
		return

	src.hallucinator = hallucinator
	RegisterSignal(hallucinator, COMSIG_PARENT_QDELETING, PROC_REF(target_deleting))

/// Signal proc for [COMSIG_QDELETING], if the mob hallucinating us is deletes, we should delete too.
/datum/hallucination/proc/target_deleting()
	SIGNAL_HANDLER

	qdel(src)

/// Starts the hallucination.
/datum/hallucination/proc/start()
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("[type] didn't implement any hallucination effects in start.")

/datum/hallucination/Destroy()
	if(hallucinator)
		UnregisterSignal(hallucinator, COMSIG_PARENT_QDELETING)
		hallucinator = null

	return ..()

/// Returns a random turf in a ring around the hallucinator mob.
/// Useful for sound hallucinations.
/datum/hallucination/proc/random_far_turf()
	var/first_offset = pick(-8, -7, -6, -5, 5, 6, 7, 8)
	var/second_offset = rand(-8, 8)
	var/x_offset
	var/y_offset
	if(prob(50))
		x_offset = first_offset
		y_offset = second_offset
	else
		x_offset = second_offset
		y_offset = first_offset

	return locate(hallucinator.x + x_offset, hallucinator.y + y_offset, hallucinator.z)
