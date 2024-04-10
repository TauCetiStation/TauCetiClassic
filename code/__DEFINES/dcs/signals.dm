// All signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice

//leaved for example (as part with "!" important to know)
//#define COMSIG_GLOB_MOB_CREATED "!mob_created"					//mob was created somewhere : (mob)

//////////////////////////////////////////////////////////////////

// /datum signals
/// when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_ADDED "component_added"
/// before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"
/// before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"
/// just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
#define COMSIG_PARENT_QDELETING "parent_qdeleting"

// /datum/element signals
/// fires on the target datum when an element is attached to it (/datum/element)
#define COMSIG_ELEMENT_ATTACH "element_attach"
/// fires on the target datum when an element is attached to it  (/datum/element)
#define COMSIG_ELEMENT_DETACH "element_detach"

// /datum/modval
/// from base of datum/modval/Update(): (old_value)
#define COMSIG_MODVAL_UPDATE "modval_update"

// /datum/religion_rites signals
/// from base of religion_rites/on_chosen(): (/mob, /obj)
#define COMSIG_RITE_ON_CHOSEN "rite_on_chosen"
/// from base of religion_rites/can_start_wrapper(): (/mob, /obj)
#define COMSIG_RITE_CAN_START "rite_can_start"
/// from base of religion_rites/start(): (/mob, /obj)
#define COMSIG_RITE_STARTED "rite_is_started"
/// from base of religion_rites/rite_step_wrapper(): (/mob, /obj)
#define COMSIG_RITE_IN_STEP "rite_in_step"
/// from base of religion_rites/step_end(): (/mob, /obj)
#define COMSIG_RITE_STEP_ENDED "rite_step_ended"
/// from base of religion_rites/invoke_effect(): (/mob, /obj)
#define COMSIG_RITE_INVOKE_EFFECT "rite_invoke_effect"
/// from base of religion_rites/can_step(): (/mob, /obj)
#define COMSIG_RITE_FAILED_CHECK "rite_failed_check"
	#define COMPONENT_CHECK_FAILED 1

//from base of obj/item/weapon/storage/handle_item_insertion(): (obj/item/I, prevent_warning, NoUpdate)
#define COMSIG_STORAGE_ENTERED "storage_entered"
	#define COMSIG_STORAGE_PROHIBIT 1
//from base of obj/item/weapon/storage/remove_from_storage(): (obj/item/I, atom/new_location, NoUpdate)
#define COMSIG_STORAGE_EXITED "storage_exited"

// /datum/religion signals
/// from base of religion/add_membern(): (/mob, holy_role)
#define COMSIG_REL_ADD_MEMBER "rel_add_member"
/// from base of religion/remove_member(): (/mob)
#define COMSIG_REL_REMOVE_MEMBER "rel_remove_member"

// /datum/role signals
/// from base of role/GetScoreboard(): ()
#define COMSIG_ROLE_GETSCOREBOARD "role_getscoreboard"
/// from base of role/extraPanelButtons(): ()
#define COMSIG_ROLE_PANELBUTTONS "role_panelbuttons"
/// from base of role/RoleTopic(): (href, href_list, datum/mind/M, admin_auth)
#define COMSIG_ROLE_ROLETOPIC "role_roletopic"
/// from base of role/OnPostSetup(): (laterole)
#define COMSIG_ROLE_POSTSETUP "role_postsetup"

// light related signals
/// from base of /atom/movable/lighting_object/update(): (turf/my_turf)
#define COMSIG_LIGHT_UPDATE_OBJECT "light_update_object"

// /datum/reagent signals
/// from base of reagent/reaction_turf(): (turf/T, volume)
#define COMSIG_REAGENT_REACTION_TURF "reagent_reaction_turf"

// /datum/species signals
///from datum/species/on_species_gain(): (datum/species/new_species, datum/species/old_species)
#define COMSIG_SPECIES_GAIN "species_gain"
///from datum/species/on_species_loss(): (datum/species/lost_species)
#define COMSIG_SPECIES_LOSS "species_loss"

// /client signals
/// from base of client/Move(): (atom/NewLoc, direction)
#define COMSIG_CLIENTMOB_MOVE "client_move"
	#define COMPONENT_CLIENTMOB_BLOCK_MOVE 1
