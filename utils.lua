-- Oleg Kotov

local Utils = {}

function Utils.cyclicShift( array, shiftAmount )

    local length = #array
    shiftAmount = shiftAmount % length
  
    if shiftAmount < 0 then
      shiftAmount = length + shiftAmount
    end
  
    local shiftedArray = {}
  
    for i = 1, length do
      local newIndex = ( i + shiftAmount - 1 ) % length + 1
      shiftedArray[newIndex] = array[i]
    end
  
    return shiftedArray
end

function Utils.difference( a, b )
    local aa = {}

    for k, v in pairs( a ) do aa[k] = v end
    for k, v in pairs( b ) do aa[k] = nil end

    local ret = {}

    for k, v in pairs( a ) do
        if aa[k] then
            ret[k] = v
        end
    end

    return ret
end

return Utils

