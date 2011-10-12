
---------------------------------------------------------------------------------------
-- Date: October 12, 2011
--
-- Version: 1.0
--
-- File name: cSceneGame.lua
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

-- Main function - MUST return a display.newGroup()
function new()
	local gameGroup = display.newGroup()
	local gameImage, gameMessage
	
	gameImage = display.newImageRect( gWS.pImageDir.."earth_eclipse.png", display.contentWidth, display.contentHeight )
	gameGroup:insert( gameImage )
	gameImage.x = display.contentCenterX
	gameImage.y = display.contentCenterY
	
	gameMessage = display.newText( "The game is now loaded", 0, 0, native.systemFont, 32 )
	gameMessage:setTextColor( 255, 255, 255 )
	gameGroup:insert( gameMessage )
	
	clean = function()
		
		if gameImage then
			display.remove( gameImage )
			gameImage = nil
		end
		
		if gameMessage then
			display.remove( gameMessage )
			gameMessage = nil
		end
		
	end
	
	-- MUST return a display.newGroup()
	return gameGroup
end
