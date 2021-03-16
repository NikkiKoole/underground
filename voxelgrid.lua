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
   self.rowCacheMax = {}
   self.rowCacheMin = {}
   for i = 1, resolution*2 + 1 do
      --self.rowCacheMax[i] = 1
      --self.rowCacheMin[i] = 1
   end
   
   self.edgeCacheMin = 0
   self.edgeCacheMax = 0
      
   return self
end

function makeMesh(vertices, triangles)
   local simple_format = {
      {"VertexPosition", "float", 3}, -- The x,y position of each vertex.
      --{"VertexColor", "float", 4}
   }
   if (#vertices == 0) then return nil end
   print(#vertices, #triangles, inspect(triangles))
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

   self:fillFirstRowCache()
   
   self:triangulateCellRows()

   if self.yNeighbor ~= nil then
      self:triangulateGapRow();
   end
   
   local r = love.math.random()
   for i = 1, #self.vertices do
      --print(inspect(self.vertices[i]), i)
      self.vertices[i] = {self.vertices[i][1] * 500, self.vertices[i][2] * 500, 0 }
   end
   
   self.mesh = makeMesh(self.vertices, self.triangles)
   --print(inspect(self.rowCacheMax) )
   for k,v in ipairs(self.rowCacheMax) do
      --print('kv', k, v)
   end
   --print()
   
end

function VoxelGrid:cacheFirstCorner(voxel)
   if (voxel.state) then

      table.insert(self.vertices, {voxel.position.x, voxel.position.y, 0})
      self.rowCacheMax[1] = #self.vertices + 1

   end

end

function VoxelGrid:cacheNextEdgeAndCorner (i, xMin, xMax)
   --print('test', i, xMin, xMax)
   --print(i, xMin.state, xMax.state)
   if (xMin.state ~= xMax.state) then
      self.rowCacheMax[i + 1] = #self.vertices 
      local data  = {xMin.xEdge,
         xMin.position.y,
         0}
         table.insert(self.vertices,  data)

   end

   if xMax.state then
      self.rowCacheMax[i + 2] = #self.vertices + 1
      table.insert(self.vertices, {xMax.position.x, xMax.position.y, 0})
   end
   
end


function VoxelGrid:fillFirstRowCache()
   self:cacheFirstCorner(self.voxels[1])
   
   
   for i = 1, self.resolution do
      self:cacheNextEdgeAndCorner(i*2, self.voxels[i], self.voxels[i+1])
     
   end
 
   local i = self.resolution 
   if self.xNeighbor ~= nil then
      self.dummyX:becomeXDummyOf(self.xNeighbor.voxels[1], self.gridSize)
      self:cacheNextEdgeAndCorner(i*2, self.voxels[i], self.dummyX);
   end
   
   
end


function VoxelGrid:swapRowCaches () 
--   print(self.rowCacheMin , self.rowCacheMax )
   local rowSwap = self.rowCacheMin
   self.rowCacheMin = self.rowCacheMax
   self.rowCacheMax = rowSwap
   --print(self.rowCacheMin , self.rowCacheMax )



   
end

function VoxelGrid:cacheNextMiddleEdge(yMin, yMax)
   self.edgeCacheMin = self.edgeCacheMax

   if yMin.state ~= yMax.state then
      self.edgeCacheMax = #self.vertices 
      table.insert(self.vertices, {yMin.position.x,yMin.yEdge,0})
   end
   
end

function VoxelGrid:triangulateCellRows()
   local index = 1
   local cells = self.resolution -1
   for y = 0, cells-1 do
      self:swapRowCaches()
      self:cacheFirstCorner(self.voxels[index + self.resolution])
      self:cacheNextMiddleEdge(self.voxels[index], self.voxels[index + self.resolution])
      for x = 0, cells-1 do
         
         --

         --print(index)
         local a = self.voxels[index]
         local b = self.voxels[index + 1]
         local c = self.voxels[index + self.resolution]
         local d = self.voxels[index + self.resolution + 1]

         local cacheIndex = (x * 2)
         self:cacheNextEdgeAndCorner(cacheIndex,c,d )
         self:cacheNextMiddleEdge(b, d)
         self:triangulateCell(cacheIndex, a, b, c, d)
       
         
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

   local cacheIndex = (self.resolution - 1) * 2

   self:cacheNextEdgeAndCorner(cacheIndex, self.voxels[i + self.resolution], self.dummyX)
   self:cacheNextMiddleEdge(self.dummyT, self.dummyX)
	
   self:triangulateCell(cacheIndex, self.voxels[i], self.dummyT,     self.voxels[i + self.resolution], self.dummyX)
end

function VoxelGrid:triangulateGapRow()
   self.dummyY:becomeYDummyOf(self.yNeighbor.voxels[1], self.gridSize)
   local cells = self.resolution -1
   local offset = cells * self.resolution
   self:swapRowCaches()
   self:cacheFirstCorner(self.dummyY)
   self:cacheNextMiddleEdge(self.voxels[cells * self.resolution], self.dummyY)

   for x = 1, cells do
      local dummySwap = self.dummyT;
      dummySwap:becomeYDummyOf(self.yNeighbor.voxels[x + 1], self.gridSize);
      self.dummyT = self.dummyY
      self.dummyY = dummySwap
      local cacheIndex = x * 2 + 1
      self:cacheNextEdgeAndCorner(cacheIndex, self.dummyT, self.dummyY)
      self:cacheNextMiddleEdge(self.voxels[x + offset + 1], self.dummyY)
		
      self:triangulateCell(cacheIndex, self.voxels[x + offset], self.voxels[x + offset + 1], self.dummyT, self.dummyY)
   end
   if (self.xNeighbor ~= nil) then
      local cacheIndex = cells  * 2
      self.dummyT:becomeXYDummyOf(self.xyNeighbor.voxels[1], self.gridSize)
      self:triangulateCell(cacheIndex, self.voxels[#self.voxels], self.dummyX, self.dummyY, self.dummyT)
   end
end

function VoxelGrid:triangulateCell(i, a,b,c,d)
   --print('triangulatecell', i,a,b,c,d)
   
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


   function addQuad2 (a, b, c, d) 
         table.insert(self.triangles, a)
         table.insert(self.triangles, b)
         table.insert(self.triangles, c)
         table.insert(self.triangles, a)
         table.insert(self.triangles, c)
         table.insert(self.triangles, d)
   end
   
   function addTriangle2(i, a, b, c)
      --print('addtriangle',i, a,b,c)
      table.insert(self.triangles, a)
      table.insert(self.triangles, b)
      table.insert(self.triangles, c)

   end
   function addPentagram2(a, b, c, d, e)
      table.insert(self.triangles, a)
      table.insert(self.triangles, b)
      table.insert(self.triangles, c)
      table.insert(self.triangles, a)
      table.insert(self.triangles, c)
      table.insert(self.triangles, d)
      table.insert(self.triangles, a)
      table.insert(self.triangles, d)
      table.insert(self.triangles, e)

      
   end
                                              

   
   if cellType == 0 then
   elseif cellType == 1 then
      --print(inspect(self.rowCacheMin))
      addTriangle2(i, self.rowCacheMin[i], self.edgeCacheMin, self.rowCacheMin[i + 1]);
      --  addTriangle(a.position, a.yEdgePosition, a.xEdgePosition)
   elseif cellType == 2 then
      	addTriangle2(self.rowCacheMin[i + 2], self.rowCacheMin[i + 1], self.edgeCacheMax)
         --addTriangle(b.position, a.xEdgePosition, b.yEdgePosition);
   elseif cellType == 3 then
      addQuad2(self.rowCacheMin[i], self.edgeCacheMin, self.edgeCacheMax, self.rowCacheMin[i + 2])
         --addQuad(a.position, a.yEdgePosition, b.yEdgePosition, b.position);
   elseif cellType == 4 then
      addTriangle2(self.rowCacheMax[i], self.rowCacheMax[i + 1], self.edgeCacheMin)
		
         --addTriangle(c.position, c.xEdgePosition, a.yEdgePosition);
   elseif cellType == 5 then
      	addQuad2(self.rowCacheMin[i], self.rowCacheMax[i], self.rowCacheMax[i + 1], self.rowCacheMin[i + 1])
         --addQuad(a.position, c.position, c.xEdgePosition, a.xEdgePosition);
      elseif cellType == 6 then
         -- special
         --addTriangle(b.position, a.xEdgePosition, b.yEdgePosition);
         --addTriangle(c.position, c.xEdgePosition, a.yEdgePosition);
         addTriangle2(self.rowCacheMin[i + 2], self.rowCacheMin[i + 1], self.edgeCacheMax)
         addTriangle2(self.rowCacheMax[i], self.rowCacheMax[i + 1], self.edgeCacheMin)
		
   elseif cellType == 7 then
      addPentagram2(self.rowCacheMin[i], self.rowCacheMax[i], self.rowCacheMax[i + 1], self.edgeCacheMax, self.rowCacheMin[i + 2])
         --addPentagon(a.position, c.position, c.xEdgePosition, b.yEdgePosition, b.position);
   elseif cellType == 8 then
      addTriangle2(self.rowCacheMax[i + 2], self.edgeCacheMax, self.rowCacheMax[i + 1])
         --addTriangle(d.position, b.yEdgePosition, c.xEdgePosition);
      elseif cellType == 9 then
         --addTriangle(a.position, a.yEdgePosition, a.xEdgePosition);
         --addTriangle(d.position, b.yEdgePosition, c.xEdgePosition);
         addTriangle2(self.rowCacheMin[i], self.edgeCacheMin, self.rowCacheMin[i + 1])
         addTriangle2(self.rowCacheMax[i + 2], self.edgeCacheMax, self.rowCacheMax[i + 1])
   elseif cellType == 10 then
      	addQuad2(self.rowCacheMin[i + 1], self.rowCacheMax[i + 1], self.rowCacheMax[i + 2], self.rowCacheMin[i + 2])
         --addQuad(a.xEdgePosition, c.xEdgePosition, d.position, b.position);
   elseif cellType == 11 then
      addPentagram2(self.rowCacheMin[i + 2], self.rowCacheMin[i], self.edgeCacheMin, self.rowCacheMax[i + 1], self.rowCacheMax[i + 2])
         --addPentagon(b.position, a.position, a.yEdgePosition, c.xEdgePosition, d.position);
   elseif cellType == 12 then
      	addQuad2(self.edgeCacheMin, self.rowCacheMax[i], self.rowCacheMax[i + 2], self.edgeCacheMax)
         --addQuad(a.yEdgePosition, c.position, d.position, b.yEdgePosition);
   elseif cellType == 13 then
      	addPentagram2(self.rowCacheMax[i], self.rowCacheMax[i + 2], self.edgeCacheMax, self.rowCacheMin[i + 1], self.rowCacheMin[i])
         --addPentagon(c.position, d.position, b.yEdgePosition, a.xEdgePosition, a.position);
   elseif cellType == 14 then
      	addPentagram2(self.rowCacheMax[i + 2],self.rowCacheMin[i + 2], self.rowCacheMin[i + 1], self.edgeCacheMin, self.rowCacheMax[i])
         --addPentagon(d.position, b.position, a.xEdgePosition, a.yEdgePosition, c.position);
   elseif cellType == 15 then
      addQuad2(self.rowCacheMin[i], self.rowCacheMax[i], self.rowCacheMax[i + 2], self.rowCacheMin[i + 2])
         --addQuad(a.position, c.position, d.position, b.position);
      end
end

function VoxelGrid:__tostring()
   return "<VoxelGrid: "..(#self.voxels)..">"
end


return VoxelGrid
