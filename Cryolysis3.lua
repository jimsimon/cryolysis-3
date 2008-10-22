------------------------------------------------------------------------------------------------------
-- Initialise the variable we will be working with
------------------------------------------------------------------------------------------------------
Cryolysis3 = LibStub("AceAddon-3.0"):NewAddon("Cryolysis3", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("Cryolysis3");
local AceConfig = LibStub("AceConfigDialog-3.0");

-- Don't move this!
Cryolysis3:SetDefaultModuleState(false);


------------------------------------------------------------------------------------------------------
-- What happens when the addon is first loaded
------------------------------------------------------------------------------------------------------
function Cryolysis3:OnInitialize()
	-- Register the database
	Cryolysis3.db = LibStub("AceDB-3.0"):New("Cryolysis3DB", Cryolysis3.defaults, "char");
	
	-- Create the buttons array
	Cryolysis3.buttons = {};
	
	-- Add info to the Options array for the Profile Options
	Cryolysis3.options.args.profile.args.options = LibStub("AceDBOptions-3.0"):GetOptionsTable(Cryolysis3.db);
	Cryolysis3.options.args.profile.args.options.name = L["Options profile"];
	Cryolysis3.options.args.profile.args.options.desc = L["Saved profile for Cryolysis 3 options"];
	Cryolysis3.options.args.profile.args.options.order = 2;

	-- Create options table and stuff
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Cryolysis3", Cryolysis3.options);
	AceConfig:AddToBlizOptions("Cryolysis3", "Cryolysis3");
end

------------------------------------------------------------------------------------------------------
-- What happens when the addon is enabled
------------------------------------------------------------------------------------------------------
function Cryolysis3:OnEnable()
	-- Store this since we use it so often
	Cryolysis3.className = select(2, UnitClass("player"));

	-- Register for some common events used by all modules
	Cryolysis3:RegisterCommonEvents();
	
	-- Create the popup dialogue
	StaticPopupDialogs["ITEM_CACHE_WARNING"] = {
		text = L["Cryolysis 3 is currently adding items to your game's item cache.  The addon should finish loading and this dialog box should disappear once this is complete."],
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}
	
	-- Load all enabled modules
	Cryolysis3:LoadModules();
end

function Cryolysis3:startup()
	--Cryolysis3:RegisterChatCommand("cryo", "ChatCommand")  --See function Cryolysis3:ChatCommand for details
	--Cryolysis3:RegisterChatCommand("cryolysis", "ChatCommand")
	Cryolysis3:RegisterChatCommand("cryo3", "ChatCommand")
	Cryolysis3:RegisterChatCommand("cryolysis3", "ChatCommand")
	
	-- Create the main sphere frame
	Cryolysis3:CreateFrame(
		"Button", "Sphere", UIParent, "SecureActionButtonTemplate",
		58, 58, true,
		nil, nil, nil,
		"Interface\\AddOns\\Cryolysis3\\textures\\background",
		nil,
		Cryolysis3.db.char.hidden["Sphere"]
	);
	
	-- Make main sphere draggable
	Cryolysis3Sphere:RegisterForDrag("LeftButton");
	Cryolysis3Sphere:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp");
	
	-- Open the config menu when right-clicking the main sphere
	Cryolysis3Sphere:SetAttribute("type2", "Menu")
	Cryolysis3Sphere.Menu = function() LibStub("AceConfigDialog-3.0"):Open("Cryolysis3") end
	
	-- Set the left and middle click actions
	Cryolysis3:UpdateButton("Sphere", "left")
	Cryolysis3:UpdateButton("Sphere", "middle")
	
	-- Handle main sphere drag start
	Cryolysis3:AddScript("Sphere", "frame", "OnDragStart");
	
	-- Handle main sphere drag stop
	Cryolysis3:AddScript("Sphere", "frame", "OnDragStop")

	-- Set mount region thingy
	Cryolysis3.Private.mountRegion = IsFlyableArea();
	
	-- Find our mounts
	Cryolysis3:FindMounts();

	-- Setup custom buttons
	Cryolysis3:CreateCustomButtons();
		
	-- Setup class-specific buttons
	Cryolysis3.GetClassModule():CreateButtons();
	
	-- Place the buttons where they're supposed to be
	Cryolysis3:UpdateAllButtonPositions();

	-- Update main sphere
	Cryolysis3:UpdateSphere("outerSphere");
	Cryolysis3:UpdateSphere("sphereText");
	Cryolysis3:UpdateSphere("sphereAttribute");
	
end

------------------------------------------------------------------------------------------------------
-- What happens when the addon is disabled
------------------------------------------------------------------------------------------------------
function Cryolysis3:OnDisable()

end

------------------------------------------------------------------------------------------------------
-- Load all enabled modules
------------------------------------------------------------------------------------------------------
function Cryolysis3:LoadModule(name)
	-- Attempt to load the LoD module
	local loaded, reason = Cryolysis3:EnableModule(name);
	if not loaded then
		-- We couldn't load it :(
		local dialogueText = L["Cryolysis 3 cannot load the module:"].." Cryolysis3_"..name.."\n";
		
		if reason == "DISABLED" then
			-- The class module was disabled
			dialogueText = dialogueText.." "..L["The module is flagged as Disabled in the Blizzard AddOn interface."];
		
		elseif reason == "MISSING" then
			-- The class module isn't there (most likely not installed)
			dialogueText = dialogueText.." "..L["The module is missing. Please close the game and install it."];
		
		elseif reason == "INCOMPATIBLE" then
			-- The class module is too old (most likely not updated)
			dialogueText = dialogueText.." "..L["The module is too old. Please close the game and update it."];
		end
		
		-- Create the popup dialogue
		StaticPopupDialogs["C3_LOD_ADDON_WARNING"] = {
			text = dialogueText,
			button1 = L["Okay"],
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1
		}
		
		-- Display the dialogue
		StaticPopup_Show("C3_LOD_ADDON_WARNING");

		return false;
	end

	return true;
end


function Cryolysis3:CacheItems(itemList)
	
	local checkAgain = false;
	
	for k, item in pairs(itemList) do
		
		if (GetItemInfo(item) == nil) then
			StaticPopup_Show("ITEM_CACHE_WARNING");
			GameTooltip:SetOwner(UIParent, "CENTER")
			GameTooltip:SetHyperlink("item:"..item..":0:0:0:0:0:0:0")
			GameTooltip:Hide()
			checkAgain = true;
		end
		
	end
	
	if checkAgain then
		return false
	else
		StaticPopup_Hide("ITEM_CACHE_WARNING");
		return true
	end
	
end

------------------------------------------------------------------------------------------------------
-- Load all enabled modules
------------------------------------------------------------------------------------------------------
function Cryolysis3:LoadModules()

	if Cryolysis3:CacheItems(Cryolysis3.Private.cacheList) then

		-- Detect what class we are playing and return English value, then load it
		local classLoaded = Cryolysis3:LoadModule(Cryolysis3.className);
		
		if (not Cryolysis3.db.char.silentMode and classLoaded == true) then
			-- Only print this if we're not in silent mode
			local classname = gsub(UnitClass("player"), "^.", function(s) return s:upper() end)
			Cryolysis3:Print(classname.." "..L["Module"].." "..L["Loaded"]);
		end

		-- Cache here, since before this we don't have a spellList
		Cryolysis3:CacheSpells();

		-- Create reagent list for the mage
		Cryolysis3.GetClassModule():CreateReagentList();
		
		for k, v in pairs(Cryolysis3.db.char.modules) do
			if (Cryolysis3.db.char.modules[k]) then
				-- Load the module if it's enabled in the config
				Cryolysis3:LoadModule(k);
			end
		end
		
		Cryolysis3:startup()
		
	else
		Cryolysis3:ScheduleTimer("LoadModules", .5)
	end
end

------------------------------------------------------------------------------------------------------
-- Get the class module
------------------------------------------------------------------------------------------------------
function Cryolysis3:GetClassModule()
	-- Return the module that fits our class
	return Cryolysis3.modules[Cryolysis3.className];
end

------------------------------------------------------------------------------------------------------
-- Having a function with msg being passed to it allows us to create /commands later if desired
-- If no msg is passed, open the GUI, else accept a chat command.
------------------------------------------------------------------------------------------------------
function Cryolysis3:ChatCommand(msg)
	if not input or input:trim() == "" then
		-- We're opening config dialogue
		LibStub("AceConfigDialog-3.0"):Open("Cryolysis3");
	else
		-- We have a chat command
		LibStub("AceConfigCmd-3.0").HandleCommand(Cryolysis3, "cryo", "cryolysis", "cryo3", "cryolysis3", msg);
	end
	
end