/// from base of client/Move(): (atom/NewLoc, direction), can not be blocked like the above one can.
#define COMSIG_CLIENTMOB_MOVING "client_moving"
/// from base of client/Move, after all movement is finished(): (atom/NewLoc, direction)
#define COMSIG_CLIENTMOB_POSTMOVE "client_postmove"
/// from base of mob/set_a_intent(): (new_intent)
#define COMSIG_MOB_SET_A_INTENT "mob_set_a_intent"
/// from base of mob/living/set_m_intent(): (new_intent)
#define COMSIG_MOB_SET_M_INTENT "mob_set_m_intent"

// /area signals
///from base of area/Entered(): (area/entered, atom/OldLoc)
#define COMSIG_AREA_ENTERED "area_entered"
///from base of area/Exited(): (area/exited, atom/NewLoc)
#define COMSIG_AREA_EXITED "area_exited"

// /atom signals
///from base of atom/Click(): (location, control, params, mob/user)
#define COMSIG_CLICK "atom_click"
/// emp_act() : severity
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"
	#define COMPONENT_PREVENT_EMP 1
/// from base of mob/living/carbon/human/electrocute_act(): (shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null, tesla_shock = 0)
#define COMSIG_ATOM_ELECTROCUTE_ACT "atom_electrocute_act"
/// from base of atom/Entered(): (atom/movable/entering, /atom/OldLoc)
#define COMSIG_ATOM_ENTERED "atom_entered"
/// from base of atom/Exited(): (atom/movable/exiting, /atom/NewLoc)
#define COMSIG_ATOM_EXITED "atom_exited"
/// from base of atom/movable/CanPass() & mob/CanPass(): (atom/movable/mover, atom/target, height)
#define COMSIG_ATOM_CANPASS "movable_canpass"
	#define COMPONENT_CANPASS  1
	#define COMPONENT_CANTPASS 2
/// from base of atom/attackby(): (/obj/item, /mob/living, params)
#define COMSIG_PARENT_ATTACKBY "atom_attackby"
	// Return this in response if you don't want afterattack to be called
	#define COMPONENT_NO_AFTERATTACK 1
/// from base of atom/examine(): (/mob)
#define COMSIG_PARENT_EXAMINE "atom_examine"
/// from base of mob/examinate(): (/mob)
#define COMSIG_PARENT_POST_EXAMINE "atom_post_examine"
/// from base of mob/examinate(): (/atom)
#define COMSIG_PARENT_POST_EXAMINATE "atom_post_examinate"
/// from base of atom/get_examine_name(): (/mob/user, list/override)
#define COMSIG_ATOM_GET_EXAMINE_NAME "atom_get_examine_name"
	//Positions for overrides list
	#define EXAMINE_POSITION_BEFORE_EVERYTHING 1
	#define EXAMINE_POSITION_ARTICLE 2
	#define EXAMINE_POSITION_BEFORE_NAME 3
	#define EXAMINE_POSITION_NAME 4
	#define EXAMINE_POSITION_AFTER_EVERYTHING 5
	//End positions
	#define COMPONENT_EXNAME_CHANGED 1
/// from base of atom/MouseDrop(): (/atom/over, /mob/user)
#define COMSIG_MOUSEDROP_ONTO "mousedrop_onto"
	#define COMPONENT_NO_MOUSEDROP 1
/// from base of atom/MouseDrop_T: (/atom/from, /mob/user)
#define COMSIG_MOUSEDROPPED_ONTO "mousedropped_onto"
/// from base of atom/add_dirt_cover: (datum/dirt_cover/dirt_datum)
#define COMSIG_ATOM_ADD_DIRT "atom_add_dirt"
/// from base of atom/clean_blood (WHICH APPERANTLY CLEANS ALL DIRT OVERLAYS ?? ??? ?)
#define COMSIG_ATOM_CLEAN_BLOOD "atom_clean_blood"
///from /mob/living/say() when atom catches message: (proc args list(message, atom/movable/speaker))
// currently works for talking_atom only
#define COMSIG_MOVABLE_HEAR "movable_hear"

