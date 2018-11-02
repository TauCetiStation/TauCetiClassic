//Device controlled Device to control the robot RND
/obj/item/device/det5controll
	name = "DET5-controller"
	icon_state = "det5_remote"
	desc = "Device to control the robot RND"
	w_class = 2.0
	var/used_det = 0

obj/item/device/det5controll/attack(mob/living/M, mob/user)
	used_det += 1
	visible_message("Used <b>[used_det]</b>")