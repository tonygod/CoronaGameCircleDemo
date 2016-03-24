
--- Corona GameCircle Sample
-- Abstract: Amazon GameCircle
-- Version: 1.0
-- Sample code is MIT licensed; see https://www.coronalabs.com/links/code/license
---------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

------------------------------
-- RENDER THE SAMPLE CODE UI
------------------------------
local sampleUI = require( "sampleUI.sampleUI" )
sampleUI:newUI( { theme="darkgrey", title="Amazon GameCircle", showBuildNum=true } )

-- The following property represents the bottom Y position of the sample title bar
local titleBarBottom = sampleUI.titleBarBottom

------------------------------
-- CONFIGURE STAGE
------------------------------

local composer = require( "composer" )
display.getCurrentStage():insert( sampleUI.backGroup )
display.getCurrentStage():insert( composer.stage )
display.getCurrentStage():insert( sampleUI.frontGroup )
composer.recycleOnSceneChange = false
local aliasGroup = display.newGroup()

----------------------
-- BEGIN SAMPLE CODE
----------------------

-- Require libraries/plugins
local widget = require( "widget" )
local gamecircle = require( "plugin.gamecircle" )

-- Set app font
composer.setVariable( "appFont", sampleUI.appFont )

-- Set common variables
composer.setVariable( "initializedGC", false )
composer.setVariable( "leaderboardsData", {} )
composer.setVariable( "achievementData", {} )
composer.setVariable( "debugOutput", false )  -- Set true to enable console print output


-- Table printing function for debugging
local function printTable( t )
    if ( composer.getVariable( "debugOutput" ) == false ) then return end
    print("--------------------------------")
    local printTable_cache = {}
    local function sub_printTable( t, indent )
        if ( printTable_cache[tostring(t)] ) then
            print( indent .. "*" .. tostring( t ) )
        else
            printTable_cache[tostring(t)] = true
            if ( type( t ) == "table" ) then
                for pos,val in pairs(t) do
                    if ( type(val) == "table" ) then
                        print( indent .. "[" .. pos .. "] => " .. tostring(t).. " {" )
                        sub_printTable( val, indent .. string.rep( " ", string.len(pos)+8 ) )
                        print( indent .. string.rep( " ", string.len(pos)+6 ) .. "}" )
                    elseif ( type(val) == "string" ) then
                        print( indent .. "[" .. pos .. '] => "' .. val .. '"' )
                    else
                        print( indent .. "[" .. pos .. "] => " .. tostring(val) )
                    end
                end
            else
                print( indent..tostring(t) )
            end
        end
    end
    if ( type(t) == "table" ) then
        print( tostring(t) .. " {" )
        sub_printTable( t, "  " )
        print( "}" )
    else
        sub_printTable( t, "  " )
    end
end

-- Reference "printTable" function as a Composer variable for usage in all scenes
composer.setVariable( "printTable", printTable )


function LeaderboardCallback(returnValue)
    if returnValue.isError == true then
        print("Get Leaderboards request returned with error message: " .. returnValue.errorMessage)
    else
        print("Leaderboard information recieved!")
        print("-num" .. returnValue.num)
        local ld = composer.getVariable( "leaderboardsData" )
        for i, leaderboard in ipairs(returnValue) do
--            print("-Leaderboard ID" .. leaderboard.id)
--            print("--name" .. leaderboard.name)
--            print("--displayText" .. leaderboard.displayText)
--            print("--scoreFormat" .. leaderboard.scoreFormat)
--            print("--imageURL" .. leaderboard.imageURL)
--            print("--imageURL may be blank, as warned by Amazon's SDK documentation, when propegated outside basic GetLeaderboards function")
            ld[#ld+1] = {
                category=leaderboard.displayText,
                title=leaderboard.name,
                id = leaderboard.id
            }
        end
        -- Show leaderboards scene
        composer.gotoScene( "leaderboards", { effect="slideUp", time=800 } )
    end
    local printTable = composer.getVariable( "printTable" )
    printTable( returnValue )
end


function AchievementCallback(returnValue)
    if returnValue.isError == true then
        print("Get Achievement request returned with error message: " .. returnValue.errorMessage)
    else
        print("Achievement information recieved!")
        local ad = composer.getVariable( "achievementData" )
        for i, achievement in ipairs(returnValue) do
--            print("-Achievement # " .. i)  
--            print("--id: " .. achievement.id)  
--            print("--title: " .. achievement.title)  
--            print("--desc: " .. achievement.desc)  
--            print("--isUnlocked: " .. achievement.isUnlocked)  
--            print("--unlockedDate: " .. achievement.unlockDate)  
--            print("--imageURL: " .. achievement.imageURL)  
--            print("--isHidden: " .. achievement.isHidden)  
--            print("--pointValue: " .. achievement.pointValue)  
--            print("--position: " .. achievement.position)  
--            print("--progress: " .. achievement.progress)
            ad[#ad+1] = {
                identifier=achievement.id,
                title=achievement.title,
                isHidden=achievement.isHidden,
                maximumPoints=achievement.pointValue,
                percentComplete=achievement.progress
            }
        end
    end
    local printTable = composer.getVariable( "printTable" )
    printTable( returnValue )
end


