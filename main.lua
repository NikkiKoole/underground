-- https://catlikecoding.com/unity/tutorials/marching-squares-series/
--https://catlikecoding.com/unity/tutorials/marching-squares-3/
-- http://jamie-wong.com/2014/08/19/metaballs-and-marching-squares/
-- https://dmahr1.github.io/618-final/midpoint.html
-- https://github.com/jasonwebb/morphogenesis-resources
-- isolines isobands
-- https://en.wikipedia.org/wiki/Marching_squares#Isobands
--https://www.cs.carleton.edu/cs_comps/0405/shape/marching_cubes.html
--http://arindam-1993.blogspot.com/2016/09/metaballs-using-marching-squares-in.html
-- https://jasonwebb.github.io/reaction-diffusion-playground/

local inspect = require 'inspect'

-- ui stuff
function pointInRect(x,y, rx, ry, rw, rh)
   if x < rx or y < ry then return false end
   if x > rx+rw or y > ry+rh then return false end
   return true
end

function pointInCircle(x,y, cx, cy, cr)
   local dx = x -cx
   local dy = y -cy
   local d  = math.sqrt ((dx*dx) + (dy*dy))
   return cr > d
end

function handleMouseClickStart()
   mouseState.hoveredSomething = false
   mouseState.down = love.mouse.isDown(1 )
   mouseState.click = false
   mouseState.released = false
   if mouseState.down ~= mouseState.lastDown then
      if mouseState.down  then
         mouseState.click  = true
      else
	 mouseState.released = true
      end
   end
   mouseState.lastDown =  mouseState.down
end

function labelButton(x,y,label, selected )
   local result= false
   local w = font and font:getWidth( label ) or love.graphics.getFont():getWidth(label)
   local h = font and font:getHeight( label ) or love.graphics.getFont():getHeight(label) 

   love.graphics.setColor(0,0,0)
   if selected then
      love.graphics.setColor(.3,.3,.3)
   end
   
   love.graphics.rectangle('fill',x-5,y-2,w+10,h+4)
   love.graphics.setColor(1,1,1)
   love.graphics.rectangle('line',x-5,y-2,w+10,h+4)
   love.graphics.print(label, x, y)

   if mouseState.click then
      local mx, my = love.mouse.getPosition( )
      if pointInRect(mx,my, x,y,w,h) then
         result = true
      end
   end

   return {
      clicked=result
   }
end
function getUIRect(id, x,y,w,h)
  local result = false
  if mouseState.click then
     local mx, my = love.mouse.getPosition( )
     if pointInRect(mx,my,x,y,w,h) then
        result = true
     end
   end
  
   return {
      clicked=result
   }
end

-- end ui stuff

function love.keypressed(key)
   if key == 'escape' then
      love.event.quit()
   end
   noise()
end

function polarize(value)
   return value > .5 and 1 or 0 
end

function noise()
   local seed = love.math.random() * 2^24
   love.math.setRandomSeed(seed)
   local offsetX = love.math.random() * 2^12
   local offsetY = love.math.random() * 2^12

   local octaves = {3*13*4, 3*13*3, 3*13*.33}
   for x = 1, 128 do
      for y = 1, 128 do
         grid[x] = grid[x] or {}

         local octave1 =  love.math.noise((offsetX + x)/octaves[1], (offsetY + y)/octaves[1])
         local octave2 =  love.math.noise((offsetX + x)/octaves[2], (offsetY + y)/octaves[2])
         local octave3 =  love.math.noise((offsetX + x)/octaves[3], (offsetY +  y)/octaves[3])
         grid[x][y] = polarize(octave1*.33 + octave2*.33 + octave3*.33) 
      end
   end
end