///called when teleporting into a protected turf: (channel, turf/origin)
#define COMSIG_ATOM_INTERCEPT_TELEPORT "intercept_teleport"
	#define COMPONENT_BLOCK_TELEPORT (1<<0)
	//#define COMPONENT_INTERFERE_TELEPORT (1<<1)

/// from base /atom/movable/proc/Moved() and /atom/proc/set_dir() return dir
#define COMSIG_ATOM_CHANGE_DIR "change_dir"

// /atom/movable signals
/// from base of atom/movable/Move(): (/atom/newLoc)
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"
	#define COMPONENT_MOVABLE_BLOCK_PRE_MOVE 1
/// from base of atom/movable/Crossed(): (/atom/movable)
#define COMSIG_MOVABLE_CROSSED "movable_crossed"
/// from base of atom/movable/Moved(): (/atom/oldLoc, dir)
#define COMSIG_MOVABLE_MOVED "movable_moved"
/// from base of atom/movable/locMoved(): (/atom/oldLoc, dir)
#define COMSIG_MOVABLE_LOC_MOVED "movable_loc_moved"
/// from base of /mob/start_pulling(): (/mob/puller)
#define COMSIG_ATOM_START_PULL "atom_start_pull"
	#define COMPONENT_PREVENT_PULL 1
/// from base of /mob/stop_pulling(): (/mob/puller)
#define COMSIG_ATOM_STOP_PULL  "atom_stop_pull"
/// from atom/movable/proc/waddle(): (waddle_angle, waddle_height)
#define COMSIG_MOVABLE_WADDLE "movable_waddle"
/// from mob/tryGrab(): (/mob/grabber, force_state, show_warnings)
#define COMSIG_MOVABLE_TRY_GRAB "movable_try_grab"
	#define COMPONENT_PREVENT_GRAB 1
/// from /obj/item/weapon/grab/proc/s_click(): (/obj/item/weapon/grab)
#define COMSIG_S_CLICK_GRAB "s_click_grab"
/// hopefully called from all places where pixel_x and pixel_y is set. used by multi_carry, and waddle. (): ()
#define COMSIG_MOVABLE_PIXELMOVE "movable_pixelmove"
///from base of area/Entered(): (/area, /atom/OldLoc). Sent to "area-sensitive" movables, see __DEFINES/traits.dm for info.
#define COMSIG_ENTER_AREA "enter_area"
///from base of area/Exited(): (/area, /atom/NewLoc). Sent to "area-sensitive" movables, see __DEFINES/traits.dm for info.
#define COMSIG_EXIT_AREA "exit_area"
/// from datum/orbit/New(): (/atom/orbiting)
#define COMSIG_MOVABLE_ORBIT_BEGIN "orbit_begin"
/// from datum/orbit/New(): (/atom/orbiting)
#define COMSIG_MOVABLE_ORBIT_STOP "orbit_stop"
///when an atom starts playing a song, used in song_tuner rites: (datum/music_player)
#define COMSIG_ATOM_STARTING_INSTRUMENT "atom_starting_instrument"
///sent to the instrument when a song stops playing: (datum/music_player)
#define COMSIG_INSTRUMENT_END "instrument_end"
///sent to the instrument (and player if available) when a song repeats: (datum/music_player)
#define COMSIG_INSTRUMENT_REPEAT "instrument_repeat"
///sent to the instrument when tempo changes, skipped on new: (datum/music_player)
#define COMSIG_INSTRUMENT_TEMPO_CHANGE "instrument_tempo_change"

// /obj signals
/// from base of datum/religion_rites/reset_rite_wrapper(): ()
#define COMSIG_OBJ_RESET_RITE "obj_reset_rite"
/// from base of datum/religion_rites/start(): ()
#define COMSIG_OBJ_START_RITE "obj_start_rite"
///from base of /turf/proc/levelupdate(). (underfloor_accessibility)
#define COMSIG_OBJ_LEVELUPDATE "obj_levelupdate"

// /obj/item signals
/// from base of obj/item/attack(): (/mob/living/target, /mob/living/user, def_zone)
#define COMSIG_ITEM_ATTACK "item_attack"
	#define COMPONENT_ITEM_NO_ATTACK 1
