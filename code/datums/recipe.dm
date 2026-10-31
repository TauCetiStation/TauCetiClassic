/* * * * * * * * * * * * * * * * * * * * * * * * * *
 * /datum/recipe by rastaf0            13 apr 2011 *
 * * * * * * * * * * * * * * * * * * * * * * * * * *
 * This is powerful and flexible recipe system.
 * It exists not only for food.
 * supports both reagents and objects as prerequisites.
 * In order to use this system you have to define a deriative from /datum/recipe
 * * reagents are reagents. Acid, milc, booze, etc.
 * * items are objects. Fruits, tools, circuit boards.
 * * result is type to create as new object
 * * time is optional parameter, you shall use in in your machine,
     default /datum/recipe procs does not rely on this parameter.
 *
 *  Functions you need:
 *  /datum/recipe/proc/make(obj/container)
 *    Creates result inside container,
 *    deletes prerequisite reagents,
 *    transfers reagents from prerequisite objects,
 *    deletes all prerequisite objects (even not needed for recipe at the moment).
 *
 *  /proc/select_recipe(list/datum/recipe/avaiable_recipes, obj/obj, exact = 1)
 *    Wonderful function that select suitable recipe for you.
 *    obj is a machine (or magik hat) with prerequisites,
 *    exact = 0 forces algorithm to ignore superfluous stuff.
 *
 *
 *  Functions you do not need to call directly but could:
 *  /datum/recipe/proc/check_reagents(datum/reagents/avail_reagents)
 *    //1=precisely,  0=insufficiently, -1=superfluous
 *
 *  /datum/recipe/proc/check_items(obj/container)
 *    //1=precisely, 0=insufficiently, -1=superfluous
 *
 * */

/datum/recipe
	var/list/reagents       // example:  = list("berryjuice" = 5) // do not list same reagent twice
	var/list/items          // example: = list(/obj/item/weapon/crowbar, /obj/item/weapon/welder) // place /foo/bar before /foo
	var/result              // example: = /obj/item/weapon/reagent_containers/food/snacks/donut/normal
	var/time = 100          // 1/10 part of second
	var/byproduct		    // example: = /obj/item/weapon/kitchen/mould		// byproduct to return, such as a mould or trash

	var/alist/recipe_ingredients_list = alist()
	var/recipe_ingredients_count = 0
	var/recipe_ingredients_length = 0
	var/recipe_error_threshold = 0.05 // 5% recipe error threshold, can be changed for any recipe if needed

/datum/recipe/New()
	for(var/reagent_type in reagents)
		recipe_ingredients_list[reagent_type] = reagents[reagent_type]

	for(var/item_type in items)
		if(!recipe_ingredients_list["[item_type]"])
			recipe_ingredients_list["[item_type]"] = 1
		else
			recipe_ingredients_list["[item_type]"] = recipe_ingredients_list["[item_type]"] + 1

	recipe_ingredients_count = values_sum(recipe_ingredients_list)
	recipe_ingredients_length = values_dot(recipe_ingredients_list, recipe_ingredients_list)

/proc/select_recipe(list/recipes_list, alist/ingredients)
	var/min_recipe = null
	var/min_error = 1
	var/ingredients_length = values_dot(ingredients, ingredients)
	for(var/datum/recipe/R in recipes_list)
		var/recipe_error = R.get_recipe_error_or_null(ingredients, ingredients_length)
		if(isnull(recipe_error))
			continue

		if(recipe_error == 0)
			return R

		if(recipe_error < min_error)
			min_error = recipe_error
			min_recipe = R

	return min_recipe

/datum/recipe/proc/get_recipe_error_or_null(alist/ingredients, ingredients_length)
	var/recipe_error = 1 - (values_dot(recipe_ingredients_list, ingredients) ** 2) / (recipe_ingredients_length * ingredients_length)

	if(recipe_error > recipe_error_threshold)
		return null

	return recipe_error

/datum/recipe/proc/get_product_amount(ingredients_count, multiplier = 1)
	var/recipe_product_count = max(1, FLOOR(ingredients_count / recipe_ingredients_count, 1))

	return recipe_product_count * multiplier

/datum/recipe/proc/make_food(obj/container)
	return new result(container)

/datum/recipe/proc/get_byproduct()
	if(byproduct)
		return byproduct
	else
		return null
