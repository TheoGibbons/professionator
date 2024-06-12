
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

---@type ProfessionatorWindow
local ProfessionatorWindow = ProfessionatorLoader:ImportModule("ProfessionatorWindow")

---@type CharacterKnownRecipesModule
local CharacterKnownRecipesModule = ProfessionatorLoader:ImportModule("CharacterKnownRecipesModule")

---@type PlayersInventoryModule
local PlayersInventoryModule = ProfessionatorLoader:ImportModule("PlayersInventoryModule")

---@type CreateWindow
local CreateWindow = ProfessionatorLoader:ImportModule("CreateWindow")

function Professionator:OnInitialize()

	-- uses the "Default" profile instead of character-specific profiles
	-- https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
	self.db = LibStub("AceDB-3.0"):New("ProfessionatorSttings", self.defaults, true)

	-- registers an options table and adds it to the Blizzard options window
	-- https://www.wowace.com/projects/ace3/pages/api/ace-config-3-0
	AC:RegisterOptionsTable("Professionator_Options", self.options)
	self.optionsFrame = ACD:AddToBlizOptions("Professionator_Options", "Professionator (label 1)")

	-- adds a child options table, in this case our profiles panel
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("Professionator_Profiles", profiles)
	ACD:AddToBlizOptions("Professionator_Profiles", "Profiles", "Professionator (label 1)")

	-- https://www.wowace.com/projects/ace3/pages/api/ace-console-3-0
	self:RegisterChatCommand("Professionator", "SlashCommand")

	self:GetCharacterInfo()

	-- Keep track of know recipes
	CharacterKnownRecipesModule:Register()

	PlayersInventoryModule:Register()

	-- The help window (that pops up to the right of the trade skills window)
	ProfessionatorWindow:Register()

	--Professionator.Utils.printAllGlobals()
end

function Professionator:OnEnable()
end

function Professionator:GetCharacterInfo()
	-- stores character-specific data
	self.db.char.level = UnitLevel("player")
end

function Professionator:SlashCommand(input, editbox)
	if input == "test" then

		ProfessionatorUnitTesting.RunTests()

	elseif input == "test-window" then

		CreateWindow:Test()

	end
end

