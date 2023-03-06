/datum/component/point_and_point
    var/id = "DEFAULT"
    var/entry_points
    var/exit_points
    var/list/image/image_holders
    var/datum/component/point_and_point/parent_point
    var/list/datum/component/point_and_point/child_points

/datum/component/point_and_point/Initialize(id)

    src.id = id

/datum/component/point_and_point/Destroy(force, silent)

    PrepareChildPoints()

    for(var/datum/component/point_and_point/point in child_points)
        RemovePoint(point)
        point.Destroy()

    parent_point = null

    return ..()


/datum/component/point_and_point/proc/PrepareEntryPointsList(id, type, dir)

    LAZYINITLIST(entry_points)
    LAZYINITLIST(entry_points["[id]"])
    LAZYINITLIST(entry_points["[id]"]["[type]"])
    LAZYINITLIST(entry_points["[id]"]["[type]"]["[dir]"])

    if(!entry_points["[id]"]["[type]"]["[dir]"])
        entry_points["[id]"]["[type]"]["[dir]"] = list(0, 0)

    return TRUE

/datum/component/point_and_point/proc/PrepareExitPointsList(type, dir)

    LAZYINITLIST(exit_points)
    LAZYINITLIST(exit_points["[type]"])
    LAZYINITLIST(exit_points["[type]"]["[dir]"])

    if(!exit_points["[type]"]["[dir]"])
        exit_points["[type]"]["[dir]"] = list(0, 0)

    return TRUE

/datum/component/point_and_point/proc/PrepareImageHolderList(type)

    LAZYINITLIST(image_holders)
    LAZYINITLIST(image_holders["[type]"])

    return TRUE

/datum/component/point_and_point/proc/PrepareChildPoints()

    LAZYINITLIST(child_points)

    return TRUE

/datum/component/point_and_point/proc/ChangeEntryPoint(id, type, dir, list/point)

    PrepareEntryPointsList(id, type, dir)
    entry_points["[id]"]["[type]"]["[dir]"] = point

    return TRUE

/datum/component/point_and_point/proc/ChangeExitPoint(type, dir, list/point)

    PrepareExitPointsList(type, dir)
    exit_points["[type]"]["[dir]"] = point

    return TRUE

/datum/component/point_and_point/proc/AddImageHolder(type, image/image_holder)

    PrepareImageHolderList(type)

    image_holder.appearance_flags |= RESET_COLOR
    image_holder.appearance_flags |= KEEP_TOGETHER

    image_holders["[type]"] = image_holder

    return TRUE

/datum/component/point_and_point/proc/RemoveImageHolder(type)

    PrepareImageHolderList(type)

    image_holders["[type]"] = null

    return TRUE

/datum/component/point_and_point/proc/GetImageHolder(type)

    PrepareImageHolderList(type)

    if(!image_holders["[type]"])
        return FALSE

    return image_holders["[type]"]

/datum/component/point_and_point/proc/GetEntryPoint(id, type, dir)

    PrepareEntryPointsList(id, type, dir)

    return entry_points["[id]"]["[type]"]["[dir]"]

/datum/component/point_and_point/proc/GetExitPoint(type, dir)

    PrepareExitPointsList(type, dir)

    return exit_points["[type]"]["[dir]"]

/datum/component/point_and_point/proc/SetOffsetImage(type, dir, image/image_holder)

    var/list/exit_point = GetExitPoint(type, dir)
    var/list/entry_point = parent_point.GetEntryPoint(id, type, dir)

    var/offset = list(entry_point[1] - exit_point[1], entry_point[2] - exit_point[2])

    image_holder.pixel_x = offset[1]
    image_holder.pixel_y = offset[2]

    return image_holder

/datum/component/point_and_point/proc/AddPoint(datum/component/point_and_point/point)

    PrepareChildPoints()

    LAZYADD(child_points, point)
    point.parent_point = src

    return point

/datum/component/point_and_point/proc/RemovePoint(datum/component/point_and_point/point)

    PrepareChildPoints()

    LAZYREMOVE(child_points, point)
    point.parent_point = null

    return point

/datum/component/point_and_point/proc/GetImage(type, dir)

    var/image/image_return = GetImageHolder(type)

    PrepareChildPoints()

    for(var/datum/component/point_and_point/point in child_points)
        var/image/child_image = point.GetImage(type, dir)
        child_image = point.SetOffsetImage(type, dir, child_image)
        image_return.add_overlay(child_image)

    return image_return
