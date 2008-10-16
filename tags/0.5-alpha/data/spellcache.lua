------------------------------------------------------------------------------------------------------
-- Local variables
------------------------------------------------------------------------------------------------------
local Cryolysis3 = Cryolysis3;


------------------------------------------------------------------------------------------------------
-- The spell cache object
------------------------------------------------------------------------------------------------------
Cryolysis3.spellCache = {

}


------------------------------------------------------------------------------------------------------
-- Function for grabbing all three sets from LPT
------------------------------------------------------------------------------------------------------
function Cryolysis3:PopulateSpellList(tbl)
	for x, y in pairs(tbl) do
		for k, v in pairs(LibStub("LibPeriodicTable-3.1"):GetSetTable(y)) do
			if (tonumber(k) ~= nil) then
				table.insert(Cryolysis3.spellList, -(tonumber(k)));
			end
		end
	end
end

------------------------------------------------------------------------------------------------------
-- Function for caching all the user's learned skills/spells
------------------------------------------------------------------------------------------------------
function Cryolysis3:CacheSpells()
	-- Temporary table to store spellbook spells
	local temp = {};

	-- Counter for the spellbook loop
	local i = 1;
	
	if (Cryolysis3.spellList == nil) then
		-- Ideally, some form of error to be printed to the screen here, as this shouldn't happen
		return false;
	end

	-- Loop through entire spellbook
	while (true) do
		-- Get spell name and rank from spell book
		local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL);
		if not spellName then
			do break; end
		end

		if (temp[spellName] == nil) then
			-- GetSpellInfo(spellname) will always return max rank
			temp[spellName..spellRank] = spellName..spellRank;
		end
		
		-- Finally increment the counter
		i = i + 1;
	end
	
	for i = 1, #(Cryolysis3.spellList), 1 do
		local name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(Cryolysis3.spellList[i]);
		if (name ~= nil) then
			if (temp[name..rank] ~= nil) then
				Cryolysis3.spellCache[Cryolysis3.spellList[i]] = {
					["name"] = name,
					["rank"] = rank,
					["icon"] = icon,
					["cost"] = cost,
					["isFunnel"] = isFunnel,
					["powerType"] = powerType,
					["castTime"] = castTime,
					["minRange"] = minRange,
					["maxRange"] = maxRange
				}
			end
		end
	end
	
	temp = nil;
	Cryolysis3.spellList = nil;
	collectgarbage("collect");
end

------------------------------------------------------------------------------------------------------
-- Function to check if we have a selected spell in our spellbook
--	If spellID is a string, it checks if we have a spell that matches this type of spell
------------------------------------------------------------------------------------------------------
function Cryolysis3:HasSpell(spellID)

	if (type(spellID) == "string") then
		-- List of spellIDs to check for
		local ID = {};

		if (spellID == "Teleport") then
			if (Cryolysis3.Private.englishFaction == "Alliance") then
				ID = {
					3562,	-- Ironforge
					3561,	-- Stormwind
					3565,	-- Darnassus
					32271,	-- The Exodar
					33690,	-- Shattrath City
				};
				
			else
				ID = {
					3567,	-- Orgrimmar
					3563,	-- Undercity
					3566,	-- Thunder Bluff
					32272,	-- Silvermoon City
					35715,	-- Shattrath City
				};
				
			end

			for i = 1, #(ID), 1 do
				if (Cryolysis3:HasSpell(ID[i])) then
					return true;
				end
			end

			return false;

		elseif (spellID == "Portal") then
			if (Cryolysis3.Private.englishFaction == "Alliance") then
				ID = {
					11416,	-- Ironforge
					10059,	-- Stormwind
					11416,	-- Darnassus
					32266,	-- The Exodar
					33691,	-- Shattrath City
				};
				
			else
				ID = {
					11417,	-- Orgrimmar
					11418,	-- Undercity
					11420,	-- Thunder Bluff
					32267,	-- Silvermoon City
					35717,	-- Shattrath City
				};
				
			end

			for i = 1, #(ID), 1 do
				if (Cryolysis3:HasSpell(ID[i])) then
					return true;
				end
			end
			return false;

		elseif (spellID == "Blessing") then
			-- fill this in when I'm less lazy

		elseif (spellID == "Greater Blessing") then
			ID = {
				25782, -- Greater Blessing of Might
				25894, -- Greater Blessing of Wisdom
				25898, -- Greater Blessing of Kings
				25890, -- Greater Blessing of Light
				25895, -- Greater Blessing of Salvation
				25899  -- Greater Blessing of Sanctuary
			};

			for i = 1, #(ID), 1 do
				if (Cryolysis3:HasSpell(ID[i])) then
					return true;
				end
			end

			return false;
		end
	else
		if (Cryolysis3.spellCache[spellID] == nil) then
			-- This spell was not in our cache, ergo we don't have it
			return false;
		else
			-- It was, we has it
			return true;
		end
	end
end