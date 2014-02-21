/obj/machinery/light/small/emergency
	var/RLumin = 1
	var/GLumin = 1
	var/BLumin = 1
	icon = 'tauceti/items/coloredLight/syreney.dmi'
	icon_state = "off"

/obj/machinery/light/small/emergency/red
	RLumin = 1
	GLumin = 0
	BLumin = 0

/obj/machinery/light/small/emergency/green
	RLumin = 0
	GLumin = 1
	BLumin = 0

/obj/machinery/light/small/emergency/blue
	RLumin = 0
	GLumin = 0
	BLumin = 1

/obj/machinery/light/small/emergency/yellow
	RLumin = 1
	GLumin = 1
	BLumin = 0

/obj/machinery/light/small/emergency/viol
	RLumin = 1
	GLumin = 0
	BLumin = 1

/obj/machinery/light/small/emergency/irid
	RLumin = 0
	GLumin = 1
	BLumin = 1

//obj/machinery/light/small/emergency/New()
	//on = 1
	//SetLuminosity(brightness)
	//SetUniqueLuminosity(RLumin*brightness,GLumin*brightness,BLumin*brightness)
	//process
/obj/machinery/light/small/emergency/update(var/trigger = 1)
	update_icon()
	if(on)
		icon_state = "on"
		if(luminosity != brightness)
			switchcount++
			if(rigged)
				if(status == 0 && trigger)

					log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
					message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast]")

					explode()
			else if( prob( min(60, switchcount*switchcount*0.01) ) )
				if(status == 0 && trigger)
					status = 4
					icon_state = "off"
					on = 0
					SetLuminosity(0)
					SetUniqueLuminosity(0,0,0)
			else
				use_power = 2
				SetLuminosity(brightness)
				SetUniqueLuminosity(RLumin*brightness,GLumin*brightness,BLumin*brightness)
	else
		icon_state = "off"
		use_power = 1
		SetLuminosity(0)
		SetUniqueLuminosity(0,0,0)
	active_power_usage = (luminosity * 10)
	if(on != on_gs)
		on_gs = on
