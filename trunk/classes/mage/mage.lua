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
			evocationbutton = {
				type = "group",
				name = GetSpellInfo(12051),
				desc = L["Adjust various settings for this button."],
				order = 30,
				args = {
					hideevocationbutton = {
						type = "toggle",
						name = L["Hide"],
						desc = L["Show or hide this button."],
						width = "full",
						get = function(info) return Cryolysis3.db.char.hidden["EvocationButton"] end,
						set = function(info, v)
							Cryolysis3.db.char.hidden["EvocationButton"] = v;
							Cryolysis3:UpdateVisibility();
						end,
						order = 10
					},
					moveevocationbutton = {
						type = "execute",
						name = L["Move Clockwise"],
						desc = L["Move this button one position clockwise."],
						func = function() Cryolysis3:IncrementButton("EvocationButton"); end,
						order = 20
					},
					scaleevocationbutton = {
						type = "range",
						name = L["Scale"],
						desc = L["Scale the size of this custom button."],
						width = "full",
						get = function(info) return Cryolysis3.db.char.scale.button["EvocationButton"]; end,
						set = function(info, v) 
							Cryolysis3.db.char.scale.button["EvocationButton"] = v;
							--Cryolysis3:UpdateAllButtonPositions()
							--Cryolysis3:UpdateAllButtonSizes()
						end,
						min = .5,
						max = 2,
						step = .1,
						isPercent = true,
						order = 70
					}
				}
			},
			buffbutton = {
				type = "group",
				name = L["Buff Menu"],
				desc = L["Adjust various settings for this button."],
				order = 30,
				args = {
					hidebuffbutton = {
						type = "toggle",
						name = L["Hide"],
						desc = L["Show or hide this button."],
						width = "full",
						get = function(info) return Cryolysis3.db.char.hidden["BuffButton"] end,
						set = function(info, v)
							Cryolysis3.db.char.hidden["BuffButton"] = v;
							Cryolysis3:UpdateVisibility();
						end,
						order = 10
					},
					movebuffbutton = {
						type = "execute",
						name = L["Move Clockwise"],
						desc = L["Move this button one position clockwise."],
						func = function() Cryolysis3:IncrementButton("BuffButton"); end,
						order = 20
					},
					scalebuffbutton = {
						type = "range",
						name = L["Scale"],
						desc = L["Scale the size of this custom button."],
						width = "full",
						get = function(info) return Cryolysis3.db.char.scale.button["BuffButton"]; end,
						set = function(info, v) 
							Cryolysis3.db.char.scale.button["BuffButton"] = v;
							--Cryolysis3:UpdateAllButtonPositions()
							--Cryolysis3:UpdateAllButtonSizes()
						end,
						min = .5,
						max = 2,
						step = .1,
						isPercent = true,
						order = 70
					}
				}
			},
			portalbutton = {
				type = "group",
				name = L["Teleport/Portal"],
				desc = L["Adjust various settings for this button."],
				order = 30,
				args = {
					hideportalbutton = {
						type = "toggle",
						name = L["Hide"],
						desc = L["Show or hide this button."],
						width = "full",
						get = function(info) return Cryolysis3.db.char.hidden["PortalButton"] end,
						set = function(info, v)
							Cryolysis3.db.char.hidden["PortalButton"] = v;
							Cryolysis3:UpdateVisibility();
						end,
						order = 10
					},
					moveportalbutton = {
						type = "execute",
						name = L["Move Clockwise"],
						desc = L["Move this button one position clockwise."],
						func = function() Cryolysis3:IncrementButton("PortalButton"); end,
						order = 20
					},
					scaleportalbutton = {
						type = "range",
						name = L["Scale"],
						desc = L["Scale the size of this custom button."],
						width = "full",
						get = function(info) return Cryolysis3.db.char.scale.button["PortalButton"]; end,
						set = function(info, v) 
							Cryolysis3.db.char.scale.button["PortalButton"] = v;
							--Cryolysis3:UpdateAllButtonPositions()
							--Cryolysis3:UpdateAllButtonSizes()
						end,
						min = .5,
						max = 2,
						step = .1,
						isPercent = true,
						order = 70
					}
				}
			},
			foodbutton = {
				type = "group",
				name = L["Food Button"],
				desc = L["Adjust various settings for this button."],
				order = 30,
				args = {
					hidefoodbutton = {
						type = "toggle",
						name = L["Hide"],
						desc = L["Show or hide this button."],
						width = "full",
						get = function(info) return Cryolysis3.db.char.hidden["FoodButton"] end,
						set = function(info, v)
							Cryolysis3.db.char.hidden["FoodButton"] = v;
							Cryolysis3:UpdateVisibility();
						end,
						order = 10
					},
					movefoodbutton = {
						type = "execute",
						name = L["Move Clockwise"],
						desc = L["Move this button one position clockwise."],
						func = function() Cryolysis3:IncrementButton("FoodButton"); end,
						order = 20
					},
					scalefoodbutton = {
						type = "range",
						name = L["Scale"],
						desc = L["Scale the size of this custom button."],
						width = "full",
						get = function(info) return Cryolysis3.db.char.scale.button["FoodButton"]; end,
						set = function(info, v) 
							Cryolysis3.db.char.scale.button["FoodButton"] = v;
							--Cryolysis3:UpdateAllButtonPositions()
							--Cryolysis3:UpdateAllButtonSizes()
						end,
						min = .5,
						max = 2,
						step = .1,
						isPercent = true,
						order = 70
					}
				}
			},
			waterbutton = {
				type = "group",
				name = L["Water Button"],
				desc = L["Adjust various settings for this button."],
				order = 30,
				args = {
					hidewaterbutton = {
						type = "toggle",
						name = L["Hide"],
						desc = L["Show or hide this button."],
						width = "full",
						get = function(info) return Cryolysis3.db.char.hidden["WaterButton"] end,
						set = function(info, v)
							Cryolysis3.db.char.hidden["WaterButton"] = v;
							Cryolysis3:UpdateVisibility();
						end,
						order = 10
					},
					movewaterbutton = {
						type = "execute",
						name = L["Move Clockwise"],
						desc = L["Move this button one position clockwise."],
						func = function() Cryolysis3:IncrementButton("WaterButton"); end,
						order = 20
					},
					scalewaterbutton = {
						type = "range",
						name = L["Scale"],
						desc = L["Scale the size of this custom button."],
						width = "full",
						get = function(info) return Cryolysis3.db.char.scale.button["WaterButton"]; end,
						set = function(info, v) 
							Cryolysis3.db.char.scale.button["WaterButton"] = v;
							--Cryolysis3:UpdateAllButtonPositions()
							--Cryolysis3:UpdateAllButtonSizes()
						end,
						min = .5,
						max = 2,
						step = .1,
						isPercent = true,
						order = 70
					}
				}
			},
			gembutton = {
				type = "group",
				name = L["Gem Button"],
				desc = L["Adjust various settings for this button."],
				order = 30,
				args = {
					hidegembutton = {
						type = "toggle",
						name = L["Hide"],
						desc = L["Show or hide this button."],
						width = "full",
						get = function(info) return Cryolysis3.db.char.hidden["GemButton"] end,
						set = function(info, v)
							Cryolysis3.db.char.hidden["GemButton"] = v;
							Cryolysis3:UpdateVisibility();
						end,
						order = 10
					},
					movegembutton = {
						type = "execute",
						name = L["Move Clockwise"],
						desc = L["Move this button one position clockwise."],
						func = function() Cryolysis3:IncrementButton("GemButton"); end,
						order = 20
					},
					scalegembutton = {
						type = "range",
						name = L["Scale"],
						desc = L["Scale the size of this custom button."],
						width = "full",
						get = function(info) return Cryolysis3.db.char.scale.button["GemButton"]; end,
						set = function(info, v) 
							Cryolysis3.db.char.scale.button["GemButton"] = v;
							--Cryolysis3:UpdateAllButtonPositions()
							--Cryolysis3:UpdateAllButtonSizes()
						end,
						min = .5,
						max = 2,
						step = .1,
						isPercent = true,
						order = 70
					}
				}
			},
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
	
	-- Lookup table for conjure spell id -> item id
	local foodLookupTable = {
		[33717]	= 22019,
		[28612]	= 22895,
		[10145]	= 8076,
		[10144]	= 8075,
		[6129]	= 1487,
		[990]	= 1114,
		[597]	= 1113,
		[587]	= 5349,
	};
	local waterLookupTable = {
		[27090]	= 22018,
		[37420]	= 30703,
		[10140]	= 8079,
		[10139]	= 8078,
		[10138]	= 8077,
		[6127]	= 3772,
		[5506]	= 2136,
		[5505]	= 2288,
		[5504]	= 5350,
	};
	local gemLookupTable = {
		[42985]	= 33312,
		[27101]	= 22044,
		[10054]	= 8008,
		[10053]	= 8007,
		[3552]	= 5513,
		[759]	= 5514,
	};

	if (foodID ~= nil) then
		Cryolysis3:CreateButton("FoodButton",	UIParent,	select(3, GetSpellInfo(foodID)));
		Cryolysis3.Private.tooltips["FoodButton"] = {};
		
		local foodName = GetItemInfo(foodLookupTable[foodID]);
		table.insert(Cryolysis3.Private.tooltips["FoodButton"],	foodName);
		table.insert(Cryolysis3.Private.tooltips["FoodButton"], string.format(L["%s click to %s: %s"], L["Left"],	L["use"],	foodName));
		table.insert(Cryolysis3.Private.tooltips["FoodButton"], string.format(L["%s click to %s: %s"], L["Right"],	L["cast"],	Cryolysis3.spellCache[foodID].name));
		
		-- Set button functions
		Cryolysis3.db.char.buttonFunctions["FoodButton"] = {};
		Cryolysis3.db.char.buttonTypes["FoodButton"] = "macrotext";
		Cryolysis3.db.char.buttonFunctions["FoodButton"].left = "/use "..foodName;
		Cryolysis3.db.char.buttonFunctions["FoodButton"].right = "/cast "..Cryolysis3.spellCache[foodID].name;
	
		if (Cryolysis3:HasSpell(43987)) then
			table.insert(Cryolysis3.Private.tooltips["FoodButton"], string.format(L["%s click to %s: %s"], L["Middle"],	L["cast"],	Cryolysis3.spellCache[43987].name));
			Cryolysis3.db.char.buttonFunctions["FoodButton"].middle = "/cast "..Cryolysis3.spellCache[43987].name;
		end
		
		Cryolysis3:UpdateAllButtonAttributes("FoodButton");
	end

	if (waterID ~= nil) then
		Cryolysis3:CreateButton("WaterButton",	UIParent,	select(3, GetSpellInfo(waterID)));
		Cryolysis3.Private.tooltips["WaterButton"] = {};
		
		local waterName = GetItemInfo(waterLookupTable[waterID]);
		table.insert(Cryolysis3.Private.tooltips["WaterButton"], Cryolysis3.spellCache[waterID].name);
		table.insert(Cryolysis3.Private.tooltips["WaterButton"], string.format(L["%s click to %s: %s"], L["Left"],	L["use"],	waterName));
		table.insert(Cryolysis3.Private.tooltips["WaterButton"], string.format(L["%s click to %s: %s"], L["Right"],	L["cast"],	Cryolysis3.spellCache[waterID].name));
		
		-- Set button functions
		Cryolysis3.db.char.buttonFunctions["WaterButton"] = {};
		Cryolysis3.db.char.buttonTypes["WaterButton"] = "macrotext";
		Cryolysis3.db.char.buttonFunctions["WaterButton"].left = "/use "..waterName;
		Cryolysis3.db.char.buttonFunctions["WaterButton"].right = "/cast "..Cryolysis3.spellCache[waterID].name;

		if (Cryolysis3:HasSpell(43987)) then
			table.insert(Cryolysis3.Private.tooltips["WaterButton"], string.format(L["%s click to %s: %s"], L["Middle"],	L["cast"],	Cryolysis3.spellCache[43987].name));
			Cryolysis3.db.char.buttonFunctions["WaterButton"].middle = "/cast "..Cryolysis3.spellCache[43987].name;
		end
		
		Cryolysis3:UpdateAllButtonAttributes("WaterButton");
	end

	if (gemID ~= nil) then
		Cryolysis3:CreateButton("GemButton",	UIParent,	select(3, GetSpellInfo(gemID)));
		Cryolysis3.Private.tooltips["GemButton"] = {};
		
		local gemName = GetItemInfo(gemLookupTable[gemID]);
		table.insert(Cryolysis3.Private.tooltips["GemButton"], Cryolysis3.spellCache[gemID].name);
		table.insert(Cryolysis3.Private.tooltips["GemButton"], string.format(L["%s click to %s: %s"], L["Left"],	L["use"],	gemName));
		table.insert(Cryolysis3.Private.tooltips["GemButton"], string.format(L["%s click to %s: %s"], L["Right"],	L["cast"],	Cryolysis3.spellCache[gemID].name));
		
		-- Set button functions
		Cryolysis3.db.char.buttonFunctions["GemButton"] = {};
		Cryolysis3.db.char.buttonTypes["GemButton"] = "macrotext";
		Cryolysis3.db.char.buttonFunctions["GemButton"].left = "/use "..gemName;
		Cryolysis3.db.char.buttonFunctions["GemButton"].right = "/cast "..Cryolysis3.spellCache[gemID].name;
		
		Cryolysis3:UpdateAllButtonAttributes("GemButton");
	end

	-- Add expand/withdraw code to our menus
	Cryolysis3:AddScript("BuffButton",	"menuButton",	"OnClick");
	Cryolysis3:AddScript("PortalButton",	"menuButton",	"OnClick");

	-- Start tooltip data
	Cryolysis3.Private.tooltips["BuffButton"] = {};
	Cryolysis3.Private.tooltips["PortalButton"] = {};
	
	-- Start adding tooltip data
	table.insert(Cryolysis3.Private.tooltips["BuffButton"],		L["Buff Menu"]);
	table.insert(Cryolysis3.Private.tooltips["BuffButton"],		L["Click to open menu."]);
	table.insert(Cryolysis3.Private.tooltips["PortalButton"],	L["Teleport/Portal"]);
	table.insert(Cryolysis3.Private.tooltips["PortalButton"],	L["Click to open menu."]);
	
	-- Start off with no last button
	Cryolysis3.lastButton = nil;
	local tooltip = {};

	-- Buff menu buttons
	if (Cryolysis3:HasSpell(168) or Cryolysis3:HasSpell(7302) or Cryolysis3:HasSpell(6117) or Cryolysis3:HasSpell(30482)) then
		-- (Frost/Ice)/Mage/Molten Armor
		local frostIce = 7302;
		if (Cryolysis3:HasSpell(168) and not Cryolysis3:HasSpell(7302)) then
			-- We have Frost Armor but not Ice Armor
			frostIce = 168;
		end
		tooltip = Cryolysis3:PrepareButton("BuffButton", "Armor", "spell", L["Armor"], frostIce, 6117, 30482);
		Cryolysis3:AddMenuItem("BuffButton", "Armor", select(3, GetSpellInfo(7302)), tooltip);
	end

	-- Intellect buttons
	if (Cryolysis3:HasSpell(1459) or Cryolysis3:HasSpell(23028)) then
		-- Arcane Intellect/Brilliance
		tooltip = Cryolysis3:PrepareButton("BuffButton", "Intellect", "spell", L["Intellect"], 1459, 23028);
		Cryolysis3:AddMenuItem("BuffButton", "Intellect", select(3, GetSpellInfo(1459)), tooltip);
	end

	-- Magic buttons
	if (Cryolysis3:HasSpell(604) or Cryolysis3:HasSpell(1008)) then
		-- Dampen/Amplify Magic
		tooltip = Cryolysis3:PrepareButton("BuffButton", "Magic", "spell", L["Magic"], 604, 1008);
		Cryolysis3:AddMenuItem("BuffButton", "Magic", select(3, GetSpellInfo(604)), tooltip);
	end

	-- Damage Shields buttons
	if (Cryolysis3:HasSpell(1463) or Cryolysis3:HasSpell(11426)) then
		-- Mana Shield/Ice Barrier
		tooltip = Cryolysis3:PrepareButton("BuffButton", "Shields", "spell", L["Damage Shields"], 1463, 11426);
		Cryolysis3:AddMenuItem("BuffButton", "Shields", select(3, GetSpellInfo(1463)), tooltip);
	end

	-- Wards buttons
	if (Cryolysis3:HasSpell(543) or Cryolysis3:HasSpell(6143)) then
		-- Fire/Frost Ward
		tooltip = Cryolysis3:PrepareButton("BuffButton", "Wards", "spell", L["Magical Wards"], 543, 6143);
		Cryolysis3:AddMenuItem("BuffButton", "Wards", select(3, GetSpellInfo(543)), tooltip);
	end

	-- Remove Curse buttons
	if (Cryolysis3:HasSpell(475)) then
		-- Remove Curse
		tooltip = Cryolysis3:PrepareButton("BuffButton", "Curse", "spell", 475, 475);
		Cryolysis3:AddMenuItem("BuffButton", "Curse", select(3, GetSpellInfo(475)), tooltip);
	end

	-- Slow Fall buttons
	if (Cryolysis3:HasSpell(130)) then
		-- Slow Fall
		tooltip = Cryolysis3:PrepareButton("BuffButton", "SlowFall", "spell", 130, 130);
		Cryolysis3:AddMenuItem("BuffButton", "SlowFall", select(3, GetSpellInfo(130)), tooltip);
	end

	-- menu defaults to closed
	Cryolysis3:OpenCloseMenu("BuffButton");

	-- Start off with no last button
	Cryolysis3.lastButton = nil;
	
	if (Cryolysis3.Private.englishFaction == "Alliance") then
		if (Cryolysis3:HasSpell(3562) or Cryolysis3:HasSpell(11416)) then
			-- Ironforge
			tooltip = Cryolysis3:PrepareButton("PortalButton", "Ironforge", "spell", 3562, 3562, 11416);
			Cryolysis3:AddMenuItem("PortalButton", "Ironforge", select(3, GetSpellInfo(3562)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(3561) or Cryolysis3:HasSpell(10059)) then
			-- Stormwind
			tooltip = Cryolysis3:PrepareButton("PortalButton", "Stormwind", "spell", 3561, 3561, 10059);
			Cryolysis3:AddMenuItem("PortalButton", "Stormwind", select(3, GetSpellInfo(3561)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(3565) or Cryolysis3:HasSpell(11419)) then
			-- Darnassus
			tooltip = Cryolysis3:PrepareButton("PortalButton", "Darnassus", "spell", 3565, 3565, 11419);
			Cryolysis3:AddMenuItem("PortalButton", "Darnassus", select(3, GetSpellInfo(3565)), tooltip);
		end

		if (Cryolysis3:HasSpell(32271) or Cryolysis3:HasSpell(32266)) then
			-- The Exodar
			tooltip = Cryolysis3:PrepareButton("PortalButton", "TheExodar", "spell", 32271, 32271, 32266);
			Cryolysis3:AddMenuItem("PortalButton", "TheExodar", select(3, GetSpellInfo(32271)), tooltip);
		end

		if (Cryolysis3:HasSpell(49359) or Cryolysis3:HasSpell(49360)) then
			-- Theramore
			tooltip = Cryolysis3:PrepareButton("PortalButton", "Theramore", "spell", 49359, 49359, 49360);
			Cryolysis3:AddMenuItem("PortalButton", "Theramore", select(3, GetSpellInfo(49359)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(33690) or Cryolysis3:HasSpell(33691)) then
			-- Shattrath
			tooltip = Cryolysis3:PrepareButton("PortalButton", "ShattrathCity", "spell", 33690, 33690, 33691);
			Cryolysis3:AddMenuItem("PortalButton", "ShattrathCity", select(3, GetSpellInfo(33690)), tooltip);
		end
	else
		-- Hoard
		if (Cryolysis3:HasSpell(3567) or Cryolysis3:HasSpell(11417)) then
			-- Orgrimmar
			tooltip = Cryolysis3:PrepareButton("PortalButton", "Orgrimmar", "spell", 3567, 3567, 11417);
			Cryolysis3:AddMenuItem("PortalButton", "Orgrimmar", select(3, GetSpellInfo(3567)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(3563) or Cryolysis3:HasSpell(11418)) then
			-- Undercity
			tooltip = Cryolysis3:PrepareButton("PortalButton", "Undercity", "spell", 3563, 3563, 11418);
			Cryolysis3:AddMenuItem("PortalButton", "Undercity", select(3, GetSpellInfo(3563)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(3566) or Cryolysis3:HasSpell(11420)) then
			-- Thunder Bluff
			tooltip = Cryolysis3:PrepareButton("PortalButton", "ThunderBluff", "spell", 3566, 3566, 11420);
			Cryolysis3:AddMenuItem("PortalButton", "ThunderBluff", select(3, GetSpellInfo(3566)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(32272) or Cryolysis3:HasSpell(32267)) then
			-- Silvermoon City
			tooltip = Cryolysis3:PrepareButton("PortalButton", "SilvermoonCity", "spell", 32272, 32272, 32267);
			Cryolysis3:AddMenuItem("PortalButton", "SilvermoonCity", select(3, GetSpellInfo(32272)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(49358) or Cryolysis3:HasSpell(49361)) then
			-- Stonard
			tooltip = Cryolysis3:PrepareButton("PortalButton", "Stonard", "spell", 49358, 49358, 49361);
			Cryolysis3:AddMenuItem("PortalButton", "Stonard", select(3, GetSpellInfo(49358)), tooltip);
		end
		
		if (Cryolysis3:HasSpell(35715) or Cryolysis3:HasSpell(35717)) then
			-- Shattrath
			tooltip = Cryolysis3:PrepareButton("PortalButton", "ShattrathCity", "spell", 35715, 35715, 35717);
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
	if (Cryolysis3.spellCache[12051] ~= nil) then
		if (name == Cryolysis3.spellCache[12051].name) then
			-- Evocation cooldown started
			handle = Cryolysis3:ScheduleRepeatingTimer(UpdateEvocation, 1);
		end
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