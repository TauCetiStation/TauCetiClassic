/////////////////////////////
// Helpers for DNA2
/////////////////////////////

#define LARGE_PROB(rs, rd, block) prob(rs * 10 + rd); block
#define STANDARD_PROB(rs, block) prob(rs * 10); block
#define SMALL_PROB(rs, rd, block) prob(rs * 10 - rd); block
#define TINY_PROB(rs, rd, block) prob(rs * 5 + rd); block

// DNA Gene activation boundaries, see dna2.dm.
// Returns a list object with 4 numbers.
/proc/GetDNABounds(block)
	var/list/BOUNDS=dna_activity_bounds[block]
	if(!istype(BOUNDS))
		return DNA_DEFAULT_BOUNDS
	return BOUNDS

// Give Random Bad Mutation to M
/proc/randmutb(mob/living/M)
	if(!M) return
	M.dna.check_integrity()
	var/list/b_blocks = list(GLASSESBLOCK,COUGHBLOCK,FAKEBLOCK,NERVOUSBLOCK,CLUMSYBLOCK,TWITCHBLOCK,HEADACHEBLOCK,BLINDBLOCK,DEAFBLOCK,HALLUCINATIONBLOCK,EPILEPSYBLOCK)
	var/list/possible_blocks = list()
	for(var/block in b_blocks)
		if(!M.dna.GetSEState(block))
			possible_blocks.Add(block)
	if(!possible_blocks.len)
		return
	var/block_pick = pick(possible_blocks)
	M.dna.SetSEState(block_pick, 1)

// Give Random Good Mutation to M
/proc/randmutg(mob/living/M)
	if(!M) return
	M.dna.check_integrity()
	var/list/g_blocks = list(HULKBLOCK,XRAYBLOCK,FIREBLOCK,TELEBLOCK,NOBREATHBLOCK,REMOTEVIEWBLOCK,REGENERATEBLOCK,INCREASERUNBLOCK,REMOTETALKBLOCK,MORPHBLOCK,BLENDBLOCK,NOPRINTSBLOCK,SHOCKIMMUNITYBLOCK,SMALLSIZEBLOCK,COLDBLOCK)
	var/list/possible_blocks = list()
	for(var/block in g_blocks)
		if(!M.dna.GetSEState(block))
			possible_blocks.Add(block)
	if(!possible_blocks.len)
		return
	var/block_pick = pick(possible_blocks)
	M.dna.SetSEState(block_pick, 1)

// Random Appearance Mutation
/proc/randmuti(mob/living/M)
	if(!M) return
	M.dna.check_integrity()
	M.dna.SetUIValue(rand(1,DNA_UI_LENGTH),rand(1,4095))

// Scramble UI or SE.
/proc/scramble(UI, mob/M, prob)
	if(!M)	return
	M.dna.check_integrity()
	if(UI)
		for(var/i = 1, i <= DNA_UI_LENGTH-1, i++)
			if(prob(prob))
				M.dna.SetUIValue(i,rand(1,4095),1)
		M.dna.UpdateUI()
		M.UpdateAppearance()

	else
		for(var/i = 1, i <= DNA_SE_LENGTH-1, i++)
			if(prob(prob))
				M.dna.SetSEValue(i,rand(1,4095),1)
		M.dna.UpdateSE()
		domutcheck(M, null)

// I haven't yet figured out what the fuck this is supposed to do.
/proc/miniscramble(input, rs, rd)
	var/output = null
	switch(input)
		if("C", "D", "E", "F")
			output = pick(STANDARD_PROB(rs, "4"), STANDARD_PROB(rs, "5"), STANDARD_PROB(rs, "6"), STANDARD_PROB(rs, "7"), TINY_PROB(rs, rd, "0"), TINY_PROB(rs, rd, "1"), SMALL_PROB(rs, rd, "2"), SMALL_PROB(rs, rd, "3"))
		if ("8", "9", "A", "B")
			output = pick(STANDARD_PROB(rs, "4"), STANDARD_PROB(rs, "5"), STANDARD_PROB(rs, "A"), STANDARD_PROB(rs, "B"), TINY_PROB(rs, rd, "C"), TINY_PROB(rs, rd, "D"), STANDARD_PROB(rs, "2"), STANDARD_PROB(rs, "3"))
		if ("4", "5", "6", "7")
			output = pick(SMALL_PROB(rs, rd, "4"), SMALL_PROB(rs, rd, "5"), STANDARD_PROB(rs, "A"), STANDARD_PROB(rs, "B"), TINY_PROB(rs, rd, "C"), TINY_PROB(rs, rd, "D"), STANDARD_PROB(rs, "2"), STANDARD_PROB(rs, "3"))
		if ("0", "1", "2", "3")
			output = pick(STANDARD_PROB(rs, "8"), STANDARD_PROB(rs, "9"), STANDARD_PROB(rs, "A"), STANDARD_PROB(rs, "B"), SMALL_PROB(rs, rd, "C"), SMALL_PROB(rs, rd, "D"), TINY_PROB(rs, rd, "E"), TINY_PROB(rs, rd, "F"))
	if(!output)
		return "5"
	return output

