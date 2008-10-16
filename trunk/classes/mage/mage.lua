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
	
	-- Check for highest rank of food
	local foodID = Cryolysis3:GetHighestRank({33717, 28612, 10145, 10144, 6129, 990, 597, 587});

	-- Check for highest rank of water
	local waterID = Cryolysis3:GetHighestRank({27090, 37420, 10140, 10139, 10138, 6127, 5506, 5505, 5504});

	-- Check for highest rank of gem
	local gemID = Cryolysis3:GetHighestRank({42985, 27101, 10054, 10053, 3552, 759});

	if (foodID ~= nil) then
		Cryolysis3:CreateButton("FoodButton",	UIParent,	select(3, GetSpellInfo(foodID)));
		Cryolysis3.Private.tooltips["FoodButton"] = {};
		
		table.insert(Cryolysis3.Private.tooltips["FoodButton"],	Cryolysis3.spellCache[foodID].name);
		table.insert(Cryolysis3.Private.tooltips["FoodButton"], string.format(L["%s click to %s: %s"], L["Left"],	L["use"],	Cryolysis3.spellCache[foodID].name));
		table.insert(Cryolysis3.Private.tooltips["FoodButton"], string.format(L["%s click to %s: %s"], L["Right"],	L["cast"],	Cryolysis3.spellCache[foodID].name));
		
		if (Cryolysis3:HasSpell(43987)) then
			table.insert(Cryolysis3.Private.tooltips["FoodButton"], string.format(L["%s click to %s: %s"], L["Middle"],	L["cast"],	Cryolysis3.spellCache[43987].name));
		end
	end

	if (waterID ~= nil) then
		Cryolysis3:CreateButton("WaterButton",	UIParent,	select(3, GetSpellInfo(waterID)));
		Cryolysis3.Private.tooltips["WaterButton"] = {};

		table.insert(Cryolysis3.Private.tooltips["WaterButton"], Cryolysis3.spellCache[waterID].name);
		table.insert(Cryolysis3.Private.tooltips["WaterButton"], string.format(L["%s click to %s: %s"], L["Left"],	L["use"],	Cryolysis3.spellCache[waterID].name));
		table.insert(Cryolysis3.Private.tooltips["WaterButton"], string.format(L["%s click to %s: %s"], L["Right"],	L["cast"],	Cryolysis3.spellCache[waterID].name));
		
		if (Cryolysis3:HasSpell(43987)) then
			table.insert(Cryolysis3.Private.tooltips["WaterButton"], string.format(L["%s click to %s: %s"], L["Middle"],	L["cast"],	Cryolysis3.spellCache[43987].name));
		end

	end

	if (gemID ~= nil) then
		Cryolysis3:CreateButton("GemButton",	UIParent,	select(3, GetSpellInfo(gemID)));
		Cryolysis3.Private.tooltips["GemButton"] = {};

		table.insert(Cryolysis3.Private.tooltips["GemButton"], Cryolysis3.spellCache[gemID].name);
		table.insert(Cryolysis3.Private.tooltips["GemButton"], string.format(L["%s click to %s: %s"], L["Left"],	L["use"],	Cryolysis3.spellCache[gemID].name));
		table.insert(Cryolysis3.Private.tooltips["GemButton"], string.format(L["%s click to %s: %s"], L["Right"],	L["cast"],	Cryolysis3.spellCache[gemID].name));
	end

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
	
	-- Start off with no last button
	Cryolysis3.lastButton = nil;
	local tooltip = {};

	-- Buff menu buttons
	if (Cryolysis3:HasSpell(7302) or Cryolysis3:HasSpell(6117) or Cryolysis3:HasSpell(30482)) then
		-- Ice/Mage/Molten Armor
		tooltip = {};
		table.insert(tooltip, L["Armor"]);
		
		if (Cryolysis3:HasSpell(7302)) then
			table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[7302].name));
		end
		
		if (Cryolysis3:HasSpell(6117)) then
			table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"],	L["cast"], Cryolysis3.spellCache[6117].name));
		end
		
		if (Cryolysis3:HasSpell(30482)) then
			table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Middle"],	L["cast"], Cryolysis3.spellCache[30482].name));
		end
		
		Cryolysis3:AddMenuItem("BuffButton", "Armor", select(3, GetSpellInfo(7302)), tooltip);
	end

	-- Intellect buttons
	if (Cryolysis3:HasSpell(1459) or Cryolysis3:HasSpell(23028)) then
		-- Arcane Intellect/Brilliance
		tooltip = {};
		table.insert(tooltip, L["Intellect"]);
		
		if (Cryolysis3:HasSpell(1459)) then
			table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[1459].name));
		end
		
		if (Cryolysis3:HasSpell(23028)) then
			table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"],	L["cast"], Cryolysis3.spellCache[23028].name));
		end
		Cryolysis3:AddMenuItem("BuffButton", "Intellect", select(3, GetSpellInfo(1459)), tooltip);
	end

	-- Magic buttons
	if (Cryolysis3:HasSpell(604) or Cryolysis3:HasSpell(1008)) then
		-- Dampen/Amplify Magic
		tooltip = {};
		table.insert(tooltip, L["Magic"]);
		
		if (Cryolysis3:HasSpell(604)) then
			table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[604].name));
		end
		
		if (Cryolysis3:HasSpell(1008)) then
			table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"],	L["cast"], Cryolysis3.spellCache[1008].name));
		end
		Cryolysis3:AddMenuItem("BuffButton", "Magic", select(3, GetSpellInfo(604)), tooltip);
	end

	-- Damage Shields buttons
	if (Cryolysis3:HasSpell(1463) or Cryolysis3:HasSpell(11426)) then
		-- Mana Shield/Ice Barrier
		tooltip = {};
		table.insert(tooltip, L["Armor"]);
		
		if (Cryolysis3:HasSpell(1463)) then
			table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[1463].name));
		end
		
		if (Cryolysis3:HasSpell(11426)) then
			table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"],	L["cast"], Cryolysis3.spellCache[11426].name));
		end
		Cryolysis3:AddMenuItem("BuffButton", "Shields", select(3, GetSpellInfo(1463)), tooltip);
	end

	-- Wards buttons
	if (Cryolysis3:HasSpell(543) or Cryolysis3:HasSpell(6143)) then
		-- Fire/Frost Ward
		tooltip = {};
		table.insert(tooltip, L["Magical Wards"]);
		
		if (Cryolysis3:HasSpell(543)) then
			table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[543].name));
		end
		
		if (Cryolysis3:HasSpell(6143)) then
			table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"],	L["cast"], Cryolysis3.spellCache[6143].name));
		end
		Cryolysis3:AddMenuItem("BuffButton", "Wards", select(3, GetSpellInfo(543)), tooltip);
	end

	-- Remove Curse buttons
	if (Cryolysis3:HasSpell(475)) then
		-- Remove Curse
		tooltip = {};
		table.insert(tooltip, Cryolysis3.spellCache[475].name);
		table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[475].name));
		Cryolysis3:AddMenuItem("BuffButton", "Curse", select(3, GetSpellInfo(475)), tooltip);
	end

	-- Slow Fall buttons
	if (Cryolysis3:HasSpell(130)) then
		-- Slow Fall
		tooltip = {};
		table.insert(tooltip, Cryolysis3.spellCache[130].name);
		table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[130].name));
		Cryolysis3:AddMenuItem("BuffButton", "SlowFall", select(3, GetSpellInfo(130)), tooltip);
	end

	-- menu defaults to closed
	Cryolysis3:OpenCloseMenu("BuffButton");

	-- Start off with no last button
	Cryolysis3.lastButton = nil;

	if (Cryolysis3.Private.englishFaction == "Alliance") then
		if (Cryolysis3:HasSpell(3562) or Cryolysis3:HasSpell(11416)) then
			-- Ironforge
			tooltip = {};
			table.insert(tooltip, Cryolysis3.spellCache[3562].name);
			
			if (Cryolysis3:HasSpell(3562)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[3562].name));
			end
			if (Cryolysis3:HasSpell(11416)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"], L["cast"], Cryolysis3.spellCache[11416].name));
			end
			Cryolysis3:AddMenuItem("PortalButton", "Ironforge", select(3, GetSpellInfo(3562)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(3561) or Cryolysis3:HasSpell(10059)) then
			-- Stormwind
			tooltip = {};
			table.insert(tooltip, Cryolysis3.spellCache[3561].name);
			
			if (Cryolysis3:HasSpell(3561)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[3561].name));
			end
			if (Cryolysis3:HasSpell(10059)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"], L["cast"], Cryolysis3.spellCache[10059].name));
			end
			Cryolysis3:AddMenuItem("PortalButton", "Stormwind", select(3, GetSpellInfo(3561)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(3565) or Cryolysis3:HasSpell(11419)) then
			-- Darnassus
			tooltip = {};
			table.insert(tooltip, Cryolysis3.spellCache[3565].name);
			
			if (Cryolysis3:HasSpell(3565)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[3565].name));
			end
			if (Cryolysis3:HasSpell(11416)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"], L["cast"], Cryolysis3.spellCache[11416].name));
			end
			Cryolysis3:AddMenuItem("PortalButton", "Darnassus", select(3, GetSpellInfo(3565)), tooltip);
		end

		if (Cryolysis3:HasSpell(32271) or Cryolysis3:HasSpell(32266)) then
			-- The Exodar
			tooltip = {};
			table.insert(tooltip, Cryolysis3.spellCache[32271].name);
			
			if (Cryolysis3:HasSpell(32271)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[32271].name));
			end
			if (Cryolysis3:HasSpell(32266)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"], L["cast"], Cryolysis3.spellCache[32266].name));
			end
			Cryolysis3:AddMenuItem("PortalButton", "TheExodar", select(3, GetSpellInfo(32271)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(33690) or Cryolysis3:HasSpell(33691)) then
			-- Shattrath
			tooltip = {};
			table.insert(tooltip, Cryolysis3.spellCache[33690].name);
			
			if (Cryolysis3:HasSpell(33690)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[33690].name));
			end
			if (Cryolysis3:HasSpell(33691)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"], L["cast"], Cryolysis3.spellCache[33691].name));
			end
			Cryolysis3:AddMenuItem("PortalButton", "ShattrathCity", select(3, GetSpellInfo(33690)), tooltip);
		end
	else
		-- Hoard
		if (Cryolysis3:HasSpell(3567) or Cryolysis3:HasSpell(11417)) then
			-- Orgrimmar
			tooltip = {};
			table.insert(tooltip, Cryolysis3.spellCache[3567].name);
			
			if (Cryolysis3:HasSpell(3567)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[3567].name));
			end
			if (Cryolysis3:HasSpell(11417)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"], L["cast"], Cryolysis3.spellCache[11417].name));
			end
			Cryolysis3:AddMenuItem("PortalButton", "Orgrimmar", select(3, GetSpellInfo(3567)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(3563) or Cryolysis3:HasSpell(11418)) then
			-- Undercity
			tooltip = {};
			table.insert(tooltip, Cryolysis3.spellCache[3563].name);
			
			if (Cryolysis3:HasSpell(3563)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[3563].name));
			end
			if (Cryolysis3:HasSpell(11418)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"], L["cast"], Cryolysis3.spellCache[11418].name));
			end
			Cryolysis3:AddMenuItem("PortalButton", "Undercity", select(3, GetSpellInfo(3563)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(3566) or Cryolysis3:HasSpell(11420)) then
			-- Thunder Bluff
			tooltip = {};
			table.insert(tooltip, Cryolysis3.spellCache[3566].name);
			
			if (Cryolysis3:HasSpell(3566)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[3566].name));
			end
			if (Cryolysis3:HasSpell(11420)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"], L["cast"], Cryolysis3.spellCache[11420].name));
			end
			Cryolysis3:AddMenuItem("PortalButton", "ThunderBluff", select(3, GetSpellInfo(3566)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(32272) or Cryolysis3:HasSpell(32267)) then
			-- Silvermoon City
			tooltip = {};
			table.insert(tooltip, Cryolysis3.spellCache[32272].name);
			
			if (Cryolysis3:HasSpell(32272)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[32272].name));
			end
			if (Cryolysis3:HasSpell(32267)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"], L["cast"], Cryolysis3.spellCache[32267].name));
			end
			Cryolysis3:AddMenuItem("PortalButton", "SilvermoonCity", select(3, GetSpellInfo(32272)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(35715) or Cryolysis3:HasSpell(35717)) then
			-- Shattrath
			tooltip = {};
			table.insert(tooltip, Cryolysis3.spellCache[35715].name);
			
			if (Cryolysis3:HasSpell(35715)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Left"],	L["cast"], Cryolysis3.spellCache[35715].name));
			end
			if (Cryolysis3:HasSpell(35717)) then
				table.insert(tooltip, string.format(L["%s click to %s: %s"], L["Right"], L["cast"], Cryolysis3.spellCache[35717].name));
			end
			Cryolysis3:AddMenuItem("PortalButton", "ShattrathCity", select(3, GetSpellInfo(35715)), tooltip);
		end
	end

	-- menu defaults to closed
	Cryolysis3:OpenCloseMenu("PortalButton");
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