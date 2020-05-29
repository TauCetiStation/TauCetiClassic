/* Stack type objects!
 * Contains:
 * 		Stacks
 * 		Recipe datum
 * 		Recipe list datum
 */

/*
 * Stacks
 */
/obj/item/stack
	gender = PLURAL
	origin_tech = "materials=1"
	usesound = 'sound/items/Deconstruct.ogg'

	var/list/datum/stack_recipe/recipes
	var/singular_name
	var/amount = 1
	var/max_amount = 50                 // also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/merge_type = null               // This path and its children should merge with this stack, defaults to src.type
	var/full_w_class = ITEM_SIZE_NORMAL // The weight class the stack should have at amount > 2/3rds max_amount
	var/is_fusion_fuel

/obj/item/stack/atom_init(mapload, new_amount = null, merge = FALSE)
	. = ..()

	if(new_amount)
		amount = new_amount
	if(!merge_type)
		merge_type = type
	if(merge)
		for(var/obj/item/stack/S in loc)
			if(S.merge_type == merge_type)
				merge(S)

	update_weight()
	update_icon()

/obj/item/stack/Destroy()
	amount = 0 // lets say anything that wants to use us, that we are empty.

	if (usr && usr.machine == src)
		usr << browse(null, "window=stack")
	if(recipes)
		recipes = null

	return ..()

/obj/item/stack/proc/update_weight()
	if(amount <= (max_amount * (1 / 3)))
		w_class = clamp(full_w_class - 2, ITEM_SIZE_TINY, full_w_class)
	else if (amount <= (max_amount * (2 / 3)))
		w_class = clamp(full_w_class - 1, ITEM_SIZE_TINY, full_w_class)
	else
		w_class = full_w_class

/obj/item/stack/examine(mob/user)
	..()
	if(src in view(1, user))
		if(get_amount() > 1)
			to_chat(user, "There are [get_amount()] [get_stack_name()] in the stack.")
		else
			to_chat(user, "There is [get_amount()] [get_stack_name()] in the stack.")

/obj/item/stack/proc/get_stack_name()
	if(singular_name)
		if(get_amount() > 1)
			return "[singular_name]\s"
		else
			return "[singular_name]"
	else
		return ""

/obj/item/stack/attack_self(mob/user)
	list_recipes(user)

