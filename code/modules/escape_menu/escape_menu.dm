var/global/list/escape_menus = list()

/// Opens the escape menu.
/// Verb, hardcoded to Escape, set in the client skin.
/client/verb/open_escape_menu()
	set name = "Open Escape Menu"
	set hidden = TRUE

	var/current_escape_menu = global.escape_menus[ckey]
	if (!isnull(current_escape_menu))
		qdel(current_escape_menu)
		return

	reset_held_keys()

	new /datum/escape_menu(src)

#define PAGE_HOME "PAGE_HOME"
#define PAGE_LEAVE_BODY "PAGE_LEAVE_BODY"

/datum/escape_menu
	/// The client that owns this escape menu
	var/client/client

	VAR_PRIVATE/ckey

	VAR_PRIVATE/datum/screen_object_holder/base_holder
	VAR_PRIVATE/datum/screen_object_holder/page_holder

	VAR_PRIVATE/atom/movable/plane_master_controller/plane_master_controller

	VAR_PRIVATE/menu_page = PAGE_HOME

/datum/escape_menu/New(client/client)
	ASSERT(!(client.ckey in global.escape_menus))

	ckey = client?.ckey
	src.client = client

	base_holder = new(client)
	populate_base_ui()

	page_holder = new(client)
	show_page()

	RegisterSignal(client, COMSIG_PARENT_QDELETING, PROC_REF(on_client_qdel))
	RegisterSignal(client, COMSIG_LOGIN, PROC_REF(on_client_mob_login))

	if (!isnull(ckey))
		global.escape_menus[ckey] = src

/datum/escape_menu/Destroy(force, ...)
	QDEL_NULL(base_holder)
	QDEL_NULL(page_holder)

	global.escape_menus -= ckey
	plane_master_controller.remove_filter("escape_menu_blur")

	return ..()

/datum/escape_menu/proc/on_client_qdel()
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	qdel(src)

/datum/escape_menu/proc/on_client_mob_login()
	SIGNAL_HANDLER
	PRIVATE_PROC(TRUE)

	if (menu_page == PAGE_LEAVE_BODY)
		qdel(src)

/datum/escape_menu/proc/show_page()
	PRIVATE_PROC(TRUE)

	page_holder.clear()

	switch (menu_page)
		if (PAGE_HOME)
			show_home_page()
		if (PAGE_LEAVE_BODY)
			show_leave_body_page()
		else
			CRASH("Unknown escape menu page: [menu_page]")

/datum/escape_menu/proc/populate_base_ui()
	PRIVATE_PROC(TRUE)

	base_holder.give_screen_object(new /atom/movable/screen/fullscreen/dimmer)
	add_blur()

	base_holder.give_protected_screen_object(give_escape_menu_title())
	base_holder.give_protected_screen_object(give_escape_menu_details())

/datum/escape_menu/proc/open_home_page()
	PRIVATE_PROC(TRUE)

	menu_page = PAGE_HOME
	show_page()

/datum/escape_menu/proc/open_leave_body()
	PRIVATE_PROC(TRUE)

	menu_page = PAGE_LEAVE_BODY
	show_page()

/datum/escape_menu/proc/add_blur()
	PRIVATE_PROC(TRUE)

	var/list/plane_master_controllers = client?.mob.hud_used.plane_master_controllers
	if (isnull(plane_master_controllers))
		return

	plane_master_controller = plane_master_controllers[PLANE_MASTERS_NON_MASTER]
	plane_master_controller.add_filter("escape_menu_blur", 1, list("type" = "blur", "size" = 2))

/atom/movable/screen/escape_menu
	plane = ESCAPE_MENU_PLANE
	icon = null

// The escape menu can be opened before SSatoms
INITIALIZE_IMMEDIATE(/atom/movable/screen/escape_menu)

#undef PAGE_HOME
#undef PAGE_LEAVE_BODY

/// A helper instance that will handle adding objects from the client's screen
/// to easily remove from later.
/datum/screen_object_holder
	VAR_PRIVATE/client/client
	VAR_PRIVATE/list/screen_objects = list()
	VAR_PRIVATE/list/protected_screen_objects = list()

/datum/screen_object_holder/New(client/client)
	ASSERT(istype(client))

	src.client = client

	RegisterSignal(client, COMSIG_PARENT_QDELETING, PROC_REF(on_parent_qdel))

/datum/screen_object_holder/Destroy()
	clear()
	client = null

	return ..()

/// Gives the screen object to the client, qdel'ing it when it's cleared
/datum/screen_object_holder/proc/give_screen_object(atom/screen_object)
	ASSERT(istype(screen_object))

	screen_objects += screen_object
	client?.screen += screen_object

/// Gives the screen object to the client, but does not qdel it when it's cleared
/datum/screen_object_holder/proc/give_protected_screen_object(atom/screen_object)
	ASSERT(istype(screen_object))

	protected_screen_objects += screen_object
	client?.screen += screen_object

/datum/screen_object_holder/proc/remove_screen_object(atom/screen_object)
	ASSERT(istype(screen_object))
	ASSERT((screen_object in screen_objects) || (screen_object in protected_screen_objects))

	screen_objects -= screen_object
	protected_screen_objects -= screen_object
	client?.screen -= screen_object

/datum/screen_object_holder/proc/clear()
	client?.screen -= screen_objects
	client?.screen -= protected_screen_objects

	QDEL_LIST(screen_objects)
	protected_screen_objects.Cut()

// We don't qdel here, as clients leaving should not be a concern for consumers
// Consumers ought to be qdel'ing this on their own Destroy, but we shouldn't
// hard del because they aren't watching for the client, that's our job.
/datum/screen_object_holder/proc/on_parent_qdel()
	PRIVATE_PROC(TRUE)
	SIGNAL_HANDLER

	clear()
	client = null