/// from base of obj/item/attack_self(): (/mob/user)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"
	#define COMPONENT_NO_INTERACT 1
///from base of obj/item/attack_atom(): (atom/attacked_atom, mob/living/user, params)
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"
///from base of obj/item/pickup(): (/mob/user)
#define COMSIG_ITEM_PICKUP "item_pickup"
	#define COMPONENT_ITEM_NO_PICKUP 1
///from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_EQUIPPED "item_equip"
///from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_DROPPED "item_drop"
/// from base of mob/ShiftClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_SHIFTCLICKWITH "item_shiftclickwith"
/// from base of mob/MiddleShiftClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_MIDDLESHIFTCLICKWITH "item_middleshiftclickwith"
/// from base of mob/CtrlClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_CTRLCLICKWITH "item_ctrlclickwith"
/// from base of mob/AltClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_ALTCLICKWITH "item_altclickwith"
/// from base of mob/CtrlShiftClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_CTRLSHIFTCLICKWITH "item_ctrlshiftclickwith"
/// from base of mob/MiddleClickOn(): (atom/target, mob/user)
#define COMSIG_ITEM_MIDDLECLICKWITH "item_middleclickwith"
	#define COMSIG_ITEM_CANCEL_CLICKWITH 1
/// from base of obj/item/CtrlShiftClick()
#define COMSIG_CLICK_CTRL_SHIFT "ctrl_shift_click"
/// from base of atom/MouseDrop(): (/atom/over, /atom/dropping, /mob/user)
#define COMSIG_ITEM_MOUSEDROP_ONTO "item_mousedrop_onto"
	// #define COMPONENT_NO_MOUSEDROP 1
/// from base of obj/item/make_wet
#define COMSIG_ITEM_MAKE_WET "item_make_wet"
/// from obj/item/dry_process
#define COMSIG_ITEM_MAKE_DRY "item_make_dry"
/// from mob/carbon/swap_hand: (mob/user)
#define COMSIG_ITEM_BECOME_ACTIVE "item_become_active"
#define COMSIG_ITEM_BECOME_INACTIVE "item_become_inactive"
/// from /obj/item/weapon/stock_parts/cell
#define COMSIG_CELL_CHARGE_CHANGED "cell_charge_changed"

// hand_like /obj/item signals
/// check if item is hand_like: ()
#define COMSIG_HAND_IS "hand_is"
/// from mob/living/silicon/robot/ClickOn(): (atom/T, mob/user, params)
#define COMSIG_HAND_ATTACK "hand_attack"
/// from mob/living/silicon/robot/drop_item(): (atom/T, mob/user)
#define COMSIG_HAND_DROP_ITEM "hand_drop_item"
/// from mob/living/silicon/robot/put_in_active_hand(): (obj/item/I, mob/user)
#define COMSIG_HAND_PUT_IN "hand_put_in"
/// from mob/living/silicon/robot/get_active_hand(): (mob/user)
#define COMSIG_HAND_GET_ITEM "hand_get_item"

//Mood (/datum/component/mood) signals
///called when you send a mood event from anywhere in the code.
#define COMSIG_ADD_MOOD_EVENT "add_mood"
///called when you clear a mood event from anywhere in the code.
#define COMSIG_CLEAR_MOOD_EVENT "clear_mood"

// mob signals
/// from base of mob/Login(): ()
#define COMSIG_LOGIN "mob_login"
/// from base of mob/Logout(): (logout_reason)
#define COMSIG_LOGOUT "mob_logout"

/// from  base of mob/ClickOn(): (atom/target, params)
#define COMSIG_MOB_CLICK "mob_click"
// from base of mob/RegularClickOn(): (atom/target, params)
#define COMSIG_MOB_REGULAR_CLICK "regular_click"
	#define COMPONENT_CANCEL_CLICK 1
