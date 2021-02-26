function createMeshGrid(resolution, size, voxels)

   -- vertices
   local vertices = {}
   local v = 1
   local stepSize = 1.0/resolution
   for y = 0, resolution do
      for x = 0, resolution do
         vertices[v] = { x * stepSize , y * stepSize , 0 } 
         v = v + 1
      end
   end
   

   -- triangle indices
   local tris = {}
   local t = 1
   local v1= 1
   for y = 0, resolution-1 do
      for x = 0, resolution-1 do
         local index = y * (resolution) + x

         if (voxels[index + 1].state == 0) then  -- cheap way of turning it off
            for i = 0, 5 do
               tris[t+i] = 1
            end
         else
            tris[t]   = v1 
            tris[t+1] = v1 + resolution + 1
            tris[t+2] = v1 + 1
            tris[t+3] = v1 + 1
            tris[t+4] = v1 + resolution + 1
            tris[t+5] = v1 + resolution + 2
         end
         t = t + 6
         v1 = v1+1
      end
      v1 = v1+1

   end
   -----
   


   local simple_format = {
      {"VertexPosition", "float", 3} -- The x,y position of each vertex.
   }

   for i = 1, #vertices do
      vertices[i][1] =  vertices[i][1] * size  
      vertices[i][2] =  vertices[i][2] * size 
   end

   local mesh = love.graphics.newMesh(simple_format, vertices, 'triangles')
   mesh:setVertexMap(tris)
   --mesh:setDrawRange(1, 6)
   
   return mesh
end