// HELLO I MAKE BELL CURVES AROUND YOUR DESIRED TARGET
// So a shitty way of replacing gaussian noise.
// input: YOUR TARGET
// rs: RAD STRENGTH
// rd: DURATION
/proc/miniscrambletarget(input, rs, rd)
	if(!input)
		return "8"
	var/output = null
	switch(input)
		if("0")
			output = pick(TINY_PROB(rs, rd, "0"), STANDARD_PROB(rs, "1"), STANDARD_PROB(rs, "2"),  SMALL_PROB(rs, rd, "3"))
		if("1")
			output = pick(STANDARD_PROB(rs, "0"), TINY_PROB(rs, rd, "1"), STANDARD_PROB(rs, "2"), STANDARD_PROB(rs, "3"), STANDARD_PROB(rs, "4"))
		if("2")
			output = pick(STANDARD_PROB(rs, "0"), STANDARD_PROB(rs, "1"), TINY_PROB(rs, rd, "2"), STANDARD_PROB(rs, "3"), STANDARD_PROB(rs, "4"), STANDARD_PROB(rs, "5"))
		if("3")
			output = pick(STANDARD_PROB(rs, "0"), STANDARD_PROB(rs, "1"), STANDARD_PROB(rs, "2"), TINY_PROB(rs, rd, "3"), STANDARD_PROB(rs, "4"), STANDARD_PROB(rs, "5"), STANDARD_PROB(rs, "6"))
		if("4")
			output = pick(STANDARD_PROB(rs, "1"), STANDARD_PROB(rs, "2"), STANDARD_PROB(rs, "3"), TINY_PROB(rs, rd, "4"), STANDARD_PROB(rs, "5"), STANDARD_PROB(rs, "6"), STANDARD_PROB(rs, "7"))
		if("5")
			output = pick(STANDARD_PROB(rs, "2"), STANDARD_PROB(rs, "3"), STANDARD_PROB(rs, "4"), TINY_PROB(rs, rd, "5"), STANDARD_PROB(rs, "6"), STANDARD_PROB(rs, "7"), STANDARD_PROB(rs, "8"))
		if("6")
			output = pick(STANDARD_PROB(rs, "3"), STANDARD_PROB(rs, "4"), STANDARD_PROB(rs, "5"), TINY_PROB(rs, rd, "6"), STANDARD_PROB(rs, "7"), STANDARD_PROB(rs, "8"), STANDARD_PROB(rs, "9"))
		if("7")
			output = pick(STANDARD_PROB(rs, "4"), STANDARD_PROB(rs, "5"), STANDARD_PROB(rs, "6"), TINY_PROB(rs, rd, "7"), STANDARD_PROB(rs, "8"), STANDARD_PROB(rs, "9"), SMALL_PROB(rs, rd, "A"))
		if("8")
			output = pick(STANDARD_PROB(rs, "5"), STANDARD_PROB(rs, "6"), STANDARD_PROB(rs, "7"), TINY_PROB(rs, rd, "8"), STANDARD_PROB(rs, "9"), STANDARD_PROB(rs, "A"), SMALL_PROB(rs, rd, "B"))
		if("9")
			output = pick(STANDARD_PROB(rs, "6"), STANDARD_PROB(rs, "7"), STANDARD_PROB(rs, "8"), TINY_PROB(rs, rd, "9"), LARGE_PROB(rs, rd, "A"), STANDARD_PROB(rs, "B"), SMALL_PROB(rs, rd, "C"))
		if("10")//A
			output = pick(STANDARD_PROB(rs, "7"), STANDARD_PROB(rs, "8"), STANDARD_PROB(rs, "9"), SMALL_PROB(rs, rd, "A"), LARGE_PROB(rs, rd, "B"), STANDARD_PROB(rs, "C"), SMALL_PROB(rs, rd, "D"))
		if("11")//B
			output = pick(STANDARD_PROB(rs, "8"), STANDARD_PROB(rs, "9"), LARGE_PROB(rs, rd, "A"), SMALL_PROB(rs, rd, "B"), LARGE_PROB(rs, rd, "C"), STANDARD_PROB(rs, "D"), SMALL_PROB(rs, rd, "E"))
		if("12")//C
			output = pick(SMALL_PROB(rs, rd, "9"), STANDARD_PROB(rs, "A"), LARGE_PROB(rs, rd, "B"), SMALL_PROB(rs, rd, "C"), LARGE_PROB(rs, rd, "D"), STANDARD_PROB(rs, "E"), SMALL_PROB(rs, rd, "F"))
		if("13")//D
			output = pick(SMALL_PROB(rs, rd, "A"), STANDARD_PROB(rs, "B"), LARGE_PROB(rs, rd, "C"), SMALL_PROB(rs, rd, "D"), LARGE_PROB(rs, rd, "E"), STANDARD_PROB(rs, "F"))
		if("14")//E
			output = pick(SMALL_PROB(rs, rd, "B"), STANDARD_PROB(rs, "C"), LARGE_PROB(rs, rd, "D"), SMALL_PROB(rs, rd, "E"), LARGE_PROB(rs, rd, "F"))
		if("15")//F
			output = pick(SMALL_PROB(rs, rd, "C"), STANDARD_PROB(rs, "D"), LARGE_PROB(rs, rd, "E"), SMALL_PROB(rs, rd, "F"))

	if(!output)
		return "8"
	return output

