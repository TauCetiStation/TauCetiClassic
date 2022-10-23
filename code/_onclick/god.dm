/mob/living/simple_animal/shade/god/RegularClickOn(atom/A)
	if(..())
		return TRUE
	god_attack(A)
	SetNextMove(CLICK_CD_RAPID)
	return TRUE
