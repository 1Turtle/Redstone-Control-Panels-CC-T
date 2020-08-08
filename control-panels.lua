----------- Variables ------------
local screen = peripheral.find("monitor") --Screen
local wS, hS = screen.getSize() --Size
local saveFile = ".CPanel-settings" --Save File
local running = true --then false, program ends
local event, mouse, x, y --Mouse input
local changed = true --Redraw screen
local design = 1 --How the buttons are listed
local power = 15 --Redstone Power

local buttons = { }
local status = { 0, 0, 0, 0, 0 }
local namedSides = {
    "", --Top
    "", --Bottom
    "", --Left
    "", --Right
    ""  --Back
}

------------ Settings ------------
--Load File
local function loadSettings(path)
    --Errors
    if not(fs.exists(path)) then
        return nil
    end
    
    local f = fs.open(path, "r")
    
    --Load Settings
    saveV = textutils.unserialize(f.readAll())
    namedSides = saveV[1]
    status = saveV[2]
    design = saveV[3]
    power = saveV[4]
    
    f.close()
end

--Save settings
local function saveSettings(path, settingsT)
    local settingsS = textutils.serialize(settingsT)
    
    --Remove old file
    if fs.exists(path) then fs.delete(path) end
    
    --Write file
    local f = fs.open(path, "w")
    f.write(settingsS)

    f.close()
end

------------- Others -------------
--Print string
local function printf(t, text, x, y)
    t.setCursorPos(x, y)
    t.write(text)
end

--Get Side
local function getSide(i)
    local result = nil

    if i == 1 then
        result = "top"
    elseif i == 2 then
        result = "bottom"
    elseif i == 3 then
        result = "left"
    elseif i == 4 then
        result = "right"
    elseif i == 5 then
        result = "back"
    end

    return result
end

local function welcome()
    local x, y = term.getCursorPos()
    local w, h = term.getSize()

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.lime)
    if y > h-8 then term.scroll(8) y = y-8 end

    term.setCursorPos(1, y-1)
    term.clearLine()
    printf(term, "    Light Switch - by Sammy_craft", 1, y)
    term.setTextColor(colors.white)
    printf(term, "-------------------------------------", 1, y+1)
    term.setTextColor(colors.cyan)
    printf(term, "currently only normal analog", 1, y+2)
    printf(term, "redstone is supported. But there", 1, y+3)
    printf(term, "will be updates, where many things", 1, y+4)
    printf(term, "will be extended, improved and added!", 1, y+5)
    printf(term, "", 1, y+6)
    term.setTextColor(colors.orange)
    printf(term, "Press Enter to Close the Control Panels!", 1, y+7)
    term.setTextColor(colors.gray)
    printf(term, "or press \'e\' to add, remove or change a button", 1, y+8)
end

--Sets Redstone Outputs
local function redstoneHandler()
    while running do
        for i=1,#namedSides,1 do
            if not(namedSides[i] == "") then
                if status[i] == 1 then
                    redstone.setAnalogOutput(getSide(i), power)
                else
                    redstone.setAnalogOutput(getSide(i), 0)
                end
            end
        end

        sleep()
    end
end

-------------- GUI ---------------
--Create Button
local function createButton(x, y, w, h, name)
    --Create button
    buttons[name] = { 0, x, y, w, h, name }

    for i=1,#namedSides,1 do
        if namedSides[i] == name then
            if status[i] == 1 then buttons[name][1] = 1 end
        end
    end
end