function love.load()
   love.window.setMode(1124, 1124, {resizable=true, vsync=true, fullscreen=false})
   colors = {
      bg    = {.95, .89, .73},
      sand  = {.79, .73, .59},
      brown = {.63, .47, .33},
      dark  = {.46, .33, .22}
   }
   grid = {}
   noise()

   vg = {vRes=128, cRes=1, size=1000, xOff = 20, yOff=20, chunks={}}
   simpleChunkyGrid(vg.vRes, vg.cRes, vg.size)


   -- ui stuff
    mouseState = {
      hoveredSomething = false,
      down = false,
      lastDown = false,
      click = false,
      offset = {x=0, y=0}
   }
   lastDraggedElement = {}
    cursors = {
      hand= love.mouse.getSystemCursor("hand"),
      arrow= love.mouse.getSystemCursor("arrow")
   }
    -- ui tsuff

    fillType = 'filled'
end



function love.update()

end

function love.mousereleased()
   lastDraggedElement = nil
end



function drawUI()
   -- local runningX = vg.size + 20
   -- love.graphics.print('fill type', runningX, 10)
   -- runningX = runningX + love.graphics.getFont():getWidth('fill type') + 20
   -- local filled = labelButton( runningX, 10, 'filled',  fillType == 'filled')
   -- if filled.clicked then
   --    fillType = 'filled'
   -- end
   
   -- runningX = runningX + love.graphics.getFont():getWidth('filled') + 20
   -- local empty = labelButton( runningX, 10, 'empty', fillType == 'empty')
   -- if empty.clicked then
   --     fillType = 'empty'
   -- end
   

end


