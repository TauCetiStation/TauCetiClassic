/mob/living/carbon/human

	proc/handle_heart_beat()

		if(pulse == PULSE_NONE) return

		if(pulse == PULSE_2FAST || shock_stage >= 10 || istype(get_turf(src), /turf/space))

			var/temp = (5 - pulse)/2

			if(heart_beat >= temp)
				heart_beat = 0
				src << sound('tauceti/sounds/effects/singlebeat.ogg',0,0,0,50)
			else if(temp != 0)
				heart_beat++

/*
		else if(istype(get_turf(src), /turf/space))
			var/protected = 0
			if( (head && istype(head, /obj/item/clothing/head/helmet/space)) && (wear_suit && istype(wear_suit, /obj/item/clothing/suit/space)) )
				protected = 1
*/