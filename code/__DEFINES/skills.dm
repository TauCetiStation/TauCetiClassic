//skills defines

//ripley and odyssey
#define SKILL_CIV_MECH "civ_mech"
#define SKILL_CIV_MECH_DEFAULT -2 //civilians
#define SKILL_CIV_MECH_NOVICE -1 // 
#define SKILL_CIV_MECH_TRAINED 0 //  engineer, medical intern, scientist, medical doctor
#define SKILL_CIV_MECH_PRO 1 // cargo techincian, recycler, robotech, paramedic, mecha operator
#define SKILL_CIV_MECH_MASTER 2 // RD, miner, QM, CE, CMO
//combat_mech
#define SKILL_COMBAT_MECH "combat_mech"
#define SKILL_COMBAT_MECH_UNTRAINED -1
#define SKILL_COMBAT_MECH_NOVICE 0	// scientist, engineer, mecha operator
#define SKILL_COMBAT_MECH_PRO 1  //nuclear,  HoS, RD, security, robotech

//police -30% handcuffs time for each level, tasers, flashes, stunbatons
#define SKILL_POLICE "police"
#define SKILL_POLICE_UNTRAINED 0 //civilians
#define SKILL_POLICE_TRAINED 1 // heads of staff
#define SKILL_POLICE_PRO 2 // security


//firearms
#define SKILL_FIREARMS "firearms"
#define SKILL_FIREARMS_UNTRAINED 0	//civilian
#define SKILL_FIREARMS_TRAINED 1	// less recoil from firearms, usage of mines and c4
#define SKILL_FIREARMS_PRO 2	   // security, nuclear, ERT



//melee_weapons skill
//buff to melee weapon attack damage(+20% dmg per level)
#define SKILL_MELEE "melee"
#define SKILL_MELEE_WEAK -1 
#define SKILL_MELEE_DEFAULT 0 //civilian, 
#define SKILL_MELEE_TRAINED 1 //cook, botanist, atmospheric techician
#define SKILL_MELEE_MASTER 2  //nuclear, СБ


// engineer skill
#define SKILL_ENGINEERING "engineering"
#define SKILL_ENGINEERING_DEFAULT 0  
#define SKILL_ENGINEERING_NOVICE 1	//  hacking
#define SKILL_ENGINEERING_TRAINED 2 //   techincal assistant, atmospheric technician
#define SKILL_ENGINEERING_PRO 3	//  bubble shield generators, singularity computer ,engineer
#define SKILL_ENGINEERING_MASTER 4	//   Telecomms, CE, RD


//atmospheric skill ATMOS
#define SKILL_ATMOS "atmospherics"
#define SKILL_ATMOS_DEFAULT 0  
#define SKILL_ATMOS_TRAINED 1	//scientist
#define SKILL_ATMOS_PRO 2	//engineer, RD
#define SKILL_ATMOS_MASTER 3	//CE, atmospheric techincian


//construction
#define SKILL_CONSTRUCTION "construction"
#define SKILL_CONSTRUCTION_DEFAULT 0
#define SKILL_CONSTRUCTION_NOVICE 1	// tables, glass, girder
#define SKILL_CONSTRUCTION_TRAINED 2  //walls, reinforced glass, RCD usage(scientist, robotech)  
#define SKILL_CONSTRUCTION_ADVANCED 3	//computer, machine frames,  RD, engineer, reinforced walls
#define SKILL_CONSTRUCTION_MASTER 4	// CE - AI core


//chemistry
#define SKILL_CHEMISTRY "chemistry"
#define SKILL_CHEMISTRY_UNTRAINED 0
#define SKILL_CHEMISTRY_PRACTICED 1 // intern, scientist, botanist
#define SKILL_CHEMISTRY_COMPETENT 2 // medical doctor, surgeon, RD
#define SKILL_CHEMISTRY_EXPERT 3 // chemist, CMO

//research
#define SKILL_RESEARCH "research"
#define SKILL_RESEARCH_DEFAULT 0
#define SKILL_RESEARCH_TRAINED 1 
#define SKILL_RESEARCH_PROFESSIONAL 2 //  slime console, xenoarch consoles
#define SKILL_RESEARCH_EXPERT 4 // AI creation and law modification, telescience console



//medical
#define SKILL_MEDICAL "medical"
#define SKILL_MEDICAL_UNTRAINED 0
#define SKILL_MEDICAL_NOVICE 1 
#define SKILL_MEDICAL_PRACTICED 2 
#define SKILL_MEDICAL_COMPETENT 3 //intern
#define SKILL_MEDICAL_EXPERT 4 //paramedic, surgeon
#define SKILL_MEDICAL_MASTER 5 //CMO, medical doctor
//higher levels means faster syringe use and better defibrillation

//surgery
#define SKILL_SURGERY "surgery"
#define SKILL_SURGERY_DEFAULT 0 //untrained, really slow
#define SKILL_SURGERY_AMATEUR 1 //scientist, intern, cook
#define SKILL_SURGERY_TRAINED 2 //  robotech, paramedic
#define SKILL_SURGERY_PROFESSIONAL 3 //medical doctor, RD
#define SKILL_SURGERY_EXPERT 4 //CMO surgeon
//higher levels means faster surgery.

//usage of auth devices, access modification, quest passes, easier paperwork
#define SKILL_COMMAND "command"
#define SKILL_COMMAND_DEFAULT 0 //Anyone
#define SKILL_COMMAND_BEGINNER 1 // officers, psychatrist, lawyer - easier paperwork, quest passes
#define SKILL_COMMAND_TRAINED 2 // internal affair, QM -   auth devices, access modification
#define SKILL_COMMAND_EXPERT 3 // heads, cult leaders,  gang leaders, ERT  - buffs for allies
#define SKILL_COMMAND_MASTER 4 // captain, nuclear and strike team leaders, ERT leader


#define SKILL_TASK_TRIVIAL 10
#define SKILL_TASK_VERY_EASY 20
#define SKILL_TASK_EASY 30
#define SKILL_TASK_AVERAGE 50
#define SKILL_TASK_TOUGH 80
#define SKILL_TASK_DIFFICULT 100
#define SKILL_TASK_CHALLENGING 150
#define SKILL_TASK_FORMIDABLE 200