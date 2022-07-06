//used to melt stuff with thermite



#define THERMITE_TIP "Этот объект покрыт термитом."
#define THERMITE_COLOR "#423b26" //rgb: 26, 23, 15

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

/datum/component/thermite/Initialize(var/_amount, var/_min_amount = 30, var/_max_time = 60, var/_min_time = 5)
	amount = _amount
	min_amount = _min_amount
	max_time = _max_time
	min_time = _min_time

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), .proc/remove_overlay)
	RegisterSignal(parent, list(COMSIG_PARENT_ATTACKBY), .proc/attack_reaction)

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
	remove_overlay()

//called when thermite is ignited by someone
/datum/component/thermite/proc/ignite(mob/user)
	var/atom/A = parent

	if(min_amount <= 0)
		A.visible_message("<span class='warning'>Thermite isn't strong enough to melt [src]! </span>")
		var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread()
		S.set_up(1, 1, parent)
		qdel(src)
		return FALSE

	else if(amount < min_amount)
		A.visible_message("<span class='warning'>There isn't enough thermite to melt [src]! </span>")
		var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread()
		S.set_up(1, 1, parent)
		qdel(src)
		return FALSE

	var/time = max_time * (min_amount / amount)
	if(time < min_time)
		time = min_time

	melt(time)

//called after ignition to add overlay and launch timer
/datum/component/thermite/proc/melt(var/time)
	var/atom/A = parent
	var/r = A.thermite_melt()

	var/overlay_loc = isturf(A) ? A : A.loc

	if(r == FALSE) //we don't have special overload for parent, so do the default melting
		var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread()
		S.set_up(3, 1, parent)
		burn_overlay = new /obj/effect/overlay/thermite(overlay_loc)
		A.visible_message("<span class='warning'>Thermite starts melting [parent]. </span>")

		var/turf/L = isturf(A) ? A : get_turf(parent)
		L.hotspot_expose(3200, 10, parent)

		burn_timer = addtimer(CALLBACK(src, .proc/burn), time SECONDS, TIMER_STOPPABLE)
	else
		burn_overlay = r

//actually destroys the parent
/datum/component/thermite/proc/burn()
	var/atom/A = parent
	var/r = A.thermite_burn()

	if(r == FALSE)
		qdel(parent)

/datum/component/thermite/proc/remove_overlay()
	if(burn_overlay != null)
		qdel(burn_overlay)

/datum/component/thermite/proc/attack_reaction(datum/source, obj/item/I,  mob/living/user, params)
	var/atom/A = parent
	var/datum/gas_mixture/env = I.return_air()
	var/temp = 0.0

	temp = (env.temperature + I.get_current_temperature()) - T0C
	if(temp > 1920)
		ignite(user)

	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/soap))
		qdel(src)

	return COMPONENT_NO_AFTERATTACK



#undef THERMITE_TIP
#undef THERMITE_COLOR