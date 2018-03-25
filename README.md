# DefUniCo

DefUniCo is a coroutine library for Defold game engine.  
The library is useful when you want to write coroutine like Unity3D in Defold.  

# Installation

You can use DefUniCo in your own project by adding this project as a [Defold library dependency](https://www.defold.com/manuals/libraries/).  
Open your game.project file and in the dependencies field under project add:  

```
https://github.com/u16kuma/defunico/archive/1.0.zip
```

Or point to the ZIP file of a [specific DefUniCo release](https://github.com/u16kuma/defunico/releases).  

# Usage

DefUniCo is very easy to use.  
All you need to do is to write template code.  

test.script  

```lua
local defunico = require("defunico.defunico")
function init(self)
    defunico.init(self)
end
function update(self, dt)
    self.update_coroutine(dt)
end
```

Let's try write coroutine!

```lua
function init(self)
    defunico.init(self)

    -- Please write coroutine code under the defunico.init
    self.start_coroutine(function(self)
        -- wait one second
        wait_seconds(1)

        print("One second has passed.")
    end)
end
```

Coroutines can be stopped by adding this code.

```lua
local co = self.start_coroutine(function() ... end)
self.stop_coroutine(co)
```

Coroutine wait some wait_* function.

```lua
self.start_coroutine(function(self)

    -- wait one second
    wait_seconds(1)

    -- wait one second
    wait_msec(1000)
    
    -- wait one second (60 fps)
    wait_frame(60)

    -- wait one second (60 fps)
    local frame = 0
    wait_until(function() 
        frame = frame + 1
        return frame >= 60
    end)

    -- wait one second (60 fps)
    frame = 0
    wait_while(function()
        frame = frame + 1
        return frame <= 60
    end)

end)
```