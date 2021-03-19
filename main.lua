local inspect = require './inspect'
VoxelMap = require './voxelmap'
Stencil = require './stencil'
CircleStencil = require './circle-stencil'


function pointInRect(x,y, rx, ry, rw, rh)
   if x < rx or y < ry then return false end
   if x > rx+rw or y > ry+rh then return false end
   return true
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

   local mx,my = love.mouse.getPosition()
   if pointInRect (mx,my, x,y,w,h) then
      love.graphics.setColor(.3,.2,.9)
   end
   if selected then
      love.graphics.setColor(.8,.3,.3)
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

function clamp(value, min, max)
   local result = value
   if value < min then result = min end
   if value > max then result = max end
   return result
end




function love.wheelmoved(x,y)
   
   if love.keyboard.isDown("lctrl") then
      local currentIndex = nil
      for i=1, #radii do
         if fillRadius == radii[i] then
            currentIndex = i
         end
      end
      newIndex = currentIndex + ((y>0 and 1) or -1)
      newIndex = clamp(newIndex, 1, #radii)
      
      fillRadius = radii[newIndex]
   elseif love.keyboard.isDown("lalt") then
      local currentIndex = nil
      for i=1, #radii do
         if fillType == fillTypes[i] then
            currentIndex = i
         end
      end
      newIndex = currentIndex + ((y>0 and 1) or -1)
      newIndex = clamp(newIndex, 1, #fillTypes)
      
      fillType = fillTypes[newIndex]
   else
      scale = scale * ((y>0 and 1.1) or .9)
   end
   
   
end


function love.keypressed(key)
   if key == 'escape' then
      love.event.quit()
   end
end

function love.load()
   scale = 1
    colors = {
      bg    = {.95, .89, .73},
      sand  = {.79, .73, .59},
      brown = {.63, .47, .33},
      dark  = {.46, .33, .22}
    }
    m = VoxelMap.new(16, 4 )

    mouseState = {
      hoveredSomething = false,
      down = false,
      lastDown = false,
      click = false,
      offset = {x=0, y=0}
   }
   --lastDraggedElement = {}
    radii = {.125, .25, .5, .75, 1,2,3,4,5,6,7,8,9, 12, 16, 32}
    fillRadius = 2
    fillTypes = {'rectangle','circle'}
    fillType = 'circle'

    --local s = Stencil:new()
    --local s2 = CircleStencil:new()
    --print((s), (s2))
    --s:woof()
    --s:stuff()
    --s2:woof()
    --s2:stuff()
    --s2:setCenter(100,100)
    --print(s2:xStart())
end

function love.draw()
   handleMouseClickStart()
   love.graphics.clear(colors.bg[1],colors.bg[2],colors.bg[3])
   love.graphics.setColor(colors.brown[1],colors.brown[2],colors.brown[3])
   local size = 500
   local mx, my = love.mouse.getPosition()

   
   local runningX = 1000 
   for i = 1, #radii do
      if labelButton(runningX, 20, radii[i], radii[i] == fillRadius).clicked then
         fillRadius = radii[i]
      end
      runningX = runningX + 25
   end
   
   runningX = 1000 
  
   for i = 1, #fillTypes do
      if labelButton(runningX, 20 + 40, fillTypes[i], fillTypes[i] == fillType).clicked then
         fillType = fillTypes[i]
      end
      runningX = runningX +  love.graphics.getFont():getWidth(fillTypes[i]) + 5
   end
   
   
   love.graphics.push()
   love.graphics.translate(size, size)   
   love.graphics.scale(scale, scale)   
   for i = 1, #m.chunks do
      local chunk = m.chunks[i]
      if chunk.mesh  then
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
   local value = -1
   if (love.mouse.isDown(1)) then
      value = 0
   end
   if (love.mouse.isDown(2)) then
      value = 1
   end
   

   local sx,sy,ex,ey, cx, cy = m:editVoxels({x=mx/size,y=my/size}, value, fillRadius, fillType)
   local w = (ex-sx)
   local h = (ey-sy)

   local f = function (v) return v * size * 2/m.chunkResolution end
   
   love.graphics.setColor(colors.sand[1],colors.sand[2],colors.sand[3], 0.5)
   love.graphics.rectangle('fill',f(sx)   ,f(sy)  , f(w) , f(h) )
   love.graphics.setColor(1,0,0, 0.75)
   if fillType == 'rectangle' then
      love.graphics.rectangle('line',f(sx)   ,f(sy)  , f(w) , f(h) )
   end
   if fillType == 'circle' then
      love.graphics.circle('line', f(sx) + f(w)/2     ,f(sy) +  f(h)/2, f(w)/2 , f(h)/2 )
   end
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

    love.graphics.setColor(0,0,0)
   love.graphics.print("fps: "..tostring(love.timer.getFPS( )), 0, 0)
   love.graphics.setColor(1,1,1)
   love.graphics.print("fps: "..tostring(love.timer.getFPS( )), 1, 1)
   
end
