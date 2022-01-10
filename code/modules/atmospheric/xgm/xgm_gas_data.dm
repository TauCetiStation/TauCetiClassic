/var/datum/xgm_gas_data/gas_data = generateGasData()

/datum/xgm_gas_data
	//Simple list of all the gas IDs.
	var/list/gases = list()
	//The friendly, human-readable name for the gas.
	var/list/name = list()
	//Specific heat of the gas.  Used for calculating heat capacity.
	var/list/specific_heat = list()
	//Molar mass of the gas.  Used for calculating specific entropy.
	var/list/molar_mass = list()
	//Tile overlays.  /images, created from references to 'icons/effects/tile_effects.dmi'
	var/list/tile_overlay = list()
	//Overlay limits.  There must be at least this many moles for the overlay to appear.
	var/list/overlay_limit = list()
	//Temperature ranges. Temperature must be between first and second values for the overlay to appear.
	var/list/temperature_range = list()
	//Flags.
	var/list/flags = list()
	//Products created when burned. For fuel only for now (not oxidizers)
	var/list/burn_product = list()
	//Dangerous Gases
	var/list/gases_dangerous = list()
	//Knowable Gases
	var/list/gases_knowable = list()

/datum/xgm_gas
	var/id = ""
	var/name = "Unnamed Gas"
	var/specific_heat = 20	// J/(mol*K)
	var/molar_mass = 0.032	// kg/mol

	var/tile_overlay = null
	var/overlay_limit = null

	var/flags = 0
	var/burn_product = "carbon_dioxide"
	var/dangerous = FALSE // currently used by canisters
	/// This variable determines whether the crew knows about this gas from the round start.
	var/knowable = FALSE

/datum/xgm_temperature_overlay
	var/id = ""

	var/icon_state = null
	var/layer = TURF_LAYER

	var/temperature_range = list(0, INFINITY)

/proc/getGasTileOverlay(icon_state, layer)
	var/atom/movable/AM = new(null)
	AM.simulated = FALSE

	var/image/I = image('icons/effects/tile_effects.dmi', icon_state = icon_state, layer = layer)
	I.plane = GAME_PLANE
	I.appearance_flags |= KEEP_APART
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	AM.appearance = I
	return AM

/proc/generateGasData()
	gas_data = new

	for(var/p in subtypesof(/datum/xgm_gas))
		var/datum/xgm_gas/gas = new p //avoid initial() because of potential New() actions

		if(gas.id in gas_data.gases)
			error("Duplicate gas id `[gas.id]` in `[p]`")

		gas_data.gases += gas.id
		gas_data.name[gas.id] = gas.name
		gas_data.specific_heat[gas.id] = gas.specific_heat
		gas_data.molar_mass[gas.id] = gas.molar_mass

		if(gas.tile_overlay)
			gas_data.tile_overlay[gas.id] = getGasTileOverlay(gas.tile_overlay, FLY_LAYER)

		if(gas.overlay_limit)
			gas_data.overlay_limit[gas.id] = gas.overlay_limit

		gas_data.flags[gas.id] = gas.flags
		gas_data.burn_product[gas.id] = gas.burn_product
		gas_data.gases_dangerous[gas.id] = gas.dangerous
		gas_data.gases_knowable[gas.id] = gas.knowable

	for(var/p in subtypesof(/datum/xgm_temperature_overlay))
		var/datum/xgm_temperature_overlay/overlay = new p

		gas_data.tile_overlay[overlay.id] = getGasTileOverlay(overlay.icon_state, overlay.layer)
		gas_data.temperature_range[overlay.id] = overlay.temperature_range

	return gas_data
