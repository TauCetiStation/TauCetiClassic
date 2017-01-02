//TODO: разложить все по полочкам
/obj/structure/sign/directions/velocity
	name = "Direction sign"
	icon = 'code/modules/locations/centcomm/tablo.dmi'
	icon_state = "tablo01"

/obj/structure/sign/directions/dock_tablo
	name = "LED Display"
	icon = 'code/modules/locations/centcomm/tablo.dmi'
	icon_state = "dock1"

/obj/structure/sign/directions/dock_tablo/tablo2
	icon_state = "dock2"

/obj/structure/sign/directions/dock_tablo/tablo3
	icon_state = "dock3"

/obj/structure/sign/directions/dock_tablo/tablo4
	icon_state = "dock4"

/obj/structure/sign/directions/dock_tablo/tablo5
	icon_state = "dock5"

/obj/structure/sign/directions/dock_tablo/arrival
	icon_state = "arrival"

/obj/structure/sign/velocity_tablo
	name = "Velocity LED Display"
	desc = "A display, sometimes shows you useful information."
	icon = 'code/modules/locations/centcomm/monitor_90.dmi'

/*/obj/structure/sign/tablo/display
	icon = 'code/modules/locations/centcomm/monitor.dmi'

/obj/structure/sign/tablo/display/display_90
	icon = 'code/modules/locations/centcomm/monitor_90.dmi'*/

//надеюсь в скором времени переписать
/obj/machinery/information_display
	anchored = 1
	density = 0
	use_power = 1
	idle_power_usage = 25
	var/mode = 1//1 - on
				//2 - off
	name = "Information display"

	icon = 'code/modules/locations/centcomm/monitor_90.dmi'
	var/icon_state_on

	New()
		icon_state_on = icon_state
		..()

	process()
		if(stat & (NOPOWER|BROKEN))
			switch_display(2)
			return

	emp_act(severity)
		if(stat & (BROKEN|NOPOWER))
			return
		switch_display(2)
		..(severity)

	verb/switch_verb()
		set src in oview(1)
		set name = "Switch monitor"
		set category = "Object"

		if (usr.stat != CONSCIOUS || !ishuman(usr))
			return

		add_fingerprint(usr)
		switch_display()

	proc/switch_display(new_mode = 0)
		switch(new_mode)
			if(1)//on
				if(stat & (NOPOWER|BROKEN))		return
				use_power = 1
				icon_state = icon_state_on
				mode = new_mode

			if(2)//off
				use_power = 0
				icon_state = "monitor_off"
				mode = new_mode

			else
				if(mode == 1)
					switch_display(2)
				else if(mode == 2)
					switch_display(1)
