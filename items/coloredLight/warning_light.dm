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



/obj/item/device/flashlight/colored
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	w_class = 2
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	m_amt = 50
	g_amt = 20
	icon_action_button = "action_flashlight"
	on = 0
	brightness_on = 4
	var/RLumin = 1
	var/GLumin = 1
	var/BLumin = 0

/obj/item/device/flashlight/colored/initialize()
	..()
	if(on)
		icon_state = "[initial(icon_state)]-on"
		SetLuminosity(brightness_on)
		SetUniqueLuminosity(RLumin*brightness_on,GLumin*brightness_on,BLumin*brightness_on)
	else
		icon_state = initial(icon_state)
		SetLuminosity(0)

/obj/item/device/flashlight/colored/update_brightness(var/mob/user = null)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		if(loc == user)
			//user.SetLuminosity(user.luminosity + brightness_on)
			user.AddLuminosityRGB(RLumin*brightness_on,GLumin*brightness_on,BLumin*brightness_on)
		else if(isturf(loc))
			//SetLuminosity(brightness_on)
			SetUniqueLuminosity(RLumin*brightness_on,GLumin*brightness_on,BLumin*brightness_on)
	else
		icon_state = initial(icon_state)
		if(loc == user)
			//user.SetLuminosity(user.luminosity - brightness_on)
			user.RemLuminosityRGB(RLumin*brightness_on,GLumin*brightness_on,BLumin*brightness_on)
		else if(isturf(loc))
			SetUniqueLuminosity(0,0,0)

/obj/item/device/flashlight/colored/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "You cannot turn the light on while in this [user.loc]." //To prevent some lighting anomalities.
		return 0
	on = !on
	update_brightness(user)
	return 1

/obj/item/device/flashlight/colored/pickup(mob/user)
	if(on)
		//user.SetLuminosity(user.luminosity + brightness_on)
		user.AddLuminosityRGB(RLumin*brightness_on,GLumin*brightness_on,BLumin*brightness_on)
		SetLuminosity(0)
		SetUniqueLuminosity(0,0,0);


/obj/item/device/flashlight/colored/dropped(mob/user)
	if(on)
		user.RemLuminosityRGB(RLumin*brightness_on,GLumin*brightness_on,BLumin*brightness_on)
		SetUniqueLuminosity(RLumin*brightness_on,GLumin*brightness_on,BLumin*brightness_on)
