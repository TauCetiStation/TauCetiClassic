/datum/unit_test/continuity
	name = "CONTINUITY: Continuity objects should return data they saved and throw an error when they should."

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
			entry_config = new /datum/primitive_field/num(
				max_num = 999,
				min_num = -999,
				can_be_null = TRUE
			)
		),
		"field2" = new /datum/primitive_field/alistfield(
			key_config = new /datum/primitive_field/text(
				max_length = 999,
				regex = @"^[ABC]$"
			),
			entry_config = new /datum/primitive_field/text(
				max_length = 999,
				regex = @"^[137]$"
			)
		),
		"field3" = new /datum/primitive_field/text(
			max_length = 999,
			in_list = list("абырвалг", "главрыба")
		),
		"field4" = new /datum/primitive_field/num(
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
		test_text()
		test_num()
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
			entry_config = new /datum/primitive_field/num
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("notfield" = testlist))
		throw EXCEPTION("No exception")
	catch(var/exception/e1)
		if(e1.name != "Missing field")
			throw EXCEPTION("Missing field expected : [e1.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = testlist, "notfield" = testlist))
		throw EXCEPTION("No exception")
	catch(var/exception/e2)
		if(e2.name != "Invalid field")
			throw EXCEPTION("Invalid field expected : [e2.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = testlist + "FF"))
		throw EXCEPTION("No exception")
	catch(var/exception/e3)
		if(e3.name != "Not a number")
			throw EXCEPTION("Not a number expected : [e3.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = null))
		throw EXCEPTION("No exception")
	catch(var/exception/e4)
		if(e4.name != "Is null")
			throw EXCEPTION("Is null expected : [e4.name] was thrown instead.")

	Object.sanitize_data(list("field" = testlist))

	return TRUE

/datum/unit_test/continuity/proc/test_alist()
	var/list/testlist = list("A" = 1, "B" = 2, "C" = 3, "D" = 4, "E" = 5, "F" = 6, "G" = 7, "H" = 8, "I" = 9, "J" = 10)
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/primitive_field/alistfield(
			key_config = new /datum/primitive_field/text(max_length = 10),
			entry_config = new /datum/primitive_field/num
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("notfield" = testlist))
		throw EXCEPTION("No exception")
	catch(var/exception/e1)
		if(e1.name != "Missing field")
			throw EXCEPTION("Missing field expected : [e1.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = testlist, "notfield" = testlist))
		throw EXCEPTION("No exception")
	catch(var/exception/e2)
		if(e2.name != "Invalid field")
			throw EXCEPTION("Invalid field expected : [e2.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = list(/atom = 15)))
		throw EXCEPTION("No exception")
	catch(var/exception/e3)
		if(e3.name != "Not a text")
			throw EXCEPTION("Not a text expected : [e3.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = list("/atom" = "15")))
		throw EXCEPTION("No exception")
	catch(var/exception/e4)
		if(e4.name != "Not a number")
			throw EXCEPTION("Not a number expected : [e4.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = null))
		throw EXCEPTION("No exception")
	catch(var/exception/e5)
		if(e5.name != "Is null")
			throw EXCEPTION("Is null expected : [e5.name] was thrown instead.")

	Object.sanitize_data(list("field" = testlist))

	return TRUE

/datum/unit_test/continuity/proc/test_text()
	var/randlength = rand(1, 10)
	var/randstring = random_string(randlength, global.alphabet_uppercase)
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/primitive_field/text(
			max_length = randlength + 1,
			regex = "^\[A-Z\]{[randlength]}$"
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("notfield" = randstring))
		throw EXCEPTION("No exception")
	catch(var/exception/e1)
		if(e1.name != "Missing field")
			throw EXCEPTION("Missing field expected : [e1.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = randstring, "notfield" = randstring))
		throw EXCEPTION("No exception")
	catch(var/exception/e2)
		if(e2.name != "Invalid field")
			throw EXCEPTION("Invalid field expected : [e2.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = null))
		throw EXCEPTION("No exception")
	catch(var/exception/e3)
		if(e3.name != "Is null")
			throw EXCEPTION("Is null expected : [e3.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = randstring + "FF"))
		throw EXCEPTION("No exception")
	catch(var/exception/e4)
		if(e4.name != "Text is longer than it should be")
			throw EXCEPTION("Text is longer than it should be expected : [e4.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = 1))
		throw EXCEPTION("No exception")
	catch(var/exception/e5)
		if(e5.name != "Not a text")
			throw EXCEPTION("Not a text expected : [e5.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = randstring + "$"))
		throw EXCEPTION("No exception")
	catch(var/exception/e6)
		if(e6.name != "Regex failed")
			throw EXCEPTION("Regex failed expected : [e6.name] was thrown instead.")

	Object.sanitize_data(list("field" = randstring))

	return TRUE

/datum/unit_test/continuity/proc/test_num()
	var/randnum = rand(-10, 10)
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/primitive_field/num(
			max_num = randnum,
			min_num = randnum
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("notfield" = randnum))
		throw EXCEPTION("No exception")
	catch(var/exception/e1)
		if(e1.name != "Missing field")
			throw EXCEPTION("Missing field expected : [e1.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = randnum, "notfield" = randnum))
		throw EXCEPTION("No exception")
	catch(var/exception/e2)
		if(e2.name != "Invalid field")
			throw EXCEPTION("Invalid field expected : [e2.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = null))
		throw EXCEPTION("No exception")
	catch(var/exception/e3)
		if(e3.name != "Is null")
			throw EXCEPTION("Is null expected : [e3.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = "[randnum]"))
		throw EXCEPTION("No exception")
	catch(var/exception/e4)
		if(e4.name != "Not a number")
			throw EXCEPTION("Not a number expected : [e4.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = randnum + 1))
		throw EXCEPTION("No exception")
	catch(var/exception/e5)
		if(e5.name != "Number is bigger than it should be")
			throw EXCEPTION("Number is bigger than it should be expected : [e5.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = randnum - 1))
		throw EXCEPTION("No exception")
	catch(var/exception/e6)
		if(e6.name != "Number is smaller than it should be")
			throw EXCEPTION("Number is smaller than it should be expected : [e6.name] was thrown instead.")

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
		throw EXCEPTION("No exception")
	catch(var/exception/e1)
		if(e1.name != "Missing field")
			throw EXCEPTION("Missing field expected : [e1.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = /atom/movable, "notfield" = /atom/movable))
		throw EXCEPTION("No exception")
	catch(var/exception/e2)
		if(e2.name != "Invalid field")
			throw EXCEPTION("Invalid field expected : [e2.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = null))
		throw EXCEPTION("No exception")
	catch(var/exception/e3)
		if(e3.name != "Is null")
			throw EXCEPTION("Is null expected : [e3.name] was thrown instead.")

	try
		Object.sanitize_data(list("field" = "atom/movable"))
		throw EXCEPTION("No exception")
	catch(var/exception/e4)
		if(e4.name != "Not a path")
			throw EXCEPTION("Not a path expected : [e4.name] was thrown instead.")

	Object.sanitize_data(list("field" = /atom/movable))

	return TRUE

/datum/unit_test/continuity/proc/test_inlists()
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field1" = new /datum/primitive_field/text(
			in_list = list("A", "B")
		),
		"field2" = new /datum/primitive_field/type(
			in_list = list(/atom, /atom/movable)
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("field1" = "C", "field2" = /atom))
		throw EXCEPTION("No exception")
	catch(var/exception/e1)
		if(e1.name != "Not an allowed text")
			throw EXCEPTION("Not an allowed text expected : [e1.name] was thrown instead.")

	try
		Object.sanitize_data(list("field1" = "A", "field2" = /atom/movable/abyrvalg))
		throw EXCEPTION("No exception")
	catch(var/exception/e2)
		if(e2.name != "Not an allowed type")
			throw EXCEPTION("Not an allowed type expected : [e2.name] was thrown instead.")

	Object.sanitize_data(list("field1" = "A", "field2" = /atom))

	A = new
	paramslist = list(
		"field" = new /datum/primitive_field/text(
			regex = @"^\d+$"
		)
	)

	Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	try
		Object.sanitize_data(list("field" = "text"))
		throw EXCEPTION("No exception")
	catch(var/exception/e3)
		if(e3.name != "Regex failed")
			throw EXCEPTION("Regex failed expected : [e3.name] was thrown instead.")

	Object.sanitize_data(list("field" = "123"))

	return TRUE

/atom/movable/abyrvalg
