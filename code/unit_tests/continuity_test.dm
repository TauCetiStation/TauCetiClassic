/datum/unit_test/continuity
	name = "CONTINUITY: Continuity objects should return data they saved and throw an erorr when they should."

	disabled = FALSE
	why_disabled = "Runtimes while checking"

	var/list/good_entries = list(
		"field1" = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
		"field2" = list("A" = "1", "B" = "3", "C" = "7"),
		"field3" = "главрыба",
		"field4" = 30,
		"field5" = /atom/movable,
	)

	var/list/bad_entries = list(
		"field1" = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, "A!"),
		"field2" = list("A" = "5", "B" = "3", "C" = "7"),
		"field3" = "череповец",
		"field4" = 42,
		"field5" = /datum,
	)

/datum/unit_test/continuity/proc/testproc()

/datum/unit_test/continuity/start_test()
	var/atom/movable/A = new
	var/list/continuity_fields = list(
		"field1" = new /datum/primitive_field/listfield(
			entry_config = new /datum/primitive_field/int(
				max_num = 999,
				min_num = -999,
				can_be_null = TRUE
			)
		),
		"field2" = new /datum/primitive_field/alistfield(
			key_config = new /datum/primitive_field/string(
				max_length = 999,
				allowed_characters = list("A", "B", "C")
			),
			entry_config = new /datum/primitive_field/string(
				max_length = 999,
				allowed_characters = list("1", "3", "7")
			)
		),
		"field3" = new /datum/primitive_field/string(
			max_length = 999,
			in_list = list("абырвалг", "главрыба")
		),
		"field4" = new /datum/primitive_field/int(
			max_num = 40,
			min_num = 0
		),
		"field5" = new /datum/primitive_field/type(
			in_list = list(/atom, /atom/movable)
		),
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", continuity_fields)

	try
		var/list/check_entries = Object.sanitize_data(good_entries)
		try
			Object.sanitize_data(bad_entries)
			throw EXCEPTION("Continuity: bad entries did not throw an error!")
		catch

		if(!(check_entries ~= good_entries))
			throw EXCEPTION("Continuity: initial and saved entries doesn't match!")

		test_list()
		test_alist()
		test_string()
		test_int()
		test_type()
		test_inlists()

		pass("Continuity works just fine.")
	catch(var/exception/e)
		fail("[e] on [e.file]:[e.line]")

	return TRUE

/datum/unit_test/continuity/proc/test_list()
	var/list/testlist = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/primitive_field/listfield(
			entry_config = new /datum/primitive_field/int
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("notfield" = testlist))
	catch(var/exception/e)
		if(e.name != "Missing field field")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = testlist, "notfield" = testlist))
	catch(e)
		if(e.name != "Invalid notfield")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = testlist + "FF"))
	catch(e)
		if(e.name != "Not a number")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = null))
	catch(e)
		if(e.name != "Is null")
			throw EXCEPTION("[e.name] was thrown instead.")

	Object.sanitize_data(list("field" = testlist))

	return TRUE

/datum/unit_test/continuity/proc/test_alist()
	var/list/testlist = list("A" = 1, "B" = 2, "C" = 3, "D" = 4, "E" = 5, "F" = 6, "G" = 7, "H" = 8, "I" = 9, "J" = 10)
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/primitive_field/alistfield(
			key_config = new /datum/primitive_field/string(max_length = 10),
			entry_config = new /datum/primitive_field/int
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("notfield" = testlist))
	catch(var/exception/e)
		if(e.name != "Missing field field")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = testlist, "notfield" = testlist))
	catch(e)
		if(e.name != "Invalid notfield")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = list(/atom = 15)))
	catch(e)
		if(e.name != "Not a text")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = list("/atom" = "15")))
	catch(e)
		if(e.name != "Not a number")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = null))
	catch(e)
		if(e.name != "Is null")
			throw EXCEPTION("[e.name] was thrown instead.")

	Object.sanitize_data(list("field" = testlist))

	return TRUE

/datum/unit_test/continuity/proc/test_string()
	var/randlength = rand(1, 10)
	var/randstring = random_string(randlength, global.alphabet_uppercase)
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/primitive_field/string(
			max_length = randlength + 1,
			allowed_characters = global.alphabet_uppercase
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("notfield" = randstring))
	catch(var/exception/e)
		if(e.name != "Missing field field")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = randstring, "notfield" = randstring))
	catch(e)
		if(e.name != "Invalid notfield")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = null))
	catch(e)
		if(e.name != "Is null")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = randstring + "FF"))
	catch(e)
		if(e.name != "Text is longer than it should be")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = 1))
	catch(e)
		if(e.name != "Not a text")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = randstring + "$"))
	catch(e)
		if(e.name != "Text contains bad characters")
			throw EXCEPTION("[e.name] was thrown instead.")

	Object.sanitize_data(list("field" = randstring))

	return TRUE

/datum/unit_test/continuity/proc/test_int()
	var/randnum = rand(-10, 10)
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/primitive_field/int(
			max_num = randnum,
			min_num = randnum
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("notfield" = randnum))
	catch(var/exception/e)
		if(e.name != "Missing field field")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = randnum, "notfield" = randnum))
	catch(e)
		if(e.name != "Invalid notfield")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = null))
	catch(e)
		if(e.name != "Is null")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = "[randnum]"))
	catch(e)
		if(e.name != "Not a number")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = randnum + 1))
	catch(e)
		if(e.name != "Number is bigger than it should be")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = randnum - 1))
	catch(e)
		if(e.name != "Number is smaller than it should be")
			throw EXCEPTION("[e.name] was thrown instead.")

	Object.sanitize_data(list("field" = randnum))

	return TRUE

/datum/unit_test/continuity/proc/test_type()
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/primitive_field/type
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("notfield" = /atom/movable))
	catch(var/exception/e)
		if(e.name != "Missing field field")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = /atom/movable, "notfield" = /atom/movable))
	catch(e)
		if(e.name != "Invalid notfield")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = null))
	catch(e)
		if(e.name != "Is null")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = "/atom/movable"))
	catch(e)
		if(e.name != "Not a path")
			throw EXCEPTION("[e.name] was thrown instead.")

	Object.sanitize_data(list("field" = /atom/movable))

	return TRUE

/datum/unit_test/continuity/proc/test_inlists()
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field1" = new /datum/primitive_field/string(
			in_list = list("A", "B")
		),
		"field2" = new /datum/primitive_field/type(
			in_list = list(/atom, /atom/movable)
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("field1" = "C", "field2" = /atom))
	catch(var/exception/e)
		if(e.name != "Not an allowed string")
			throw EXCEPTION("[e.name] was thrown instead.")

	try
		Object.sanitize_data(list("field1" = "A", "field2" = /atom/movable/abyrvalg))
	catch(e)
		if(e.name != "Not an allowed type")
			throw EXCEPTION("[e.name] was thrown instead.")

	Object.sanitize_data(list("field1" = "A", "field2" = /atom))

	A = new
	paramslist = list(
		"field" = new /datum/primitive_field/string(
			regex = @"^\d+$"
		)
	)

	Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("field" = "text"))
	catch(e)
		if(e.name != "Regex failed")
			throw EXCEPTION("[e.name] was thrown instead.")

	Object.sanitize_data(list("field" = "123"))

	return TRUE

/atom/movable/abyrvalg
