Stencil = require './Stencil'
local CircleStencil = Stencil:new()

function CircleStencil:woof()
   print(self)
   print('woof circle')
end

function CircleStencil:__tostring()
   return "<CircleStencil: "..self.radius..">"
end


return CircleStencil
