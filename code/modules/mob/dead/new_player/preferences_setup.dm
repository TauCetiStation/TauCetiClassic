//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/randomize_appearance_for(mob/living/carbon/human/H)
	if(H)
		if(H.gender == MALE)
			gender = MALE
		else
			gender = FEMALE
	s_tone = random_skin_tone()
	h_style = random_hair_style(gender, species, ipc_head)
	grad_style = random_gradient_style()
	f_style = random_facial_hair_style(gender, species)
	randomize_hair_color("hair")
	randomize_hair_color("facial")
	randomize_hair_color("gradient")
	randomize_eyes_color()
	randomize_skin_color()
	underwear = rand(1,underwear_m.len)
	undershirt = rand(1,undershirt_t.len)
	socks = rand(1,socks_t.len)
	backbag = 2
	use_skirt = pick(TRUE, FALSE)
	var/datum/species/S = all_species[species]
	age = rand(S.min_age, S.max_age)
	if(H)
		copy_to(H)


/datum/preferences/proc/randomize_hair_color(target = "hair")
	if(prob (75) && target == "facial") // Chance to inherit hair color
		r_facial = r_hair
		g_facial = g_hair
		b_facial = b_hair
		return

	var/list/colors_rgb = random_hair_color()

	var/red = colors_rgb[1]
	var/green = colors_rgb[2]
	var/blue = colors_rgb[3]

	switch(target)
		if("hair")
			r_hair = red
			g_hair = green
			b_hair = blue
		if("facial")
			r_facial = red
			g_facial = green
			b_facial = blue
		if("gradient")
			r_grad = red
			g_grad = green
			b_grad = blue

/datum/preferences/proc/randomize_eyes_color()
	var/list/colors_rgb = random_eye_color()

	r_eyes = colors_rgb[1]
	g_eyes = colors_rgb[2]
	b_eyes = colors_rgb[3]

/datum/preferences/proc/randomize_skin_color()
	var/list/colors_rgb = random_skin_color()

	r_skin = colors_rgb[1]
	g_skin = colors_rgb[2]
	b_skin = colors_rgb[3]

/datum/preferences/proc/update_preview_icon()		//seriously. This is horrendous.
	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob

	if(job_preferences["Assistant"] == JP_LOW)
		previewJob = SSjob.GetJob("Assistant")

	if(!previewJob)
		var/highest_pref = 0
		for(var/job in job_preferences)
			if(job_preferences[job] > highest_pref)
				previewJob = SSjob.GetJob(job)
				highest_pref = job_preferences[job]

	if(previewJob)
		if(istype(previewJob, /datum/job/ai))
			parent.show_character_previews(image('icons/mob/AI.dmi', "ai", dir = SOUTH))
			return
		if(istype(previewJob, /datum/job/cyborg))
			parent.show_character_previews(image('icons/mob/robots.dmi', "robot", dir = SOUTH))
			return

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES, species)
	copy_to(mannequin)

	var/datum/species/S = all_species[species]
	if(S)
		S.before_job_equip(mannequin, previewJob, TRUE)
	if(previewJob)
		mannequin.job = previewJob.title
		previewJob.equip(mannequin, TRUE, GetPlayerAltTitle(previewJob))
	if(S)
		S.after_job_equip(mannequin, previewJob, TRUE)

	COMPILE_OVERLAYS(mannequin)
	parent.show_character_previews(new /mutable_appearance(mannequin))
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
