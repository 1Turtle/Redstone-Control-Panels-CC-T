# Redstone-Control-Panels-CC-T

Features
--------
With this program you can control all 5 sides of the computer from the [CC:T mod](https://github.com/SquidDev-CC/CC-Tweaked). You can give the button name, change the view of the buttons (between LIST and BUTTONS) and adjust the signal strength.
![Alt Text](/screenshot.png "Screenshot of Turtles Explorer")

Download
--------
> 👉Note: **Redstone-Control-Panel** is only for [CC:T](https://github.com/SquidDev-CC/CC-Tweaked) and is not tested on other versions of ComputerCraft

to download this program directly to your ComputerCraft computer, type this in **the interactive Lua prompt**:

```
domain = "https://github.com/1Turtle/Redstone-Control-Panels-CC-T/releases/latest/download/control-panels.lua"
content = http.get(domain).readAll()
f = fs.open("control-panels.lua", "w")
f.write(content)
f.close()
```
