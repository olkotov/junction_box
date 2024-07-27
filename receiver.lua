-- Oleg Kotov

local EntityModule = require( "entity" )
local Entity = EntityModule.Entity
local EntityType = EntityModule.EntityType

local Receiver = Entity:new()

function Receiver:new( rotation, canRotate )

    local obj = Entity:new( rotation, canRotate )

    obj.type = EntityType.Receiver

    obj.inOutSides = {
        true,  -- top
        false, -- right
        false, -- bottom
        false  -- left
    }
    
    setmetatable( obj, self )
    self.__index = self

    obj:syncRotate()

    return obj
end

function Receiver:getSprite()
    if self:isPowered() then
        return "receiver_powered"
    else
        return "receiver_unpowered"
    end
end

return Receiver

