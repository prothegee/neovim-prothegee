
local NTWRKRQ = {}

--[[

# NTWRKRQ
NeTWoRK ReQuest

---

REQUIREMENTS:
- curl (executable)

NOTE:
- data dir:
    - $cwd/.nvim/ntwrkrq.json -- ntwrkrq json file
    - $cwd/.nvim/ntwrkrq-data.json -- ntwrkrq data name json file:
        - example:
        ```json
        ```

TODO:
- ui:
    1.  [?] req input name (expand input fix width)
    2.  [?] req input method (expand input fix width)
    3.  [?] req input url (expand input fix width)
    4.  [?] req input parameters (expand input fix width)
    5.  [?] req input headers (scrollable input fix width)
    6.  [?] req input body (scrollable input fix width)
    7.  [?] ib send (<CR> will send)
    8.  [?] ib save (<CR> will save name)
    9.  [?] ib load (<CR> will load name, under: $cwd/.nvim/ntwrkrq-data.json)
    10. [?] resp output status (expand input fix width)
    11. [?] resp output body data (scrollable input fix width)
- ui tui:
*------------------------------------NTWRKRQ------------------------------------*
| *--name-----------------------------------------*  *------* *------* *------* |
| |                                               |  | SEND | | SAVE | | LOAD | |
| *-----------------------------------------------*  *------* *------* *------* |
| *--method--* *--url----------------*     *--status--------------------------* |
| |          | |                     |     |                                  | |
| *----------* *---------------------*     *----------------------------------* |
| *--parameters----------------------*     *--body data-----------------------* |
| |                                  |     |                                  | |
| *----------------------------------*     |                                  | |
| *--headers-------------------------*     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| *----------------------------------*     |                                  | |
| *--body----------------------------*     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| |                                  |     |                                  | |
| *----------------------------------*     *----------------------------------* |
*-------------------------------------------------------------------------------*
- ui state navigate:
    1. name
    2. send
    3. save
    4. load
    5. method
    6. url
    7. parameters
    8. headers
    9. body
    n. _BACK_TO_NO_1_
--]]

---

local config = {
    border = "rounded",
    highlight_ns = vim.api.nvim_create_namespace("NTWRKRQ_HL")
}

local state = {
    buf = nil,
    win = nil,
    cwd = vim.fn.getcwd(),
    curl = "",
    input_url = "",
    input_schema = "", -- http, https, !ws, !wss
    input_method = "",
    input_payload_body = "",
    input_payload_header = "",
    mode = "", -- "", "name", "name_collection"
    is_loading = false, -- loading state
}

local is_windows = function()
    return package.config:sub(1,1) == "\\"
end

local init_ntwrkrq = function()
end

---

-- @note order: 1
local function init_ui_input_name()
    -- TODO
end

-- @note order: 2
local function init_ui_input_method()
    -- TODO
end

-- @note order: 3
local function init_ui_input_url()
    -- TODO
end

-- @note order: 4
local function init_ui_input_parameters()
    -- TODO
end

-- @note order: 5
local function init_ui_input_headers()
    -- TODO
end

-- @note order: 6
local function init_ui_input_body()
    -- TODO
end

-- @note order: 7
local function init_ui_ib_send()
    -- TODO
end

-- @note order: 8
local function init_ui_ib_save()
    -- TODO
end

-- @note order: 9
local function init_ui_ib_load()
    -- TODO
end

-- @note ordeer: 10
local function init_ui_output_status()
    -- TODO
end

-- @note order: 11
local function init_ui_output_body_data()
    -- TODO
end

local function create_window(mode)
    init_ntwrkrq()

    vim.notify("NTWRKRQ: todo create_window")

    -- TODO: create parent window
    init_ui_input_name()
    init_ui_input_method()
    init_ui_input_url()
    init_ui_input_parameters()
    init_ui_input_headers()
    init_ui_input_body()
    init_ui_ib_send()
    init_ui_ib_save()
    init_ui_ib_load()
    init_ui_output_status()
    init_ui_output_body_data()

    -- finally?
end

---

-- reserved

---

NTWRKRQ.cmd = {
    ntwrkrq = "NtwrkRq",
    ntwrkrq_name = "NtwrkRqName",
    ntwrkrq_name_collection = "NtwrkRqNameCollection",
}

