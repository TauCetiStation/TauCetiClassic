/obj/effect/effect/jet_trails
	name = "jet trails"
	icon = 'tauceti/modules/_spacecraft/spacecraft.dmi'
	icon_state = "jet_trails"
	anchored = 1.0

/datum/effect/effect/system/jet_trail_follow
	var/turf/oldposition
	var/processing = 1
	var/on = 1

	set_up(atom/atom)
		attach(atom)
		oldposition = get_turf(atom)

	start()
		if(!src.on)
			src.on = 1
			src.processing = 1
		if(src.processing)
			src.processing = 0
			spawn(0)
				var/turf/T = get_turf(src.holder)
				if(T != src.oldposition)
					if(istype(T, /turf/space))
						var/obj/effect/effect/jet_trails/I = new /obj/effect/effect/jet_trails(src.oldposition)
						src.oldposition = T
						I.dir = src.holder.dir
						flick("jet_fade", I)
						I.icon_state = "blank"
						spawn( 20 )
							I.delete()
					spawn(2)
						if(src.on)
							src.processing = 1
							src.start()
				else
					spawn(2)
						if(src.on)
							src.processing = 1
							src.start()

	proc/stop()
		src.processing = 0
		src.on = 0