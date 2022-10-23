//infestation
#define TOTAL_HUMAN         1
#define TOTAL_ALIEN         2
#define ALIEN_PERCENT       3
#define FIRST_HELP_PERCENT  20
#define SECOND_HELP_PERCENT 60
#define WIN_PERCENT         190

//alien list
#define ALIEN_QUEEN			"Королева"
#define ALIEN_DRONE			"Трутни"
#define ALIEN_SENTINEL		"Стражи"
#define ALIEN_HUNTER		"Охотники"
#define ALIEN_LARVA			"Грудоломы"
#define ALIEN_FACEHUGGER	"Лицехваты"
#define ALIEN_MAID			"Горничные"

//alien embryo
#define MAX_EMBRYO_GROWTH 40
#define MAX_EMBRYO_STAGE 5
#define FULL_EMBRYO_GROWTH MAX_EMBRYO_GROWTH * MAX_EMBRYO_STAGE

//Facehugger's control type
#define FACEHUGGERS_STATIC_AI     0   // don't move by themselves
#define FACEHUGGERS_DYNAMIC_AI    1   // controlled by simple AI
#define FACEHUGGERS_PLAYABLE      2   // controlled by players

//Time it takes to impregnate someone with facehugger
#define MIN_IMPREGNATION_TIME 220
#define MAX_IMPREGNATION_TIME 250
