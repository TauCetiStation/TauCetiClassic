//used to melt stuff with thermite



#define THERMITE_TIP "Этот объект покрыт термитом."
#define THERMITE_COLOR "#86784e"

/datum/mechanic_tip/thermite
	tip_name = THERMITE_TIP

/datum/mechanic_tip/thermite/New()
	description = "Вы можете его расплавить, воспламенив термит горелкой/энергомечом/прочими средствами."



/datum/component/thermite
	//how much thermite is on parent
	var/amount

	//how much thermite is required to burn parent. set to zero/negative if you don't want for you atom to be melted at all
	var/min_amount

	//maximal time for burning parent, decreases with more thermite applied
	var/max_time

	//minimal time for burning parent, so you can't melt wall instantly with 999 units of thermite
	var/min_time

	//storing overlay for deletion
	var/burn_overlay

	//timer for burning parent
	var/burn_timer

	//color which parent had before thermite was splashed on it
	var/old_color

	//anchor state which parent had before thermite was ignited on it
	var/old_anchor

/datum/component/thermite/Initialize(_amount, _min_amount = 30, _max_time = 60, _min_time = 5)
	amount = _amount
	min_amount = _min_amount
	max_time = _max_time
	min_time = _min_time

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), .proc/Destroy)
	RegisterSignal(parent, list(COMSIG_PARENT_ATTACKBY), .proc/item_attack_reaction)
	RegisterSignal(parent, list(COMSIG_ATOM_FIRE_ACT), .proc/fire_attack_reaction)

	var/atom/A = parent
	old_color = A.color
	A.color = THERMITE_COLOR

	var/datum/mechanic_tip/thermite/ttip = new
	parent.AddComponent(/datum/component/mechanic_desc, list(ttip))

/datum/component/thermite/Destroy()
	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(THERMITE_TIP))
	UnregisterSignal(parent, list(COMSIG_PARENT_QDELETING))
	UnregisterSignal(parent, list(COMSIG_PARENT_ATTACKBY))

	var/atom/A = parent
	A.color = old_color
	if(istype(A, /atom/movable))
		var/atom/movable/M = A
		M.freeze_movement = FALSE
		M.anchored = old_anchor
	if(burn_overlay != null)
		if(istype(burn_overlay, /image))
			A.cut_overlay(burn_overlay)
		else
			qdel(burn_overlay)
	if(burn_timer != null)
		deltimer(burn_timer)

//called when thermite is ignited by someone
/datum/component/thermite/proc/ignite()
	var/atom/A = parent

	if(istype(A, /atom/movable))
		var/atom/movable/M = A
		M.freeze_movement = TRUE //we don't want for stuff to move while it's burning (i.e officier beepsky)
		old_anchor = M.anchored
		M.anchored = TRUE

	if(min_amount <= 0)
		A.visible_message("<span class='warning'>Thermite isn't strong enough to melt [parent]! </span>")
		qdel(src)
		return

	else if(amount < min_amount)
		A.visible_message("<span class='warning'>There isn't enough thermite to melt [parent]! </span>")
		qdel(src)
		return

	var/time = max_time * (min_amount / amount)
	if(time < min_time)
		time = min_time

	melt(time)

//called after ignition to add overlay and launch timer
/datum/component/thermite/proc/melt(time)
	var/atom/A = parent
	var/r = A.thermite_melt()

	var/overlay_loc = isturf(A) ? A : A.loc

	if(r == FALSE) //we don't have overload for parent, so do the default melting
		var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread()
		S.set_up(3, 1, parent)
		burn_overlay = new /obj/effect/overlay/thermite(overlay_loc)
		A.visible_message("<span class='warning'>Thermite starts melting [parent]. </span>")

		var/turf/L = isturf(A) ? A : get_turf(parent)
		L.hotspot_expose(3200, 10, parent)
	else
		burn_overlay = r
	burn_timer = addtimer(CALLBACK(src, .proc/burn), time SECONDS, TIMER_STOPPABLE)

//actually destroys the parent
/datum/component/thermite/proc/burn()
	var/atom/A = parent
	var/r = A.thermite_burn()

	if(r == FALSE) //we don't have overload for parent, so do the default burning
		qdel(parent)

/datum/component/thermite/proc/item_attack_reaction(datum/source, obj/item/I,  mob/living/user, params)
	var/datum/gas_mixture/env = I.return_air()
	var/temp = 0.0
	temp = (env.temperature + I.get_current_temperature()) - T0C
	if(temp > 1920)
		ignite()
	else if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/soap) && burn_timer == null)
		to_chat(user, "You clean [parent], scrubbing thermite off it.")
		qdel(src)
	else if(istype(I, /obj/item/weapon/reagent_containers))
		return

	return COMPONENT_NO_ATTACK_PROCESSING

/datum/component/thermite/proc/fire_attack_reaction()
	ignite()

/datum/component/thermite/proc/set_amount(_amount, ignore_burning = FALSE)
	if(!ignore_burning && burn_timer != null)
		return
	amount = _amount
	if(amount <= 0)
		qdel(src)



#undef THERMITE_TIP
#undef THERMITE_COLOR
