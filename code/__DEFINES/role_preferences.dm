//Roles preferences
#define BE_TRAITOR		1
#define BE_OPERATIVE	2
#define BE_CHANGELING	4
#define BE_WIZARD		8
#define BE_MALF			16
#define BE_REV			32
#define BE_ALIEN		64
#define BE_PAI			128
#define BE_CULTIST		256
#define BE_NINJA		512
#define BE_RAIDER		1024
#define BE_PLANT		2045
#define BE_MEME			4096
#define BE_MUTINEER   	8192
#define BE_SHADOWLING	16384
#define BE_ABDUCTOR		32768

var/list/be_special_flags = list(
	"Traitor" = BE_TRAITOR,
	"Operative" = BE_OPERATIVE,
	"Changeling" = BE_CHANGELING,
	"Wizard" = BE_WIZARD,
	"Malf AI" = BE_MALF,
	"Revolutionary" = BE_REV,
	"Xenomorph" = BE_ALIEN,
	"pAI" = BE_PAI,
	"Cultist" = BE_CULTIST,
	"Ninja" = BE_NINJA,
	"Raider" = BE_RAIDER,
	"Diona" = BE_PLANT,
	"Meme" = BE_MEME,
	"Mutineer" = BE_MUTINEER,
	"Shadowling" = BE_SHADOWLING,
	"Abductor" = BE_ABDUCTOR
	)