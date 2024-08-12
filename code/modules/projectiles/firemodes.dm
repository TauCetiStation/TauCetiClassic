/datum/firemode
	var/name = "default"
	var/list/settings = list()
	var/obj/item/weapon/gun/gun = null

/datum/firemode/New(obj/item/weapon/gun/_gun, list/properties = null)
	..()
	if(!properties) return

	gun = _gun
	for(var/propname in properties)
		var/propvalue = properties[propname]

		if(propname == "mode_name")
			name = propvalue
		else if(isnull(propvalue))
			settings[propname] = gun.vars[propname] //better than initial() as it handles list vars like dispersion
		else
			settings[propname] = propvalue

/datum/firemode/proc/apply_to(obj/item/weapon/gun/_gun)
	gun = _gun
	for(var/propname in settings)
		if (propname in gun.vars)
			gun.vars[propname] = settings[propname]

//Called whenever the firemode is switched to, or the gun is picked up while its active
/datum/firemode/proc/update()
	return

//Automatic firing
//Todo: Way more checks and safety here
/datum/firemode/automatic
	settings = list(burst = 1, suppress_delay_warning = TRUE)
	//The full auto clickhandler we have
	var/datum/click_handler/fullauto/CH = null

/datum/firemode/automatic/update(var/force_state = null)
	var/mob/living/L = gun.owner
	if(gun && gun.owner)
		L = gun.loc
	var/enable = FALSE
	//Force state is used for forcing it to be disabled in circumstances where it'd normally be valid
	if (!isnull(force_state))
		enable = force_state
	else if (L)
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
		if (!CH)
			//If we're turning it off, but the click handler doesn't exist, then we have nothing to do
			return

		//Todo: make client click handlers into a list
		if (CH.owner) //Remove our handler from the client
			CH.owner.CH = null //wew
		QDEL_NULL(CH) //And delete it
		return

	else
		//We're trying to turn things on
		if (CH)
			return //The click handler exists, we dont need to do anything


		//Create and assign the click handler
		//A click handler intercepts mouseup/drag/down events which allow fullauto firing
		CH = new /datum/click_handler/fullauto()
		CH.reciever = gun //Reciever is the gun that gets the fire events
		L.client.CH = CH //Put it on the client
		CH.owner = L.client //And tell it where it is

