
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

---@type WorldMapButton
local WorldMapButton = ItemPlannerLoader:ImportModule("WorldMapButton")
---@type ModalWindow
local ModalWindow = ItemPlannerLoader:ImportModule("ModalWindow")

function ItemPlanner:OnInitialize()

	-- uses the "Default" profile instead of character-specific profiles
	-- https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
	self.db = LibStub("AceDB-3.0"):New("ItemPlannerDB", self.defaults, true)

	-- registers an options table and adds it to the Blizzard options window
	-- https://www.wowace.com/projects/ace3/pages/api/ace-config-3-0
	AC:RegisterOptionsTable("ItemPlanner_Options", self.options)
	self.optionsFrame = ACD:AddToBlizOptions("ItemPlanner_Options", "ItemPlanner (label 1)")

	-- adds a child options table, in this case our profiles panel
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("ItemPlanner_Profiles", profiles)
	ACD:AddToBlizOptions("ItemPlanner_Profiles", "Profiles", "ItemPlanner (label 1)")

	-- https://www.wowace.com/projects/ace3/pages/api/ace-console-3-0
	self:RegisterChatCommand("ip", "SlashCommand")
	self:RegisterChatCommand("ItemPlanner", "SlashCommand")

	self:GetCharacterInfo()

    WorldMapButton:Initialize(self)
	ModalWindow:Initialize(self)

	--TestLoop()

	--ItemPlanner.Utils:printAllGlobals()
end

function ItemPlanner:OnEnable()
end

function ItemPlanner:GetCharacterInfo()
	-- stores character-specific data
	self.db.char.level = UnitLevel("player")
end

local function GetCurrentTimeMilliseconds()
	return GetTime() + (debugprofilestop() / 1000)
end


-----@type QuestieDB
--local QuestieDB = ItemPlannerLoader:ImportModule("QuestieDB");
--function TestLoop()
--
--	local startTime = GetCurrentTimeMilliseconds()
--
--	-- Table to store calculated values and original items
--	local calculatedValues = {}
--
--	-- Loop over the QuestieDB.itemData array
--	for key, item in pairs(QuestieDB.itemData) do
--
--		local item = ItemPlanner.Item:Create(item)
--
--		local product = item:calculateProduct()
--
--		-- Insert the calculated value along with the original item into the table
--		table.insert(calculatedValues, {value = product, item = item})
--	end
--
--	-- Sort the table based on the calculated values in descending order
--	table.sort(calculatedValues, function(a, b)
--		return a.value > b.value
--	end)
--
--	-- Print the top 2 items
--	for i = 1, 2 do
--		local topItem = calculatedValues[i].item
--		print("Item:", topItem:getName(), "Calculated Value:", calculatedValues[i].value)
--	end
--
--	print("Elapsed time: " .. (GetCurrentTimeMilliseconds() - startTime) .. " seconds")
--
--end

function ItemPlanner:SlashCommand(input, editbox)
	if input == "enable" then
		self:Enable()
		self:Print("Enabled.")
	elseif input == "disable" then
		-- unregisters all events and calls ItemPlanner:OnDisable() if you defined that
		self:Disable()
		self:Print("Disabled.")
	elseif input == "test" then

		local unitTester = ItemPlanner.UnitTester:Create()
		unitTester:RunTests()

	elseif input == "message" then
		print("this is our saved message:", self.db.profile.someInput)
	else
		self:Print("Some useful help message.")
		-- https://github.com/Stanzilla/WoWUIBugs/issues/89
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		--[[ or as a standalone window
		if ACD.OpenFrames["ItemPlanner_Options"] then
			ACD:Close("ItemPlanner_Options")
		else
			ACD:Open("ItemPlanner_Options")
		end
		--]]
	end
end

