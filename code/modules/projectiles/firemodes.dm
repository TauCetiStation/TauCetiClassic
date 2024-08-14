/datum/firemode
	var/name = "default"
	var/datum/firemode_settings/settings
	var/obj/item/weapon/gun/gun = null

/datum/firemode/New(obj/item/weapon/gun/_gun, list/properties = null)
	..()
	if(!properties) return

	gun = _gun
	for(var/propname in properties)
		var/propvalue = properties[propname]

		if(propname == "mode_name")
			name = propvalue

/datum/firemode_settings
	var/fire_delay
	var/firemode_name
	var/burst
	var/burst_delay
	var/spread

/datum/firemode/proc/apply_to(obj/item/weapon/gun/G)
	gun = G
	//if(settings.fire_delay)
	G.fire_delay = settings.fire_delay
	if(settings.firemode_name)
		G.firemode_name = settings.firemode_name
	if(settings.burst)
		G.burst = settings.burst
	if(settings.burst_delay)
		G.burst_delay = settings.burst_delay
	if(settings.spread)
		G.spread = settings.spread

//Called whenever the firemode is switched to, or the gun is picked up while its active
/datum/firemode/proc/update()
	return

//Automatic firing
/datum/firemode/automatic
	settings = /datum/firemode_settings/automatic
	var/datum/click_handler/fullauto/fullauto_click_handler = null

/datum/firemode_settings/automatic
	firemode_name = "Автоматический"
	burst = 1
	burst_delay = 0
	spread = 0.5

/datum/firemode/automatic/update(force_state = null)
	var/mob/living/L = gun.owner
	if(gun && gun.owner)
		L = gun.loc
	var/enable = FALSE
	//Force state is used for forcing it to be disabled in circumstances where it'd normally be valid
	if (!isnull(force_state))
		enable = force_state
	else if (L && L.client)
		//First of all, lets determine whether we're enabling or disabling the click handler


		//We enable it if the gun is held in the user's active hand
		if (L.get_active_hand() == gun)
			//Lets also make sure it can fire
			var/can_fire = TRUE

			//Projectile weapons need to have enough ammo to fire
			if(istype(gun, /obj/item/weapon/gun/projectile))
				var/obj/item/weapon/gun/projectile/P = gun
				if (!P.get_ammo())
					can_fire = FALSE

			//TODO: Centralise all this into some can_fire proc
			if (can_fire)
				enable = TRUE
		else
			enable = FALSE

	//Ok now lets set the desired state
	if (!enable)
		if (!fullauto_click_handler)
			//If we're turning it off, but the click handler doesn't exist, then we have nothing to do
			return

		//Todo: make client click handlers into a list
		if (fullauto_click_handler.owner) //Remove our handler from the client
			fullauto_click_handler.owner.client_click_handler = null //wew
		QDEL_NULL(fullauto_click_handler) //And delete it
		return

	else
		//We're trying to turn things on
		if (fullauto_click_handler)
			return //The click handler exists, we dont need to do anything


		//Create and assign the click handler
		//A click handler intercepts mouseup/drag/down events which allow fullauto firing
		fullauto_click_handler = new /datum/click_handler/fullauto()
		fullauto_click_handler.reciever = gun //Reciever is the gun that gets the fire events
		L.client.client_click_handler = fullauto_click_handler //Put it on the client
		fullauto_click_handler.owner = L.client //And tell it where it is

