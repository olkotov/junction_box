-- Oleg Kotov

local utils = require( "utils" )

local EntityType = {
    Undefined = 0,

    Emitter = 1,
    Receiver = 2,

    Straight = 3,
    Cross = 4,
    ThreeWay = 5,
    NinetyDegree = 6,

    Rotator = 7
}

local Side = {
    Top = 1,
    Right = 2,
    Bottom = 3,
    Left = 4
}

local Entity = {}

function Entity:new( rotation, canRotate )
    local obj = {

        type = EntityType.Undefined,

        rotation = 0,
        canRotate = true,

        -- inSides, outSides
        inOutSides = {
            false, -- top
            false, -- right
            false, -- bottom
            false  -- left
        },

        neighborOffsets = {
            { -1, 0  }, -- top
            {  0, 1  }, -- right
            {  1, 0  }, -- bottom
            {  0, -1 }  -- left
        },

        oppositeSides = {
            Side.Bottom, -- top
            Side.Left,   -- right
            Side.Top,    -- bottom
            Side.Right   -- left
        },

        -- для обновления состояния
        prevInputObjects = {},
        prevOutputObjects = {},

        -- список объектов которые нас питают
        inputObjects = {
            nil, -- top
            nil, -- right
            nil, -- bottom
            nil  -- left
        },

        -- список объектов которых мы питаем
        outputObjects = {
            nil, -- top
            nil, -- right
            nil, -- bottom
            nil  -- left
        }
    }

    setmetatable( obj, self )
    self.__index = self

    obj.rotation = rotation or 0

    assert( obj.rotation >= 0 and obj.rotation <= 3, "invalid rotation" )
    
    if canRotate == nil then
        obj.canRotate = true
    else
        obj.canRotate = canRotate
    end

    return obj
end

function Entity:syncRotate()
    if self.rotation > 0 then
        self.inOutSides = utils.cyclicShift( self.inOutSides, self.rotation )
    end
end

function Entity:getSprite()

end

function Entity:getAngle()
    local angles = { 0, 90, 180, 270 }
    local angle = angles[self.rotation + 1]
    return math.rad( angle )
end

function Entity:getType()
    return self.type
end

function Entity:rotate()
    self.rotation = ( self.rotation + 1 ) % 4
    self.inOutSides = utils.cyclicShift( self.inOutSides, 1 )
end

function Entity:isPowered()
    return next( self.inputObjects ) ~= nil
end

function Entity:haveInSide( side )
    return self.inOutSides[side]
end

function Entity:haveOutSide( side )
    return self.inOutSides[side]
end

function Entity:isPowerEntity( entity )
    for _, entry in pairs( self.outputObjects ) do
        if entry.entity == entity then
            return true
        end
    end
    return false
end

function Entity:checkInputPower( row, col, board, boardSize )

    -- излучатель не может принимать энергию
    if self.type == EntityType.Emitter then return end

    self.prevInputObjects = self.inputObjects
    self.inputObjects = { nil, nil, nil, nil }

    for side, canReceiveFromSide in ipairs( self.inOutSides ) do

        -- проверяем что мы можем принять энергию с этой стороны
        if canReceiveFromSide then

            -- получаем координаты клетки для этой стороны
            local neighborRow = row + self.neighborOffsets[side][1]
            local neighborCol = col + self.neighborOffsets[side][2]

            -- проверяем что не вышли за сетку
            if neighborRow >= 1 and neighborRow <= boardSize and neighborCol >= 1 and neighborCol <= boardSize then

                -- получаем объект из клетки
                local entity = board[neighborRow][neighborCol]

                -- если объект в клетке существует
                if entity ~= nil then

                    -- проверяем что объект запитан
                    if entity:isPowered() then

                        local oppositeSide = self.oppositeSides[side]

                        -- мы не можем питаться от того кого мы питаем и от
                        -- объекта который не может передать питание в нашу сторону,
                        -- но мы можем получить питание, даже если уже запитаны
                        local powerThem = self:isPowerEntity( entity )
                        local haveOutSide = entity:haveOutSide( oppositeSide )

                        local canPowerUs = not powerThem and haveOutSide

                        -- если объект может нас питать
                        if canPowerUs then

                            -- то добавляем его в список питающихся объектов
                            self.inputObjects[side] = { entity = entity, row = neighborRow, col = neighborCol }
                        end
                    end
                end
            end
        end
    end
end

