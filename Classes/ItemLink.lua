--- @class ItemLinkHelper
ItemLinkHelper = {

    -- gsplit: iterate over substrings in a string separated by a pattern
    --
    -- Parameters:
    -- text (string)    - the string to iterate over
    -- pattern (string) - the separator pattern
    -- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
    --                    string, not a Lua pattern
    --
    -- Returns: iterator
    --
    -- Usage:
    -- for substr in gsplit(text, pattern, plain) do
    --   doSomething(substr)
    -- end
    gsplit = function(text, pattern, plain)
        local splitStart, length = 1, #text
        return function()
            if splitStart then
                local sepStart, sepEnd = string.find(text, pattern, splitStart, plain)
                local ret
                if not sepStart then
                    ret = string.sub(text, splitStart)
                    splitStart = nil
                elseif sepEnd < sepStart then
                    -- Empty separator!
                    ret = string.sub(text, splitStart, sepStart)
                    if sepStart < length then
                        splitStart = sepStart + 1
                    else
                        splitStart = nil
                    end
                else
                    ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or ''
                    splitStart = sepEnd + 1
                end
                return ret
            end
        end
    end,

    -- split: split a string into substrings separated by a pattern.
    --
    -- Parameters:
    -- text (string)    - the string to iterate over
    -- pattern (string) - the separator pattern
    -- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
    --                    string, not a Lua pattern
    --
    -- Returns: table (a sequence table containing the substrings)
    split = function(text, pattern, plain)
        local ret = {}
        for match in Professionator.ItemLinkHelper.gsplit(text, pattern, plain) do
            table.insert(ret, match)
        end
        return ret
    end,

    -- Pass in a string like (1) and get back a string like (2)
    -- 1. "|cff1eff00|Hitem:10242:::::::::::::::::|h[Heavy Lamellar Gauntlets]|h|r"
    -- 2. "|cff1eff00|Hitem:10242::::::614:::::::::::|h[Heavy Lamellar Gauntlets of the Monkey]|h|r"
    addSuffixToItemLink = function(itemLink, suffixId, suffixText)
        -- Split the string on "|"
        local parts = Professionator.ItemLinkHelper.split(itemLink, "|")

        -- Add suffixText to the end of the third part
        parts[4] = parts[4]:sub(1, -2) .. suffixText .. "]"

        -- Split the second part using ":"
        local itemParts = Professionator.ItemLinkHelper.split(parts[3], ":")

        -- Replace the 8th item if it exists
        if itemParts[8] then
            itemParts[8] = suffixId
        end

        -- Join all parts back together
        parts[3] = table.concat(itemParts, ":")

        local newItemLink = table.concat(parts, "|")

        -- // Print but replace all | with \|
        print(newItemLink:gsub("|", "||"))

        return newItemLink
    end,

    -- Get the item links for an item id and suffix id
    -- NOTE: This function can generate a link for suffixed items eg "Heavy Lamellar Gauntlets of the Monkey" which will
    -- function as expected when hovered over. However when you try to link it in the chat it will brick. So... This
    -- function also provides a linkable version of the item link that can be used in chat (the linked item will look
    -- like "[Heavy Lamellar Gauntlets] of the Monkey" which when viewed won't show the stats provided by the
    -- "of the monkey" but it is the best I can do.
    --
    -- TODO: When shift clicking a suffixed item in game it can be linked in chat. So it must be possible to generate a linkable link here???...
    --
    -- @suffixId @see https://warcraft.wiki.gg/wiki/SuffixId
    getItemLinks = function(itemId, suffixId, suffixText)

        local _, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemId)
        local itemLinkHoverable = itemLink
        local itemLinkLinkable = itemLink

        -- If suffixId is provided then continue
        if suffixId then
            itemLinkLinkable = itemLinkLinkable .. suffixText
            itemLinkHoverable = Professionator.ItemLinkHelper.addSuffixToItemLink(itemLinkHoverable, suffixId, suffixText)
        end

        return {
            hoverable = itemLinkHoverable,
            linkable = itemLinkLinkable,
            itemTexture = itemTexture,
        }
    end,

}

Professionator.ItemLinkHelper = ItemLinkHelper