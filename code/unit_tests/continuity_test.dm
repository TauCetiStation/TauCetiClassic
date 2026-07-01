#define RUNTIME_SENTINEL "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT"
#define RUNTIMED(proc_output) proc_output == RUNTIME_SENTINEL


/datum/unit_test/continuity
	name = "CONTINUITY: Continuity objects should return data they saved and throw an erorr when they should."

	disabled = TRUE
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
		"field1" = new /datum/continuity_field/listfield(
			entry_config = new /datum/continuity_field/int(
				max_num = 999,
				min_num = -999,
				can_be_null = TRUE
			)
		),
		"field2" = new /datum/continuity_field/alistfield(
			key_config = new /datum/continuity_field/string(
				max_length = 999,
				allowed_characters = list("A", "B", "C")
			),
			entry_config = new /datum/continuity_field/string(
				max_length = 999,
				allowed_characters = list("1", "3", "7")
			)
		),
		"field3" = new /datum/continuity_field/string(
			max_length = 999,
			in_list = list("абырвалг", "главрыба")
		),
		"field4" = new /datum/continuity_field/int(
			max_num = 40,
			min_num = 0
		),
		"field5" = new /datum/continuity_field/type(
			in_list = list(/atom, /atom/movable)
		),
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", continuity_fields)

	var/list/check_entries = Object.sanitize_data(good_entries)
	var/list/check_entries2 = Object.sanitize_data(bad_entries)

	if(!(check_entries ~= good_entries))
		fail("Continuity: initial and saved entries doesn't match!")
		return TRUE

	if(!RUNTIMED(check_entries2))
		fail("Continuity: doesn't throw an error when should!")
		return TRUE

	if(!test_list())
		fail("Continuity: List test failed!")
		return TRUE

	if(!test_alist())
		fail("Continuity: Alist test failed!")
		return TRUE

	if(!test_string())
		fail("Continuity: String test failed!")
		return TRUE

	if(!test_int())
		fail("Continuity: Int test failed!")
		return TRUE

	if(!test_type())
		fail("Continuity: Type test failed!")
		return TRUE

	if(!test_inlists())
		fail("Coninuity: Inlist test failed!")
		return TRUE

	pass("Continuity works just fine.")

	return TRUE

/datum/unit_test/continuity/proc/test_list()
	var/list/testlist = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/continuity_field/listfield(
			entry_config = new /datum/continuity_field/int
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	if(!RUNTIMED(Object.sanitize_data(list("notfield" = testlist))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = testlist + "FF"))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = null))))
		return FALSE

	return TRUE

/datum/unit_test/continuity/proc/test_alist()
	var/list/testlist = list("A" = 1, "B" = 2, "C" = 3, "D" = 4, "E" = 5, "F" = 6, "G" = 7, "H" = 8, "I" = 9, "J" = 10)
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/continuity_field/alistfield(
			key_config = new /datum/continuity_field/string(max_length = 10),
			entry_config = new /datum/continuity_field/int
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	if(!RUNTIMED(Object.sanitize_data(list("notfield" = testlist))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = testlist + list(/atom = 15)))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = testlist + list("/atom" = "15")))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = null))))
		return FALSE

	return TRUE

/datum/unit_test/continuity/proc/test_string()
	var/randlength = rand(1, 10)
	var/randstring = random_string(randlength, global.alphabet_uppercase)
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/continuity_field/string(
			max_length = randlength + 1,
			allowed_characters = global.alphabet_uppercase
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	if(!RUNTIMED(Object.sanitize_data(list("notfield" = randstring))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = randstring + "FF"))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = 1))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = randstring + "$"))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = null))))
		return FALSE

	return TRUE

/datum/unit_test/continuity/proc/test_int()
	var/randnum = rand(-10, 10)
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/continuity_field/int(
			max_num = randnum,
			min_num = randnum
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	if(!RUNTIMED(Object.sanitize_data(list("notfield" = randnum))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = "[randnum]"))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = randnum + 1))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = randnum - 1))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = null))))
		return FALSE

	return TRUE

/datum/unit_test/continuity/proc/test_type()
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field" = new /datum/continuity_field/type
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	if(!RUNTIMED(Object.sanitize_data(list("notfield" = /atom/movable))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = "atom/movable"))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field" = null))))
		return FALSE

	return TRUE

/datum/unit_test/continuity/proc/test_inlists()
	var/atom/movable/A = new
	var/list/paramslist = list(
		"field1" = new /datum/continuity_field/string(
			in_list = list("A", "B")
		),
		"field2" = new /datum/continuity_field/type(
			in_list = list(/atom, /atom/movable)
		)
	)

	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	if(!RUNTIMED(Object.sanitize_data(list("field1" = "C", "field2" = /atom))))
		return FALSE

	if(!RUNTIMED(Object.sanitize_data(list("field1" = "A", "field2" = /atom/movable/abyrvalg))))
		return FALSE

	A = new
	paramslist = list(
		"field" = new /datum/continuity_field/string(
			regex = @"^\d+$"
		)
	)

	Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", paramslist)

	if(!RUNTIMED(Object.sanitize_data(list("field" = "text"))))
		return FALSE

	return TRUE

/atom/movable/abyrvalg

#undef RUNTIMED
#undef RUNTIME_SENTINEL
