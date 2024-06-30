
local ProfessionatorDB = ProfessionatorLoader:ImportModule("ProfessionatorDB")
local PlayersInventoryModule = ProfessionatorLoader:ImportModule("PlayersInventoryModule")

Professionator.CalculationEngine = {}
Professionator.CalculationEngine.__index = Professionator.CalculationEngine
function Professionator.CalculationEngine:Create(professionName, startLevel, endLevel)
    local this =
    {
        professionName = professionName,
        startLevel = startLevel,
        endLevel = endLevel,
    }
    setmetatable(this, self)
    return this
end

function Professionator.CalculationEngine:Calculate()

    local possibleRecipes = ProfessionatorDB[self.professionName]

    -- print(self.professionName)

    local result = Professionator.CalculationResult:Create(self.professionName, self.startLevel, self.endLevel, PlayersInventoryModule:GetInventory():Clone())

    -- Loop from startLevel to endLevel and populate self.result with the best recipe at each level
    for level = self.startLevel, self.endLevel - 1 do

        Professionator.Utils.dd("")
        Professionator.Utils.dd("-----------------------------------")
        Professionator.Utils.dd("")

        local bestScoreForThisLevel = math.huge

        -- for every possible recipe
        if possibleRecipes ~= nil then
            for spellId, recipe in pairs(possibleRecipes) do

                recipe = Professionator.Recipe:Create(self.professionName, recipe)

                -- If the recipe is a candidate for the current level (i.e. it can be used to level up)
                if self:recipeIsCandidate(recipe, level) then

                    -- Save the current recipe at this level
                    --local saveRecipeAtLevel = result:saveRecipeAtLevel(level)
                    local resultBackup = result:Clone()

                    -- Try place this recipe here and see what the overall score is
                    local score = result:placeRecipeAtLevel(recipe, level)
                    Professionator.Utils.dd("score: " .. score .. " | level: " .. level .. " | spellId: " .. spellId .. " | recipe: " .. recipe:getSpellId() .. " | bestScoreForThisLevel: " .. bestScoreForThisLevel)

                    if score < bestScoreForThisLevel then
                        -- If this recipe is better than the current best recipe at this level
                        bestScoreForThisLevel = score
                    else
                        -- If not, revert the change
                        --if saveRecipeAtLevel ~= nil then
                        --    result:restoreRecipeAtLevel(level, saveRecipeAtLevel)
                        --end
                        if resultBackup ~= nil then
                            result = resultBackup
                        end
                    end

                end

            end
        end

    end

    return result

end

function Professionator.CalculationEngine:recipeIsCandidate(recipe, level)

    -- Can the player make this recipe at this level?
    -- and the recipe isn't grey at this level
    if not recipe:canGiveSkillUp(level) then
        return false
    end

    return true

end


