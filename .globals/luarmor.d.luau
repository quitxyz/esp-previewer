--[[
	@description luarmor globals for editor support
]]

--// runtime
declare script_key: string
declare LRM_IsUserPremium: boolean
declare LRM_LinkedDiscordID: string?
declare LRM_ScriptName: string
declare LRM_TotalExecutions: number
declare LRM_SecondsLeft: number
declare LRM_UserNote: string

--// functions
type GenericFunction<T, U...> = (U...) -> T
declare function LRM_INIT_SCRIPT<T, U...>(f: GenericFunction<T, U...>): GenericFunction<T, U...>