--Draw Button
local function drawButton(button)
    --Variables
    local status = button[1]
    local x = button[2]
    local y = button[3]
    local w = button[4]
    local h = button[5]
    local name = button[6]
    screen.setTextColor(colors.white)

    --Set BG
    if status == 0 then
        screen.setBackgroundColor(colors.red)
    elseif status == 2 then
        screen.setBackgroundColor(colors.orange)
    elseif status == 4 then
        screen.setBackgroundColor(colors.lime)
    elseif status == 1 then
        screen.setBackgroundColor(colors.green)
    end

    --Fill button
    for i=1,h,1 do
        screen.setCursorPos(x, i-1+y)
        for j=1,w,1 do
            screen.write(" ")
        end
    end

    --Draw Name
    if #name-w > w then
        printf(screen,  string.sub(name, 1, w-2) .. "..", x+w/2-#name/2, y+(h/2))
    elseif #name > w then
        printf(screen, string.sub(name, 1, w), x+w/2-w/2, y+(h/2)-1)
        printf(screen, string.sub(name, w+1), x+w/2-#string.sub(name, w+1)/2, y+(h/2))
    
    else
        printf(screen, name, x+w/2-#name/2, y+(h/2))
    end
end

--InfoBar
local function infoBar()
    --Draw BG
    screen.setCursorPos(1, 1)
    screen.setBackgroundColor(colors.black)
    screen.setTextColor(colors.white)
    screen.clearLine()

    --Draw Layout
    screen.setTextColor(colors.yellow)
    screen.write("[")
    screen.setTextColor(colors.white)
    screen.write("Layout:")
    if design == 1 then
        screen.write("LIST")
    elseif design == 2 then
        screen.write("BUTTON")
    else
        screen.write("?")
    end
    screen.setTextColor(colors.yellow)
    screen.write("]")

    --Draw Power
    screen.setCursorPos(wS-#("Power:"..tostring(power))-3,1)
    screen.setTextColor(colors.yellow)
    screen.write("[")
    screen.setTextColor(colors.white)
    screen.write("Power:"..power)
    screen.setTextColor(colors.gray)
    screen.write("+-")
    screen.setTextColor(colors.yellow)
    screen.write("]")

    screen.setTextColor(colors.white)
end

--create GUI
local function createGUI()
    --Variables
    local buttonsC = 1

    --Clear screen
    screen.setBackgroundColor(colors.black)
    screen.setTextColor(colors.gray)
    
    --Fill BG
    for i=1,hS,1 do
        screen.setCursorPos(1, i)
        for j=1,wS,1 do
            screen.write("\127")
        end
    end

    if design == 1 then
        for i=1,#namedSides,1 do
            if not(namedSides[i] == "") then
                buttonsC = buttonsC + 2
                createButton(2, buttonsC, wS-2, 1, namedSides[i], getSide(i))
            end
        end
    else
        for i=1,#namedSides,1 do
            if not(namedSides[i] == "") then
                if buttonsC == 1 then
                    createButton(2, 3, (wS-4)/3, (hS-4)/2, namedSides[i], getSide(i))
                elseif buttonsC == 2 then
                    createButton((wS-4)/3+4, 3, (wS-4)/3, (hS-4)/2, namedSides[i], getSide(i))
                elseif buttonsC == 3 then
                    createButton(((wS-4)/3)*2+5, 3, (wS-4)/3, (hS-4)/2, namedSides[i], getSide(i))
                elseif buttonsC == 4 then
                    createButton(2, (hS-4)/2+4, (wS-4)/3, (hS-4)/2, namedSides[i], getSide(i))
                elseif buttonsC == 5 then
                    createButton((wS-4)/3+4, (hS-4)/2+4, (wS-4)/3, (hS-4)/2, namedSides[i], getSide(i))
                end

                buttonsC = buttonsC + 1
            end
        end
    end
end

--Redraw GUI
local function drawGUI()
    --Draw Infobar
    infoBar()

    --Draw Buttons
    for i=1,#namedSides,1 do
        if not(namedSides[i] == "") then
            drawButton(buttons[namedSides[i]])
        end
    end
end

------------- Loops --------------
--Inputs
local function getMousePos()
    --Loop
    local event, side, xPos, yPos
    while running do
        if not(running == 1) then
            event, side, xPos, yPos = os.pullEvent( "monitor_touch" )
        else
            event = nil side = nil xPos = nil yPos = nil
        end

        local condition = true
        if os.version() == "CraftOS 1.8" then condition = (peripheral.getName(screen) == side) end
        
        if condition then
            --Infobar
            if yPos == 1 then
                local lengthL = 4+9
                if design == 2 then lengthL = 7+9 end

                --Layout
                if xPos >= 1 and xPos <= lengthL then
                    design = design + 1
                    if design > 2 then design = 1 end

                    buttons = { }
                    createGUI()
                    drawGUI()
                    changed = true
                end

                --Power
                if xPos == wS-2 then
                    if power < 15 then
                        power = power + 1
                        changed = true
                    end
                elseif xPos == wS-1 then
                    if power > 1 then
                        power = power - 1
                        changed = true
                    end
                end
            end

            --Buttons
            for i=1,#namedSides,1 do
                if not(namedSides[i] == "") and yPos > 1 and yPos < hS then
                    --Variables
                    local x = buttons[namedSides[i]][2]
                    local y = buttons[namedSides[i]][3]
                    local w = buttons[namedSides[i]][4]
                    local h = buttons[namedSides[i]][5]

                    --If mouse hits current button
                    if xPos >= x and xPos <= x-1+w and yPos >= y and yPos <= y-1+h then
                        if buttons[namedSides[i]][1] == 0 then
                            buttons[namedSides[i]][1] = 4
                            changed = true
                            sleep(0.15)
                            buttons[namedSides[i]][1] = 1
                            status[i] = 1
                            changed = true
                        else
                            buttons[namedSides[i]][1] = 2
                            changed = true
                            sleep(0.15)
                            buttons[namedSides[i]][1] = 0
                            status[i] = 0
                            changed = true
                        end
                    end
                end
            end
        end
    end

    return
end

--Change name
--Add/Change Button names
local function setName()
    sleep(0.05)
    term.clear()
    term.setCursorPos(1,1)
    term.setBackgroundColor(colors.black)

    for i=1,5,1 do
        term.setTextColor(colors.white)
        printf(term, (i .. ". " .. getSide(i)), 1,i)
        term.setTextColor(colors.red)
        if namedSides[i] == "" then
            printf(term, (" NIL\n"), 11, i)
        else
            printf(term, (" \"" .. namedSides[i] .. "\"\n"), 11, i)
        end
    end
    term.setTextColor(colors.gray)
    print("\n'q' = exit")

    term.setTextColor(colors.lightGray)
    term.clearLine()
    term.write("enter the number you want to change: ")
    term.setTextColor(colors.gray)

    local input = nil
    while (input == nil) do
        input = io.read()

        if input == "q" then break end

        if not(tonumber(input) == nil) and tonumber(input) >= 1 and tonumber(input) <= 5 then
            term.setTextColor(colors.lightGray)
            printf(term, "enter a new name for the button.\n", 1,8)
            term.setTextColor(colors.gray)
            printf(term, "If you don't enter anything,", 1,9)
            printf(term, "the button will be deleted.", 1,10)
            term.setTextColor(colors.lightGray)
            printf(term, "New name: ", 1, 11)
            term.setTextColor(colors.gray)
            local newName = io.read()

            print(namedSides[tonumber(input)])
            if newName == "" then
                namedSides[tonumber(input)] = ""
                redstone.setAnalogOutput(getSide(tonumber(input)), 0)
            else
                namedSides[tonumber(input)] = newName
            end

            buttons = { }
            createGUI()
            drawGUI()
            setName()
        else
            input = nil
            term.clear()
            term.setCursorPos(1,1)

            for i=1,5,1 do
                term.setTextColor(colors.white)
                printf(term, (i .. ". " .. getSide(i)), 1,i)
                term.setTextColor(colors.red)
                printf(term, (" \"" .. namedSides[i] .. "\"\n"), 11, i)
            end
            term.setTextColor(colors.gray)
            print("\n'q' = exit")

            term.clearLine()
            term.setTextColor(colors.lightGray)
            term.write("enter the number you want to change: ")
            term.setTextColor(colors.gray)
        end
    end

    term.clear()
    term.setCursorPos(1,1)
    welcome()
    return
end

--Keyboard
local function keyboardHandler()
    --Loop
    local event, key
    while running do
        if not(running == 1) then
            event, key = os.pullEvent( "key" )
        else
            event = nil key = nil
        end

        if key == keys.enter then
            running = false
        elseif key == keys.e then
            setName()
        end
    end

    return
end

--Main
local function main()
    --Setup
    loadSettings(saveFile)
    createGUI()
    welcome()

    --Check for Size
    if wS < 29 or hS < 12 then
        screen.setBackgroundColor(colors.yellow)
        screen.setTextColor(colors.black)

        --Fill BG
        for i=1,hS,1 do
            screen.setCursorPos(1, i)
            for j=1,wS,1 do
                screen.write("\127")
            end
        end
        
        screen.setTextColor(colors.red)
        printf(screen, "This screen is", wS/2-6, hS/2)
        printf(screen, "too small!", wS/2-5, hS/2+1)

        return
    end

    --Main Loop
    while running do
        if changed then changed = false drawGUI() end
        sleep()
    end

    return
end

--Loop
parallel.waitForAny( main, getMousePos, keyboardHandler, redstoneHandler )

--END
local saveV = { namedSides, status, design, power }
saveSettings(saveFile, saveV)

for i=1,5,1 do redstone.setAnalogOutput(getSide(i), 0) end

screen.setBackgroundColor(colors.black)
screen.clear()
print()
