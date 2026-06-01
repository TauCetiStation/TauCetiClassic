/datum/unit_test/continuity
	name = "CONTINUITY: Continuity objects should return data they saved."

	disabled = TRUE
	why_disabled = "Runtimes while checking"

	var/list/continuity_fields = list(
		"field1" = list("field_type" = "list", "entry_config" = list("field_type" = "int", "max_num" = 999, "min_num" = -999, "can_be_null" = TRUE)),
		"field2" = list("field_type" = "alist", "key_config" = list("field_type" = "string", "max_length" = 999, "allowed_characters" = list("A", "B", "C")), "entry_config" = list("field_type" = "string", "max_length" = 999, "allowed_characters" = list("1", "3", "7"))),
		"field3" = list("field_type" = "string", "max_length" = 999, "in_list" = list("абырвалг", "главрыба")),
		"field4" = list("field_type" = "int", "max_num" = 40, "min_num" = 0),
		"field5" = list("field_type" = "type", "in_list" = list(/atom, /atom/movable)),
	)

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

	var/datum/component/continuity_object/Object_list
	var/datum/component/continuity_object/Object_alist
	var/datum/component/continuity_object/Object_string
	var/datum/component/continuity_object/Object_int
	var/datum/component/continuity_object/Object_type

/datum/unit_test/continuity/proc/testproc()

/datum/unit_test/continuity/start_test()
	var/atom/movable/A = new
	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", continuity_fields)

	var/list/check_entries = Object.sanitize_data(good_entries)
	var/list/check_entries2 = Object.sanitize_data(bad_entries)

	if(!(check_entries ~= good_entries))
		fail("Continuity: initial and saved entries doesn't match!")

	if(check_entries2 != "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		fail("Continuity: doesn't throw an error when should!")

	if(!test_list())
		fail("Continuity: List test failed!")

	if(!test_alist())
		fail("Continuity: Alist test failed!")

	if(!test_string())
		fail("Continuity: String test failed!")

	if(!test_int())
		fail("Continuity: Int test failed!")

	if(!test_type())
		fail("Continuity: Type test failed!")

	if(!test_inlists())
		fail("Coninuity: Inlist test failed!")

	pass("Continuity works just fine.")

	return TRUE

/datum/unit_test/continuity/proc/test_list()
	var/list/testlist = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	var/atom/movable/A = new
	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", list("field" = list("field_type" = "list", "entry_config" = list("field_type" = "int"))))

	if(!Object.sanitize_data(list("notfield" = testlist)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = testlist + "FF")) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = null)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	return TRUE

/datum/unit_test/continuity/proc/test_alist()
	var/list/testlist = list("A" = 1, "B" = 2, "C" = 3, "D" = 4, "E" = 5, "F" = 6, "G" = 7, "H" = 8, "I" = 9, "J" = 10)
	var/atom/movable/A = new
	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", list("field" = list("field_type" = "alist", "key_config" = list("field_type" = "string"), "entry_config" = list("field_type" = "int"))))

	if(!Object.sanitize_data(list("notfield" = testlist)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = testlist + list(/atom = 15))) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = testlist + list("/atom" = "15"))) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = null)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	return TRUE

/datum/unit_test/continuity/proc/test_string()
	var/randlength = rand(1, 10)
	var/randstring = random_string(randlength, global.alphabet_uppercase)
	var/atom/movable/A = new
	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", list("field" = list("field_type" = "string", "max_length" = randlength + 1, allowed_characters = global.alphabet_uppercase)))

	if(!Object.sanitize_data(list("notfield" = randstring)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = randstring + "FF")) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = 1)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = randstring + "$")) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = null)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	return TRUE

/datum/unit_test/continuity/proc/test_int()
	var/randnum = rand(-10, 10)
	var/atom/movable/A = new
	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", list("field" = list("field_type" = "int", "max_num" = randnum, "min_num" = randnum)))

	if(!Object.sanitize_data(list("notfield" = randnum)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = "[randnum]")) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = randnum + 1)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = randnum - 1)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = null)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	return TRUE

/datum/unit_test/continuity/proc/test_type()
	var/atom/movable/A = new
	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", list("field" = list("field_type" = "type")))

	if(!Object.sanitize_data(list("notfield" = /atom/movable)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = "/atom/movable")) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field" = null)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	return TRUE

/datum/unit_test/continuity/proc/test_inlists()
	var/atom/movable/A = new
	var/datum/component/continuity_object/Object = A.AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(testproc)), CALLBACK(src, PROC_REF(testproc)), "atom", list("field1" = list("field_type" = "string", "in_list" = list("A", "B")), "field2" = list("field_type" = "type", "in_list" = list(/atom, /atom/movable))))

	if(!Object.sanitize_data(list("field1" = "C", "field2" = /atom)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	if(!Object.sanitize_data(list("field1" = "A", "field2" = /atom/movable/abyrvalg)) == "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT")
		return FALSE

	return TRUE

/atom/movable/abyrvalg