function love.draw()
   local chunkSize = vg.size / vg.cRes
   local voxelSize = chunkSize /  vg.vRes
   
   handleMouseClickStart()
   love.graphics.clear(1,0,0)

  
   
   love.graphics.setColor(1,1,1)

   
   drawUI()

   
   
   --local  m = createMeshGrid(8,500)

   
   love.graphics.setWireframe(false)
   for i = 1, #vg.chunks do
      local chunk = vg.chunks[i]
      if (chunk.mesh) then
      love.graphics.draw(chunk.mesh,
                         vg.xOff + chunk.pos[1],
                         vg.yOff + chunk.pos[2])
      end
   end

   

   -- debug draw

   love.graphics.setWireframe(false)
  
    for i = 1, #vg.chunks do
       local chunk = vg.chunks[i]
       for y = 0, vg.vRes-1 do
          for x = 0, vg.vRes-1 do
             local voxelIndex = (y * vg.vRes + x) + 1
             if (chunk.voxels[voxelIndex].state == 0) then
                love.graphics.setColor(0,0,0)
             else
                love.graphics.setColor(.7,.7,.7)

             end
             
             -- love.graphics.rectangle('fill',
             --                         vg.xOff + chunk.pos[1] + x*voxelSize,
             --                         vg.yOff + chunk.pos[2] + y*voxelSize,
             --                         voxelSize/4, voxelSize/4)

             --print(i, x,y,voxelIndex)
             --love.graphics.setColor(0,0,1, .3)

             -- local dotSize = voxelSize/3
             -- love.graphics.rectangle('fill',
             --                         vg.xOff + chunk.pos[1] + chunk.voxels[voxelIndex].position.x  - (dotSize/2),
             --                         vg.yOff + chunk.pos[2] + chunk.voxels[voxelIndex].position.y - (dotSize/2),
             --                         dotSize, dotSize)

             -- love.graphics.setColor(0,0,0, .3)
             -- local edgeDotSize = voxelSize/8
             -- love.graphics.rectangle('fill',
             --                         vg.xOff + chunk.pos[1] + chunk.voxels[voxelIndex].xEdgePosition.x  - (edgeDotSize/2),
             --                         vg.yOff + chunk.pos[2] + chunk.voxels[voxelIndex].xEdgePosition.y - (edgeDotSize/2),
             --                         edgeDotSize, edgeDotSize)

             -- love.graphics.rectangle('fill',
             --                         vg.xOff + chunk.pos[1] + chunk.voxels[voxelIndex].yEdgePosition.x  - (edgeDotSize/2),
             --                         vg.yOff + chunk.pos[2] + chunk.voxels[voxelIndex].yEdgePosition.y - (edgeDotSize/2),
             --                         edgeDotSize, edgeDotSize)
             
             
             
          end
       end
       
      --love.graphics.draw(chunk.mesh, chunk.pos[1], chunk.pos[2])
   end
   
    --love.graphics.draw(m, 10, 10)

    if love.mouse.isDown(1 ) or love.mouse.isDown(2 ) then
       
       local mx, my = love.mouse.getPosition()
       if mx >=vg.xOff and mx <= vg.size + vg.xOff then
          if my >= vg.yOff and my <= vg.size  + vg.yOff then
             mx = mx - vg.xOff
             my = my - vg.yOff
             
             local voxelX = math.floor(mx / voxelSize)
             local voxelY = math.floor(my / voxelSize)
             local chunkX = math.floor(voxelX / vg.vRes)
             local chunkY = math.floor(voxelY / vg.vRes)
             -- make it use the local voxels
             voxelX = voxelX -  chunkX * vg.vRes
             voxelY = voxelY - chunkY * vg.vRes
             
             local chunkIndex = (chunkY * vg.cRes + chunkX) + 1
             local voxelIndex = (voxelY * vg.vRes + voxelX) + 1
            
             if (chunkIndex <= vg.cRes^2 and voxelIndex <= vg.vRes^2) then
                vg.chunks[chunkIndex].voxels[voxelIndex].state = love.mouse.isDown(1 )  and 1 or 0 
                vg.chunks[chunkIndex].meshOld = createMeshGrid(vg.vRes, chunkSize, vg.chunks[chunkIndex].voxels)
                
                local v, t = triangulateChunk(vg.chunks[chunkIndex].voxels)

                vg.chunks[chunkIndex].mesh = makeMesh(v,t)

             end
             
          end
       end
    end


    local noiseCellsize = vg.size / #grid
    --print(noiseCellsize)
    for x = 1, #grid do
       for y = 1, #grid[1] do
          
          if (grid[x][y] == 1) then
             love.graphics.setColor(colors.sand[1], colors.sand[2], colors.sand[3], 0.2)
          else
             love.graphics.setColor(colors.dark[1], colors.dark[2], colors.dark[3], 0.2)
          end

          love.graphics.rectangle('fill', x*noiseCellsize, y*noiseCellsize, noiseCellsize, noiseCellsize)
       end
    end
    
    
    
   love.graphics.print("fps: "..tostring(love.timer.getFPS( )), 0, 0)
end

