BennyBridge = BennyBridge or {}
BennyBridge.Version = BennyBridge.Version or {}

local VERSION_URL = 'https://raw.githubusercontent.com/benny1x/version-repo/refs/heads/main/%s'

--- resource name -> github version file
local VERSION_FILES = {
    ['benny-airdrops'] = 'airdrops.txt',
    ['benny-cservice'] = 'cservice.txt',
    ['benny-loot'] = 'loot.txt',
    ['benny-turfs'] = 'turfs.txt',
}

local function normalize(version)
    if type(version) ~= 'string' then
        return nil
    end

    version = version:match('^%s*(.-)%s*$') or version
    version = version:gsub('%s+', '')
    version = version:match('[%d%.]+')
    return version and version ~= '' and version or nil
end

local function parse(version)
    local parts = {}
    for piece in string.gmatch(version, '%d+') do
        parts[#parts + 1] = tonumber(piece) or 0
    end
    return parts
end

--- @return integer -1 if a < b, 0 if equal, 1 if a > b
local function compare(a, b)
    local left = parse(a)
    local right = parse(b)
    local len = math.max(#left, #right)

    for i = 1, len do
        local l = left[i] or 0
        local r = right[i] or 0
        if l < r then
            return -1
        end
        if l > r then
            return 1
        end
    end

    return 0
end

local function printBanner(resource, current, latest, status)
    local label = resource or 'unknown'

    if status == 'latest' then
        print(('^2[Benny Scripts]^7 %s is up to date ^2(v%s)^7'):format(label, current))
        return
    end

    if status == 'outdated' then
        print(('^3[Benny Scripts]^7 %s is ^1outdated^7! You have ^1v%s^7, latest is ^2v%s^7'):format(label, current, latest))
        print('^3[Benny Scripts]^7 Update at ^5https://bennyscripts.tebex.io/^7')
        return
    end

    if status == 'ahead' then
        print(('^3[Benny Scripts]^7 %s is newer than the public release (^2v%s^7 local / ^3v%s^7 remote)'):format(label, current, latest))
        return
    end

    print(('^1[Benny Scripts]^7 Failed to check version for %s'):format(label))
end

--- Check a resource against the Benny version repo.
--- @param resource? string defaults to invoking / current resource
--- @param fileName? string e.g. 'airdrops.txt' (optional override)
function BennyBridge.Version.Check(resource, fileName)
    if Config.VersionCheck == false then
        return
    end

    resource = resource or GetInvokingResource() or GetCurrentResourceName()
    if type(resource) ~= 'string' or resource == '' then
        return
    end

    if GetResourceState(resource) ~= 'started' and resource ~= GetCurrentResourceName() then
        return
    end

    fileName = fileName or VERSION_FILES[resource]
    if not fileName then
        BennyBridge.mDebug('version: no file mapped for', resource)
        return
    end

    local current = normalize(GetResourceMetadata(resource, 'version', 0))
    if not current then
        print(('^1[Benny Scripts]^7 %s has no version in fxmanifest'):format(resource))
        return
    end

    local url = VERSION_URL:format(fileName)

    PerformHttpRequest(url, function(statusCode, body)
        if statusCode ~= 200 or type(body) ~= 'string' then
            printBanner(resource, current, nil, 'error')
            BennyBridge.mDebug('version check http failed', resource, statusCode)
            return
        end

        local latest = normalize(body)
        if not latest then
            printBanner(resource, current, nil, 'error')
            return
        end

        local cmp = compare(current, latest)
        if cmp == 0 then
            printBanner(resource, current, latest, 'latest')
        elseif cmp < 0 then
            printBanner(resource, current, latest, 'outdated')
        else
            printBanner(resource, current, latest, 'ahead')
        end
    end, 'GET', '', {
        ['User-Agent'] = 'benny-bridge-version-check',
    })
end

--- Check every known Benny script that is currently started.
function BennyBridge.Version.CheckAll()
    if Config.VersionCheck == false then
        return
    end

    for resource, fileName in pairs(VERSION_FILES) do
        if GetResourceState(resource) == 'started' then
            BennyBridge.Version.Check(resource, fileName)
        end
    end
end

CreateThread(function()
    Wait(2500)
    BennyBridge.Version.CheckAll()
end)
