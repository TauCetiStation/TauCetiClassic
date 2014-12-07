/obj/item/weapon/pickaxe/hammer/copyhammer
	name = "copyhammer(in dev)"
	icon_state = "toyhammer"
	item_state = "toyhammer"


/obj/item/weapon/pickaxe/hammer/copyhammer/attack(atom/something, mob/user as mob)
//	world << "trying clone"
//	world << something

/*	var/list/denyvar = list("client", "key", "loc", "type")

	if(ismob(something))
		return

	if(isobj(something))
		var/obj/orig_obj = something
		var/obj/copy_obj = new orig_obj.type


		for(var/V in orig_obj.vars)
			if(V in denyvar)
				continue
			else
				copy_obj.vars[V] = orig_obj.vars[V]*/

/obj/item/weapon/pickaxe/hammer/copyhammer/afterattack(atom/A as obj, mob/user as mob)

	var/list/denyvar = list("type","loc","locs","vars", "parent", "parent_type","verbs","ckey","key")

	if(ismob(A))
		return

	if(isobj(A))
		var/obj/orig_obj = A
		var/obj/copy_obj = new orig_obj.type


		for(var/V in orig_obj.vars)
			if(V in denyvar)
				continue
			else
				copy_obj.vars[V] = orig_obj.vars[V]