/*
	These defines specificy screen locations.  For more information, see the byond documentation on the screen_loc var.

	The short version:

	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	In addition, the keywords NORTH, SOUTH, EAST, WEST and CENTER can be used to represent their respective
	screen borders. NORTH-1, for example, is the row just below the upper edge. Useful if you want your
	UI to scale with screen size.

	The size of the user's screen is defined by client.view (indirectly by world.view), in our case "15x15".
	Therefore, the top right corner (except during admin shenanigans) is at "15,15"
*/

//Lower left, persistant menu
#define ui_inventory "WEST:12,SOUTH:10"

//Middle left indicators
#define ui_lingchemdisplay "WEST:12,CENTER-1:30"
#define ui_lingstingdisplay "WEST:12,CENTER-3:22"

//Lower center, persistant menu
#define ui_sstore1 "CENTER-5:20,SOUTH:10"
#define ui_id "CENTER-4:24,SOUTH:10"
#define ui_belt "CENTER-3:28,SOUTH:10"
#define ui_back "CENTER-2:28,SOUTH:10"
#define ui_rhand "CENTER:-32,SOUTH:10"
#define ui_lhand "CENTER: 32,SOUTH:10"
#define ui_equip "CENTER:-32,SOUTH+1:10"
#define ui_swaphand1 "CENTER:-32,SOUTH+1:10"
#define ui_swaphand2 "CENTER: 32,SOUTH+1:10"
#define ui_storage1 "CENTER+1:36,SOUTH:10"
#define ui_storage2 "CENTER+2:40,SOUTH:10"

#define ui_inv1 "CENTER-2:32,SOUTH:10"			//borgs
#define ui_inv2 "CENTER-1:32,SOUTH:10"			//borgs
#define ui_inv3 "CENTER  :32,SOUTH:10"			//borgs
#define ui_borg_store "CENTER+2:32,SOUTH:10"		//borgs
#define ui_borg_inventory "CENTER-3:32,SOUTH:10"	//borgs
#define ui_borg_pull "EAST-2:52,SOUTH+1:14"
#define ui_borg_module "EAST-1:56,SOUTH+1:14"
#define ui_borg_panel "EAST-2:52,SOUTH:10"
#define ui_borg_health "EAST-1:56,CENTER-1:30"	//borgs have the health display where humans have the pressure damage indicator.

#define ui_monkey_mask "CENTER-3:28,SOUTH:10"	//monkey
#define ui_monkey_back "CENTER-2:28,SOUTH:10"	//monkey

#define ui_alien_head "CENTER-4:24,SOUTH:10"
#define ui_alien_oclothing "CENTER-3:28,SOUTH:10"

//Lower right, persistant menu
#define ui_dropbutton "EAST-4:44,SOUTH:10"
#define ui_drop_throw "EAST-1:56,SOUTH+1:14"
#define ui_pull_resist "EAST-2:52,SOUTH+1:14"
#define ui_movi "EAST-2:52,SOUTH:10"
#define ui_acti "EAST-3:48,SOUTH:10"
#define ui_zonesel "EAST-1:56,SOUTH:10"
#define ui_acti_alt "EAST-1:56,SOUTH:10" 		//alternative intent switcher for when the interface is hidden (F12)

//Gun buttons
#define ui_gun1 "EAST-2:52,SOUTH+2:14"
#define ui_gun2 "EAST-1:56, SOUTH+3:14"
#define ui_gun3 "EAST-2:52,SOUTH+3:14"
#define ui_gun_select "EAST-1:56,SOUTH+2:14"


//Upper-middle right (alerts)
#define ui_alert1 "EAST-1:56,CENTER+5:54"
#define ui_alert2 "EAST-1:56,CENTER+4:50"
#define ui_alert3 "EAST-1:56,CENTER+3:46"
#define ui_alert4 "EAST-1:56,CENTER+2:42"
#define ui_alert5 "EAST-1:56,CENTER+1:38"


//Middle right (status indicators)
#define ui_healthdoll "EAST-1:56,CENTER-1:30"
#define ui_health "EAST-1:56,CENTER:34"
#define ui_internal "EAST-1:56,CENTER+1:38"

//aliens
#define ui_alien_nightvision "EAST-1:56,CENTER:34"
#define ui_alien_health "EAST-1:56,CENTER-1:30"			//aliens have the health display where humans have the pressure damage indicator.
#define ui_alienplasmadisplay "EAST-1:56,CENTER-2:30"


// AI
#define ui_ai_core "SOUTH:12,WEST"
#define ui_ai_camera_list "SOUTH:12,WEST+1"
#define ui_ai_track_with_camera "SOUTH:12,WEST+2"
#define ui_ai_camera_light "SOUTH:12,WEST+3"
#define ui_ai_sensor "SOUTH:12,WEST+4"
#define ui_ai_crew_manifest "SOUTH:12,WEST+5"
#define ui_ai_alerts "SOUTH:12,WEST+6"
#define ui_ai_announcement "SOUTH:12,WEST+7"
#define ui_ai_state_laws "SOUTH:12,WEST+8"
#define ui_ai_pda_send "SOUTH:12,WEST+9"
#define ui_ai_pda_log "SOUTH:12,WEST+10"
#define ui_ai_control_integrated_radio "SOUTH:12,WEST+11"
#define ui_ai_take_picture "SOUTH:12,WEST+12"
#define ui_ai_view_images "SOUTH:12,WEST+13"
#define ui_ai_shuttle "SOUTH:12,WEST+14"


//Pop-up inventory
#define ui_shoes "WEST+1:16,SOUTH:10"
#define ui_iclothing "WEST:12,SOUTH+1:14"
#define ui_oclothing "WEST+1:16,SOUTH+1:14"
#define ui_gloves "WEST+2:20,SOUTH+1:14"
#define ui_glasses "WEST:12,SOUTH+2:18"
#define ui_mask "WEST+1:16,SOUTH+2:18"
#define ui_l_ear "WEST+2:20,SOUTH+2:18"
#define ui_r_ear "WEST+2:20,SOUTH+3:22"
#define ui_head "WEST+1:16,SOUTH+3:22"

//Mecha
#define ui_iarrowleft "SOUTH-1,EAST-3"
#define ui_iarrowright "SOUTH-1,EAST-1"
