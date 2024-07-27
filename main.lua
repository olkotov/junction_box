-- Oleg Kotov

local Emitter = require( "emitter" )
local Receiver = require( "receiver" )
local Straight = require( "straight" )
local Cross = require( "cross" )
local ThreeWay = require( "three_way" )
local NinetyDegree = require( "ninety_degree" )

local Rotator = require( "rotator" )

local EntityModule = require( "entity" )
local EntityType = EntityModule.EntityType
local Side = EntityModule.Side

local cellSize -- in px
local boardSize = 8
local board = {}

local sprites

local gameState = ""

-------------------------------------------------------------------

function loadImages()
    sprites = {
        ["background_dark"] = love.graphics.newImage( "images/bg_dark.png" ),
        ["background_light"] = love.graphics.newImage( "images/bg_light.png" ),
        ["bg_non_rotateble"] = love.graphics.newImage( "images/bg_non_rotateble.png" ),
        ["emitter_unpowered"] = love.graphics.newImage( "images/emitter_unpowered.png" ),
        ["emitter_powered"] = love.graphics.newImage( "images/emitter_powered.png" ),
        ["receiver_unpowered"] = love.graphics.newImage( "images/receiver_unpowered.png" ),
        ["receiver_powered"] = love.graphics.newImage( "images/receiver_powered.png" ),
        ["straight_unpowered"] = love.graphics.newImage( "images/straight_unpowered.png" ),
        ["straight_powered"] = love.graphics.newImage( "images/straight_powered.png" ),
        ["cross_unpowered"] = love.graphics.newImage( "images/cross_unpowered.png" ),
        ["cross_powered"] = love.graphics.newImage( "images/cross_powered.png" ),
        ["three_way_unpowered"] = love.graphics.newImage( "images/three_way_unpowered.png" ),
        ["three_way_powered"] = love.graphics.newImage( "images/three_way_powered.png" ),
        ["ninety_degree_unpowered"] = love.graphics.newImage( "images/ninety_degree_unpowered.png" ),
        ["ninety_degree_powered"] = love.graphics.newImage( "images/ninety_degree_powered.png" ),
        ["rotator"] = love.graphics.newImage( "images/rotator.png" ),
    }
end


function reset()
    gameState = ""
end

function initBoard()

    -- row 1
    local _11 = Rotator:new()
    local _12 = NinetyDegree:new( 2, false )
    local _13 = NinetyDegree:new( 1 )
    local _14 = Straight:new( 0, false )
    local _15 = NinetyDegree:new( 2 )
    local _16 = Rotator:new()
    local _17 = Straight:new()
    local _18 = NinetyDegree:new( 1 )

    -- row 2
    local _21 = NinetyDegree:new( 2 )
    local _22 = Straight:new()
    local _23 = NinetyDegree:new()
    local _24 = Rotator:new()
    local _25 = Straight:new( 1, false )
    local _26 = Straight:new( 1 )
    local _27 = Straight:new()
    local _28 = NinetyDegree:new()

    -- row 3
    local _31 = NinetyDegree:new( 1 )
    local _32 = NinetyDegree:new( 3 )
    local _33 = NinetyDegree:new( 1 )
    local _34 = NinetyDegree:new( 2 )
    local _35 = NinetyDegree:new( 1 )
    local _36 = NinetyDegree:new( 2 )
    local _37 = NinetyDegree:new()
    local _38 = NinetyDegree:new( 2 )

    -- row 4
    local _41 = Straight:new()
    local _42 = NinetyDegree:new( 1 )
    local _43 = NinetyDegree:new( 2 )
    local _44 = NinetyDegree:new( 1 )
    local _45 = NinetyDegree:new( 3 )
    local _46 = Straight:new()
    local _47 = Straight:new( 1, false )
    local _48 = Straight:new()

    -- row 5
    local _51 = Straight:new( 1, false )
    local _52 = NinetyDegree:new( 3 )
    local _53 = Straight:new()
    local _54 = Straight:new()
    local _55 = NinetyDegree:new( 3 )
    local _56 = Straight:new( 1, false )
    local _57 = Rotator:new()
    local _58 = Straight:new( 1, false )

    -- row 6
    local _61 = Rotator:new()
    local _62 = Straight:new( 1, false )
    local _63 = NinetyDegree:new()
    local _64 = NinetyDegree:new( 3 )
    local _65 = Rotator:new()
    local _66 = Straight:new()
    local _67 = NinetyDegree:new( 1 )
    local _68 = NinetyDegree:new( 3 )

    -- row 7
    local _71 = NinetyDegree:new( 2 )
    local _72 = NinetyDegree:new( 0 , false )
    local _73 = Rotator:new()
    local _74 = NinetyDegree:new()
    local _75 = NinetyDegree:new( 3 )
    local _76 = Straight:new()
    local _77 = Straight:new()
    local _78 = Emitter:new( 2 )

    -- row 8
    local _81 = NinetyDegree:new()
    local _82 = Straight:new()
    local _83 = Straight:new()
    local _84 = Receiver:new( 3 )
    local _85 = Rotator:new()
    local _86 = NinetyDegree:new()
    local _87 = Straight:new()
    local _88 = NinetyDegree:new( 3 )
    
    board = {
        { _11, _12, _13, _14, _15, _16, _17, _18 },
        { _21, _22, _23, _24, _25, _26, _27, _28 },
        { _31, _32, _33, _34, _35, _36, _37, _38 },
        { _41, _42, _43, _44, _45, _46, _47, _48 },
        { _51, _52, _53, _54, _55, _56, _57, _58 },
        { _61, _62, _63, _64, _65, _66, _67, _68 },
        { _71, _72, _73, _74, _75, _76, _77, _78 },
        { _81, _82, _83, _84, _85, _86, _87, _88 }
    }

    -- activate emitter
    _78:update( 7, 8, board, boardSize )
