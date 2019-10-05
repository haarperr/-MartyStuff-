function OpenClothes(room)

    local options = {
        { label = 'Change Clothes', action = ShowChangeClothes },
        { label = 'Save Clothes', action = ShowSaveClothes },
        { label = 'Remove Clothes', action = ShowRemoveClothes }
    }

    local menu = {
        name = 'clothes',
        title = 'Clothes',
        options = options
    }

    TriggerEvent('disc-base:openMenu', menu)
end

function ShowChangeClothes()
    ESX.TriggerServerCallback('disc-property:getClothes', function(clothes)
        local options = {}

        for k, v in pairs(clothes) do
            v.action = function()
                ChangeToClothes(v.skin, v.label)
            end
            table.insert(options, v)
        end

        local menu = {
            name = 'show_clothes',
            title = 'Clothes',
            options = options
        }

        TriggerEvent('disc-base:openMenu', menu)
    end)
end

function ChangeToClothes(clothes, label)
    TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerEvent('skinchanger:loadClothes', skin, clothes)
        TriggerEvent('esx_skin:setLastSkin', skin)

        TriggerEvent('skinchanger:getSkin', function(skin)
            TriggerServerEvent('esx_skin:save', skin)
        end)
    end)
    ESX.UI.Menu.CloseAll()
    exports['mythic_notify']:DoHudText('success', 'Change to Clothes: ' .. label)
end

function ShowSaveClothes()
    local menu = {
        type = 'dialog',
        title = 'Name your Outfit',
        action = SaveClothes
    }
    TriggerEvent('disc-base:openMenu', menu)
end

function SaveClothes(value)
    TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerServerEvent('esx_clotheshop:saveOutfit', value, skin)
        exports['mythic_notify']:DoHudText('success', 'Saved Clothes: ' .. value)
        ESX.UI.Menu.CloseAll()
    end)
end

function ShowRemoveClothes()
    ESX.TriggerServerCallback('disc-property:getClothes', function(clothes)
        local options = {}

        for k, v in pairs(clothes) do
            v.action = function()
                RemoveClothes(v.label)
            end
            table.insert(options, v)
        end

        local menu = {
            name = 'remove_clothes',
            title = 'Remove Clothes',
            options = options
        }

        TriggerEvent('disc-base:openMenu', menu)
    end)
end

function RemoveClothes(label)
    TriggerServerEvent('disc-property:removeOutfit', label)
    exports['mythic_notify']:DoHudText('success', 'Removed Clothes: ' .. label)
    ESX.UI.Menu.CloseAll()
end

