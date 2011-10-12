-- ui.lua (currently includes Button class with labels, font selection and optional event model)

-- Version 1.5 (works with multitouch, adds setText() method to buttons)
--
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in the 
-- Software without restriction, including without limitation the rights to use, copy, 
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the 
-- following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies 
-- or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.

----------------------------------------------------
-- Edited by William Flagello, williamflagello.com
----------------------------------------------------
-- Works with Dynamic Scaling.
----------------------------------------------------

-- 
-- Abstract: Goshts Vs Monsters sample project 
-- Designed and created by Jonathan and Biffy Beebe of Beebe Games exclusively for Ansca, Inc.
-- http://beebegamesonline.appspot.com/

-- (This is easiest to play on iPad or other large devices, but should work on all iOS and Android devices)
-- 
-- Version: 1.0
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.


module(..., package.seeall)

-----------------
-- Helper function for newButton utility function below
local function newButtonHandler( self, event )

	local result = true

	local default = self[1]
	local over = self[2]
	
	-- General "onEvent" function overrides onPress and onRelease, if present
	local onEvent = self._onEvent
	
	local onPress = self._onPress
	local onRelease = self._onRelease

	local buttonEvent = {}
	if (self._id) then
		buttonEvent.id = self._id
	end

	local phase = event.phase
	if "began" == phase then
		if over then 
			default.isVisible = false
			over.isVisible = true
		end

		if onEvent then
			buttonEvent.phase = "press"
			result = onEvent( buttonEvent )
		elseif onPress then
			result = onPress( event )
		end

		-- Subsequent touch events will target button even if they are outside the stageBounds of button
		display.getCurrentStage():setFocus( self, event.id )
		self.isFocus = true
		
	elseif self.isFocus then
		local bounds = self.stageBounds
		local x,y = event.x,event.y
		local isWithinBounds = 
			bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y

		if "moved" == phase then
			if over then
				-- The rollover image should only be visible while the finger is within button's stageBounds
				default.isVisible = not isWithinBounds
				over.isVisible = isWithinBounds
			end
			
		elseif "ended" == phase or "cancelled" == phase then 
			if over then 
				default.isVisible = true
				over.isVisible = false
			end
			
			if "ended" == phase then
				-- Only consider this a "click" if the user lifts their finger inside button's stageBounds
				if isWithinBounds then
					if onEvent then
						buttonEvent.phase = "release"
						result = onEvent( buttonEvent )
					elseif onRelease then
						result = onRelease( event )
					end
				end
			end
			
			-- Allow touch events to be sent normally to the objects they "hit"
			display.getCurrentStage():setFocus( self, nil )
			self.isFocus = false
		end
	end

	return result
end


---------------
-- Button class