NTWRKRQ.http = {
    -- https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers
    -- NOTE:
    -- - if:
    --  - it has E suffix, has experimental
    --  - it has W suffix, has warning
    header = {
        Accept = "Accept",
        AcceptCH = "Accept-CH",
        AcceptEncoding = "Accept-Encoding",
        AcceptLanguage = "Accept-Language",
        AcceptPatch = "Accept-Patch",
        AcceptPost = "Accept-Post",
        AcceptRanges = "Accept-Ranges",
        AccessControlAllowCredentials = "Access-Control-Allow-Credentials",
        AccessControlAllowHeaders = "Access-Control-Allow-Headers",
        AccessControlAllowOrigin = "Access-Control-Allow-Origin",
        AccessControlAllowMethod = "Access-Control-Allow-Method",
        Age = "Age",
        Allow = "Allow",
        AltSvc = "Alt-Svc",
        AltUsed = "Alt-Used",
        AttributionReportingEligible_E = "Attribution-Reporting-Eligible",
        AttributionReportingRegisterSource_E = "Attribution-Reporting-Register-Source",
        AttributionReportingRegisterTrigger_E = "Attribution-Reporting-Register-Trigger",
        Authorization = "Authorization",
        AvailableDictionary_E = "Available-Dictionary",
        CacheControl = "Cache-Control",
        ClearSiteData = "Clear-Site-Data",
        Connection = "Connection",
        ContentDigest = "Content-Digest",
        ContentDisposition = "Content-Disposition",
        ContentEncoding = "Content-Encoding",
        ContentLanguage = "Content-Language",
        ContentLength = "Content-Length",
        ContentLocation = "Content-Location",
        ContentRange = "Content-Range",
        ContentSecurityPolicy = "Content-Security-Policy",
        ContentSecurityPolicyReportOnly = "Content-Security-Policy-Report-Only",
        ContentType = "Content-Type",
        Cookie = "Cookie",
        CriticalCH_E = "Critical-CH",
        CrossOriginEmbedderPolicy = "Cross-Origin-Embedder-Policy",
        CrossOriginOpenerPolicy = "Cross-Origin-Opener-Policy",
        CrossOriginResourcePolicy = "Cross-Origin-Resource-Policy",
        Date = "Date",
        DeviceMemory = "Device-Memory",
        DictionaryID_E = "Dictionary-ID",
        Downlink_E = "Downlink",
        EarlyData_E = "Early-Data",
        ECT_E = "ECT",
        ETag = "ETag",
        Expect = "Expect",
        Expires = "Expires",
        Forwarded = "Forwarded",
        From = "From",
        Host = "Host",
        IdempotencyKey = "Idempotency-Key",
        IfMatch = "If-Match",
        IfModifiedSince = "If-Modified-Since",
        IfNoneMatch = "If-None-Match",
        IfRange = "If-Range",
        IfUnmodifiedSince = "If-Modified-Since",
        IntegrityPolicy = "Integrity-Policy",
        IntegrityPolicyReportOnly = "Integrity-Policy-Report-Only",
        KeepAlive = "Keep-Alive",
        LastModified = "Last-Modified",
        Link = "Link",
        Location = "Location",
        MaxForwards = "Max-Forwards",
        NEL_E = "NEL",
        NoVarySearch_E = "No-Vary-Search",
        ObserveBrowsingTopics_EW = "Observe-BrowsingTopics",
        Origin = "Origin",
        OriginAgentCluster = "Origin-Agent-Cluster",
        PermissionsPolicy = "Permissions-Policy",
        Prefer = "Prefer",
        PreferenceApplied = "Preference-Applied",
        Priority = "Priority",
        ProxyAuthenticate = "Proxy-Authenticate",
        ProxyAuthorization = "Proxy-Authorization",
        Range = "Rane",
        Referer = "Referer",
        ReferrerPolicy = "Referrer-Policy",
        Refresh = "Refresh",
        ReportingEndpoints = "ReportingEndpoints",
        ReprDigest = "Repr-Digest",
        RetryAfter = "Retry-After",
        RTT_E = "RTT",
        SaveData_E = "Save-Data",
        SecBrowsingTopics_EW = "Sec-Browsing-Topics",
        SecCHPrefersColorScheme_E = "Sec-CH-Prefers-Color-Scheme",
        SecCHPrefersReduceMotion_E = "Sec-CH-Prefers-Reduce-Motion",
        SecCHPrefersReduceTransparency_E = "Sec-CH-Prefers-Reduce-Transparency",
        SecCHUA_E = "Sec-CH-UA",
        SeCHUAArch_E = "Sec-CH-UA-Arch",
        SecCHUABitness_E = "Sec-CH-UA-Bitness",
        SecCHUAFormFactors_E = "Sec-CH-UA-Bitness",
        SecCHUAFullVersion_E = "Sec-CH-UA-Full-Version",
        SecCHUAFullVersionList_E = "Sec-CH-UA-Full-Version-List",
        SecCHUAMobile_E = "Sec-CH-UA-Mobile",
        SecCHUAModel_E = "Sec-CH-UA-Model",
        SecCHUAPlatform_E = "Sec-CH-UA-Platform",
        SecCHUAPlatformVersion_E = "Sec-CH-UA-Platform",
        SecCHUAWoW64_E = "Sec-CH-UA-Wow64",
        SecFetchDest = "Sec-Fetch-Dest",
        SecFetchMode = "Sec-Fetch-Mode",
        SecFetchSite = "Sec-Fetch-Site",
        SecFetchUser = "Sec-Fetch-User",
        SecGPC_E = "Sec-GPC",
        SecPurpose = "Sec-Purpose",
        SecSpeculationTags_E = "Sec-Speculation-Tags",
        SecWebSocketAccept = "Sec-WebSocket-Accept",
        SecWebSocketExtensions = "Sec-WebSocket-Extensions",
        SecWebSocketKey = "Sec-WebSocket-Key",
        SecWebSocketProtocol = "Sec-WebSocket-Protocol",
        SecWebSocketVersion = "Sec-WebSocket-Version",
        Server = "Server",
        ServerTiming = "Server-Timing",
        ServiceWorker = "Service-Worker",
        ServiceWorkerAllowed = "Service-Worker-Allowed",
        ServiceWorkerNavigationPreload = "Service-Worker-Navigation-Preload",
        SetCookie = "Set-Cookie",
        SetLogin = "Set-Login",
        SourceMap = "Source-Map",
        SpeculationRules_E = "Speculation-Rules",
        StrictTransportSecurity = "Strict-Transport-Security",
        SupportsLoadingMode_E = "Supports-Loading-Mode",
        TE = "TE",
        TimingAllowOrigin = "Timing-Allow-Origin",
        Trailer = "Trailer",
        TransferEncoding = "Transfer-Encoding",
        Upgrade = "Upgrade",
        UpgradeInsecureRequest = "Upgrade-Insecure-Request",
        UseAsDictionary_E = "Use-As-Dictionary",
        UserAgent = "User-Agent",
        Vary = "Vary",
        Via = "Via",
        WantContentDigest = "Want-Content-Digest",
        WantReprDigest = "Want-Repr-Digest",
        WWWAuthenticate = "WWW-Authenticate",
        -- X-?
    },
    -- https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods
    method = {
        GET = "GET",
        HEAD = "HEAD",
        POST = "POST",
        PUT = "PUT",
        DELETE = "DELETE",
        CONNECT = "CONNECT",
        OPTIONS = "OPTIONS",
        TRACE = "TRACE",
        PATCH = "PATCH"
    },
    -- https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status
}

NTWRKRQ.default = {
    -- shortcut map
    map = "<C-A-tab>"
}

---

function NTWRKRQ.show()
    local curl_exec = "curl"

    if is_windows() then
        curl_exec = curl_exec + ".exe"
    end

    if not vim.fn.findfile(curl_exec) then
        vim.notify("curl exec not found", vim.log.levels.WARN)
        return
    end

    create_window()
end

---

vim.api.nvim_create_user_command(
    NTWRKRQ.cmd.ntwrkrq,
    NTWRKRQ.show,
    {
        desc = "Network Request default launch"
    }
)

---

return NTWRKRQ

