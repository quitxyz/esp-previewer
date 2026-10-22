--[[
	@description pandaauth globals for editor support
]]

--// types
type PandaAuthReason =
    "OK"
    | "INVALID_KEY"
    | "RATE_LIMITED"
    | "NETWORK"
    | "NO_SERVICE"
    | "NO_KEY"
    | "NO_HTTP"
    | "IDENTITY"
    | "PROTOCOL"

type PandaAuthenticationMethod = "ClientID" | "UserID_Only" | "Auto"

type PandaAuthV4Api = {
    Validate: (key: string) -> boolean,
    Validate_Premium: (key: string) -> boolean,
    ValidateEx: (key: string) -> (boolean, PandaAuthReason, boolean),

    GetExpiry: () -> string?,
    GetExpiryUnix: () -> number?,
    GetTimeLeft: () -> number?,
    IsExpired: () -> boolean,
    GetExpiryFormatted: () -> string,

    GetAuthMethod: () -> PandaAuthenticationMethod?,
    GetIdentity: () -> string?,
}

type PandaV4Api = {
    InitScript: () -> any,
}

--// runtime
declare PandaAuthV4: PandaAuthV4Api
declare PandaV4: PandaV4Api

--// functions
declare function Validate(key: string): boolean
declare function GetKey(): string
