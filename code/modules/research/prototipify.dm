#define PROTOTYPE_ADJECTIVES list("prototype", "mock-up", "model")
#define PROTOTYPE_DESC_REMARKS list("Seems somewhat unreliable.", "Is somewhat wibbly-wobbly.", "Does not neccesarily work.", "50% of the time it gives 100% output.", "In most cases - it works.")

#define CRIT_FAIL_ADJECTIVES list("defective", "broken", "borked", "unusable", "useless")
#define CRIT_FAIL_REMARKS list("Completely unusable.", "Utterly pointless.", "In no possible way useful.", "Broken to the point of no return.", "Defective.", "Doesn't seem to work.")

#define PROTOTYPE_MARK(mark) "Mk. [num2roman(mark)]"

// This is very important. Almost all items constructed via protolathe are unreliable
// And are deconstructions of items made by deconstructing other items
// So consider them tests of "new" construction techniques for an item already known
/obj/proc/prototipify(min_reliability=0, max_reliability=100, veiled_threat = FALSE)
	origin_tech = null

	var/rel_val = rand(min_reliability, max_reliability)
	var/saved_rel_val = rel_val
	var/mark = 0
	while(rel_val >= 100)
		rel_val -= 100
		mark += 1
	if(rel_val < 0)
		rel_val = 0

	reliability = mark > 0 ? 100 : rel_val

	//veiled_threat just used for hide information about the brokenness of the item
	if(veiled_threat)
		/*
		/have opinion this will not give any special effect
		/on the current casual R&D system and prototypes,
		/but the idea seems to be correct and good.
		/Look at the almost complete absence of rigged batteries
		/and crit_fail check in examine (stock_parts/cell)
		/and weapon overlay in nuclear gun (energy/gun/nuclear)
		/and probably more feedbacks for user which he would be better not showing
		*/
		crit_fail = TRUE
		name += " " + PROTOTYPE_MARK(max(mark, 1))
	else
		if(reliability < 100)
			if(!prob(reliability))
				crit_fail = TRUE
				name = pick(CRIT_FAIL_ADJECTIVES) + " " + name
				desc += " " + pick(CRIT_FAIL_REMARKS)
			else
				name = pick(PROTOTYPE_ADJECTIVES) + " " + name
				desc += " " + pick(PROTOTYPE_DESC_REMARKS)
		else
			name += " " + PROTOTYPE_MARK(mark)

	for(var/obj/sub_obj in contents)
		sub_obj.prototipify(min_reliability, max_reliability, veiled_threat)

	set_prototype_qualities(rel_val=saved_rel_val, mark=mark)

	update_icon()

/obj/proc/set_prototype_qualities(rel_val=100, mark=0)
	for(var/i in 1 to 10)
		if(prob(300 - rel_val))
			price *= 1.2
		else
			break

	if(crit_fail)
		price *= 0.75
	else if(!prob(rel_val))
		price *= 0.9

/obj/item/set_prototype_qualities(rel_val=100, mark=0)
	..()
	if(!prob(200 - rel_val))
		w_class = max(SIZE_MINUSCULE, w_class - 1)
	else if(!prob(rel_val))
		w_class += 1
	if(mark > 0)
		toolspeed -= 0.2 * (mark - 1)
	while(!prob(reliability))
		if(toolspeed > 3)
			break
		toolspeed += 0.2

/obj/item/weapon/stock_parts/set_prototype_qualities(rel_val=100, mark=0)
	..()
	if(mark)
		rating += mark - 1
	while(!prob(reliability))
		if(rating == 0)
			break
		rating = max(rating - 1, 0)

#undef PROTOTYPE_ADJECTIVES
#undef PROTOTYPE_DESC_REMARKS

#undef CRIT_FAIL_ADJECTIVES
#undef CRIT_FAIL_REMARKS

#undef PROTOTYPE_MARK
