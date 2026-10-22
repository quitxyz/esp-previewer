--[[
	@description junkie globals for editor support
]]

--// key
declare JD_IS_PREMIUM: boolean
declare JD_EXPIRES_AT: number?
declare JD_CREATED_AT: number
declare JD_REASON: string
declare JD_SCRIPT_ID: string

--// discord
declare JD_DISCORD_ID: string?
declare JD_DISCORD_DISPLAY_NAME: string?
declare JD_DISCORD_PFP: string?
declare JD_DISCORD_USERNAME: string?

--// statistics
declare JD_EXECUTIONS: number
declare JD_SCRIPT_EXECUTIONS: number
declare JD_USAGE: number
declare JD_SCRIPT_USAGE: number
declare JD_SESSION_COUNT: number
declare JD_KEY_SESSION_COUNT: number
declare JD_LIVE_USERS: { number }
