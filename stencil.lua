local Stencil = {}
Stencil.__index = Stencil

function Stencil:new()
   local o = {}
   setmetatable(o, self)
   self.__index = self
   o.radius = 2
   o.fillType = 1
   o.centerX = 0
   o.centerY = 0
   return o
end

function Stencil:setCenter(x,y)
   self.centerX = x
   self.centerY = y
end


function Stencil:xStart()
   return self.centerX - self.radius
end
function Stencil:xEnd()
   return self.centerX + self.radius
end
function Stencil:yStart()
   return self.centerY - self.radius
end
function Stencil:yEnd()
   return self.centerY + self.radius
end

function Stencil:apply(voxel, value, grid)
   --print(self:xStart(), voxel.position.x, voxel.position.y)
   --print(grid.localPos.x, grid.localPos.y)
   voxel.state = value
end


function Stencil:__tostring()
    return "<Stencil: "..">"
end
function Stencil:stuff()
   print(self)
   print('stencil stuff')
end

function Stencil:woof()
   print(self)
   print('woof stencil')
end

return Stencil
