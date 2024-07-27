-- Oleg Kotov

local EntityModule = require( "entity" )
local Entity = EntityModule.Entity
local EntityType = EntityModule.EntityType

local Emitter = Entity:new()

function Emitter:new( rotation, canRotate )

    local obj = Entity:new( rotation, canRotate )

    obj.type = EntityType.Emitter

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

function Emitter:getSprite()
    if self:isPowered() then
        return "emitter_powered"
    else
        return "emitter_unpowered"
    end
end

function Emitter:isPowered()
    return true
end

function Emitter:unpower()

end

return Emitter

