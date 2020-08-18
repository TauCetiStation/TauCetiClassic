/obj/machinery/wish_granter
	name = "Wish Granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	use_power = NO_POWER_USE
	anchored = 1
	density = 1

	var/charges = 1
	var/insisting = 0

/obj/machinery/wish_granter/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	user.SetNextMove(CLICK_CD_MELEE)
	if(charges <= 0)
		to_chat(user, "The Wish Granter lies silent.")
		return 1

	else if(!ishuman(user))
		to_chat(user, "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's.")
		return 1

	else if(is_special_character(user))
		to_chat(user, "Even to a heart as dark as yours, you know nothing good will come of this.  Something instinctual makes you pull away.")
		return 1

	else if (!insisting)
		to_chat(user, "Your first touch makes the Wish Granter stir, listening to you.  Are you really sure you want to do this?")
		insisting++

	else
		to_chat(user, "You speak.  [pick("I want the station to disappear","Humanity is corrupt, mankind must be destroyed","I want to be rich", "I want to rule the world","I want immortality.")].  The Wish Granter answers.")
		to_chat(user, "Your head pounds for a moment, before your vision clears.  You are the avatar of the Wish Granter, and your power is LIMITLESS!  And it's all yours.  You need to make sure no one can take it from you.  No one can know, first.")

		charges--
		insisting = 0

		if (!(HULK in user.mutations))
			user.mutations.Add(HULK)

		if (!(LASEREYES in user.mutations))
			user.mutations.Add(LASEREYES)

		if (!(XRAY in user.mutations))
			user.mutations.Add(XRAY)
			user.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
			user.see_in_dark = 8
			user.see_invisible = SEE_INVISIBLE_LEVEL_TWO

		if (!(COLD_RESISTANCE in user.mutations))
			user.mutations.Add(COLD_RESISTANCE)

		if (!(TK in user.mutations))
			user.mutations.Add(TK)

		user.update_mutations()

		SSticker.mode.traitors += user.mind
		user.mind.special_role = "Avatar of the Wish Granter"

		var/datum/objective/silence/silence = new
		silence.owner = user.mind
		user.mind.objectives += silence

		var/obj_count = 1
		for(var/datum/objective/OBJ in user.mind.objectives)
			to_chat(user, "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]")
			obj_count++

		to_chat(user, "You have a very bad feeling about this.")
