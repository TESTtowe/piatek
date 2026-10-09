-- Tło w pliku gry. EditableImage w Studio nie wymaga publikowania assetu.
-- W opublikowanej grze właściciel musi włączyć Mesh / Image APIs albo użyć MenuImage.
local AssetService = game:GetService("AssetService")
local EncodingService = game:GetService("EncodingService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local ArtBackground = {}

function ArtBackground.new(parent, UI, config, ready, loadData)
    local self = { images = {}, width = 1672, height = 941, status = "loading", closed = false }
    local photo = UI.frame(parent, { Name = "Photograph", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1, Visible = false, ZIndex = 8 })
    self.photo = photo
    function self:resize(width, height)
        local aspect = self.width / self.height
        local targetWidth = math.max(width, height * aspect)
        photo.Size = UDim2.fromOffset(math.ceil(targetWidth), math.ceil(targetWidth / aspect))
    end
    function self:destroy()
        self.closed = true
        for _, image in ipairs(self.images) do image:Destroy() end
        self.images = {}
        photo:Destroy()
    end
    task.spawn(function()
        local ok, reason = pcall(function()
            if config.MenuImage ~= "" then
                local image = UI.make("ImageLabel", { Name = "PublishedBackdrop", Image = config.MenuImage, BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Stretch, ZIndex = 8 }, photo)
                local loaded = true
                ContentProvider:PreloadAsync({ image }, function(_, status)
                    if status ~= Enum.AssetFetchStatus.Success then loaded = false end
                end)
                assert(loaded, "Published background image failed to load")
                return
            end
            local data = loadData and loadData() or require(script.Parent:WaitForChild("MenuArt"))
            self.width, self.height = data.width, data.height
            for index, tile in ipairs(data.tiles) do
                if self.closed then error("Background disposed") end
                local image = AssetService:CreateEditableImage({ Size = Vector2.new(tile.width, tile.height) })
                if not image then error("EditableImage memory budget exhausted") end
                table.insert(self.images, image)
                local packed = EncodingService:Base64Decode(buffer.fromstring(tile.data))
                local algorithm = Enum.CompressionAlgorithm.Zstd
                local expected = tile.width * tile.height * 4
                assert(EncodingService:GetDecompressedBufferSize(packed, algorithm) == expected, "Image byte count mismatch")
                local pixels = EncodingService:DecompressBuffer(packed, algorithm)
                assert(buffer.len(pixels) == expected, "Invalid image payload")
                image:WritePixelsBuffer(Vector2.zero, Vector2.new(tile.width, tile.height), pixels)
                UI.make("ImageLabel", { Name = "PhotoTile" .. index, ImageContent = Content.fromObject(image), BackgroundTransparency = 1,
                    Position = UDim2.fromScale(tile.x / data.width, tile.y / data.height),
                    Size = UDim2.fromScale(tile.width / data.width, tile.height / data.height), ScaleType = Enum.ScaleType.Stretch, ZIndex = 8 }, photo)
                -- Silnik aktualizuje tylko jeden EditableImage na klatkę. Bez blokowania wejścia.
                RunService.Heartbeat:Wait()
            end
        end)
        if self.closed then return end
        if ok then
            self.status = "image"
            photo.Visible = true
        else
            self.status = "scene"
            for _, image in ipairs(self.images) do image:Destroy() end
            self.images = {}
            for _, child in ipairs(photo:GetChildren()) do child:Destroy() end
            -- API lub pamięć obrazu nie mogą zablokować wejścia do gry.
            warn("Friday background: using 3D scene. " .. tostring(reason))
        end
        ready(self.status)
    end)
    return self
end

return ArtBackground
