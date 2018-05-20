-- LibHSLColor-1.0
-- Functions for converting from HSL to RGB and back that mirror the ColorMixin
-- API
--
-- Copyright 2018 Jason Greer
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local LibHSLColor = _G.LibStub:NewLibrary("LibHSLColor-1.0", 0)

if not LibHSLColor then
    return
end

local function hueToRGB(m1, m2, h)
    if h < 0 then
        h = h + 1
    end

    if h > 1 then
        h = h - 1
    end

    if h * 6 < 1 then
        return m1 + (m2 - m1) * h * 6
    end

    if h * 2 < 1 then
        return m2
    end

    if h * 3 < 2 then
        return m1 + (m2 - m1) * (2 / 3 - h) * 6
    end

    return m1
end

local function hslToRGB(h, s, l)
    h = h / 360

    local m2
    if l < 0.5 then
        m2 = l * (s + 1)
    else
        m2 = l + s - l * s
    end

    local m1 = l * 2 - m2
    local r = hueToRGB(m1, m2, h + 1 / 3)
    local g = hueToRGB(m1, m2, h)
    local b = hueToRGB(m1, m2, h - 1 / 3)

    return r, g, b
end

local function hslaToRGBA(h, s, l, a)
    local r, g, b = hslToRGB(h, s, l)

    return r, g, b, a
end

local function rgbToHSL(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local d = max - min
    local l = (max + min) / 2
    local h, s

    if d == 0 then
        return 0, 0, l
    end

    if l > 0.5 then
        s = d / (2 - max - min)
    else
        s = d / (max + min)
    end

    if max == r then
        h = (g - b) / d
        if g < b then
            h = h + 6
        end
    elseif max == g then
        h = (b - r) / d + 2
    elseif max == b then
        h = (r - g) / d + 4
    end

    h = h / 6

    return h, s, l
end

local function rgbToHSLA(r, g, b, a)
    local h, s, l = rgbToHSL(r, g, b)

    return h, s, l, a
end

local HSLColor = {}
local HSLColor_MT = {__index = HSLColor}

function HSLColor:IsEqualTo(otherColor)
    return self.h == otherColor.h and self.s == otherColor.s and self.l == otherColor.l and self.a == otherColor.a
end

function HSLColor:GetHSL()
    return self.h, self.s, self.l
end

function HSLColor:GetHSLA()
    return self.h, self.s, self.l, self.a or 1
end

function HSLColor:GetRGB()
    return hslToRGB(self.h, self.s, self.l)
end

function HSLColor:GetRGBA()
    return hslaToRGBA(self.h, self.s, self.l, self.a)
end

function HSLColor:SetHSL(h, s, l)
    self:SetHSLA(h, s, l, nil)
end

function HSLColor:SetHSLA(h, s, l, a)
    self.h = h
    self.s = s
    self.l = l
    self.a = a
end

function HSLColor:SetRGB(r, g, b)
    self:SetHSL(rgbToHSL(r, g, b))
end

function HSLColor:SetRGBA(r, g, b, a)
    self:SetHSLA(rgbToHSLA(r, g, b, a))
end

function LibHSLColor.CreateColor(h, s, l, a)
    return setmetatable({h = h, s = s, l = l, a = a}, HSLColor_MT)
end

LibHSLColor.RGBToHSL = rgbToHSL
LibHSLColor.RGBAToHSLA = rgbToHSLA
LibHSLColor.HSLToRGB = hslToRGB
LibHSLColor.HSLAToRGBA = hslaToRGBA
