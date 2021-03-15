local VoxelGrid = require './voxelgrid'

local VoxelMap = {}
VoxelMap.__index = VoxelMap

local fillTypeNames = {"Filled", "Empty"}

function VoxelMap:__tostring()
    return "<VoxelMap: "..self.voxelResolution..", "..self.chunkResolution..">"
end

function VoxelMap.new(voxelResolution, chunkResolution)
   local self = setmetatable({}, VoxelMap)
   self.voxelResolution = voxelResolution
   self.chunkResolution = chunkResolution
   self.size = 2.0
   self.halfSize = self.size*.5
   self.chunkSize = self.size / chunkResolution
   self.voxelSize = self.chunkSize / voxelResolution
   self.chunks = {}
   
   local index = 1
   for y = 0, chunkResolution-1 do
      for x = 0, chunkResolution-1 do
         local chunk = VoxelGrid:new(voxelResolution, self.chunkSize)
         chunk.localPos = {x = x * self.chunkSize - self.halfSize,
                           y = y * self.chunkSize - self.halfSize }

         if x > 0 then
            self.chunks[index - 1].xNeighbor = chunk
         end
         if y > 0 then
            self.chunks[index - chunkResolution].yNeighbor = chunk
            if x > 0 then
               self.chunks[index - chunkResolution - 1].xyNeighbor = chunk
            end
         end
         
         self.chunks[index] = chunk
         index = index + 1 
      end
   end

   for i = #self.chunks, 1, -1 do
      self.chunks[i]:triangulate()
   end

   return self
end



function VoxelMap:editVoxels(point, value, radius, formtype)
   
   local useFloat = true
   local centerX, centerY
   if (useFloat) then
      centerX = ((point.x) / self.voxelSize)  --+.5
      centerY = ((point.y) / self.voxelSize)  -- +.5
   else
      centerX = math.floor((point.x) / self.voxelSize) --- .5
      centerY = math.floor((point.y) / self.voxelSize) --- .5
   end

   
   -- radius goes from 0 to 5?
   local radius = radius
   local xStart = (centerX - radius  - 0) / self.voxelResolution
   if xStart < 0 then xStart = 0 end
   local xEnd = (centerX + radius  - 0) / self.voxelResolution
   if xEnd > self.chunkResolution then xEnd = self.chunkResolution end 

   local yStart = (centerY - radius + 0) / self.voxelResolution
   if yStart < 0 then yStart = 0 end
   local yEnd = (centerY + radius - 0 ) / self.voxelResolution
   if yEnd > self.chunkResolution then yEnd = self.chunkResolution end

   for voxelY = math.floor((yEnd ) * self.voxelResolution), math.floor(yStart  * self.voxelResolution), -1 do
      for voxelX = math.floor(xEnd * self.voxelResolution), math.floor(xStart  * self.voxelResolution), -1 do

         -- begin rect ?
         local draw = true

         
         local chunkX = math.floor(voxelX / self.voxelResolution)
         local chunkY = math.floor(voxelY / self.voxelResolution)
         local chunkIndex =  math.floor(chunkX) + (math.floor(chunkY) * self.chunkResolution)
         local voxelX2 = (voxelX % self.voxelResolution) 
         local voxelY2 = (voxelY % self.voxelResolution) 

         local voxelIndex =  math.floor(voxelX2) + (math.floor(voxelY2) * self.voxelResolution)
         -- end rect

         -- begi circle
         if formtype == 'circle' then
            local px = centerX 
            local py = centerY 
            local x = voxelX - px
            local y = voxelY - py
         
            local doCircle = true
            if doCircle then
               draw = false
               if (x * x + y * y <= (radius^2)) then
                  draw = true
               end
            end
         end
         
         
         -- end circle
         --print( self.chunkResolution^2, , self.voxelResolution^2, voxelIndex )

         if chunkIndex < self.chunkResolution^2 and voxelIndex < self.voxelResolution^2 then
            if value > -1  and draw then
               --print(voxelIndex, self.voxelResolution^2)
               self.chunks[chunkIndex + 1].voxels[voxelIndex + 1].state = value
            end
         end


      end
   end
   

   if (value > -1) then
      for chunkY = math.floor(yEnd) , math.floor(yStart) , -1 do
         for chunkX = math.floor(xEnd) , math.floor(xStart) , -1 do
            local chunkIndex =  math.floor(chunkX) + (math.floor(chunkY) * self.chunkResolution)
            if chunkIndex < self.chunkResolution^2  then
               self.chunks[chunkIndex + 1]:triangulate()
            end
         end
      end
 end
   
   return xStart, yStart,xEnd, yEnd,
   centerX/self.voxelResolution, centerY/ self.voxelResolution
end

return VoxelMap