function PlayerProfileCallback(returnValue)
    if returnValue.isError == true then
        print("Player Profile returned with error message: " .. returnValue.errorMessage)
    else
        print("Player Profile return with this info: " .. returnValue.player.alias .. "-" .. returnValue.player.id)
        if ( aliasGroup.numChildren == 0 ) then
            -- Save player data to variable
            composer.setVariable( "localPlayerData", returnValue.player )
            -- Display local player alias
            local textGroup = display.newGroup()
            aliasGroup:insert( textGroup )
            composer.stage:insert( aliasGroup )
            textGroup.anchorChildren = true
            local back = display.newRect( aliasGroup, 0, 0, display.actualContentWidth, 34 )
            back:setFillColor( 0.5,0.5,0.5,0.15 )
            local alias = display.newText( textGroup, "GameCircle Alias: ", 0, back.y, sampleUI.appFont, 14 )
            alias:setFillColor( 0.5 )
            alias.anchorX = 1
            local name = display.newText( textGroup, returnValue.player.alias, alias.x, back.y, sampleUI.appFont, 14 )
            name:setFillColor( 0.7 )
            name.anchorX = 0
            aliasGroup.x = display.contentCenterX
            aliasGroup.y = titleBarBottom + 36 - (aliasGroup.height*0.5)
            transition.to( aliasGroup, { time=800, y=aliasGroup.y+aliasGroup.height, transition=easing.outQuad } )
        end
    end
    local printTable = composer.getVariable( "printTable" )
    printTable( returnValue )
end


-- Scene buttons handler function
local function handleSceneButton( event )
    local target = event.target
    local leaderboardsButton = composer.getVariable( "leaderboardsButton" )
    local achievementsButton = composer.getVariable( "achievementsButton" )
    
    if ( target.id == "leaderboards" and composer.getSceneName( "current" ) == "achievements" ) then
        composer.gotoScene( "leaderboards", { effect="slideRight", time=600 } )
    elseif ( target.id == "achievements" and composer.getSceneName( "current" ) == "leaderboards" ) then
        composer.gotoScene( "achievements", { effect="slideLeft", time=600 } )
    end
end


-- Gamecircle initialization listener function
local function initCallback( result )
    
    if ( composer.getVariable( "initializedGC" ) == false ) then
        
        if ( result ) then
            
            -- Create "Leaderboards" scene button
            local leaderboardsButton = widget.newButton(
            {
                id = "leaderboards",
                label = "Leaderboards",
                shape = "rectangle",
                width = display.actualContentWidth/2,
                height = 36,
                font = sampleUI.appFont,
                fontSize = 16,
                fillColor = { default={ 0.13,0.34,0.48,1 }, over={ 0.13,0.34,0.48,1 } },
                labelColor = { default={ 1,1,1,1 }, over={ 1,1,1,0.8 } },
                onRelease = handleSceneButton
            })
            leaderboardsButton.anchorX = 1
            leaderboardsButton.anchorY = 0
            leaderboardsButton.x = display.contentCenterX
            leaderboardsButton.y = titleBarBottom
            composer.stage:insert( leaderboardsButton )
            composer.setVariable( "leaderboardsButton", leaderboardsButton )
            
            -- Create "Achievements" scene button
            local achievementsButton = widget.newButton(
            {
                id = "achievements",
                label = "Achievements",
                shape = "rectangle",
                width = display.actualContentWidth/2,
                height = 36,
                font = sampleUI.appFont,
                fontSize = 16,
                fillColor = { default={ 0.13,0.39,0.44,1 }, over={ 0.13,0.39,0.44,1 } },
                labelColor = { default={ 1,1,1,1 }, over={ 1,1,1,0.8 } },
                onRelease = handleSceneButton
            })
            achievementsButton.anchorX = 0
            achievementsButton.anchorY = 0
            achievementsButton.x = display.contentCenterX
            achievementsButton.y = titleBarBottom
            composer.stage:insert( achievementsButton )
            composer.setVariable( "achievementsButton", achievementsButton )
            
            -- Set initialized flag as true
            composer.setVariable( "initializedGC", true )
            
            -- Request local player information
            gamecircle.GetLocalPlayerProfile( PlayerProfileCallback )
            
            -- Load leaderboard categories
            gamecircle.Leaderboard.GetLeaderboards( LeaderboardCallback )
            
            -- Load achievement descriptions
            gamecircle.Achievement.GetAchievements( AchievementCallback )
        
        else
            -- Display alert that GameCircle cannot be initialized
            native.showAlert( "Error", "Player is not signed into GameCircle", { "OK" } )
        end
        
        local printTable = composer.getVariable( "printTable" )
        printTable( result )
    end
end


local checkInitTimer -- retry timer

-- Checks GameCircle IsReady and IsPlayerSignedIn states and calls
-- initCallback if both are true
local function checkGamecircleState()
    print( "Checking GameCircle sign in state" )
    if ( gamecircle.IsReady() ) then
        if ( gamecircle.IsPlayerSignedIn() ) then
            if ( checkInitTimer ) then
                timer.cancel( checkInitTimer )
                checkInitTimer = nil
            end
            initCallback( true )
        end
    end
end


-- Initialize GameCircle if platform is an Amazon device
if ( system.getInfo( "targetAppStore" ) == "amazon" ) then
    gamecircle.Init( true, true, true )
--    gamecircle.SetSignedInListener( initCallback ) -- CRASHES
    checkInitTimer = timer.performWithDelay( 1000, checkGamecircleState, -1 ) -- check signed in state once/sec
else
    native.showAlert( "Not Supported", "Amazon GameCircle is not supported on this platform. Please build and deploy to an Amazon device.", { "OK" } )
end
