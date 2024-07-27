-- Oleg Kotov

local EntityModule = require( "entity" )
local Entity = EntityModule.Entity
local EntityType = EntityModule.EntityType

local NinetyDegree = Entity:new()

function NinetyDegree:new( rotation, canRotate )

    local obj = Entity:new( rotation, canRotate )

    obj.type = EntityType.NinetyDegree

    obj.inOutSides = {
        true,  -- top
        true,  -- right
        false, -- bottom
        false  -- left
    }

    setmetatable( obj, self )
    self.__index = self

    obj:syncRotate()

    return obj
end

function NinetyDegree:getSprite()
    if self:isPowered() then
        return "ninety_degree_powered"
    else
        return "ninety_degree_unpowered"
    end
end

return NinetyDegree

