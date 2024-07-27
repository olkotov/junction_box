-- Oleg Kotov

local EntityModule = require( "entity" )
local Entity = EntityModule.Entity
local EntityType = EntityModule.EntityType

local Straight = Entity:new()

function Straight:new( rotation, canRotate )

    local obj = Entity:new( rotation, canRotate )

    obj.type = EntityType.Straight

    obj.inOutSides = {
        true,  -- top
        false, -- right
        true,  -- bottom
        false  -- left
    }

    setmetatable( obj, self )
    self.__index = self

    obj:syncRotate()

    return obj
end

function Straight:getSprite()
    if self:isPowered() then
        return "straight_powered"
    else
        return "straight_unpowered"
    end
end

return Straight

