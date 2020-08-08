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

	var/red
	var/green
	var/blue

	var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", "punk")
	switch(col)
		if("blonde")
			red = 255
			green = 255
			blue = 0
		if("black")
			red = 0
			green = 0
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 51
		if("copper")
			red = 255
			green = 153
			blue = 0
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("wheat")
			red = 255
			green = 255
			blue = 153
		if("old")
			red = rand (100, 255)
			green = red
			blue = red
		if("punk")
			red = rand (0, 255)
			green = rand (0, 255)
			blue = rand (0, 255)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

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
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	r_eyes = red
	g_eyes = green
	b_eyes = blue

/datum/preferences/proc/randomize_skin_color()
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	r_skin = red
	g_skin = green
	b_skin = blue


/datum/preferences/proc/update_preview_icon()		//seriously. This is horrendous.
	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob

	if(job_preferences["Test Subject"] == JP_LOW)
		previewJob = SSjob.GetJob("Test Subject")

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
	var/mob/living/carbon/human/dummy/mannequin = new(null, species)
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
	qdel(mannequin)