/// from mob/proc/slip(): (weaken_duration, obj/slipped_on, lube)
#define COMSIG_MOB_SLIP "movable_slip"
/// from base of mob/death(): (gibbed)
#define COMSIG_MOB_DIED "mob_died"
///from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"
///from base of item/equipped(): (obj/item/I, slot)
#define COMSIG_MOB_EQUIPPED "mob_equipped"
///from base of obj/allowed(mob/M): (/obj) returns ACCESS_ALLOWED if mob has id access to the obj
#define COMSIG_MOB_TRIED_ACCESS "tried_access"
	#define COMSIG_ACCESS_ALLOWED 1
///from base of /mob/proc/update_z: (new_z)
#define COMSIG_MOB_Z_CHANGED "mob_z_changed"

// living signals
///from base of mob/living/rejuvenate(): ()
#define COMSIG_LIVING_REJUVENATE "living_rejuvenate"
/// from base of /mob/start_pulling(): (/atom/movable/target)
#define COMSIG_LIVING_START_PULL "living_start_pull"
/// from base of /mob/stop_pulling(): (/atom/movable/target)
#define COMSIG_LIVING_STOP_PULL "living_stop_pull"
// send this signal when mob is lying
#define COMSIG_MOB_STATUS_LYING "mob_lying"
// send this signal when mob is standing
#define COMSIG_MOB_STATUS_NOT_LYING "mob_not_lying"
/// from base of atom/movable/buckle_mob(): (mob/buckled)
#define COMSIG_MOVABLE_BUCKLE "buckle"
/// from base of atom/movable/unbuckle_mob(): (mob/buckled)
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"
/// from base of /mob/Move_Pulled(): (atom/target)
#define COMSIG_LIVING_MOVE_PULLED "living_move_pulled"
	#define COMPONENT_PREVENT_MOVE_PULLED 1
/// from base of mob/CtrlClickOn(): (atom/target)
#define COMSIG_LIVING_CLICK_CTRL "living_click_ctrl"
/// from base of mob/CtrlShiftClickOn(): (atom/target)
#define COMSIG_LIVING_CLICK_CTRL_SHIFT "living_click_ctrl_shift"
/// from slime CtrlClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_CTRL "xeno_slime_click_ctrl"
/// from slime ShiftClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_SHIFT "xeno_slime_click_shift"
/// from turf ShiftClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_SHIFT "xeno_turf_click_shift"
/// from turf AltClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_CTRL "xeno_turf_click_alt"
/// from monkey CtrlClickOn(): (/mob)
#define COMSIG_XENO_MONKEY_CLICK_CTRL "xeno_monkey_click_ctrl"
/// from mob/living/check_shields(): (atom/attacker, damage, attack_text, hit_dir)
#define COMSIG_LIVING_CHECK_SHIELDS "check_shields"
	#define COMPONENT_ATTACK_SHIELDED 1
// from mob/living/learn_combo(): (datum/combat_combo/combo, datum/combat_moveset/moveset)
#define COMSIG_LIVING_LEARN_COMBO "learn_combo"
// from mob/living/forget_combo(): (datum/combat_combo/combo, datum/combat_moveset/moveset)
#define COMSIG_LIVING_FORGET_COMBO "forget_combo"
///from base of mob/living/carbon/swap_hand(): (obj/item)
#define COMSIG_MOB_SWAP_HANDS "mob_swap_hands"
	#define COMPONENT_BLOCK_SWAP 1
///from mob/living/vomit(): (/mob)
#define COMSIG_LIVING_VOMITED "living_vomited"
///from ai_actual_track(): (mob/living)
#define COMSIG_LIVING_CAN_TRACK "mob_cantrack"
	#define COMPONENT_CANT_TRACK (1<<0)
#define COMSIG_LIVING_BUMPED "living_bumped"

/// from /obj/effect/proc_holder/changeling/transform/sting_action(): (mob/living/carbon/human/user)
#define COMSIG_CHANGELING_TRANSFORM "changeling_transform"
/// from /mob/living/carbon/proc/finish_monkeyize()
#define COMSIG_HUMAN_MONKEYIZE "human_monkeyize"
/// from /mob/living/carbon/proc/finish_humanize(): (species)
#define COMSIG_MONKEY_HUMANIZE "monkey_humanize"
/// from /mob/verb/a_intent_change(): (intent as text)
#define COMSIG_LIVING_INTENT_CHANGE "living_intent_change"

