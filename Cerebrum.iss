#include objects/cBase.iss
#include objects/cEvents.iss
#include objects/cMapper.iss
#include objects/cMount.iss
#include objects/cNavigator.iss
#include objects/cBot.iss
#include objects/cConsumable.iss
#include objects/cTradeskills.iss
#include objects/cConfig.iss
#include objects/cInventory.iss
#include objects/cActionPlayer.iss
#include objects/cLocation.iss
#include objects/cGrind.iss
#include objects/cGUI.iss
#include objects/cTargeting.iss
#include objects/cToon.iss
#include objects/cTalentTree.iss
#include objects/cBlacklist.iss
#include objects/cPOI.iss
#include routines/${Me.Class}.iss
#include objects/cOBDB.iss
#include objects/cState.iss
#include objects/cAutoequip.iss
#include objects/cActionSlot.iss
#include objects/cHuman.iss
#include objects/cMapEditor.iss
#include objects/cFlightPlan.iss
#include objects/cFlee.iss
#include objects/cParty.iss
#include objects/cQuest.iss

function main()
{
	declarevariable Config cConfig script
	declarevariable GUI cGUI script
	declarevariable Events cEvents script
	declarevariable Mapper cMapper script
	declarevariable Navigator cNavigator script
	declarevariable Bot cBot script
	declarevariable Consumable cConsumable script
	declarevariable Tradeskills cTradeskills script
	declarevariable Inventory cInventory script
	declarevariable ActionPlayer cActionPlayer script
	declarevariable Grind cGrind script
	declarevariable Toon cToon script
	declarevariable Class cClass script
	declarevariable Location cLocation script
	declarevariable Targeting cTargeting script
	declarevariable TalentTree cTalentTreeHandler script
	declarevariable CBDB cBDB script
	declarevariable GlobalBlacklist cBlacklist script
	declarevariable POI cPOI script
	declarevariable Mount cMount script
	declarevariable State cState script
	declarevariable Autoequip cAutoequip script
	declarevariable ActionSlot cActionSlot script
	declarevariable Human cHuman script
	declarevariable MapEditor cMapEditor script
	declarevariable FlightPlan cFlightPlan script
	declarevariable Flee cFlee script
	declarevariable Avoidance cAvoid script
	declarevariable Party cParty script
	declarevariable RCore RCore script
	declarevariable Quest cQuest script
	declarevariable Play cPlay script
	declarevariable Record cRecord script
	declarevariable Questgiver cQuestgiver script

	call Bot.Start
}

function atexit()
{
		ActionPlayer:StatsLog
		UI -unload "${Script.CurrentDirectory}/Interface/CerebrumRadar.xml"
		UI -unload "${Script.CurrentDirectory}/gui/gui.xml"
		UI -unload "${Script.CurrentDirectory}/routines/${Me.Class}.xml"
		UI -unload "Interface/CerebrumSkin/CerebrumSkin.xml"	
}