function makeMesh(vertices, triangles)
   local simple_format = {
      {"VertexPosition", "float", 3} -- The x,y position of each vertex.
   }
   if (#vertices == 0) then return nil end
   print(#vertices)
   local mesh = love.graphics.newMesh(simple_format, vertices, 'triangles')
   mesh:setVertexMap(triangles)
   --mesh:setDrawRange(1, 6)
   
   return mesh
end


function triangulateChunk(voxels)
   local vertices = {}
   local triangles = {}
   local vRes = vg.vRes


   function addPentagon(a,b,c,d,e)
      local vertexIndex = #vertices + 1
      table.insert(vertices, {a.x, a.y, 0})
      table.insert(vertices, {b.x, b.y, 0})
      table.insert(vertices, {c.x, c.y, 0})
      table.insert(vertices, {d.x, d.y, 0})
      table.insert(vertices, {e.x, e.y, 0})

      table.insert(triangles, vertexIndex)
      table.insert(triangles, vertexIndex + 1)
      table.insert(triangles, vertexIndex + 2)
      table.insert(triangles, vertexIndex)
      table.insert(triangles, vertexIndex + 2)
      table.insert(triangles, vertexIndex + 3)
      table.insert(triangles, vertexIndex)
      table.insert(triangles, vertexIndex + 3)
      table.insert(triangles, vertexIndex + 4)

   end
   
   function addQuad(a,b,c,d)
      local vertexIndex = #vertices + 1
      table.insert(vertices, {a.x, a.y, 0})
      table.insert(vertices, {b.x, b.y, 0})
      table.insert(vertices, {c.x, c.y, 0})
      table.insert(vertices, {d.x, d.y, 0})

      table.insert(triangles, vertexIndex)
      table.insert(triangles, vertexIndex + 1)
      table.insert(triangles, vertexIndex + 2)
      table.insert(triangles, vertexIndex)
      table.insert(triangles, vertexIndex + 2)
      table.insert(triangles, vertexIndex + 3)
   end
   
   
   function addTriangle(a,b,c)
      local vertexIndex = #vertices + 1
      table.insert(vertices, {a.x, a.y, 0})
      table.insert(vertices, {b.x, b.y, 0})
      table.insert(vertices, {c.x, c.y, 0})

      table.insert(triangles, vertexIndex)
      table.insert(triangles, vertexIndex + 1)
      table.insert(triangles, vertexIndex + 2)
   end
   
   function triangulateCell(a, b, c, d)
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

      assert(cellType >= 0 and cellType <= 15)
      
      if     cellType == 0 then
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
   
   
   function triangulateCellRows(voxels) 
      local cells = vRes-1
      local index = 1
      for y = 0, cells-1 do
         for x= 0, cells-1 do
            --print(index, index+1, index + vRes, index + vRes + 1)

            triangulateCell(voxels[index] ,
                            voxels[index+1],
                            voxels[index + vRes],
                            voxels[index +vRes + 1])
                            
            index = index +1
         end
         index = index + 1
      end
      
   end
   
   triangulateCellRows(voxels, vertices, triangles)
   return vertices, triangles
end



function simpleChunkyGrid(vRes, cRes, size)
   local halfSize = size * .5
   local chunkSize = size / cRes
   local voxelSize = chunkSize / vRes
   local chunks = {}
   local index = 1

   -- function createVoxel(x,y)
   --    local result = {}
   --    result.pos = {(x + 0.5) * voxelSize, (y + 0.5) * voxelSize}
   --    return result
   -- end
 
   -- function initChunk(resolution, size)
   --    local index = 1
   --    local result = {voxels={}}
   --    for y = 0, vRes do
   --       for x = 0, vRes do
   --          result.voxels[index] = createVoxel(x,y)
   --          index = index + 1
   --       end
   --    end
   --    return result
   -- end

   function createVoxels()
      local result = {}
      local index = 1
      for y = 0, vRes-1 do 
         for x = 0, vRes-1 do
            local position = {x=(x+.5)*voxelSize, y=(y+.5)*voxelSize}
            result[index] = {
               state = 0, -- polarize(love.math.random()),
               position = position,
               xEdgePosition = {x=position.x + (voxelSize*.5), y=position.y},
               yEdgePosition = {x=position.x, y=position.y + (voxelSize*.5)},
            }
            index = index + 1
         end
      end
      return result
   end


   
   
   function initChunk(resolution, size)
      local result = {}
      result.voxels = createVoxels()

      local v,t = triangulateChunk(result.voxels)

      result.mesh = makeMesh(v,t)

--      print(inspect(result.voxels))
    --  result.meshOld = createMeshGrid(resolution, size, result.voxels)
      return result
   end
   
   
   function createChunk(x,y)
      local chunk = initChunk(vRes, chunkSize)
      chunk.pos = {x * chunkSize, y * chunkSize}
      return chunk
   end

   for y = 0, cRes-1 do
      for x = 0, cRes-1 do
         chunks[index] = createChunk(x,y)
         index = index+1
      end
   end
   vg.chunks = chunks
end



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
