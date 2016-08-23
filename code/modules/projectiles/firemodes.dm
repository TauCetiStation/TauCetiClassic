/datum/firemode
	var/burst_fire = 0
	var/burst_this_many = 1
	var/burst_delay = 2

/datum/firemode/proc/switch_firemode()
	return

/datum/firemode/standard/switch_firemode(mob/user)
	burst_fire = !(burst_fire)
	burst_this_many = 3
	playsound(user, 'sound/weapons/guns/generic_switch.ogg', 100, 1)
	user << "<span class='notice'>You switch firemode to [burst_fire ? "[burst_this_many]-rnd burst" : "semi-automatic"].</span>"
	user.next_click = world.time + 3