function Entity:checkOutputPower( row, col, board, boardSize )

    self.prevOutputObjects = self.outputObjects
    self.outputObjects = { nil, nil, nil, nil }

    if not self:isPowered() then return end

    -- перебираем все стороны
    for side, canTransmitToSide in ipairs( self.inOutSides ) do
    
        -- базовая проверка, что мы можем питать эту сторону
        if canTransmitToSide then

            -- получаем координаты соседней клетке
            local neighborRow = row + self.neighborOffsets[side][1]
            local neighborCol = col + self.neighborOffsets[side][2]

            -- проверяем что не выходим за границу сетки
            if neighborRow >= 1 and neighborRow <= boardSize and neighborCol >= 1 and neighborCol <= boardSize then

                -- пытаемся получить объект на соседей клетке
                local entity = board[neighborRow][neighborCol]

                -- если объект на соседей клетке существует
                if entity ~= nil then

                    local oppositeSide = self.oppositeSides[side]

                    -- мы не можем питать того кто питает нас, источник питания и объект который не может принять питание
                    -- но мы можем дополнительно запитать объект который уже запитан
                    local powerUs = entity:isPowerEntity( self )
                    local isEmitter = entity:getType() == EntityType.Emitter
                    local haveInSide = entity:haveInSide( oppositeSide )

                    local canPowerThem = not isEmitter and not powerUs and haveInSide

                    -- если мы можем питать объект
                    if canPowerThem then

                        -- то добавляем его в список питающих объектов
                        self.outputObjects[side] = { entity = entity, row = neighborRow, col = neighborCol }
                    end
                end
            end
        end
    end
end

function Entity:notifyPower( side, info )
    local oppositeSide = self.oppositeSides[side]
    self.outputObjects[oppositeSide] = info
end

function Entity:notifyUnpower( side )
    local oppositeSide = self.oppositeSides[side]
    self.outputObjects[oppositeSide] = nil
end

function Entity:update( row, col, board, boardSize )

    -- здесь мы получаем список объектов которые нас питают
    self:checkInputPower( row, col, board, boardSize )

    local addedObjects = utils.difference( self.inputObjects, self.prevInputObjects )
    local removedObjects = utils.difference( self.prevInputObjects, self.inputObjects )

    -- сообщаем объектам, что больше от них не питаемся
    for side, entry in pairs( removedObjects ) do
        entry.entity:notifyUnpower( side )
    end

    -- сообщаем объектам, что теперь питаемся от них
    for side, entry in pairs( addedObjects ) do
        local info = { entity = self, row = row, col = col }
        entry.entity:notifyPower( side, info )
    end

    -- здесь мы получаем список объектов которых мы питаем
    self:checkOutputPower( row, col, board, boardSize )

    addedObjects = utils.difference( self.outputObjects, self.prevOutputObjects )
    removedObjects = utils.difference( self.prevOutputObjects, self.outputObjects )

    -- выключаем питание у старых объектов
    for side, entry in pairs( removedObjects ) do
        entry.entity:unpower( side )
    end

    -- включаем питание у новых объектов
    for side, entry in pairs( addedObjects ) do       
        local info = { entity = self, row = row, col = col }
        entry.entity:power( side, entry.row, entry.col, board, boardSize, info )
    end
end

function Entity:power( side, row, col, board, boardSize, info_in )

    -- мы уже кем-то запитаны?
    local wasPowered = self:isPowered()

    -- добавляем в список питающих объектов
    local oppositeSide = self.oppositeSides[side]
    self.inputObjects[oppositeSide] = info_in

    -- если мы не были запитаны, то запитываем
    -- все объекты которые мы можем запитать
    if not wasPowered then

        -- здесь мы получаем список объектов
        -- которых мы можем запитать
        self:checkOutputPower( row, col, board, boardSize )

        -- включаем питание у новых объектов
        for side, entry in pairs( self.outputObjects ) do            
            local info_out = { entity = self, row = row, col = col }
            entry.entity:power( side, entry.row, entry.col, board, boardSize, info_out )
        end
    end
end

function Entity:unpower( side )

    -- убираем из списка питающих объектов
    local oppositeSide = self.oppositeSides[side]
    self.inputObjects[oppositeSide] = nil

    -- нас всё ещё кто-то питает
    if self:isPowered() then return end

    -- у нас больше нет питания, нужно убрать
    -- питание у всех кого мы питаем
    for side, entry in pairs( self.outputObjects ) do
        entry.entity:unpower( side )
        self.outputObjects[side] = nil
    end
end

return {
    Entity = Entity,
    EntityType = EntityType,
    Side = Side
}