/obj/item/stack/proc/list_recipes(mob/user, recipes_sublist)
	if (!recipes)
		return
	if (!src || amount<=0)
		user << browse(null, "window=stack")
	user.set_machine(src) //for correct work of onclose
	var/list/recipe_list = recipes
	if (recipes_sublist && recipe_list[recipes_sublist] && istype(recipe_list[recipes_sublist], /datum/stack_recipe_list))
		var/datum/stack_recipe_list/srl = recipe_list[recipes_sublist]
		recipe_list = srl.recipes
	var/t1 = text("<HTML><HEAD><title>Constructions from []</title></HEAD><body><TT>Amount Left: []<br>", src, src.amount)
	for(var/i=1;i<=recipe_list.len,i++)
		var/E = recipe_list[i]
		if (isnull(E))
			t1 += "<hr>"
			continue

		if (i>1 && !isnull(recipe_list[i-1]))
			t1+="<br>"

		if (istype(E, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/srl = E
			if (src.amount >= srl.req_amount)
				t1 += "<a href='?src=\ref[src];sublist=[i]'>[srl.title] ([srl.req_amount] [src.singular_name]\s)</a>"
			else
				t1 += "[srl.title] ([srl.req_amount] [src.singular_name]\s)<br>"

		if (istype(E, /datum/stack_recipe))
			var/datum/stack_recipe/R = E
			var/max_multiplier = round(src.amount / R.req_amount)
			var/title
			var/can_build = 1
			can_build = can_build && (max_multiplier>0)
			/*
			if (R.one_per_turf)
				can_build = can_build && !(locate(R.result_type) in usr.loc)
			if (R.on_floor)
				can_build = can_build && istype(usr.loc, /turf/simulated/floor)
			*/
			if (R.res_amount>1)
				title+= "[R.res_amount]x [R.title]\s"
			else
				title+= "[R.title]"
			title+= " ([R.req_amount] [src.singular_name]\s)"
			if (can_build)
				t1 += text("<A href='?src=\ref[src];sublist=[recipes_sublist];make=[i]'>[title]</A>  ")
			else
				t1 += text("[]", title)
				continue
			if (R.max_res_amount>1 && max_multiplier>1)
				max_multiplier = min(max_multiplier, round(R.max_res_amount/R.res_amount))
				t1 += " |"
				var/list/multipliers = list(5,10,25)
				for (var/n in multipliers)
					if (max_multiplier>=n)
						t1 += " <A href='?src=\ref[src];make=[i];multiplier=[n]'>[n*R.res_amount]x</A>"
				if (!(max_multiplier in multipliers))
					t1 += " <A href='?src=\ref[src];make=[i];multiplier=[max_multiplier]'>[max_multiplier*R.res_amount]x</A>"

	t1 += "</TT></body></HTML>"
	user << browse(t1, "window=stack")
	onclose(user, "stack")
	return

/obj/item/stack/Topic(href, href_list)
	..()
	if (usr.incapacitated() || (usr.get_active_hand() != src && usr.get_inactive_hand() != src))
		return

	if (href_list["sublist"] && !href_list["make"])
		list_recipes(usr, text2num(href_list["sublist"]))

	if (href_list["make"])
		var/list/recipes_list = recipes
		if (href_list["sublist"])
			var/datum/stack_recipe_list/srl = recipes_list[text2num(href_list["sublist"])]
			recipes_list = srl.recipes
		var/datum/stack_recipe/R = recipes_list[text2num(href_list["make"])]
		var/multiplier = text2num(href_list["multiplier"])
		if (!multiplier) multiplier = 1
		if(src.amount < (R.req_amount*multiplier))
			if (R.req_amount*multiplier>1)
				to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.req_amount*multiplier] [R.title]\s!</span>")
			else
				to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.title]!</span>")
			return
		if (R.one_per_turf && (locate(R.result_type) in usr.loc))
			to_chat(usr, "<span class='warning'>There is another [R.title] here!</span>")
			return
		if (R.on_floor)
			usr.client.cob.turn_on_build_overlay(usr.client, R, src)
			usr << browse(null, "window=stack")
			return
		if (R.time)
			if(usr.is_busy())
				return
			to_chat(usr, "<span class='notice'>Building [R.title] ...</span>")
			if (!do_after(usr, R.time, target = usr))
				return
		if(!src.use(R.req_amount*multiplier))
			return
		var/atom/O = new R.result_type( usr.loc )
		O.dir = usr.dir
		if (R.max_res_amount>1)
			var/obj/item/stack/new_item = O
			new_item.amount = R.res_amount*multiplier
		O.add_fingerprint(usr)
		//BubbleWrap - so newly formed boxes are empty
		if ( istype(O, /obj/item/weapon/storage) )
			for (var/obj/item/I in O)
				qdel(I)
		//BubbleWrap END
	if (src && usr.machine==src) //do not reopen closed window
		INVOKE_ASYNC(src, .proc/interact, usr)
		return
	return

/obj/item/stack/proc/get_amount()
	. = (amount)

/obj/item/stack/proc/is_cyborg()
	return istype(loc, /obj/item/weapon/robot_module) || istype(loc, /mob/living/silicon)

/obj/item/stack/use(used, transfer = FALSE)
	if(used < 0)
		stack_trace("[src.type]/use() called with a negative parameter [used]")
		return FALSE
	if(zero_amount())
		return FALSE
	if(amount < used)
		return FALSE

	amount -= used

	if(!zero_amount())
		update_weight()
		update_icon()

	return TRUE

/obj/item/stack/tool_use_check(mob/living/user, amount)
	if(get_amount() < amount)
		if(singular_name)
			if(amount > 1)
				to_chat(user, "<span class='warning'>You need at least [amount] [singular_name]\s to do this!</span>")
			else
				to_chat(user, "<span class='warning'>You need at least [amount] [singular_name] to do this!</span>")
		else
			to_chat(user, "<span class='warning'>You need at least [amount] to do this!</span>")

		return FALSE

	return TRUE