// /proc/updateappearance has changed behavior, so it's been removed
// Use mob.UpdateAppearance() instead.

// Simpler. Don't specify UI in order for the mob to use its own.
/mob/proc/UpdateAppearance(list/UI=null)
	if(ishuman(src))
		if(UI!=null)
			src.dna.UI=UI
			dna.UpdateUI()
		dna.check_integrity()
		var/mob/living/carbon/human/H = src
		H.r_hair   = dna.GetUIValueRange(DNA_UI_HAIR_R,    255)
		H.g_hair   = dna.GetUIValueRange(DNA_UI_HAIR_G,    255)
		H.b_hair   = dna.GetUIValueRange(DNA_UI_HAIR_B,    255)

		H.r_facial = dna.GetUIValueRange(DNA_UI_BEARD_R,   255)
		H.g_facial = dna.GetUIValueRange(DNA_UI_BEARD_G,   255)
		H.b_facial = dna.GetUIValueRange(DNA_UI_BEARD_B,   255)

		H.r_skin   = dna.GetUIValueRange(DNA_UI_SKIN_R,    255)
		H.g_skin   = dna.GetUIValueRange(DNA_UI_SKIN_G,    255)
		H.b_skin   = dna.GetUIValueRange(DNA_UI_SKIN_B,    255)

		H.r_eyes   = dna.GetUIValueRange(DNA_UI_EYES_R,    255)
		H.g_eyes   = dna.GetUIValueRange(DNA_UI_EYES_G,    255)
		H.b_eyes   = dna.GetUIValueRange(DNA_UI_EYES_B,    255)

		H.r_belly  = dna.GetUIValueRange(DNA_UI_BELLY_R,   255)
		H.g_belly  = dna.GetUIValueRange(DNA_UI_BELLY_G,   255)
		H.b_belly  = dna.GetUIValueRange(DNA_UI_BELLY_B,   255)

		H.s_tone   = 35 - dna.GetUIValueRange(DNA_UI_SKIN_TONE, 220) // Value can be negative.

		if (dna.GetUIState(DNA_UI_GENDER))
			H.gender = FEMALE
		else
			H.gender = MALE

		//Hair
		var/hair = dna.GetUIValueRange(DNA_UI_HAIR_STYLE,hair_styles_list.len)
		if((0 < hair) && (hair <= hair_styles_list.len))
			H.h_style = hair_styles_list[hair]

		//Facial Hair
		var/beard = dna.GetUIValueRange(DNA_UI_BEARD_STYLE,facial_hair_styles_list.len)
		if((0 < beard) && (beard <= facial_hair_styles_list.len))
			H.f_style = facial_hair_styles_list[beard]

		//Height
		var/height = dna.GetUIValueRange(DNA_UI_HEIGHT, heights_list.len)
		if((0 < height) && (height <= heights_list.len))
			H.height = heights_list[height]

		H.apply_recolor()
		H.update_body()
		H.update_hair()
		H.regenerate_icons()

// Used below, simple injection modifier.
/proc/probinj(pr, inj)
	return prob(pr+inj*pr)

#undef LARGE_PROB
#undef STANDARD_PROB
#undef SMALL_PROB
#undef TINY_PROB