function newButton( params )
	local button, defaultSrc , defaultX , defaultY , overSrc , overX , overY , size, font, textColor, offset
	
	if params.defaultSrc then
		button = display.newGroup()
		default = display.newImageRect ( params.defaultSrc , params.defaultX , params.defaultY )
		button:insert( default, true )
	end
	
	if params.overSrc then
		over = display.newImageRect ( params.overSrc , params.overX , params.overY )
		over.isVisible = false
		button:insert( over, true )
	end
	
	-- Public methods
	function button:setText( newText )
	
		local labelText = self.text
		if ( labelText ) then
			--labelText:removeSelf()
			display.remove( labelText )
			labelText = nil
			self.text = nil
		end

		local labelShadow = self.shadow
		if ( labelShadow ) then
			--labelShadow:removeSelf()
			display.remove( labelShadow )
			labelShadow = nil
			self.shadow = nil
		end

		local labelHighlight = self.highlight
		if ( labelHighlight ) then
			--labelHighlight:removeSelf()
			display.remove( labelHighlight )
			labelHighlight = nil
			self.highlight = nil
		end
		
		if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
		if ( params.font ) then font=params.font else font=native.systemFontBold end
		if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
		
		size = size * 2
		
		-- Optional vertical correction for fonts with unusual baselines (I'm looking at you, Zapfino)
		if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
		
		if ( params.emboss ) then
			-- Make the label text look "embossed" (also adjusts effect for textColor brightness)
			local textBrightness = ( textColor[1] + textColor[2] + textColor[3] ) / 3
			
			labelHighlight = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelHighlight:setTextColor( 255, 255, 255, 20 )
			else
				labelHighlight:setTextColor( 255, 255, 255, 140 )
			end
			button:insert( labelHighlight, true )
			labelHighlight.x = labelHighlight.x + 1.5; labelHighlight.y = labelHighlight.y + 1.5 + offset
			self.highlight = labelHighlight

			labelShadow = display.newText( newText, 0, 0, font, size )
			if ( textBrightness > 127) then
				labelShadow:setTextColor( 0, 0, 0, 128 )
			else
				labelShadow:setTextColor( 0, 0, 0, 20 )
			end
			button:insert( labelShadow, true )
			labelShadow.x = labelShadow.x - 1; labelShadow.y = labelShadow.y - 1 + offset
			self.shadow = labelShadow
			
			labelHighlight.xScale = .5; labelHighlight.yScale = .5
			labelShadow.xScale = .5; labelShadow.yScale = .5
		end
		
		labelText = display.newText( newText, 0, 0, font, size )
		labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
		button:insert( labelText, true )
		labelText.y = labelText.y + offset
		self.text = labelText
		
		labelText.xScale = .5; labelText.yScale = .5
	end
	
	if params.text then
		button:setText( params.text )
	end
	
	if ( params.onPress and ( type(params.onPress) == "function" ) ) then
		button._onPress = params.onPress
	end
	if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
		button._onRelease = params.onRelease
	end
	
	if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
		button._onEvent = params.onEvent
	end
	
	-- set button to active (meaning, can be pushed)
	button.isActive = true
	
	-- Set button as a table listener by setting a table method and adding the button as its own table listener for "touch" events
	button.touch = newButtonHandler
	button:addEventListener( "touch", button )

	if params.x then
		button.x = params.x
	end
	
	if params.y then
		button.y = params.y
	end
	
	if params.id then
		button._id = params.id
	end

	return button
end


--------------
-- Label class

function newLabel( params )
	local labelText
	local size, font, textColor, align
	local t = display.newGroup()
	
	if ( params.bounds ) then
		local bounds = params.bounds
		local left = bounds[1]
		local top = bounds[2]
		local width = bounds[3]
		local height = bounds[4]
	
		if ( params.size and type(params.size) == "number" ) then size=params.size else size=20 end
		if ( params.font ) then font=params.font else font=native.systemFontBold end
		if ( params.textColor ) then textColor=params.textColor else textColor={ 255, 255, 255, 255 } end
		if ( params.offset and type(params.offset) == "number" ) then offset=params.offset else offset = 0 end
		if ( params.align ) then align = params.align else align = "center" end
		
		if ( params.text ) then
			labelText = display.newText( params.text, 0, 0, font, size )
			labelText:setTextColor( textColor[1], textColor[2], textColor[3], textColor[4] )
			t:insert( labelText )
			-- TODO: handle no-initial-text case by creating a field with an empty string?
	
			if ( align == "left" ) then
				labelText.x = left + labelText.contentWidth * 0.5
			elseif ( align == "right" ) then
				labelText.x = (left + width) - labelText.contentWidth * 0.5
			else
				labelText.x = ((2 * left) + width) * 0.5
			end
		end
		
		labelText.y = top + labelText.contentHeight * 0.5

		-- Public methods
		function t:setText( newText )
			if ( newText ) then
				labelText.text = newText
				
				if ( "left" == align ) then
					labelText.x = left + labelText.contentWidth / 2
				elseif ( "right" == align ) then
					labelText.x = (left + width) - labelText.contentWidth / 2
				else
					labelText.x = ((2 * left) + width) / 2
				end
			end
		end
		
		function t:setTextColor( r, g, b, a )
			local newR = 255
			local newG = 255
			local newB = 255
			local newA = 255

			if ( r and type(r) == "number" ) then newR = r end
			if ( g and type(g) == "number" ) then newG = g end
			if ( b and type(b) == "number" ) then newB = b end
			if ( a and type(a) == "number" ) then newA = a end

			labelText:setTextColor( r, g, b, a )
		end
	end
	
	-- Return instance (as display group)
	return t
	
end

local function newSliderHandler( self, event )
 
        local result = true
        
        -- General "onEvent" function overrides onPress and onRelease, if present
        local onEvent = self._onEvent
        
        local onPress = self._onPress
        local onRelease = self._onRelease
 
        local sliderEvent = { value = self.value }
        if (self._id) then
                sliderEvent.id = self._id
        else
                sliderEvent.id = 0
        end
        
        local contentX, contentY = self:localToContent(0, 0)
 
        local phase = event.phase
        if "began" == phase then
                if self.thumbOver then 
                        self.thumbDefault.isVisible = false
                        self.thumbOver.isVisible = true
                end
                
                self.thumbDefault.offsetX, self.thumbDefault.offsetY = self.thumbDefault:contentToLocal(event.x, event.y)
                
                if onEvent then
                        sliderEvent.phase = "press"
                        result = onEvent( sliderEvent )
                elseif onPress then
                        result = onPress( event )
                end
 
                -- Subsequent touch events will target slider even if they are outside the contentBounds of slider
                display.getCurrentStage():setFocus( self, event.id )
                self.isFocus = true
                
        elseif self.isFocus then
                local oldValue = self.value
 
                -- find new position of thumb
                if self.isVertical then
                        local y = (event.y - contentY) / self.yScale
                        y = y - self.thumbDefault.offsetY
                        
                        if y < self.thumbMin then
                                y = self.thumbMin
                        end
                        if y > self.thumbMax then
                                y = self.thumbMax
                        end
                        
                        local newValue = (((y - self.thumbMin) / (self.thumbMax - self.thumbMin)) * self.range) + self.minValue
                        self:setValue(newValue)
                else
                        local x = (event.x - contentX) / self.xScale
                        x = x - self.thumbDefault.offsetX
                        
                        if x < self.thumbMin then
                                x = self.thumbMin
                        end
                        if x > self.thumbMax then
                                x = self.thumbMax
                        end
 
                        local newValue = (((x - self.thumbMin) / (self.thumbMax - self.thumbMin)) * self.range) + self.minValue
                        self:setValue(newValue)
                end
 
                sliderEvent.value = self.value
 
                if "moved" == phase then
                        if self.value ~= oldValue then
                                if onEvent then
                                        sliderEvent.phase = "moved"
                                        result = onEvent( sliderEvent )
                                end
                        end
                elseif "ended" == phase or "cancelled" == phase then 
                        if self.thumbOver then 
                                self.thumbDefault.isVisible = true
                                self.thumbOver.isVisible = false
                        end
                        
                        if "ended" == phase then
                                if onEvent then
                                        sliderEvent.phase = "release"
                                        result = onEvent( sliderEvent )
                                elseif onRelease then
                                        result = onRelease( event )
                                end
                        end
                        
                        -- Allow touch events to be sent normally to the objects they "hit"
                        display.getCurrentStage():setFocus( self, nil )
                        self.isFocus = false
                end
        end
 
        return result
end
 
-- newSlider( params )
-- where params is a table containing:
--              track                   - name of track image
--              thumbDefault    - name of default thumb image
--              thumbOver               - name of thumb over image (optional)
--              minValue                - min value (optional, defaults to 0)
--              maxValue                - max value (optional, defaults to 100)
--              value                   - initial value (optional, defaults to minValue)
--              isInteger               - true if integer, false if real (continuous value) (defaults to false)
--              isVertical              - true if vertical; otherwise is horizontal (defaults to horizontal)
--              onPress                 - function to call when slider is pressed
--              onRelease               - function to call when slider is released
--              onEvent                 - function to call when an event occurs
--              onChange                - function to call when value changes
--  
function newSlider( params )
	local slider
	
	slider = display.newGroup()
	
	function slider:setValue(newValue)
		self.value = newValue
                
		local position = ((self.value - self.minValue) / self.range) * (self.thumbMax - self.thumbMin) + self.thumbMin
		if self.isVertical then
			self.thumbDefault.y = position
			self.thumbOver.y = position
		else
			self.thumbDefault.x = position
			self.thumbOver.x = position
		end
		
		local onChange = self._onChange
		local sliderEvent = { value = self.value }
		if (self._id) then
			sliderEvent.id = self._id
		end
		sliderEvent.phase = "change"
		if onChange then
			result = onChange( sliderEvent )
		end
	end
 
	if params.track then
		slider.track = display.newImage( params.track )
		slider:insert( slider.track, true )
	end
        
	if params.thumbDefault then
		slider.thumbDefault = display.newImage( params.thumbDefault )
		slider:insert( slider.thumbDefault, true )
	end
        
	if params.thumbOver then
		slider.thumbOver = display.newImage( params.thumbOver )
		slider.thumbOver.isVisible = false
		slider:insert( slider.thumbOver, true )
	end
        
	if ( params.maxValue ~= nil ) then
		slider.maxValue = params.maxValue
	else
		slider.maxValue = 100
	end
	if ( params.minValue ~= nil ) then
		slider.minValue = params.minValue
	else
		slider.minValue = 0
	end
 
	slider.range = slider.maxValue - slider.minValue
        
	if ( params.isInteger == true ) then
		slider.isInteger = true
	else
		slider.isInteger = false
	end
	if ( params.isVertical == true ) then
		slider.isVertical = true
	else
		slider.isVertical = false
	end
	if ( params.onPress and ( type(params.onPress) == "function" ) ) then
		slider._onPress = params.onPress
	end
	if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
		slider._onRelease = params.onRelease
	end     
	if (params.onEvent and ( type(params.onEvent) == "function" ) ) then
		slider._onEvent = params.onEvent
	end
	if(params.onChange and ( type(params.onChange) == "function" ) ) then
		slider._onChange = params.onChange
	end
 
	-- Set slider as a table listener by setting a table method and adding the slider as its own table listener for "touch" events
	slider.touch = newSliderHandler
	slider:addEventListener( "touch", slider )
 
	if params.x then
		slider.x = params.x
	end
        
	if params.y then
		slider.y = params.y
	end
        
	if params.id then
		slider._id = params.id
	end
        
	if slider.isVertical then
		slider.thumbMin = -(slider.track.height / 2) + (slider.thumbDefault.height / 2)
		slider.thumbMax = (slider.track.height / 2) - (slider.thumbDefault.height / 2)
	else
		slider.thumbMin = -(slider.track.width / 2) + (slider.thumbDefault.width / 2)
		slider.thumbMax = (slider.track.width / 2) - (slider.thumbDefault.width / 2)
	end
        
	if ( params.value ~= nil ) then
		slider:setValue(params.value)
	else
		slider:setValue(slider.minValue)
	end

	return slider
end