/obj/item/proc/use_multi(mob/user, list/res_list)
	. = TRUE
	for(var/x in res_list)
		var/obj/item/stack/S = x
		if(S.amount < res_list[x])
			. = FALSE
			to_chat(user, "<span class='notice'>There is not enough [S.name]. You need [res_list[x]].</span>")
			break
	if(.)
		for(var/x in res_list)
			var/obj/item/stack/S = x
			S.use(res_list[x])

/obj/item/stack/proc/zero_amount()
	if(amount < 1 && !is_cyborg())
		qdel(src)
		return TRUE
	return FALSE

/obj/item/stack/proc/add(_amount)
	if(_amount < 0)
		stack_trace("[src.type]/add() called with a negative parameter [_amount]")
		return
	amount += _amount
	update_icon()
	update_weight()

/obj/item/stack/proc/set_amount(_amount)
	amount = _amount
	if(!zero_amount())
		update_icon()
		update_weight()

/obj/item/stack/proc/merge(obj/item/stack/S) //Merge src into S, as much as possible
	if(QDELETED(S) || QDELETED(src) || S == src) //amusingly this can cause a stack to consume itself, let's not allow that.
		return
	var/transfer = get_amount()
	var/old_loc = loc
	transfer = min(transfer, S.max_amount - S.amount)
	if(pulledby)
		pulledby.start_pulling(S)
	S.copy_evidences(src)
	use(transfer, TRUE)
	if (istype(old_loc, /obj/item/weapon/storage) && amount < 1 && !is_cyborg())
		var/obj/item/weapon/storage/s = old_loc
		s.update_ui_after_item_removal()
	S.add(transfer)

/obj/item/stack/attack_hand(mob/user)
	if (user.get_inactive_hand() == src)
		if(zero_amount())
			return
		change_stack(user, 1)
		if(!QDELETED(src) && usr.machine == src)
			INVOKE_ASYNC(src, .proc/interact, usr)
	else
		..()

/obj/item/stack/AltClick(mob/living/user)
	if(!istype(user) || !CanUseTopic(user))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return
	if(is_cyborg())
		return
	else
		if(zero_amount())
			return
		//get amount from user
		var/min = 0
		var/max = get_amount()
		var/stackmaterial = round(input(user,"How many sheets do you wish to take out of this stack? (Maximum  [max])") as num)
		if(stackmaterial == null || stackmaterial <= min || stackmaterial >= get_amount() || !CanUseTopic(user))
			return
		else
			change_stack(user, stackmaterial)
			to_chat(user, "<span class='notice'>You take [stackmaterial] sheets out of the stack</span>")

/obj/item/stack/proc/change_stack(mob/user, amount)
	var/obj/item/stack/F = new type(user, amount, FALSE)
	. = F
	F.copy_evidences(src)
	user.put_in_hands(F)
	add_fingerprint(user)
	F.add_fingerprint(user)
	use(amount, TRUE)

/obj/item/stack/attackby(obj/item/I, mob/user, params)
	if(istype(I, merge_type))
		var/obj/item/stack/S = I
		merge(S)
		to_chat(user, "<span class='notice'>Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s.</span>")
		if(!QDELETED(S) && usr.machine == S)
			INVOKE_ASYNC(S, /obj/item/stack.proc/interact, usr)
		if(!QDELETED(src) && usr.machine == src)
			INVOKE_ASYNC(src, .proc/interact, usr)
	else
		return ..()

/obj/item/stack/proc/copy_evidences(obj/item/stack/from)
	src.blood_DNA = from.blood_DNA
	src.fingerprints  = from.fingerprints
	src.fingerprintshidden  = from.fingerprintshidden
	src.fingerprintslast  = from.fingerprintslast
	//TODO bloody overlay

/*
 * Recipe datum
 */
/datum/stack_recipe
	var/title = "ERROR"
	var/result_type
	var/req_amount = 1
	var/res_amount = 1
	var/max_res_amount = 1
	var/time = 0
	var/one_per_turf = FALSE
	var/on_floor = FALSE

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = FALSE, on_floor = FALSE)
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor

/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes = null
	var/req_amount = 1

/datum/stack_recipe_list/New(title, recipes, req_amount = 1)
	src.title = title
	src.recipes = recipes
	src.req_amount = req_amount
