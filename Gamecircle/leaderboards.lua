
local composer = require( "composer" )
local gamecircle = require( "plugin.gamecircle" )
local widget = require( "widget" )

local scene = composer.newScene()

local radioGroup = display.newGroup()

composer.setVariable( "currentScore", 200 )
composer.setVariable( "currentLeaderboardID", "" )
composer.setVariable( "currentLeaderboardTitle", "" )

local appFont = composer.getVariable( "appFont" )


-- Radio button handler function
local function handleRadio( event )
    
    for j = 1,radioGroup.numChildren do
        if ( radioGroup[j].isOn == true and radioGroup[j].label ) then
            radioGroup[j].label:setFillColor( 1, 1, 1, 1 )
            composer.setVariable( "currentLeaderboardID", event.target.id )
            composer.setVariable( "currentLeaderboardTitle", event.target.title )
        elseif ( radioGroup[j].isOn == false and radioGroup[j].label ) then
            radioGroup[j].label:setFillColor( 1, 1, 1, 0.7 )
        end
    end
end


-- Button handler function
local function handleButton( event )
    
    local target = event.target
    
    -- Show leaderboard panel
    if ( target.id == "showLeaderboard" ) then
        gamecircle.Leaderboard.OpenOverlay( composer.getVariable( "currentLeaderboardID" ) )  
        
        
	-- Submit high score
    elseif ( target.id == "submitScore" ) then
        local leaderboardId = composer.getVariable( "currentLeaderboardID" )
        gamecircle.Leaderboard.SubmitScore( leaderboardId, composer.getVariable( "currentScore" ) )
        
	-- Decrement current score
    elseif ( target.id == "decScore" and composer.getVariable( "currentScore" ) >= 20 ) then
        composer.setVariable( "currentScore", composer.getVariable( "currentScore" ) - 10 )
        composer.getVariable( "submitButton" ):setLabel( "Submit ("..composer.getVariable( "currentScore" )..")" )
        
	-- Increment current score
    elseif ( target.id == "incScore" ) then
        composer.setVariable( "currentScore", composer.getVariable( "currentScore" ) + 10 )
        composer.getVariable( "submitButton" ):setLabel( "Submit ("..composer.getVariable( "currentScore" )..")" )
    end
    return true
end


function scene:create( event )
    
    local sceneGroup = self.view
    sceneGroup:insert( radioGroup )
    
    local decButton = widget.newButton{
        id = "decScore",
        label = "-10",
        shape = "rectangle",
        width = 52,
        height = 32,
        font = appFont,
        fontSize = 16,
        fillColor = { default={ 0.06,0.31,0.55,1 }, over={ 0.06,0.31,0.55,1 } },
        labelColor = { default={ 1,1,1,1 }, over={ 1,1,1,0.8 } },
        onRelease = handleButton
    }
    decButton.x = display.contentCenterX - 98
    decButton.y = 362
    sceneGroup:insert( decButton )
    
    local incButton = widget.newButton{
        id = "incScore",
        label = "+10",
        shape = "rectangle",
        width = 52,
        height = 32,
        font = appFont,
        fontSize = 16,
        fillColor = { default={ 0.06,0.31,0.55,1 }, over={ 0.06,0.31,0.55,1 } },
        labelColor = { default={ 1,1,1,1 }, over={ 1,1,1,0.8 } },
        onRelease = handleButton
    }
    incButton.x = display.contentCenterX - 38
    incButton.y = 362
    sceneGroup:insert( incButton )
    
    local submitButton = widget.newButton{
        id = "submitScore",
        label = "Submit ("..composer.getVariable( "currentScore" )..")",
        shape = "rectangle",
        width = 128,
        height = 32,
        font = appFont,
        fontSize = 16,
        fillColor = { default={ 0.11,0.47,0.78,1 }, over={ 0.11,0.47,0.78,1 } },
        labelColor = { default={ 1,1,1,1 }, over={ 1,1,1,0.8 } },
        onRelease = handleButton
    }
    submitButton.x = display.contentCenterX + 60
    submitButton.y = 362
    sceneGroup:insert( submitButton )
    composer.setVariable( "submitButton", submitButton )
    
    local showLeaderboardButton = widget.newButton{
        id = "showLeaderboard",
        label = "Show Leaderboard",
        shape = "rectangle",
        width = 248,
        height = 32,
        font = appFont,
        fontSize = 16,
        fillColor = { default={ 0.31,0.35,0.67,1 }, over={ 0.31,0.35,0.67,1 } },
        labelColor = { default={ 1,1,1,1 }, over={ 1,1,1,0.8 } },
        onRelease = handleButton
    }
    showLeaderboardButton.x = display.contentCenterX
    showLeaderboardButton.y = 408
    sceneGroup:insert( showLeaderboardButton )
    
    local ld = composer.getVariable( "leaderboardsData" )
    for i = 1,#ld do
        local on = false ; if ( i == 1 ) then on = true end
        local radioButton = widget.newSwitch{
            left = 40,
            top = 88+(i*36),
            style = "radio",
            id = ld[i].id,
            initialSwitchState = on,
            onPress = handleRadio
        }
        radioGroup:insert( radioButton )
        local radioLabel = display.newText( radioGroup, ld[i].title, 0, radioButton.y, appFont, 16 )
        radioButton.label = radioLabel
        radioButton.title = ld[i].title
        radioLabel.anchorX = 0
        radioLabel.x = 80
        if ( i == 1 ) then
            radioLabel:setFillColor( 1, 1, 1, 1 )
            composer.setVariable( "currentLeaderboardID", radioButton.id )
            composer.setVariable( "currentLeaderboardTitle", radioButton.title )
        else
            radioLabel:setFillColor( 1, 1, 1, 0.7 )
        end
    end
end


scene:addEventListener( "create", scene )

return scene
