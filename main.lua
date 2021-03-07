local inspect = require './inspect'
VoxelMap = require './voxelmap'

function love.keypressed(key)
   if key == 'escape' then
      love.event.quit()
   end
end

function love.load()
    colors = {
      bg    = {.95, .89, .73},
      sand  = {.79, .73, .59},
      brown = {.63, .47, .33},
      dark  = {.46, .33, .22}
    }
    m = VoxelMap.new(32, 4)
    value = -1
end

function love.mousepressed(mx, my, button)
  
   value = button

end
function love.mousereleased(mx, my, button)
   value = -1
end


function love.draw()
   love.graphics.clear(colors.bg[1],colors.bg[2],colors.bg[3])
   love.graphics.setColor(colors.brown[1],colors.brown[2],colors.brown[3])
   local size = 500
   local mx, my = love.mouse.getPosition()
   
   
   love.graphics.push()
   love.graphics.translate(size, size)   
   
   for i = 1, #m.chunks do
      local chunk = m.chunks[i]
      if chunk.mesh then
         --print('hi hello?', 100, 100)
         love.graphics.draw(chunk.mesh, chunk.localPos.x * size, chunk.localPos.y * size)
      end
      if false then
      for j = 1, #chunk.voxels do
         local worldPos = {
            x = (chunk.localPos.x + chunk.voxels[j].position.x) * size,
            y = (chunk.localPos.y + chunk.voxels[j].position.y) * size
         }
         
         local xEdge = {
            x = (chunk.localPos.x + chunk.voxels[j].xEdgePosition.x) * size,
            y = (chunk.localPos.y + chunk.voxels[j].xEdgePosition.y) * size
         }
         
         local yEdge = {
            x = (chunk.localPos.x + chunk.voxels[j].yEdgePosition.x) * size,
            y = (chunk.localPos.y + chunk.voxels[j].yEdgePosition.y) * size
         }
         
         if (chunk.voxels[j].state == 1) then
            love.graphics.rectangle('fill',worldPos.x - 2, worldPos.y - 2, 4, 4)
         else
            love.graphics.rectangle('line',worldPos.x - 2, worldPos.y - 2, 4, 4)
         end
         
         love.graphics.rectangle('fill',xEdge.x -1 ,xEdge.y - 1, 2, 2)
         love.graphics.rectangle('fill',yEdge.x -1, yEdge.y - 1, 2, 2)
      end
      end
   end
   
   love.graphics.pop()
   

   local sx,sy,ex,ey, cx, cy = m:editVoxels({x=mx/size,y=my/size}, value)
   local w = (ex-sx)
   local h = (ey-sy)

   local f = function (v) return v * size * 2/m.chunkResolution end
   
   love.graphics.setColor(colors.sand[1],colors.sand[2],colors.sand[3], 0.5)
   love.graphics.rectangle('fill',f(sx)   ,f(sy)  , f(w) , f(h) )
   love.graphics.setColor(1,0,0, 0.75)
   love.graphics.rectangle('line',f(sx)   ,f(sy)  , f(w) , f(h) )

   love.graphics.circle('line', f(sx) + f(w)/2     ,f(sy) +  f(h)/2, f(w)/2 , f(h)/2 )
   --print(math.floor((sx * m.chunkResolution) +.5) , math.floor((ex * m.chunkResolution) -.5) )
   love.graphics.rectangle('fill',f(cx) - 5 ,f(cy) - 5, 10, 10)


   -- display the affected chunks
   love.graphics.setColor(0,0,1, 0.1)

   local ckx = math.floor(sx) * size * 2/m.chunkResolution
   local cky = math.floor(sy) * size * 2/m.chunkResolution
   
   local ckx2 = math.ceil(ex) * size * 2/m.chunkResolution
   local cky2 = math.ceil(ey) * size * 2/m.chunkResolution
   love.graphics.rectangle('fill', ckx,cky, ckx2 - ckx, cky2 - cky)

   --value = -1
end
