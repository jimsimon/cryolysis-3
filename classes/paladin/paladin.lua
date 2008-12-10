------------------------------------------------------------------------------------------------------
-- Local variables
------------------------------------------------------------------------------------------------------
local Cryolysis3 = Cryolysis3;
local module = Cryolysis3:NewModule("PALADIN", Cryolysis3.ModuleCore, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Cryolysis3");


------------------------------------------------------------------------------------------------------
-- Update sphere
------------------------------------------------------------------------------------------------------
local function UpdateSphereTooltip()
	Cryolysis3.Private.tooltips["Sphere"][2] = select(1, GetItemInfo(17033))..": "..(GetItemCount(17033) or 0);
	Cryolysis3.Private.tooltips["Sphere"][3] = select(1, GetItemInfo(21177))..": "..(GetItemCount(21177) or 0);
end


------------------------------------------------------------------------------------------------------
-- Function to generate options
------------------------------------------------------------------------------------------------------
function module:CreateOptions()
	-- The option to shut off this module
	local options = {
	}
	
	return options;
end

------------------------------------------------------------------------------------------------------
-- Function to generate configuration options
------------------------------------------------------------------------------------------------------
function module:CreateConfigOptions()
	-- The various configurations this module produces
	local configOptions = {
		
		type = "group",
		name = gsub(UnitClass("player"), "^.", function(s) return s:upper() end),
		desc = L["Adjust various options for this module."],
		args = {

		}
	}
		
	return configOptions;
end

------------------------------------------------------------------------------------------------------
-- What happens when the module is initialised
------------------------------------------------------------------------------------------------------
function module:OnInitialize()
	-- Register our options with the global array
	--module:RegisterOptions(options);
	
	if select(2,UnitClass("player")) == "PALADIN" then
		Cryolysis3.Private.cacheList = {21177, 17033}
	end
	
end

------------------------------------------------------------------------------------------------------
-- What happens when the module is enabled
------------------------------------------------------------------------------------------------------
function module:OnEnable()
	-- And we're live!
	
	-- Create a list of the paladin's spells to be cached
	Cryolysis3.spellList = {};
	
	-- Local table of the LPT sets we will be using
	local t = {
		"ClassSpell.Paladin.Holy",
		"ClassSpell.Paladin.Protection",
		"ClassSpell.Paladin.Retribution"
	};
	
	-- Create spellList
	Cryolysis3:PopulateSpellList(t);
	
	-- Add talent spellds
	table.insert(Cryolysis3.spellList, 31935); -- Avenger's Shield
	table.insert(Cryolysis3.spellList, 53563); -- Bacon of Light
	table.insert(Cryolysis3.spellList, 20217); -- Blessing of Kings
	table.insert(Cryolysis3.spellList, 20911); -- Blessing of Sanctuary
	table.insert(Cryolysis3.spellList, 35395); -- Crusader Strike
	table.insert(Cryolysis3.spellList, 20216); -- Divine Favor
	table.insert(Cryolysis3.spellList, 31842); -- Divine Illumination
	table.insert(Cryolysis3.spellList, 53385); -- Divine Storm
	table.insert(Cryolysis3.spellList, 53595); -- Hammer of the Righteous
	table.insert(Cryolysis3.spellList, 20925); -- Holy Shield
	table.insert(Cryolysis3.spellList, 20473); -- Holy Shock
	table.insert(Cryolysis3.spellList, 20066); -- Repentance
	table.insert(Cryolysis3.spellList, 20375); -- Seal of Command
	
	-- Insert our config options
	module:RegisterConfigOptions(module:CreateConfigOptions())
	
	-- Register our wanted events
	module:RegisterClassEvents();
end

------------------------------------------------------------------------------------------------------
-- What happens when the module is disabled
------------------------------------------------------------------------------------------------------
function module:OnDisable()

end

------------------------------------------------------------------------------------------------------
-- Function for creating a reagent list
------------------------------------------------------------------------------------------------------
function module:CreateReagentList()
	local reagentList = {
		-- Greater Blessing reagents
		["Symbol of Kings"]		= 21177,
		
		-- Divine Intervention reagents
		["Symbol of Divinity"]		= 17033,
	}
	
	-- Check for Greater Blessings
	if (Cryolysis3:HasSpell("Greater Blessing")) then
		if (Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Symbol of Kings"])] == nil) then
			-- Default Symbol of Kings restock amount
			Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Symbol of Kings"])] = 100;
		end
		
		-- Add this to our list of restockable reagents
		Cryolysis3.Private.classReagents["Symbol of Kings"] = reagentList["Symbol of Kings"];

		-- We're in need of reagents
		Cryolysis3.Private.hasReagents = true;
	end
	
	-- Check for Divine Intervention
	if (Cryolysis3:HasSpell(19752)) then
		if (Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Symbol of Divinity"])] == nil) then
			-- Default Symbol of Divinity restock amount
			Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Symbol of Divinity"])] = 5;
		end
		
		-- Add this to our list of restockable reagents
		Cryolysis3.Private.classReagents["Symbol of Divinity"] = reagentList["Symbol of Divinity"];

		-- We're in need of reagents
		Cryolysis3.Private.hasReagents = true;
	end
end

------------------------------------------------------------------------------------------------------
-- Function for creating all the buttons used by this class
------------------------------------------------------------------------------------------------------
function module:CreateButtons()
	-- Start tooltip data
	Cryolysis3.Private.tooltips["BlessingButton"]	= {};
	Cryolysis3.Private.tooltips["SealButton"]	= {};
	
	-- Start adding tooltip data
	table.insert(Cryolysis3.Private.tooltips["BlessingButton"],	L["Blessings Menu"]);
	table.insert(Cryolysis3.Private.tooltips["BlessingButton"],	L["Click to open menu."]);
	table.insert(Cryolysis3.Private.tooltips["SealButton"],		L["Seal Menu"]);
	table.insert(Cryolysis3.Private.tooltips["SealButton"],		L["Click to open menu."]);
	
	local tooltip = {};
	local hasSpell = false;
	
	if (Cryolysis3:HasSpell(19740) or Cryolysis3:HasSpell(25782)) then
		-- Blessing of Might/Greater Blessing of Might
		tooltip = Cryolysis3:PrepareButton("BlessingButton", "Might", "spell", GetSpellInfo(19740), 19740, 25782);
		Cryolysis3:AddMenuItem("BlessingButton", "Might", select(3, GetSpellInfo(19740)), tooltip);
	end
	
	if (Cryolysis3:HasSpell(19742) or Cryolysis3:HasSpell(25894)) then
		-- Blessing of Wisdom/Greater Blessing of Wisdom
		tooltip = Cryolysis3:PrepareButton("BlessingButton", "Wisdom", "spell", GetSpellInfo(19742), 19742, 25894);
		Cryolysis3:AddMenuItem("BlessingButton", "Wisdom", select(3, GetSpellInfo(19742)), tooltip);
	end
	
	if (Cryolysis3:HasSpell(20217) or Cryolysis3:HasSpell(25898)) then
		-- Blessing of Kings/Greater Blessing of Kings
		tooltip = Cryolysis3:PrepareButton("BlessingButton", "Kings", "spell", GetSpellInfo(20217), 20217, 25898);
		Cryolysis3:AddMenuItem("BlessingButton", "Kings", select(3, GetSpellInfo(20217)), tooltip);
	end
	
	if (Cryolysis3:HasSpell(20911) or Cryolysis3:HasSpell(25899)) then
		-- Blessing of Sanctuary/Greater Blessing of Sanctuary
		tooltip = Cryolysis3:PrepareButton("BlessingButton", "Sanctuary", "spell", GetSpellInfo(20911), 20911, 25899);
		Cryolysis3:AddMenuItem("BlessingButton", "Sanctuary", select(3, GetSpellInfo(20911)), tooltip);
	end
	
	-- Seal of Righteousness
	tooltip = Cryolysis3:PrepareButton("SealButton", "Righteousness", "spell", GetSpellInfo(21084), 21084);
	Cryolysis3:AddMenuItem("SealButton", "Righteousness", select(3, GetSpellInfo(21084)), tooltip);
	
	-- Create Seal button
	Cryolysis3:CreateButton("SealButton",	UIParent,	"Interface\\Icons\\Spell_Holy_HolySmite", "menuButton");

	if (Cryolysis3:HasSpell("Blessing")) then
		-- We have a blessing of some description
		Cryolysis3:CreateButton("BlessingButton",	UIParent,	"Interface\\Icons\\Spell_Shaman_BlessingOfEternals", "menuButton");
	end

	-- Update Sphere tooltip
	UpdateSphereTooltip();
end

------------------------------------------------------------------------------------------------------
-- Register for our needed events
------------------------------------------------------------------------------------------------------
function module:RegisterClassEvents()
	-- Events relevant to this class
	module:RegisterEvent("UNIT_MANA");
	module:RegisterEvent("BAG_UPDATE");
end

------------------------------------------------------------------------------------------------------
-- We all loves the manas!
------------------------------------------------------------------------------------------------------
function module:UNIT_MANA(event, unitId)
	if (tonumber(Cryolysis3.db.char.outerSphere) == 3 and unitId == "player") then
		Cryolysis3:UpdateSphere("outerSphere");
	end
end

------------------------------------------------------------------------------------------------------
-- Whenever something changes in our bags
------------------------------------------------------------------------------------------------------
function module:BAG_UPDATE()
	-- Update Sphere tooltip
	UpdateSphereTooltip();
end