------------------------------------------------------------------------------------------------------
-- Local variables
------------------------------------------------------------------------------------------------------
local Cryolysis3 = Cryolysis3;
local L = LibStub("AceLocale-3.0"):GetLocale("Cryolysis3");


------------------------------------------------------------------------------------------------------
-- Function to find all mounts in our inventory
------------------------------------------------------------------------------------------------------
function Cryolysis3:DetectMounts(mountType)
	-- Make sure this isn't nil
	if (mountType == nil) then return; end

	local name, link, mountID;
	local mounts = {};
	local mountTable = LibStub("LibPeriodicTable-3.1"):GetSetTable("Misc.Mount."..mountType:gsub("%a", string.upper, 1));
	
	for k, v in pairs(mountTable) do
		if (GetItemCount(k) > 0) then
			-- We have this mount in our inventory, get mount info
			name, link = GetItemInfo(k);
			
			if (not Cryolysis3.db.char.silentMode) then
				-- Only print this if we're not in silent mode
				Cryolysis3:Print(L["Found Mount: "]..link);
			end

			if (Cryolysis3.db.char.chosenMount[mountType] == nil) then
				-- Default to this mount chosen
				Cryolysis3.db.char.chosenMount[mountType] = name;
			end

			-- Add it to our array of found mounts
			mounts[name] = name;
		end
	end
	
	name, link = nil;
	if (mountType == "normal") then
		if (Cryolysis3.className == "PALADIN") then
			if (Cryolysis3:HasSpell(23214)) then
				-- Summon Charger (Alliance) (100%)
				mountID = 23214;
			elseif (Cryolysis3:HasSpell(34767)) then
				-- Summon Charger (Horde) (100%)
				mountID = 34767;
			elseif (Cryolysis3:HasSpell(13819)) then
				-- Summon Warhorse (Alliance) (60%)
				mountID = 13819;
			elseif (Cryolysis3:HasSpell(34769)) then
				-- Summon Warhorse (Horde) (60%)
				mountID = 34769;
			end
		elseif (Cryolysis3.className == "WARLOCK") then
			-- Warlock shit goes here
			if (Cryolysis3:HasSpell(23161)) then
				-- Summon Dreadsteed (100%)
				mountID = 23161;
			elseif (Cryolysis3:HasSpell(5784)) then
				-- Summon Felsteed (60%)
				mountID = 5784;
			end
		end
	elseif (mountType == "flying") then
		-- Druid shit goes here
		if (Cryolysis3:HasSpell(40120)) then
			-- Swift Flight Form (280%)
			mountID = 40120;
		elseif (Cryolysis3:HasSpell(33943)) then
			-- Flight Form (60%)
			mountID = 33943;
		end
	end

	if (mountID ~= nil) then
		name = Cryolysis3.spellCache[mountID].name;
		link = GetSpellLink(mountID);
	end
	
	if (name ~= nil) then
		mounts[name] = name;
		if (not Cryolysis3.db.char.silentMode) then
			-- Only print this if we're not in silent mode
			Cryolysis3:Print(L["Found Mount: "]..link);
		end

		if (Cryolysis3.db.char.chosenMount[mountType] == nil) then
			Cryolysis3.db.char.chosenMount[mountType] = name;
		end
	end
	
	-- Finally add the found mounts array to the private variable
	Cryolysis3.Private.mounts[mountType] = mounts;
	mounts = nil;
end	

