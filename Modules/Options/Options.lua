Professionator.defaults = {
	profile = {
		someToggle = true,
		someRange = 7,
		someInput = "Hello World",
		someSelect = 2, -- Banana
	},
}

-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
Professionator.options = {
	type = "group",
	name = "Professionator (label 2)",
	handler = Professionator,
	args = {
		someToggle = {
			type = "toggle",
			order = 1,
			name = "a checkbox",
			desc = "some description",
			-- inline getter/setter example
			get = function(info) return Professionator.db.profile.someToggle end,
			set = function(info, value) Professionator.db.profile.someToggle = value end,
		},
		someRange = {
			type = "range",
			order = 2,
			name = "a slider",
			-- this will look for a getter/setter on our handler object
			get = "GetSomeRange",
			set = "SetSomeRange",
			min = 1, max = 10, step = 1,
		},
		someKeybinding = {
			type = "keybinding",
			order = 3,
			name = "a keybinding",
			get = "GetValue",
			set = "SetValue",
		},
		group1 = {
			type = "group",
			order = 4,
			name = "a group",
			inline = true,
			-- getters/setters can be inherited through the table tree
			get = "GetValue",
			set = "SetValue",
			args = {
				someInput = {
					type = "input",
					order = 1,
					name = "an input box",
					width = "double",
				},
				someDescription = {
					type = "description",
					order = 2,
					name = function() return format("The current time is: |cff71d5ff%s|r", date("%X")) end,
					fontSize = "large",
				},
				someSelect = {
					type = "select",
					order = 3,
					name = "a dropdown",
					values = {"Apple", "Banana", "Strawberry"},
				},
			},
		},
	},
}

function Professionator:GetSomeRange(info)
	return self.db.profile.someRange
end

function Professionator:SetSomeRange(info, value)
	self.db.profile.someRange = value
end

-- for documentation on the info table
-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function Professionator:GetValue(info)
	return self.db.profile[info[#info]]
end

function Professionator:SetValue(info, value)
	self.db.profile[info[#info]] = value
end
