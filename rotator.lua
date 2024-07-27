-- Oleg Kotov

local EntityModule = require( "entity" )
local Entity = EntityModule.Entity
local EntityType = EntityModule.EntityType

local Rotator = Entity:new()

function Rotator:new()

    local obj = Entity:new()

    obj.type = EntityType.Rotator

    obj.inOutSides = {
        false, -- top
        false, -- right
        false, -- bottom
        false  -- left
    }

    setmetatable( obj, self )
    self.__index = self

    obj:syncRotate()

    return obj
end

function Rotator:getSprite()
        return "rotator"
end

function Rotator:update( row, col, board, boardSize )

    for side = 1, 4, 1 do

        -- получаем координаты клетки для этой стороны
        local neighborRow = row + self.neighborOffsets[side][1]
        local neighborCol = col + self.neighborOffsets[side][2]

        -- проверяем что не вышли за сетку
        if neighborRow >= 1 and neighborRow <= boardSize and neighborCol >= 1 and neighborCol <= boardSize then

            -- получаем объект из клетки
            local entity = board[neighborRow][neighborCol]

            -- если объект в клетке существует
            if entity ~= nil then
                local isRotator = entity:getType() == EntityType.Rotator

                -- if not isRotator then
                    entity:rotate()
                    entity:update( neighborRow, neighborCol, board, boardSize )
                -- end
            end
        end
    end
end

return Rotator

