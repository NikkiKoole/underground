local Voxel = require './voxel'
local inspect = require './inspect'
local VoxelGrid = {}
VoxelGrid.__index = VoxelGrid

function VoxelGrid:new(resolution, size)
   local self = setmetatable({}, VoxelGrid)
   self.gridSize = size
   self.voxelSize = size / resolution
   self.voxels = {}
   self.xNeighbor = nil
   self.yNeighbor = nil
   self.xyNeighbor = nil
   self.dummyX = Voxel:createEmpty()
   self.dummyY = Voxel:createEmpty()
   self.dummyT = Voxel:createEmpty()
   local index = 1
   for y = 0, resolution-1 do
      for x = 0, resolution-1 do
         self.voxels[index] = Voxel:new(x, y, self.voxelSize)
         index = index + 1
      end
   end
   self.resolution = resolution
   print(resolution)
   return self
end

function makeMesh(vertices, triangles)
   local simple_format = {
      {"VertexPosition", "float", 3}, -- The x,y position of each vertex.
      --{"VertexColor", "float", 4}
   }
   if (#vertices == 0) then return nil end
   local mesh = love.graphics.newMesh(simple_format, vertices, 'triangles')
   mesh:setVertexMap(triangles)
   return mesh
end


function VoxelGrid:triangulate()
   self.vertices = {}
   self.triangles = {}
   
   if self.xNeighbor ~= nil then
      self.dummyX:becomeXDummyOf(self.xNeighbor.voxels[1], self.gridSize)
   end
   
   self:triangulateCellRows()

   if self.yNeighbor ~= nil then
      self:triangulateGapRow();
   end
   
   local r = love.math.random()
   for i = 1, #self.vertices do
      self.vertices[i] = {self.vertices[i][1] * 500, self.vertices[i][2] * 500, 0 }
   end
   
   self.mesh = makeMesh(self.vertices, self.triangles)
   
end
function VoxelGrid:triangulateCellRows()
   local index = 1
   local cells = self.resolution -1
   for y = 0, cells-1 do
      
      for x = 0, cells-1 do
         self:triangulateCell(self.voxels[index] ,
                              self.voxels[index+1],
                              self.voxels[index + self.resolution],
                              self.voxels[index + self.resolution + 1])
        
         
         index = index +1
      end
      if self.xNeighbor ~= nil then
         self:triangulateGapCell(index)
      end
      index = index +1
   end

end

function VoxelGrid:triangulateGapCell(i)
   local dummySwap = self.dummyT
   dummySwap:becomeXDummyOf(self.xNeighbor.voxels[i + 1], self.gridSize )
   self.dummyT = self.dummyX
   self.dummyX = dummySwap
   self:triangulateCell(self.voxels[i], self.dummyT,     self.voxels[i + self.resolution], self.dummyX)
end

function VoxelGrid:triangulateGapRow()
   self.dummyY:becomeYDummyOf(self.yNeighbor.voxels[1], self.gridSize)
   local cells = self.resolution -1
   local offset = cells * self.resolution

   for x = 1, cells do
      local dummySwap = self.dummyT;
      dummySwap:becomeYDummyOf(self.yNeighbor.voxels[x + 1], self.gridSize);
      self.dummyT = self.dummyY
      self.dummyY = dummySwap
      self:triangulateCell(self.voxels[x + offset], self.voxels[x + offset + 1], self.dummyT, self.dummyY)
   end
   if (self.xNeighbor ~= nil) then
      self.dummyT:becomeXYDummyOf(self.xyNeighbor.voxels[1], self.gridSize)
      self:triangulateCell(self.voxels[#self.voxels], self.dummyX, self.dummyY, self.dummyT)
   end
end

function VoxelGrid:apply(stencil, value)
   -- --print('voxelgrid apply: ', self.localPos.x, self.localPos.y)
   -- local xStart= stencil:xStart()
   -- print('xStart before', xStart)
   -- if xStart < 0 then xStart = 0 end
   
   -- local xEnd= stencil:xEnd() 
   -- print('xEnd before', xEnd)

   -- if xEnd > self.resolution then xEnd = self.resolution end

   -- local yStart= stencil:yStart() 
   -- if yStart < 0 then yStart = 0 end
   -- local yEnd= stencil:yEnd()
   -- if yEnd > self.resolution then yEnd = self.resolution end

   -- for y = yStart, yEnd do
   --    for x = xStart, xEnd do
   --       local i = math.floor(y) * self.resolution + math.floor(x)
   --       i = i + 1
   --       if i <= #self.voxels then
   --          --print(i)
   --          print(x, y)
   --          stencil:apply(self.voxels[i], value)

            
   --          --self.voxels[i].state = value
   --       end
   --    end
   -- end
end


function VoxelGrid:triangulateCell(a,b,c,d)
   local cellType = 0
   if (a.state == 1) then
      cellType = cellType + 1
   end
   if (b.state == 1) then
      cellType = cellType + 2
   end
   if (c.state == 1) then
      cellType = cellType + 4
   end
   if (d.state == 1) then
      cellType = cellType + 8
   end


   function addPentagon(a,b,c,d,e)
      local vertexIndex = #self.vertices + 1
      table.insert(self.vertices, {a.x, a.y, 0})
      table.insert(self.vertices, {b.x, b.y, 0})
      table.insert(self.vertices, {c.x, c.y, 0})
      table.insert(self.vertices, {d.x, d.y, 0})
      table.insert(self.vertices, {e.x, e.y, 0})

      table.insert(self.triangles, vertexIndex)
      table.insert(self.triangles, vertexIndex + 1)
      table.insert(self.triangles, vertexIndex + 2)
      table.insert(self.triangles, vertexIndex)
      table.insert(self.triangles, vertexIndex + 2)
      table.insert(self.triangles, vertexIndex + 3)
      table.insert(self.triangles, vertexIndex)
      table.insert(self.triangles, vertexIndex + 3)
      table.insert(self.triangles, vertexIndex + 4)

   end
   
   function addQuad(a,b,c,d)
      local vertexIndex = #self.vertices + 1
      table.insert(self.vertices, {a.x, a.y, 0})
      table.insert(self.vertices, {b.x, b.y, 0})
      table.insert(self.vertices, {c.x, c.y, 0})
      table.insert(self.vertices, {d.x, d.y, 0})

      table.insert(self.triangles, vertexIndex)
      table.insert(self.triangles, vertexIndex + 1)
      table.insert(self.triangles, vertexIndex + 2)
      table.insert(self.triangles, vertexIndex)
      table.insert(self.triangles, vertexIndex + 2)
      table.insert(self.triangles, vertexIndex + 3)
   end
   
   
   function addTriangle(a,b,c)
      local vertexIndex = #self.vertices + 1
      table.insert(self.vertices, {a.x, a.y, 0})
      table.insert(self.vertices, {b.x, b.y, 0})
      table.insert(self.vertices, {c.x, c.y, 0})

      table.insert(self.triangles, vertexIndex)
      table.insert(self.triangles, vertexIndex + 1)
      table.insert(self.triangles, vertexIndex + 2)
   end

   
   if cellType == 0 then
      elseif cellType == 1 then
         addTriangle(a.position, a.yEdgePosition, a.xEdgePosition)
      elseif cellType == 2 then
         addTriangle(b.position, a.xEdgePosition, b.yEdgePosition);
      elseif cellType == 3 then
         addQuad(a.position, a.yEdgePosition, b.yEdgePosition, b.position);
      elseif cellType == 4 then
         addTriangle(c.position, c.xEdgePosition, a.yEdgePosition);
      elseif cellType == 5 then
         addQuad(a.position, c.position, c.xEdgePosition, a.xEdgePosition);
      elseif cellType == 6 then
         -- special
         addTriangle(b.position, a.xEdgePosition, b.yEdgePosition);
         addTriangle(c.position, c.xEdgePosition, a.yEdgePosition);
      elseif cellType == 7 then
         addPentagon(a.position, c.position, c.xEdgePosition, b.yEdgePosition, b.position);
      elseif cellType == 8 then
         addTriangle(d.position, b.yEdgePosition, c.xEdgePosition);
      elseif cellType == 9 then
         addTriangle(a.position, a.yEdgePosition, a.xEdgePosition);
         addTriangle(d.position, b.yEdgePosition, c.xEdgePosition);
      elseif cellType == 10 then
         addQuad(a.xEdgePosition, c.xEdgePosition, d.position, b.position);
      elseif cellType == 11 then
         addPentagon(b.position, a.position, a.yEdgePosition, c.xEdgePosition, d.position);
      elseif cellType == 12 then
         addQuad(a.yEdgePosition, c.position, d.position, b.yEdgePosition);
      elseif cellType == 13 then
         addPentagon(c.position, d.position, b.yEdgePosition, a.xEdgePosition, a.position);
      elseif cellType == 14 then
         addPentagon(d.position, b.position, a.xEdgePosition, a.yEdgePosition, c.position);
      elseif cellType == 15 then
         addQuad(a.position, c.position, d.position, b.position);
      end
end

function VoxelGrid:__tostring()
   return "<VoxelGrid: "..(#self.voxels)..">"
end


return VoxelGrid
