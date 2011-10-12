
---------------------------------------------------------------------------------------
-- Date: October 12, 2011
--
-- Version: 1.0
--
-- File name: cAssetLoader.lua
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

require "sprite"

-- These are the require statements needed to load the LUA files
-- associated with the sheets.  For this example I am just using
-- the uma "horse" sheet from the Ansca sample code found in:
-- Sample Code\Sprites\HorseAnimation
sheetDataUma1 = require "uma1"
sheetDataUma2 = require "uma2"
sheetDataUma3 = require "uma3"
sheetDataUma4 = require "uma4"

-- This is the info we use to define our chunks so we can
-- load the data one chunk at a time.  You can replace these
-- sprite sheets with your own data, or add additional types
-- of data to load as long as you handle that in LoadChunk()
DataChunk =
{
	{ sht=sheetDataUma1,	file="uma1.png",	ptr=nil },
	{ sht=sheetDataUma2,	file="uma2.png",	ptr=nil },
	{ sht=sheetDataUma3,	file="uma3.png",	ptr=nil },
	{ sht=sheetDataUma4,	file="uma4.png",	ptr=nil },
}

-- Set up our chunk start, count, etc so we can begin reading in data
function Initialize()

	gWS.nLoadIndex = 1
	gWS.nLoadCount = #DataChunk

end

-- Yes, you could pass in the chunk index, but since this will be
-- called by a timer, you cannot pass any parameters, hence the use
-- of the nLoadIndex and nLoadCount global variables
function LoadChunk()

	if ( gWS.nLoadIndex > 0 and gWS.nLoadIndex <= gWS.nLoadCount ) then
	
		local data = DataChunk[gWS.nLoadIndex].sht.getSpriteSheetData()
		
		if ( data ) then
			local fileName = gWS.pImageDir..DataChunk[gWS.nLoadIndex].file
			local spriteSheet = sprite.newSpriteSheetFromData( fileName, data )
			if ( spriteSheet ) then
				local nFrames = #data.frames
				DataChunk[gWS.nLoadIndex].ptr = sprite.newSpriteSet( spriteSheet, 1, nFrames )
			else
				print( "*** ERROR *** Unable to newSpriteSheetFromData()" )
			end
		else
			print( "*** ERROR *** Unable to getSpriteSheetData()" )
		end

		-- Get ready for the next chunk
		gWS.nLoadIndex = gWS.nLoadIndex + 1
	end
	
end

-- We are done with our loading
function Shutdown()

	-- Ensure that if LoadChunk() is called, we do nothing
	gWS.nLoadIndex = #DataChunk + 1
	
end

-- This is just hear so you can call it to load everything.
-- Normally you would want to load a chunk at a time, and
-- update the screen to reflect your progress.
-- This is NOT the place to change or "fix" anything, this
-- is just here so you can see how to load everything.  Look
-- in cSceneLoad.lua for the actual loading method being used.

function LoadAll()

	Initialize()
	
	while gWS.nLoadIndex <= gWS.nLoadCount do
		LoadChunk()
	end
	
	Shutdown()
	
end

