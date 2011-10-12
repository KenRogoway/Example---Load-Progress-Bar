---------------------------------------------------------------------------------------
-- Date: October 12, 2011
--
-- Version: 1.0
--
-- File name: main.lua
--
-- Code type: Example Code
--
-- Author: Ken Rogoway
--
-- Demonstrates: Loading assets while updating a progress bar to show the percent complete
--
-- Update History:
--
-- Comments: The space images used are from NASA and are in the public domain.
-- 			 The horse image sheets are from the horse demo provided by Ansca.
--
-- Sample code is MIT licensed:
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- Copyright (C) 2011 Ken Rogoway. All Rights Reserved.
---------------------------------------------------------------------------------------

-- Our Global World state.  Used for all global variables
-- so they can be accessed in other modules
gWS = {}

gWS.sysModel = system.getInfo("model")
gWS.strPlatform = system.getInfo("platformName")
gWS.strEnvironment = system.getInfo("environment" )

-- Where to find our image assets
gWS.pImageDir = "Images/"

-- These scale factors are used since the
-- source art assets are 800x600
gWS.nScaleX = display.contentWidth/800.0
gWS.nScaleY = display.contentHeight/600.0

-- This is to access the module that loads our assets
gWS.pAssetLoader = require( "cAssetLoader" )

-- These are used to let the loading code know how many
-- chunks are being loaded and what chunk we are loading
-- These should be set in the cAssetLoader:Init() code
-- since that is where you know how many chunks there are
gWS.nLoadIndex = 0
gWS.nLoadCount = 1

-- Seed randomizer
local seed = os.time();
math.randomseed( seed )

-- SOME INITIAL SETTINGS
display.setStatusBar( display.HiddenStatusBar ) --Hide status bar from the beginning

local oldTimerCancel = timer.cancel

timer.cancel = function(t)
	if t then
		oldTimerCancel(t)
	end
end

local oldRemove = display.remove
display.remove = function( o )
	if o ~= nil then
		
		Runtime:removeEventListener( "enterFrame", o )
		oldRemove( o )
		o = nil
	end
end

-- Import director class
local director = require("director")
ui = require( "ui" )

-- Create a main group
local mainGroup = display.newGroup()

-- Main function
local function main()
	
	-- Add the group from director class
	mainGroup:insert(director.directorView)
	
	audio.setVolume( 1.0 )
	
	director:changeScene( "cSceneLoad" )
	
	return true
end

-- Begin
main()
