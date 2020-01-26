#define PROTOTYPE_ADJECTIVES list("prototype", "mock-up", "model")
#define PROTOTYPE_DESC_REMARKS list("Seems somewhat unreliable.", "Is somewhat wibbly-wobbly.", "Does not neccesarily work.", "50% of the time it gives 100% output.", "In most cases - it works.")

// This is very important. Almost all items constructed via protolathe are unreliable
// And are deconstructions of items made by deconstructing other items
// So consider them tests of "new" construction techniques for an item already known
/obj/proc/prototipify()
	origin_tech = null
	name = pick(PROTOTYPE_ADJECTIVES) + " " + name
	desc += " " + pick(PROTOTYPE_DESC_REMARKS)
	reliability = rand(100)

	for(var/obj/sub_obj in contents)
		sub_obj.prototipify()

	if(!prob(reliability))
		crit_fail = TRUE
	update_icon()

/obj/item/prototipify()
	w_class += 1
	..()

#undef PROTOTYPE_ADJECTIVES
#undef PROTOTYPE_DESC_REMARKS
