-- Oleg Kotov

local EntityModule = require( "entity" )
local Entity = EntityModule.Entity
local EntityType = EntityModule.EntityType

local Cross = Entity:new()

function Cross:new( rotation, canRotate )

    local obj = Entity:new( rotation, canRotate )

    obj.type = EntityType.Cross

    obj.inOutSides = {
        true, -- top
        true, -- right
        true, -- bottom
        true  -- left
    }

    setmetatable( obj, self )
    self.__index = self

    obj:syncRotate()

    return obj
end

function Cross:getSprite()
    if self:isPowered() then
        return "cross_powered"
    else
        return "cross_unpowered"
    end
end

return Cross

