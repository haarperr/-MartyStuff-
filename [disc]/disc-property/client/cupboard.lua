function OpenCupboard(room)
    ESX.TriggerServerCallback('disc-property:getPropertyInventoryFor', function(data)

        if data == nil then
            TriggerServerEvent('disc-property:createPropertyInventoryFor', room)
            data = {}
        end

        data.inventory_name = room

        TriggerEvent('esx_inventoryhud:openDiscPropertyInventory', data)
    end, room)
end
