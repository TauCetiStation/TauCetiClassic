/proc/cmp_numeric_dsc(a,b)
	return b - a

/proc/cmp_numeric_asc(a,b)
	return a - b

/proc/cmp_text_asc(a,b)
	return sorttext(b,a)

/proc/cmp_text_dsc(a,b)
	return sorttext(a,b)

/proc/cmp_name_asc(atom/a, atom/b)
	return sorttext(b.name, a.name)

/proc/cmp_name_dsc(atom/a, atom/b)
	return sorttext(a.name, b.name)

// list datums should have "order" variable, or it will throw error
// because ":" checks for variable at runtime it's better 
// not to use this cmp for heavy code or big lists
/proc/cmp_general_order_asc(datum/A, datum/B)
	return A:order - B:order

var/global/cmp_field = "name"
/proc/cmp_records_asc(datum/data/record/a, datum/data/record/b)
	return sorttext(b.fields[cmp_field], a.fields[cmp_field])

/proc/cmp_records_dsc(datum/data/record/a, datum/data/record/b)
	return sorttext(a.fields[cmp_field], b.fields[cmp_field])

/proc/cmp_ckey_asc(client/a, client/b)
	return sorttext(b.ckey, a.ckey)

/proc/cmp_ckey_dsc(client/a, client/b)
	return sorttext(a.ckey, b.ckey)

/proc/cmp_subsystem_init(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return initial(b.init_order) - initial(a.init_order)	//uses initial() so it can be used on types

/proc/cmp_subsystem_display(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return sorttext(b.name, a.name)

/proc/cmp_subsystem_priority(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return a.priority - b.priority

/proc/cmp_timer(datum/timedevent/a, datum/timedevent/b)
	return a.timeToRun - b.timeToRun

/proc/cmp_qdel_item_time(datum/qdel_item/A, datum/qdel_item/B)
	. = B.hard_delete_time - A.hard_delete_time
	if (!.)
		. = B.destroy_time - A.destroy_time
	if (!.)
		. = B.failures - A.failures
	if (!.)
		. = B.qdels - A.qdels


/proc/cmp_quirk_asc(datum/quirk/A, datum/quirk/B)
	var/a_sign = num2sign(initial(A.value) * -1)
	var/b_sign = num2sign(initial(B.value) * -1)

	// Neutral traits go last.
	if(a_sign == 0)
		a_sign = 2
	if(b_sign == 0)
		b_sign = 2

	var/a_name = initial(A.name)
	var/b_name = initial(B.name)

	if(a_sign != b_sign)
		return a_sign - b_sign
	else
		return sorttext(b_name, a_name)

/proc/cmp_abs_mood_asc(datum/mood_event/A, datum/mood_event/B)
	var/abs_a = abs(A.mood_change)
	var/abs_b = abs(B.mood_change)

	return abs_a - abs_b

/proc/cmp_abs_mood_dsc(datum/mood_event/A, datum/mood_event/B)
	var/abs_a = abs(A.mood_change)
	var/abs_b = abs(B.mood_change)

	return abs_b - abs_a

/proc/cmp_bridge_commands(a,b)
	return bridge_commands[a].position - bridge_commands[b].position

/proc/cmp_filter_data_priority(list/A, list/B)
	return A["priority"] - B["priority"]

/proc/cmp_job_titles(list/A, list/B)
	. = A["priority"] - B["priority"]
	if (!.)
		. = sorttext(B["rank"], A["rank"])
	if (!.)
		. = sorttext(B["name"], A["name"])

/proc/cmp_spawners_asc(datum/spawner/A, datum/spawner/B)
	return A.priority - B.priority
