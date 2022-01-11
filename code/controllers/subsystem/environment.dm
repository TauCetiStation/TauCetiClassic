SUBSYSTEM_DEF(environment)
    name = "Environment"

    init_order = SS_INIT_ENVIRONMENT

    flags = SS_NO_FIRE

    var/list/envtype = list()

    var/list/turf_type = list()
    var/list/turf_image = list()
    var/list/turf_light_color = list()

    var/list/air = list()
    var/list/air_pressure = list()

    var/list/post_gen_type = list()

/datum/controller/subsystem/environment/Initialize(timeofday)
    for(var/z_value in 1 to post_gen_type.len)
        populate(z_value)

/datum/controller/subsystem/environment/proc/populate(z_value)
    if(!post_gen_type[z_value])
        return

    var/datum/map_generator/gen = new (post_gen_type[z_value])
    gen.defineRegion(locate(1, 1, z_value), locate(world.maxx, world.maxy, z_value))
    gen.generate()

/datum/controller/subsystem/environment/proc/update(z_value, new_envtype)
    if(envtype.len < z_value)
        envtype.len = turf_type.len = turf_image.len = turf_light_color.len = \
            air.len = air_pressure.len = post_gen_type.len = z_value

    if(envtype[z_value] == new_envtype && turf_type[z_value]) // same envtype and initialized
        return

    var/envtype_ = new_envtype
    var/turf/turf_type_
    var/image/turf_image_
    var/turf_light_color_
    var/datum/gas_mixture/air_
    var/air_pressure_
    var/post_gen_type_

    switch(envtype_)
        if (ENV_TYPE_SPACE)
            turf_type_ = /turf/simulated/environment/space
        if (ENV_TYPE_SNOW)
            turf_type_ = /turf/simulated/environment/snow
            post_gen_type_ = /datum/map_generator/snow
            turf_light_color_ = COLOR_BLUE
        else
            error("[envtype_] is not valid environment type, revert to space")
            envtype_ = ENV_TYPE_SPACE
            turf_type_ = /turf/simulated/environment/space

    //Properties for environment tiles
    var/oxygen = initial(turf_type_.oxygen)
    var/carbon_dioxide = initial(turf_type_.carbon_dioxide)
    var/nitrogen = initial(turf_type_.nitrogen)
    var/phoron = initial(turf_type_.phoron)

    air_ = new(_temperature=initial(turf_type_.temperature))
    air_.adjust_multi(
        "oxygen", oxygen, "carbon_dioxide", carbon_dioxide,
        "nitrogen", nitrogen, "phoron", phoron
        )

    air_pressure_ = air_.return_pressure()

    turf_image_ = image(
        initial(turf_type_.icon),
        initial(turf_type_.icon_state),
        layer=initial(turf_type_.layer)
    )
    turf_image_.plane = initial(turf_type_.plane)

    envtype[z_value] = envtype_
    turf_type[z_value] = turf_type_
    turf_image[z_value] = turf_image_
    turf_light_color[z_value] = turf_light_color_
    air[z_value] = air_
    air_pressure[z_value] = air_pressure_
    post_gen_type[z_value] = post_gen_type_
