
---------------------------------------------------------------------------------------
-- Date: October 12, 2011
--
-- Version: 1.0
--
-- File name: cSceneLoad.lua
--
-- Code type: Example Code
--
-- Author: Ken Rogoway
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

module(..., package.seeall)

local bUseListener = false
local nMeterX = 272		-- final X position of the meter bar when at 100 percent
local nMeterY = 562		-- Y position of the meter bar
local nMeterW = 480		-- Width of my meter bar image
local nMeterH = 30		-- Height of my meter bar image

-- This is set to 1/2 second (500 ms) so let it go slow enough to
-- see the bar advance since we are using a very small set of data
-- You would want to set this to a much smaller value, so there is
-- minimal delay between chunks, but probably at least 1/30 of a
-- second (33 ms) so there is time to update the display.
local nDelayBetweenChunks = 500

-- Main function - MUST return a display.newGroup()
function new()
	local splashGroup = display.newGroup()
	local loadingImage, loadingBar, loadingMask
	
	loadingImage = display.newImageRect( gWS.pImageDir.."load_bkgd.png", display.contentWidth, display.contentHeight )
	splashGroup:insert( loadingImage )
	loadingImage.x = display.contentCenterX
	loadingImage.y = display.contentCenterY

	loadingBar = display.newImageRect( gWS.pImageDir.."load_bar.png", math.floor( nMeterW * gWS.nScaleX ), math.floor( nMeterH * gWS.nScaleY ) )
	splashGroup:insert( loadingBar )
	
	loadingBar:setReferencePoint( display.TopLeftReferencePoint )
	loadingBar.x = math.floor( (nMeterX-nMeterW) * gWS.nScaleX )
	loadingBar.y = math.floor( nMeterY * gWS.nScaleY )
	
	loadingMask = display.newImageRect(	gWS.pImageDir.."load_mask.png", display.contentWidth, display.contentHeight )
	splashGroup:insert( loadingMask )
	
	loadingMask.x = display.contentCenterX
	loadingMask.y = display.contentCenterY
	
	-- Update the percent complete bar
	function updateBar()
		local nPercent = math.floor( 100 * (gWS.nLoadIndex-1) / gWS.nLoadCount )
		--print( "Percent = ", nPercent )
		loadingBar.x = math.floor( (nMeterX-nMeterW + (nMeterW*nPercent/100)) * gWS.nScaleX )
		if ( nPercent >= 100 ) then
			-- final resting place at 100 percent
			loadingBar.x = math.floor( nMeterX * gWS.nScaleX )
		end
	end
	
	function myLoadChunk()
		-- Load a chunk of data
		gWS.pAssetLoader.LoadChunk()
		
		if ( bUseListener == false ) then
			-- update the loading bar.  See the comments above
			-- regarding using a event to trigger this
			updateBar()
		end
		
		-- Are there any chunks remaining?  If so, set a timer to
		-- load the next one.
		if ( gWS.nLoadIndex <= gWS.nLoadCount ) then
			timer.performWithDelay( nDelayBetweenChunks, myLoadChunk )
		else
			-- Done, so finish any data stuff
			gWS.pAssetLoader.Shutdown()
			
			if ( bUseListener == true ) then
				Runtime:removeEventListener( "enterFrame", updateBar )
			end
			
			-- Onward and outward
			director:changeScene( "cSceneGame" )
		end
	end
	
	-- Set everything up so we can start going
	gWS.pAssetLoader.Initialize()
	
	updateBar()	-- update it once for 0 percent

	-- Start it going
	timer.performWithDelay( nDelayBetweenChunks, myLoadChunk )
	
	if ( bUseListener == true ) then
		Runtime:addEventListener( "enterFrame", updateBar )
	end
		
	clean = function()
		
		if loadingImage then
			display.remove( loadingImage )
			loadingImage = nil
		end
		
		if loadingBar then
			display.remove( loadingBar )
			loadingBar = nil
		end
		
		if loadingMask then
			display.remove( loadingMask )
			loadingMask = nil
		end
	end
	
	-- MUST return a display.newGroup()
	return splashGroup
end
