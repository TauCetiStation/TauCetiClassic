#define PROTOTYPE_ADJECTIVES list("prototype", "mock-up", "model")
#define PROTOTYPE_DESC_REMARKS list("Seems somewhat unreliable.", "Is somewhat wibbly-wobbly.", "Does not neccesarily work.", "50% of the time it gives 100% output.", "In most cases - it works.")

#define CRIT_FAIL_ADJECTIVES list("defective", "broken", "borked", "unusable", "useless")
#define CRIT_FAIL_REMARKS list("Completely unusable.", "Utterly pointless.", "In no possible way useful.", "Broken to the point of no return.", "Defective.", "Doesn't seem to work.")

// This is very important. Almost all items constructed via protolathe are unreliable
// And are deconstructions of items made by deconstructing other items
// So consider them tests of "new" construction techniques for an item already known
/obj/proc/prototipify(min_reliability=0, max_reliability=100)
	origin_tech = null
	reliability = CLAMP(rand(min_reliability, max_reliability), 0, 100)

	if(reliability < 100)
		if(!prob(reliability))
			crit_fail = TRUE
			name = pick(CRIT_FAIL_ADJECTIVES) + " " + name
			desc += " " + pick(CRIT_FAIL_REMARKS)
		else
			name = pick(PROTOTYPE_ADJECTIVES) + " " + name
			desc += " " + pick(PROTOTYPE_DESC_REMARKS)
	else
		name = pick(PROTOTYPE_ADJECTIVES) + " " + name + " MK I"

	for(var/obj/sub_obj in contents)
		sub_obj.prototipify(min_reliability, max_reliability)

	update_icon()

/obj/item/prototipify(min_reliability=0, max_reliability=100)
	..()
	if(!prob(reliability))
		w_class += 1

/obj/item/weapon/stock_parts/prototipify(min_reliability=0, max_reliability=100)
	..()
	while(!prob(reliability))
		if(rating == 0)
			break
		rating = max(rating - 1, 0)

#undef PROTOTYPE_ADJECTIVES
#undef PROTOTYPE_DESC_REMARKS

#undef CRIT_FAIL_ADJECTIVES
#undef CRIT_FAIL_REMARKS
