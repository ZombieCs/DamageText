function GetRandomDouble(min, max, positive)
    positive = positive == nil and true or positive

    if positive or math.random(0, 1) == 0 then
        return min + math.random() * (max - min)
    else
        return -min + math.random() * (-max + min)
    end
end

-- @event returns void
AddEventHandler("OnPlayerHurt", function(event --[[ Event ]])
    local playerid = event:GetInt("userid")
    local attackerid = event:GetInt("attacker")
    local dmg_health = event:GetInt("dmg_health")

    local player = GetPlayer(playerid)
    if not player.IsValid then return EventResult.Continue end
    local attacker = GetPlayer(attackerid)
    if not attacker.IsValid then return EventResult.Continue end
    local playervec = player:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
    local attvec = attacker:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin

    local offset = 40;
    local deltaX = attvec.x - playervec.x;
    local deltaY = attvec.y - playervec.y;
    local deltaZ = attvec.z - playervec.z;
    local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
    local newX = playervec.x + (deltaX / distance) * offset;
    local newY = playervec.y + (deltaY / distance) * offset;
    local newZ = playervec.z + (deltaZ / distance) * offset;

    local position = Vector(
        newX + GetRandomDouble(10, 15, false),
        newY + GetRandomDouble(10, 15, false),
        newZ + GetRandomDouble(20, 80)
    )
    local anglex = player:CBaseEntity().CBodyComponent.SceneNode.AbsRotation

    if (attacker and attacker.IsValid) or (attacker and attacker:CCSPlayerController().IsValid and attacker:CCSPlayerController().IsValid) then
        anglex.y = GetRandomDouble(0, 360)
    else
        anglex.y = anglex.y - 90
    end
    anglex.x = anglex.x + 0
    anglex.z = anglex.z + 90

    local hitgroup = event:GetInt("hitgroup")

    local fontSize = config:Fetch("damage.fontsize.default")
    local defaultColor=config:Fetch("damage.textcolor.default")
    local color = Color(defaultColor[1], defaultColor[2], defaultColor[3], defaultColor[4])

    if hitgroup == 1 then
        fontSize = config:Fetch("damage.fontsize.headshot")
        local headshotColor=config:Fetch("damage.textcolor.headshot")
        color = Color(headshotColor[1], headshotColor[2], headshotColor[3], headshotColor[4])
    end

    if dmg_health >= event:GetInt("health") then
        local killColor=config:Fetch("damage.textcolor.kill")
        fontSize = config:Fetch("damage.fontsize.kill")
        color = Color(killColor[1], killColor[2], killColor[3], killColor[4])
    end

    local text = CPointWorldText(CreateEntityByName("point_worldtext"):ToPtr())
    
    text.MessageText = math.floor(dmg_health)
    text.Enabled = true
    text.FontSize = fontSize
    text.Color = color
    text.Fullbright = true
    text.WorldUnitsPerPx = 0.1
    text.DepthOffset = 0
    text.JustifyHorizontal = PointWorldTextJustifyHorizontal_t.POINT_WORLD_TEXT_JUSTIFY_HORIZONTAL_CENTER
    text.JustifyVertical = PointWorldTextJustifyVertical_t.POINT_WORLD_TEXT_JUSTIFY_VERTICAL_CENTER

    local bEntity = CBaseEntity(text:ToPtr())
    bEntity:Teleport(Vector(position.x, position.y, position.z), QAngle(anglex.x, anglex.y, anglex.z))

    SetTimeout(config:Fetch("damage.displaytime")*1000, function()
        bEntity:Despawn()
        -- bEntity:AcceptInput("Kill", bEntity, bEntity, "", 0)
    end)


    return EventResult.Continue
end)


