------------------------------------------------------------------------------------------------------
-- Local variables
------------------------------------------------------------------------------------------------------
local Cryolysis3 = Cryolysis3;
local module = Cryolysis3:NewModule("MAGE", Cryolysis3.ModuleCore, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Cryolysis3");
local handle = nil;


------------------------------------------------------------------------------------------------------
-- Function to update the cooldown on Evocation
------------------------------------------------------------------------------------------------------
local function UpdateEvocation()
	-- Get cooldown data
	local start, duration, enabled = GetSpellCooldown(Cryolysis3.spellCache[12051].name);
		
	if duration == 0 then
		-- Spell is not on cooldown
		if (handle ~= nil) then
			-- We had a timer enabled, cancel it
			Cryolysis3:CancelTimer(handle);
			handle = nil;
		end

		-- Liven up the button
		Cryolysis3EvocationButton.texture:SetDesaturated(false);

		-- Remove text from button
		Cryolysis3EvocationButtonText:SetText("");

		-- Insert tooltip data saying its ready
		Cryolysis3.Private.tooltips["EvocationButton"][2] = L["Ready"];
	else
		-- Spell is on cooldown
		if (handle == nil) then
			handle = Cryolysis3:ScheduleRepeatingTimer(UpdateEvocation, 1);
		end
		
		-- Gray out the button
		Cryolysis3EvocationButton.texture:SetDesaturated(true);
		
		-- Get timer data
		local timeleft = Cryolysis3:TimerData(start, duration);
		
		if (timeleft.minutes > 0) then
			-- Insert tooltip data with minutes
			Cryolysis3.Private.tooltips["EvocationButton"][2] = timeleft.minutes.." "..L["minutes"]..", "..timeleft.seconds.." "..L["seconds"];
			
			-- Write remaining time on the button
			Cryolysis3EvocationButtonText:SetText(timeleft.minutes..":"..timeleft.seconds);
		else
			-- Insert tooltip data without minutes
			Cryolysis3.Private.tooltips["EvocationButton"][2] =  timeleft.seconds.." "..L["seconds"];
			
			-- Write remaining time on the button			
			Cryolysis3EvocationButtonText:SetText(timeleft.seconds);
		end
	end
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
		"ClassSpell.Mage.Arcane",
		"ClassSpell.Mage.Fire",
		"ClassSpell.Mage.Frost"
	};
	
	-- Create spellList
	Cryolysis3:PopulateSpellList(t);
	
	-- Insert our config options
	module:RegisterConfigOptions(module:CreateConfigOptions());
	
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
		-- Arcane Brilliance and Ritual of Refreshment reagents
		["Arcane Powder"]		= 17020,
		
		-- Teleport reagents
		["Rune of Teleportation"]	= 17031,
		
		-- Portal reagents
		["Rune of Portals"]		= 17032,
	}
	
	-- Check for Arcane Brilliance or Ritual of Refreshment
	if (Cryolysis3:HasSpell(23028) or Cryolysis3:HasSpell(43987)) then
		if (Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Arcane Powder"])] == nil) then
			-- Default Arcane Powder restock amount
			Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Arcane Powder"])] = 20;
		end
		
		-- Add this to our list of restockable reagents
		Cryolysis3.Private.classReagents["Arcane Powder"] = reagentList["Arcane Powder"];

		-- We're in need of reagents
		Cryolysis3.Private.hasReagents = true;
	end
	
	-- Check for Teleport
	if (Cryolysis3:HasSpell("Teleport")) then
		if (Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Rune of Teleportation"])] == nil) then
			-- Default Rune of Teleportation restock amount
			Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Rune of Teleportation"])] = 10;
		end
		
		-- Add this to our list of restockable reagents
		Cryolysis3.Private.classReagents["Rune of Teleportation"] = reagentList["Rune of Teleportation"];

		-- We're in need of reagents
		Cryolysis3.Private.hasReagents = true;
	end
	
	-- Check for Portal	
	if (Cryolysis3:HasSpell("Portal")) then
		if (Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Rune of Portals"])] == nil) then
			-- Default Rune of Portals restock amount
			Cryolysis3.db.char.RestockQuantity[GetItemInfo(reagentList["Rune of Portals"])] = 10;
		end
		
		-- Add this to our list of restockable reagents
		Cryolysis3.Private.classReagents["Rune of Portals"] = reagentList["Rune of Portals"];

		-- We're in need of reagents
		Cryolysis3.Private.hasReagents = true;
	end	
	
end

------------------------------------------------------------------------------------------------------
-- Function for creating all the buttons used by this class
------------------------------------------------------------------------------------------------------
function module:CreateButtons()
	if (Cryolysis3:HasSpell(12051)) then
		-- We has an Evocation, create and set up the button for it
		Cryolysis3:CreateButton("EvocationButton", UIParent, Cryolysis3.spellCache[12051].icon);
		
		-- Start tooltip data
		Cryolysis3.Private.tooltips["EvocationButton"] = {};

		-- Start adding tooltip data
		table.insert(Cryolysis3.Private.tooltips["EvocationButton"], Cryolysis3.spellCache[12051].name);
		
		-- Set Evocation button action
		Cryolysis3.db.char.buttonTypes["EvocationButton"] = "spell";
		Cryolysis3.db.char.buttonFunctions["EvocationButton"] = {};
		Cryolysis3.db.char.buttonFunctions["EvocationButton"]["left"] = 12051;

		-- Update all actions
		Cryolysis3:UpdateButton("EvocationButton", "left");

		-- Update Evocation cooldown
		UpdateEvocation();
	end
	
	-- Create our needed buttons
	Cryolysis3:CreateButton("BuffButton",	UIParent,	"Interface\\Icons\\INV_Staff_13");
	Cryolysis3:CreateButton("PortalButton", UIParent,	"Interface\\Icons\\Spell_Nature_AstralRecalGroup");
	
	-- Add expand/withdraw code to our menus
	Cryolysis3:AddScript("BuffButton",	"menuButton",	"OnClick");
	Cryolysis3:AddScript("PortalButton",	"menuButton",	"OnClick");

	-- Start tooltip data
	Cryolysis3.Private.tooltips["BuffButton"] = {};
	Cryolysis3.Private.tooltips["PortalButton"] = {};
	
	-- Start adding tooltip data
	table.insert(Cryolysis3.Private.tooltips["BuffButton"],		L["Buff Button"]);
	table.insert(Cryolysis3.Private.tooltips["BuffButton"],		L["Click to open menu."]);
	table.insert(Cryolysis3.Private.tooltips["PortalButton"],	L["Teleport and Portal Menu"]);
	table.insert(Cryolysis3.Private.tooltips["PortalButton"],	L["Click to open menu."]);
	
	local lastButton = nil;

	-- Buff menu buttons
	if (Cryolysis3:HasSpell(7302) or Cryolysis3:HasSpell(6117) or Cryolysis3:HasSpell(30482)) then
		-- Ice/Mage/Molten Armor
		if (lastButton == nil) then
			lastButton = Cryolysis3BuffButton;
		end
		
		-- Create the button
		Cryolysis3:CreateMenuItemButton("BuffButtonArmor",	lastButton,	Cryolysis3.spellCache[7302].icon, "BuffButton");
		
		-- Update last button added
		lastButton = Cryolysis3BuffButtonArmor;
	end

	-- Intellect buttons
	if (Cryolysis3:HasSpell(1459) or Cryolysis3:HasSpell(23028)) then
		-- Arcane Intellect/Brilliance
		if (lastButton == nil) then
			lastButton = Cryolysis3BuffButton;
		end
		
		-- Create the button
		Cryolysis3:CreateMenuItemButton("BuffButtonIntellect",	lastButton,	Cryolysis3.spellCache[1459].icon, "BuffButton");
		
		-- Update last button added
		lastButton = Cryolysis3BuffButtonIntellect;
	end

	-- menu defaults to closed
	Cryolysis3:OpenCloseMenu("BuffButton");
end

------------------------------------------------------------------------------------------------------
-- Register for our needed events
------------------------------------------------------------------------------------------------------
function module:RegisterClassEvents()
	-- Events relevant to this class
	module:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	module:RegisterEvent("BAG_UPDATE");
	module:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	module:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	module:RegisterEvent("UNIT_SPELLCAST_SENT");
	module:RegisterEvent("TRADE_SHOW");
	module:RegisterEvent("TRADE_CLOSED");
	module:RegisterEvent("UNIT_MANA");
end

------------------------------------------------------------------------------------------------------
-- Our big bad combat log, this will fire more than Rambo's collected movies
------------------------------------------------------------------------------------------------------
function module:COMBAT_LOG_EVENT_UNFILTERED()

end

------------------------------------------------------------------------------------------------------
-- Whenever something changes in our bags
------------------------------------------------------------------------------------------------------
function module:BAG_UPDATE()

end

------------------------------------------------------------------------------------------------------
-- Casting.... casting.... YUS! Done!
------------------------------------------------------------------------------------------------------
function module:UNIT_SPELLCAST_SUCCEEDED(info, unit, name, rank)
	if (name == Cryolysis3.spellCache[12051].name) then
		-- Evocation cooldown started
		handle = Cryolysis3:ScheduleRepeatingTimer(UpdateEvocation, 1);
	end
end

------------------------------------------------------------------------------------------------------
-- Dammit need Combustion off cooldown NOW!
------------------------------------------------------------------------------------------------------
function module:SPELL_UPDATE_COOLDOWN()

end

------------------------------------------------------------------------------------------------------
-- Thar she flies!
------------------------------------------------------------------------------------------------------
function module:UNIT_SPELLCAST_SENT()

end

------------------------------------------------------------------------------------------------------
-- No, I'm not a vending machine. "Watr plx" is also not a valid way of asking.
------------------------------------------------------------------------------------------------------
function module:TRADE_SHOW()

end

------------------------------------------------------------------------------------------------------
-- Get out of ma face!
------------------------------------------------------------------------------------------------------
function module:TRADE_CLOSED()

end

------------------------------------------------------------------------------------------------------
-- We all loves the manas!
------------------------------------------------------------------------------------------------------
function module:UNIT_MANA(event, unitId)
	if (tonumber(Cryolysis3.db.char.outerSphere) == 3 and unitId == "player") then
		Cryolysis3:UpdateSphere("outerSphere");
	end
end