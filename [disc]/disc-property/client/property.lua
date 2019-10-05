function ShowViewProperty(property)

    local propData = GetPropertyDataForProperty(property)

    if propData == nil then
        return
    end

    local options = {
        { label = 'View Property', action = function()
            EnterProperty(property)
        end, },
        { label = 'Buy Property for $' .. propData.price, action = function()
            ShowConfirmBuy(property)
        end }
    }

    local menu = {
        title = 'View Property',
        name = 'view_property',
        options = options
    }
    TriggerEvent('disc-base:openMenu', menu)
end

function ShowManageProperty(property)
    local options = {
        { label = 'Give Keys', action = function()
            ShowGiveKeys(property)
        end },
        { label = 'Take Keys', action = function()
            ShowKeyUsers(property)
        end },
        { label = 'Sell Property', action = function()
            ShowConfirmSell(property)
        end }
    }

    local menu = {
        name = 'property_management',
        title = 'Manage Property',
        options = options
    }
    TriggerEvent('disc-base:openMenu', menu)
end

function ShowConfirmSell(property)
    local options = {
        { label = 'Yes', action = function()
            SellProperty(property)
        end },
        { label = 'No', action = function()
            ESX.UI.Menu.Close('confirm_sell')
        end }
    }

    local menu = {
        name = 'confirm_sell',
        title = 'Confirm',
        options = options
    }

    TriggerEvent('disc-base:openMenu', menu)
end

function SellProperty(property)
    TriggerServerEvent('disc-property:sellProperty', property)
    ESX.UI.Menu.CloseAll()
    exports['mythic_notify']:DoHudText('success', 'Property Sold!')
    TriggerEvent('disc-property:forceUpdatePropertyData')
end

function ShowConfirmBuy(property)
    local options = {
        { label = 'Yes', action = function()
            BuyProperty(property)
        end },
        { label = 'No', action = function()
            ESX.UI.Menu.Close('confirm_buy')
        end }
    }

    local menu = {
        name = 'confirm_buy',
        title = 'Confirm',
        options = options
    }

    TriggerEvent('disc-base:openMenu', menu)
end

function BuyProperty(property)
    ESX.TriggerServerCallback('disc-property:buyProperty', function(bought)
        if bought then
            ESX.UI.Menu.CloseAll()
            exports['mythic_notify']:DoHudText('success', 'Property Bought!')
            TriggerEvent('disc-property:forceUpdatePropertyData')
        else
            exports['mythic_notify']:DoHudText('error', 'You do not have enough money')
        end
    end, property)
end

function ShowGiveKeys(property)
    local menu = {
        type = 'dialog',
        name = 'searching_users',
        title = 'Insert First or Last Name',
        action = function(value)
            ShowSearchedUsers(value, property)
        end
    }
    TriggerEvent('disc-base:openMenu', menu)
end

function ShowSearchedUsers(value, property)
    ESX.TriggerServerCallback('disc-property:searchUsers', function(results)
        if #results == 0 then
            exports['mythic_notify']:DoHudText('error', 'No civilian found')
            return
        end
        local options = {}
        for k, v in pairs(results) do
            table.insert(options,
                    {
                        label = v.firstname .. ' ' .. v.lastname, action = function(value, m)
                        TriggerServerEvent('disc-property:GiveKeys', property, v.identifier)
                        exports['mythic_notify']:DoHudText('success', 'Gave keys to ' .. v.firstname .. ' ' .. v.lastname)
                        ESX.UI.Menu.CloseAll()
                    end
                    })
        end
        local menu = {
            type = 'default',
            name = 'property_civ_select',
            title = 'Select Civilian',
            options = options
        }
        TriggerEvent('disc-base:openMenu', menu)
    end, value)
end

function ShowKeyUsers(property)
    ESX.TriggerServerCallback('disc-property:getKeyUsers', function(results)
        if #results == 0 then
            exports['mythic_notify']:DoHudText('error', 'No civilian found')
            return
        end
        local options = {}
        for k, v in pairs(results) do
            table.insert(options,
                    {
                        label = v.firstname .. ' ' .. v.lastname, action = function(value, m)
                        TriggerServerEvent('disc-property:TakeKeys', property, v.identifier)
                        exports['mythic_notify']:DoHudText('success', 'Took keys from ' .. v.firstname .. ' ' .. v.lastname)
                        ESX.UI.Menu.CloseAll()
                    end
                    })
        end
        local menu = {
            type = 'default',
            name = 'property_civ_select',
            title = 'Select Civilian',
            options = options
        }
        TriggerEvent('disc-base:openMenu', menu)
    end, property)
end