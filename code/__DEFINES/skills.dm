
#define SKILL_CIV_MECH "Civilian exosuits"
#define SKILL_COMBAT_MECH "Combat exosuits"
#define SKILL_POLICE "Police"
#define SKILL_FIREARMS "Firearms"
#define SKILL_MELEE "Melee weapons"
#define SKILL_ENGINEERING "Engineering"
#define SKILL_ATMOS "Atmospherics"
#define SKILL_CONSTRUCTION "Construction"
#define SKILL_CHEMISTRY "Chemistry"
#define SKILL_RESEARCH "Research"
#define SKILL_MEDICAL "Medical"
#define SKILL_SURGERY "Surgery"
#define SKILL_COMMAND "Command"

// base task time, not mandatory but helps to keep tasks difficulty consistent
// usually final time will be modified by task and user skills
#define SKILL_TASK_TRIVIAL 1 SECONDS
#define SKILL_TASK_VERY_EASY 2 SECONDS
#define SKILL_TASK_EASY 3 SECONDS
#define SKILL_TASK_AVERAGE 5 SECONDS
#define SKILL_TASK_TOUGH 8 SECONDS
#define SKILL_TASK_DIFFICULT 10 SECONDS
#define SKILL_TASK_CHALLENGING 15 SECONDS
#define SKILL_TASK_FORMIDABLE 20 SECONDS
#define HELP_OTHER_TIME 20 SECONDS

#define SKILL_LEVEL_MIN 0
#define SKILL_LEVEL_HUMAN_MAX 4
#define SKILL_LEVEL_MAX 5

// all skill levels, based on skill can be named differently depending on custom_ranks
#define SKILL_LEVEL_NONE 0
#define SKILL_LEVEL_NOVICE 1
#define SKILL_LEVEL_TRAINED 2
#define SKILL_LEVEL_PRO 3
#define SKILL_LEVEL_MASTER 4
#define SKILL_LEVEL_ROBUST 5
