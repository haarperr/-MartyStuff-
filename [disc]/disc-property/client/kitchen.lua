function OpenKitchen(property)

    local options = {
        { label = 'Make Food', action = MakeFood }
    }

    if IsPlayerOwnerOf(property) then
        table.insert(options, { label = 'Manage Property', action = function()
            ShowManageProperty(property)
        end })
    end

    local menu = {
        name = 'kitchen',
        title = 'Kitchen',
        options = options
    }

    TriggerEvent('disc-base:openMenu', menu)
end

function MakeFood()
    TriggerServerEvent('disc-base:givePlayerItem', Config.FoodItem, 1)
end
