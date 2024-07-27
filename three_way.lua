-- Oleg Kotov

local EntityModule = require( "entity" )
local Entity = EntityModule.Entity
local EntityType = EntityModule.EntityType

local ThreeWay = Entity:new()

function ThreeWay:new( rotation, canRotate )

    local obj = Entity:new( rotation, canRotate )

    obj.type = EntityType.ThreeWay

    obj.inOutSides = {
        true,  -- top
        true,  -- right
        true,  -- bottom
        false  -- left
    }

    setmetatable( obj, self )
    self.__index = self

    obj:syncRotate()

    return obj
end

function ThreeWay:getSprite()
    if self:isPowered() then
        return "three_way_powered"
    else
        return "three_way_unpowered"
    end
end

return ThreeWay

