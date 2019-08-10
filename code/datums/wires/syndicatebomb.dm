var/const/SYNDIEBOMB_WIRE_BOOM     = 1    // Explodes if pulsed or cut while active, defuses a bomb that isn't active on cut
var/const/SYNDIEBOMB_WIRE_UNBOLT   = 2    // Unbolts the bomb if cut, hint on pulsed
var/const/SYNDIEBOMB_WIRE_DELAY    = 4    // Raises the timer on pulse, does nothing on cut
var/const/SYNDIEBOMB_WIRE_PROCEED  = 8    // Lowers the timer, explodes if cut while the bomb is active
var/const/SYNDIEBOMB_WIRE_ACTIVATE = 16   // Will start a bombs timer if pulsed, will hint if pulsed while already active, will stop a timer a bomb on cut

/datum/wires/syndicatebomb
	random = TRUE
	holder_type = /obj/machinery/syndicatebomb
	wire_count = 5

/datum/wires/syndicatebomb/can_use()
	var/obj/machinery/syndicatebomb/S = holder
	return !S.degutted

/datum/wires/syndicatebomb/additional_checks_and_effects(mob/living/user)
	return isdrone(user)

/datum/wires/syndicatebomb/update_cut(index, mended)
	var/obj/machinery/syndicatebomb/S = holder

	switch(index)
		if(SYNDIEBOMB_WIRE_BOOM)
			if(!mended)
				if(S.active)
					S.loc.visible_message("<span class='warning'>[bicon(holder)] An alarm sounds! It's go-</span>")
					S.timer = 0
				else
					S.defused = TRUE
			if(mended)
				S.defused = FALSE //cutting and mending all the wires of an inactive bomb will thus cure any sabotage

		if(SYNDIEBOMB_WIRE_UNBOLT)
			if (!mended && S.anchored)
				playsound(S, 'sound/effects/stealthoff.ogg', VOL_EFFECTS_MASTER, 30)
				S.loc.visible_message("<span class='notice'>[bicon(holder)] The bolts lift out of the ground!</span>")
				S.anchored = FALSE

		if(SYNDIEBOMB_WIRE_PROCEED)
			if(!mended && S.active)
				S.loc.visible_message("<span class='warning'>[bicon(holder)] An alarm sounds! It's go-</span>")
				S.timer = 0

		if(SYNDIEBOMB_WIRE_ACTIVATE)
			if (!mended && S.active)
				S.loc.visible_message("<span class='notice'>[bicon(holder)] The timer stops! The bomb has been defused!</span>")
				S.icon_state = "syndicate-bomb-inactive-wires" //no cutting possible with the panel closed
				S.active = FALSE
				S.defused = TRUE

/datum/wires/syndicatebomb/update_pulsed(index)
	var/obj/machinery/syndicatebomb/S = holder

	switch(index)
		if(SYNDIEBOMB_WIRE_BOOM)
			if (S.active)
				S.loc.visible_message("<span class='warning'>[bicon(holder)] An alarm sounds! It's go-</span>")
				S.timer = 0

		if(SYNDIEBOMB_WIRE_UNBOLT)
			S.loc.visible_message("<span class='notice'>[bicon(holder)] The bolts spin in place for a moment.</span>")

		if(SYNDIEBOMB_WIRE_DELAY)
			playsound(S.loc, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER, 30)
			S.loc.visible_message("<span class='notice'>[bicon(holder)] The bomb chirps.</span>")
			S.timer += 10

		if(SYNDIEBOMB_WIRE_PROCEED)
			playsound(S.loc, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER, 30)
			S.loc.visible_message("<span class='warning'>[bicon(holder)] The bomb buzzes ominously!</span>")

			if (S.timer >= 61) //Long fuse bombs can suddenly become more dangerous if you tinker with them
				S.timer = 60
			if (S.timer >= 21)
				S.timer -= 10
			else if (S.timer >= 11) //both to prevent negative timers and to have a little mercy
				S.timer = 10

		if(SYNDIEBOMB_WIRE_ACTIVATE)
			if(!S.active && !S.defused)
				playsound(S.loc, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 30)
				S.loc.visible_message("<span class='warning'>[bicon(holder)] You hear the bomb start ticking!</span>")
				S.active = TRUE

				if(!S.open_panel) //Needs to exist in case the wire is pulsed with a signaler while the panel is closed
					S.icon_state = "syndicate-bomb-active"
				else
					S.icon_state = "syndicate-bomb-active-wires"

				START_PROCESSING(SSobj, S)
			else
				S.loc.visible_message("<span class='notice'>[bicon(holder)] The bomb seems to hesitate for a moment.</span>")
				S.timer += 5
