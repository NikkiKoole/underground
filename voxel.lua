local Voxel = {}
Voxel.__index = Voxel

function polarize(value)
   return value > .5 and 1 or 0 
end

function Voxel:createEmpty()
   local self = setmetatable({}, Voxel)
   -- self.state = nil
   -- self.position = nil
   -- self.xEdgePosition = nil
   -- self.yEdgePosition = nil

   return self
end

function Voxel:new(x, y, size)
   local self = setmetatable({}, Voxel)
   self.state           = 0 -- polarize(love.math.random())
   self.position        = {x=(x+.5) * size, y=(y+.5) * size}
   
   self.xEdgePosition   = {x=self.position.x + (size*.5), y=self.position.y}
   self.yEdgePosition   = {x=self.position.x , y=self.position.y + (size*.5)}
   --print(x,y, x%16, y%16)

   --local wigglex = ((x%16)/16) -.5
   --local wiggley = ((y%16)/16) -.5
   --print(x, wigglex)
   --self.xEdgePosition   = {x=self.position.x + (size*.5) + wigglex*.1, y=self.position.y + wiggley*.1 }
   --self.yEdgePosition   = {x=self.position.x +  wigglex*.05  , y=self.position.y + (size*.5) +  wiggley*.05 }
  
   self.xEdge = self.position.x + size*.5
   self.yEdge = self.position.y + size*.5

   return self
end

function Voxel:becomeXDummyOf(voxel, offset)
   self.state = voxel.state
   self.position = {
      x = voxel.position.x,
      y = voxel.position.y,
   }

   self.xEdgePosition = {
      x = voxel.xEdgePosition.x,
      y = voxel.xEdgePosition.y
   }
   
   self.yEdgePosition = {
      x = voxel.yEdgePosition.x,
      y = voxel.yEdgePosition.y
   }
   self.position.x = self.position.x + offset
   self.xEdgePosition.x = self.xEdgePosition.x + offset
   self.yEdgePosition.x = self.yEdgePosition.x + offset

   self.xEdge = voxel.xEdge + offset
   self.yEdge = voxel.yEdge
end

function Voxel:becomeYDummyOf(voxel, offset)
   self.state = voxel.state
   self.position  = {
      x = voxel.position.x,
      y = voxel.position.y,
   }
   self.xEdgePosition = {
      x = voxel.xEdgePosition.x,
      y = voxel.xEdgePosition.y
   }
   self.yEdgePosition = {
      x = voxel.yEdgePosition.x,
      y = voxel.yEdgePosition.y
   }
  
   self.position.y = self.position.y + offset
   self.xEdgePosition.y = self.xEdgePosition.y + offset
   self.yEdgePosition.y = self.yEdgePosition.y + offset

   self.xEdge = voxel.xEdge;
   self.yEdge = voxel.yEdge + offset;
end

function Voxel:becomeXYDummyOf(voxel, offset)
   self.state = voxel.state
   self.position = {
      x = voxel.position.x,
      y = voxel.position.y,
   }
   self.xEdgePosition = {
      x = voxel.xEdgePosition.x,
      y = voxel.xEdgePosition.y
   }
   self.yEdgePosition = {
      x = voxel.yEdgePosition.x,
      y = voxel.yEdgePosition.y
   }
   self.position.x = self.position.x + offset
   self.position.y = self.position.y + offset
   self.xEdgePosition.x = self.xEdgePosition.x + offset
   self.yEdgePosition.x = self.yEdgePosition.x + offset
   self.xEdgePosition.y = self.xEdgePosition.y + offset
   self.yEdgePosition.y = self.yEdgePosition.y + offset

   self.xEdge = voxel.xEdge + offset;
   self.yEdge = voxel.yEdge + offset;
end



function Voxel:__tostring()
    return "<Voxel: "..self.position.x..", "..self.position.y..">"
end

return Voxel
