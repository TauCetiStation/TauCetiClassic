//message types for chat bridge
//can be mapped on different discord/slack/rocketchat/etc. channels in bridge bot

//service messages
#define BRIDGE_ROUNDSTAT  "roundstat"  //shuttle/server starting/round starting
#define BRIDGE_SERVICE    "service"    //private debug msgs
#define BRIDGE_ANNOUNCE   "announce"   //general announces for players

//admin
#define BRIDGE_ADMINCOM       "admincom"       //admin faxes and command console
#define BRIDGE_ADMINLOG       "adminlog"       //tickets & pm
#define BRIDGE_ADMINALERT     "adminalert"     //new ticket and no admins online, panikbunker
#define BRIDGE_ADMINBAN       "adminban"       //bans
#define BRIDGE_ADMINWL        "adminwl"        //whitelist changes
#define BRIDGE_ADMINIMPORTANT "adminimportant" //important notifications for main channel

//misc
#define BRIDGE_OOC        "ooc"


//predefined colors for attachment (slack, discord)
#define BRIDGE_COLOR_ROUNDSTAT  "#00ffff"
#define BRIDGE_COLOR_SERVICE    "#000000"
#define BRIDGE_COLOR_ANNOUNCE   "#00ff00"

#define BRIDGE_COLOR_ADMINCOM   "#00ffff"
#define BRIDGE_COLOR_ADMINLOG   "#00ffff"
#define BRIDGE_COLOR_ADMINALERT "#ff0000"
#define BRIDGE_COLOR_ADMINBAN   "#ff0000"
#define BRIDGE_COLOR_ADMINWL    "#ffff00"

//mention types, can be mappet to specific groups
//if not listed - bot will try to find and slap user
#define BRIDGE_MENTION_HERE       "here"
#define BRIDGE_MENTION_EVERYONE   "everyone"
#define BRIDGE_MENTION_ROUNDSTART "roundstart"
#define BRIDGE_MENTION_EVENT      "event"
