------------------------------------------------------------------------------------------------------
-- Local variables
------------------------------------------------------------------------------------------------------
local Cryolysis3 = Cryolysis3;
--local L = LibStub("AceLocale-3.0"):GetLocale("Cryolysis3");


------------------------------------------------------------------------------------------------------
-- Create a frame based on inputted variables
------------------------------------------------------------------------------------------------------
function Cryolysis3:substr(string, start, length)
	if not string then
		return ''
	end
	-- Sanity checks: make sure integers are integers.
	start = floor(tonumber(start)) or 1
	if length == nil then
		length = strlen(string)
	end
	if length < 0 and start < 0 and abs(length) > abs(start) then
		return false
	end
	if start < 0 then
		start = strlen(string) + (start + 1)
	end
	length = floor(tonumber(length))
	local String = ''
	if length >= 0 then
		String = strsub(string, start, (start - 1) + length)
	else
		String = string
		String = strsub(String, start)
		String = strsub(String, 1, strlen(String) + length)
	end
	return String
end

------------------------------------------------------------------------------------------------------
-- Function to set the default skin during a class's OnEnable
------------------------------------------------------------------------------------------------------
function Cryolysis3:SetDefaultSkin(name)
	if Cryolysis3.db.char.skin == nil then
		Cryolysis3.db.char.skin = name;
	end
end

------------------------------------------------------------------------------------------------------
-- Function to quickly determine minutes and seconds remaining of a timer
------------------------------------------------------------------------------------------------------
function Cryolysis3:TimerData(start, duration)
	local timeleft	= (start + duration) - GetTime();
	
	return {
		["minutes"] = floor(timeleft / 60),
		["seconds"] = floor(math.fmod(timeleft, 60))
	};
end

------------------------------------------------------------------------------------------------------
-- Create a frame based on inputted variables
------------------------------------------------------------------------------------------------------
function Cryolysis3:SaveAnchorPosition(frameType, name)
	-- Create the frame name with the Cryolysis3 prefix
	local frameName = "Cryolysis3"..name;
	
	-- Get the item we are using
	local item = getglobal(frameName);
	
	if not item then
		return false;
	end

	-- Begin tons of nil checks to deal with a clear DB
	if Cryolysis3.db.char.positions[frameType] == nil then
		Cryolysis3.db.char.positions[frameType] = {}
	end
	
	if Cryolysis3.db.char.positions[frameType][name] == nil then
		Cryolysis3.db.char.positions[frameType][name] = {}
	end
	
	-- Set the center X and Y coord positions
	Cryolysis3.db.char.positions[frameType][name].x, Cryolysis3.db.char.positions[frameType][name].y = item:GetCenter();
	
	-- Set the actual X and Y coord positions
	Cryolysis3.db.char.positions[frameType][name].x = Cryolysis3.db.char.positions[frameType][name].x * item:GetEffectiveScale();
	Cryolysis3.db.char.positions[frameType][name].y = Cryolysis3.db.char.positions[frameType][name].y * item:GetEffectiveScale();
end

------------------------------------------------------------------------------------------------------
-- Create a frame based on inputted variables
------------------------------------------------------------------------------------------------------
function Cryolysis3:LoadAnchorPosition(frameType, name)
	-- Create the frame name with the Cryolysis3 prefix
	local frameName = "Cryolysis3"..name;
	
	-- Get the item we are using
	local item = getglobal(frameName);
	
	if not item then
		return false;
	end
	
	-- Get the scale of the button
	local scale = item:GetEffectiveScale();
	
	-- Begin tons of nil checks to deal with a clear DB
	if Cryolysis3.db.char.positions[frameType] == nil then
		return false;
	end
	
	if Cryolysis3.db.char.positions[frameType][name] == nil then
		return false;
	end
	
	if Cryolysis3.db.char.positions[frameType][name]["x"] == nil then
		return false;
	end
	
	if Cryolysis3.db.char.positions[frameType][name]["y"] == nil then
		return false;
	end

	item:ClearAllPoints();
	item:SetPoint("CENTER", UIParent, "BOTTOMLEFT", 
		Cryolysis3.db.char.positions[frameType][name]["x"] / scale, 
		Cryolysis3.db.char.positions[frameType][name]["y"] / scale
	);

end

------------------------------------------------------------------------------------------------------
-- Update visibility of things
------------------------------------------------------------------------------------------------------
function Cryolysis3:UpdateVisibility()
	for k, v in pairs(Cryolysis3.db.char.buttons) do
		local f = getglobal("Cryolysis3"..v);
		if (f ~= nil) then
			if (Cryolysis3.db.char.hidden[v] == true) then
				-- Hide this button
				f:Hide();
			else
				if (f:IsVisible() == nil) then
					-- It's not visible
					f:Show();
				end
			end
		end
	end

	local f = getglobal("Cryolysis3Sphere");
	if (Cryolysis3.db.char.hidden["Sphere"] == true) then
		-- Hide this button
		f:Hide();
	else
		if (f:IsVisible() == nil) then
			-- It's not visible
			f:Show();
		end
	end
end

------------------------------------------------------------------------------------------------------
-- Update visibility of things
------------------------------------------------------------------------------------------------------
function Cryolysis3:GetHighestRank(spells)
	for k, v in pairs(spells) do
		if (Cryolysis3:HasSpell(k)) then
			return k;
		end
	end

	return nil;
end

------------------------------------------------------------------------------------------------------
-- Function to update item counts on buttons
------------------------------------------------------------------------------------------------------
function Cryolysis3:UpdateItemCount(buttonName, lookupTable)
	local button = getglobal("Cryolysis3"..buttonName);
	local buttonText = getglobal("Cryolysis3"..buttonName.."Text");

	for k, v in pairs(lookupTable) do
		if Cryolysis3:HasSpell(k) then
			local temp = GetItemCount(v);
			if temp > 0 then
				button.texture:SetDesaturated(nil);

				if (Cryolysis3.db.char.buttonText[buttonName] ~= nil) then
					buttonText:SetText(temp);
				else
					buttonText:SetText(nil);
				end

				return
			else
				buttonText:SetText(nil);
				button.texture:SetDesaturated(true);
			end
		end
	end
end