end

-------------------------------------------------------------------

function checkWin()

    if gameState == "win" then return end

    -- just check one reseiver in my case (hardcode)
    -- you can use arrays and cycles for emitter and receivers

    local receiver = board[8][4]

    if receiver:isPowered() then
        gameState = "win"
        print( "YOU WIN!" ) 
    end
end

-------------------------------------------------------------------

function love.mousepressed( x, y, button )
    
    -- if game is over, ignore clicks
    if gameState == "win" then return end

    -- if not left mouse button, ignore clicks
    if button ~= 1 then return end

    local row = math.floor( y / cellSize ) + 1
    local col = math.floor( x / cellSize ) + 1

    local entity = board[row][col]

    local isClickedInBoard = row >= 1 and row <= boardSize and col >= 1 and col <= boardSize
    local isCellFilled = entity ~= nil

    if isClickedInBoard and isCellFilled then

        local canRotate = entity.canRotate
        local isRotator = entity:getType() == EntityType.Rotator

        if canRotate and not isRotator then
            entity:rotate()
            entity:update( row, col, board, boardSize )
        end

        if isRotator then
            entity:update( row, col, board, boardSize )
        end

        checkWin()
    end
end

-------------------------------------------------------------------

function drawCell( cellSprite, row, col )
    local drawX = ( col - 1 ) * cellSize
    local drawY = ( row - 1 ) * cellSize
    love.graphics.draw( cellSprite, drawX, drawY )
end

function drawCells()
    for row = 1, boardSize do
        for col = 1, boardSize do
            local cellSprite
            if ( row + col ) % 2 ~= 0 then
                cellSprite = sprites["background_light"]
            else
                cellSprite = sprites["background_dark"]
            end
            drawCell( cellSprite, row, col )
        end
    end
end

function drawEntity( entity, row, col )

    local tileSprite = sprites[entity:getSprite()]

    local halfSize = cellSize * 0.5

    local drawX = ( col - 1 ) * cellSize + halfSize
    local drawY = ( row - 1 ) * cellSize + halfSize

    if not entity.canRotate then
        love.graphics.draw( sprites["bg_non_rotateble"], drawX, drawY, 0, 1, 1, halfSize, halfSize )
    end

    love.graphics.draw( tileSprite, drawX, drawY, entity:getAngle(), 1, 1, halfSize, halfSize )
end

function drawEntities()

    for row = 1, boardSize do
        for col = 1, boardSize do
            local entity = board[row][col]

            if entity ~= nil then
                drawEntity( entity, row, col )
            end
        end
    end
end

-------------------------------------------------------------------

function love.load()

    print( "game started" )

    loadImages()

    cellSize = sprites["background_dark"]:getWidth()

    local screenHeight = cellSize * boardSize
    local screenWidth = screenHeight

    love.window.setMode( screenWidth, screenHeight )
    love.window.setTitle( "Junction Box" )

    initBoard()
end

function love.draw()

    -- background color
    love.graphics.clear( 63/255, 124/255, 182/255 )
    
    drawCells()
    drawEntities()
end

function love.keypressed( key )

    if key == "r" then
        print( "restart" )
        reset()
        initBoard()
    end
end

