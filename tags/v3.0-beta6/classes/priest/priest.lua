------------------------------------------------------------------------------------------------------
-- Local variables
------------------------------------------------------------------------------------------------------
local Cryolysis3 = Cryolysis3;
local module = Cryolysis3:NewModule("PRIEST", Cryolysis3.ModuleCore, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Cryolysis3");


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
		"ClassSpell.Priest.Discipline",
		"ClassSpell.Priest.Holy",
		"ClassSpell.Priest.Shadow Magic"
	};
	
	-- Create spellList
	Cryolysis3:PopulateSpellList(t);
	
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
		-- Prayer reagents
		["Sacred Candle"]	= 17029,
		["Holy Candle"]		= 17028,
	};
	

	-- Begin checking Prayer of Fortitude
	if (Cryolysis3:HasSpell(25392) or Cryolysis3:HasSpell(21564)) then
		-- Rank 3 and Rank 2 overrides Rank 1
		if (Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Sacred Candle"])] == nil) then
			-- Default Sacred Candle restock amount
			Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Sacred Candle"])] = 20;
		end
		
		-- Add this to our list of restockable reagents
		Cryolysis3.Private.classReagents["Sacred Candle"] = reagentList["Sacred Candle"];
		
		-- We're in need of reagents
		Cryolysis3.Private.hasReagents = true;
		
	elseif (Cryolysis3:HasSpell(21562)) then
		if (Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Holy Candle"])] == nil) then
			-- Default Holy Candle restock amount
			Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Holy Candle"])] = 20;
		end
		
		-- Add this to our list of restockable reagents
		Cryolysis3.Private.classReagents["Holy Candle"] = reagentList["Holy Candle"];

		-- We're in need of reagents
		Cryolysis3.Private.hasReagents = true;
	end
	
	-- Begin checking Prayer of Shadow Protection
	if (Cryolysis3:HasSpell(27683) or Cryolysis3:HasSpell(39374)) then
		if (Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Sacred Candle"])] == nil) then
			-- Default Sacred Candle restock amount
			Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Sacred Candle"])] = 20;
		end
		
		-- Add this to our list of restockable reagents
		Cryolysis3.Private.classReagents["Sacred Candle"] = reagentList["Sacred Candle"];
		
		-- We're in need of reagents
		Cryolysis3.Private.hasReagents = true;
	end
	
	-- Begin checking Prayer of Spirit
	if (Cryolysis3:HasSpell(27681) or Cryolysis3:HasSpell(32999)) then
		if (Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Sacred Candle"])] == nil) then
			-- Default Sacred Candle restock amount
			Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Sacred Candle"])] = 20;
		end
		
		-- Add this to our list of restockable reagents
		Cryolysis3.Private.classReagents["Sacred Candle"] = reagentList["Sacred Candle"];
		
		-- We're in need of reagents
		Cryolysis3.Private.hasReagents = true;
	end
end

------------------------------------------------------------------------------------------------------
-- Function for creating all the buttons used by this class
------------------------------------------------------------------------------------------------------
function module:CreateButtons()
	local showBuffMenu = 
		Cryolysis3:HasSpell(1243)	-- Power Word: Fortitude
		or Cryolysis3:HasSpell(588)	-- Inner Fire

	if (showBuffMenu) then
		-- We have a buff, create and set up the buff menu button
		Cryolysis3:CreateButton("BuffButton", UIParent, "Interface\\Icons\\Spell_Holy_PrayerOfFortitude")
	end
end

------------------------------------------------------------------------------------------------------
-- Register for our needed events
------------------------------------------------------------------------------------------------------
function module:RegisterClassEvents()
	-- Events relevant to this class
	module:RegisterEvent("UNIT_MANA");
end

------------------------------------------------------------------------------------------------------
-- We all loves the manas!
------------------------------------------------------------------------------------------------------
function module:UNIT_MANA(event, unitId)
	if (tonumber(Cryolysis3.db.char.outerSphere) == 3 and unitId == "player") then
		Cryolysis3:UpdateSphere("outerSphere");
	end
end