// simple_animal/hostile signals
/// from simple_animal/hostile/proc/UnarmedAttack(): (atom/target)
#define COMSIG_MOB_HOSTILE_ATTACKINGTARGET "mob_hostile_attackingtarget"
/// from simple_animal/hostile/proc/Shoot(): (atom/target)
#define COMSIG_MOB_HOSTILE_SHOOT "mob_hostile_shoot"

// Component specific signals.
/// send this signal to remove a list of tip ids(use tip_names as tip ids): (/list/tip_ids_to_remove)
#define COMSIG_TIPS_REMOVE "comsig_tip_remove"

/// send this signal to cause all forcefield components to protect a thing: (atom/to_protect)
#define COMSIG_FORCEFIELD_PROTECT "comsig_forcefield_protect"
/// send this signal to cause all forcefield components to unprotect a thing: (atom/to_unprotect)
#define COMSIG_FORCEFIELD_UNPROTECT "comsig_forcefield_unprotect"

/// send this signal to add /datum/name_modifier to a mob: (name_modifier_type, strength)
#define COMSIG_NAME_MOD_ADD "comsig_mob_mod_add"
/// send this signal to remove /datum/name_modifier from a mob: (name_modifier_type, strength)
#define COMSIG_NAME_MOD_REMOVE "comsig_mob_mod_remove"

/// from base of /datum/mob_modifier/revert. Called to notify other modifiers that they should re-apply: (datum/component/mob_modifier/reverting)
#define COMSIG_MOB_MOD_UPDATE "mob_mod_update"

/// send this signal to add /datum/component/vis_radius to a list of mobs or one mob: (mob/mob_or_mobs)
#define COMSIG_SHOW_RADIUS "show_radius"
/// send this signal to remove /datum/component/vis_radius to a mobs: ()
#define COMSIG_HIDE_RADIUS "hide_radius"

// send this signal to stop suppressing in /datum/component/silence: ()
#define COMSIG_START_SUPPRESSING "start_suppressing"
// send this signal to stop suppressing in /datum/component/silence: ()
#define COMSIG_STOP_SUPPRESSING "stop_suppressing"

// send this signal to toggle zoom in /datum/component/zoom: (mob/user)
#define COMSIG_ZOOM_TOGGLE "zoom_toggle"

/// a client (re)connected, after all /client/New() checks have passed : (client/connected_client)
#define COMSIG_GLOB_CLIENT_CONNECT "!client_connect"

///from /obj/machinery/door/airlock/bumpopen(), to the carbon who bumped: (airlock)
#define COMSIG_CARBON_BUMPED_AIRLOCK_OPEN "carbon_bumped_airlock_open"
/// Return to stop the door opening on bump.
	#define STOP_BUMP (1<<0)

/// Called from update_health_hud, whenever a bodypart is being updated on the health doll
#define COMSIG_BODYPART_UPDATING_HEALTH_HUD "bodypart_updating_health_hud"
	/// Return to override that bodypart's health hud with your own icon
	#define COMPONENT_OVERRIDE_BODYPART_HEALTH_HUD (1<<0)

/// from /proc/health_analyze(): (list/args = list(message, scan_hallucination_boolean))
/// Consumers are allowed to mutate the scan_results list to add extra information
#define COMSIG_LIVING_HEALTHSCAN "living_healthscan"
// send this signal to make effect impedrezene for mob/living
#define COMSIG_IMPEDREZENE_DIGEST "impedrezene_digest"
// send this signal to make effect flashing eyes for mob/living
#define COMSIG_FLASH_EYES "flash_eyes"
// send this signal to make effect enter water turf for mob/living/carbon/human
#define COMSIG_HUMAN_ENTERED_WATER "human_entered_water"
// send this signal to make effect exit water turf for mob/living/carbon/human
#define COMSIG_HUMAN_EXITED_WATER "human_exited_water"
// send this signal to disable gene for mob/living/carbon
#define COMSIG_REMOVE_GENE_DISABILITY "remove_gene_disability"
// send this signal to handle disabilities in life for mob/living/carbon/human
#define COMSIG_HANDLE_DISABILITIES "handle_disabilities"