------------------------------------------------------------------------------------------------------
-- Function to find what mounts we carry/can summon
------------------------------------------------------------------------------------------------------
function Cryolysis3:FindMounts(hasLoaded)
	if (Cryolysis3.db.char.buttonFunctions.MountButton == nil) then
		-- Make sure this is a table
		Cryolysis3.db.char.buttonFunctions.MountButton = {};
	end
	
	-- There hsould be a shaman check here, they like Astral Recall more than HS.
	local hs = GetItemInfo(6948);	-- Hearthstone
	if (Cryolysis3.db.char.buttonFunctions["MountButton"].right == nil) then
		-- Set the default right button to the Hearthstone
		Cryolysis3.db.char.buttonFunctions["MountButton"].right = "/use "..hs;
	end
	
	if (hasLoaded == nil) then
		-- Create the mount button
		Cryolysis3:CreateButton("MountButton", UIParent);
		Cryolysis3.db.char.buttonTypes["MountButton"] = "macrotext";

		-- Set this tooltip to be dynamically generated
		Cryolysis3.Private.tooltips["MountButton"] = true;
	end

	-- Detect normal and flying mounts
	Cryolysis3:DetectMounts("normal");
	Cryolysis3:DetectMounts("flying");
	
	-- Shorthand variables
	local chosenNormal = Cryolysis3.db.char.chosenMount["normal"];
	local chosenFlying = Cryolysis3.db.char.chosenMount["flying"];
	
	if (Cryolysis3.Private.mounts["normal"][chosenNormal] == nil) then
		-- Our chosen normal no longer exists in bags
		Cryolysis3.db.char.chosenMount["normal"] = nil;
	end
	
	if (Cryolysis3.Private.mounts["flying"][chosenFlying] == nil) then
		-- Our chosen flying no longer exists in bags
		Cryolysis3.db.char.chosenMount["flying"] = nil;
	end
	
	-- Update the mount button macro
	Cryolysis3:UpdateMountButtonMacro();

	-- Update the mount attributes
	Cryolysis3:UpdateAllButtonAttributes("MountButton");
	
	-- We have to do it this way to support doing this when we change zones
	Cryolysis3:UpdateMountButtonTexture();
end

------------------------------------------------------------------------------------------------------
-- Function to find what mounts we carry/can summon
------------------------------------------------------------------------------------------------------
function Cryolysis3:UpdateMountButtonMacro()
	local macro = "";
	local hs = GetItemInfo(6948);

	if (Cryolysis3.db.char.chosenMount["normal"] == nil) then
		-- We have no normal mount
		if (Cryolysis3.db.char.chosenMount["flying"] == nil) then
			-- We have neither ground mount nor flying, just set this to use HS
			macro = macro.."/use "..hs;
		else
			-- We have no ground, but we do have a flying mount
			macro = macro.."/use [noflyable] "..hs.."; "..Cryolysis3.db.char.chosenMount["flying"];
		end
	else
		if (Cryolysis3.db.char.chosenMount["flying"] == nil) then
			-- We have only ground mount
			macro = macro.."/use "..Cryolysis3.db.char.chosenMount["normal"];
		else
			-- We have both ground and flying
			macro = macro.."/use [flyable] "..Cryolysis3.db.char.chosenMount["flying"].."; "..Cryolysis3.db.char.chosenMount["normal"];
		end
	end
	
	local MacroParameters = {
		"Cryo3",
		1,
		string.format("#showtooltip\n%s", macro),
		1
	};

	if (GetMacroIndexByName(Cryolysis3.Private.macroName) ~= 0) then
		EditMacro(Cryolysis3.Private.macroName, unpack(MacroParameters));
	elseif ((GetNumMacros()) < 18) then
		CreateMacro(unpack(MacroParameters));
	else
		Cryolysis3:Print("Too many macros exist, Cryolysis cannot create its macro");
		return false;
	end

	-- Now finally set left button to this macro
	Cryolysis3.db.char.buttonFunctions["MountButton"].left = macro;
end

------------------------------------------------------------------------------------------------------
-- Update the texture on the mount button
------------------------------------------------------------------------------------------------------
function Cryolysis3:UpdateMountButtonTexture()
	-- Get the texture and the icon object
	local texture = select(2, GetMacroInfo(GetMacroIndexByName(Cryolysis3.Private.macroName)));
	local t = getglobal("Cryolysis3MountButtonIcon");

	-- Set the texture
	t:SetTexture(texture);
end