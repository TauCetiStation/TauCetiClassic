#define CREW_SIZE_MIN 4
#define CREW_SIZE_MAX 8

var/global/deaths_during_shift = 0

// This is not at all like on /tg/.
// "Family" and "gang" used interchangeably in code.
/datum/faction/gang
	/// The number of points this family has gained. Used for determining a victor if multiple families complete their objectives.
	var/points = 0
	/// A counter used to minimize the overhead of computationally intensive, periodic family point gain checks. Used and set internally.
	var/check_counter = 0

/datum/faction/gang/process()
	check_counter++
	if(check_counter >= 5)
		check_counter = 0

		check_tagged_turfs()
		check_gang_clothes()
		check_rollin_with_crews()
	..()

/// Internal. Assigns points to families according to gang tags.
/datum/faction/gang/proc/check_tagged_turfs()
	adjust_points(5 * gang_tags.len)

/// Internal. Assigns points to families according to clothing of all currently living humans.
/datum/faction/gang/proc/check_gang_clothes() // TODO: make this grab the sprite itself, average out what the primary color would be, then compare how close it is to the gang color so I don't have to manually fill shit out for 5 years for every gang type
	for(var/role in members)
		var/datum/role/gangster/G = role
		if(!G.antag.current || !G.antag.current.client || !ishuman(G.antag.current))
			continue
		var/mob/living/carbon/human/H = G.antag.current
		for(var/clothing in H.get_all_slots())
			if(is_type_in_list(clothing, acceptable_clothes))
				adjust_points(1)

		CHECK_TICK

/// Internal. Assigns points to families according to groups of nearby family members.
/datum/faction/gang/proc/check_rollin_with_crews()
	var/list/areas_to_check = list()
	for(var/GG in members)
		var/datum/role/gangster/G = GG
		if(!G.antag.current || !G.antag.current.client)
			continue
		areas_to_check += get_area(G.antag.current)
	for(var/AA in areas_to_check)
		var/area/A = AA
		var/members_in_area = 0
		for(var/mob/living/carbon/human/H in A)
			if(H.stat != CONSCIOUS || !H.mind || !H.client)
				continue
			var/datum/role/gangster/is_gangster = isanygangster(H)
			if(is_gangster in members)
				members_in_area++
			CHECK_TICK
		if(!members_in_area)
			continue

		if(members_in_area >= CREW_SIZE_MIN)
			if(members_in_area >= CREW_SIZE_MAX)
				adjust_points(0.5) // Discourage larger clumps, spread ur people out
			else
				adjust_points(1)
