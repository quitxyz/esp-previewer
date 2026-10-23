--[[
    @author quit (quit.xyz)
    @description a standalone modular roblox esp library
    @version "0.1.0"
    @build "compact"
    @date "2026-10-23"
]]

local a={cache={}::any}do do local function b()local c=cloneref or function(c)
return c end return{Players=c(game:GetService'Players'),RunService=c(game:
GetService'RunService'),Workspace=c(game:GetService'Workspace')}end function a.a
():typeof(b())local c=a.cache.a if not c then c={c=b()}a.cache.a=c end return c.
c end end do local function b()local c={enabled=true,maxDistance=2000,deadPolicy
='hide',selection='all',renderPriority=Enum.RenderPriority.Camera.Value+1,box={
enabled=true,style='corner',color=Color3.fromRGB(198,198,200),opacity=1,
thickness=1,padding=3,cornerLength=0.25,outline={enabled=true,color=Color3.
fromRGB(5,5,5),opacity=1,thickness=1},fill={enabled=false,color=Color3.fromRGB(
198,198,200),opacity=0.15}}}local d,e={enabled=c.enabled,maxDistance=c.
maxDistance,deadPolicy=c.deadPolicy,box=c.box},{selection={all=true,enemies=true
,teammates=true},deadPolicy={hide=true,show=true,only=true},style={full=true,
corner=true}}local function f(g,h,i,j)assert(type(h)=='table',
'ESP settings must be a table')local k=table.clone(g)for l,m in h do local n,o=j
==''and tostring(l)or j..'.'..tostring(l),i[l]if j==''and i==c and l=='groups'
then assert(type(m)=='table','ESP groups must be a table')local p=table.clone(g.
groups or{})for q,r in m do assert(q=='enemy'or q=='friendly',
'Unknown ESP group: '..tostring(q))p[q]=f(p[q]or{},r,d,'groups.'..q)end k.groups
=p continue end assert(o~=nil,'Unknown ESP setting: '..n)assert(typeof(m)==
typeof(o),'Invalid type for ESP setting: '..n)if typeof(o)=='table'then k[l]=f(g
[l]or{},m,o,n)continue end if e[l]then assert(e[l][m],
'Invalid value for ESP setting: '..n)elseif type(m)=='number'then assert(m==m
and m>-math.huge,'Invalid number for ESP setting: '..n)assert(m<math.huge or l==
'maxDistance','Invalid number for ESP setting: '..n)if l=='opacity'then assert(m
>=0 and m<=1,n..' must be between 0 and 1')elseif l=='cornerLength'then assert(m
>0 and m<=0.5,n..' must be greater than 0 and at most 0.5')elseif l=='thickness'
then assert(m>0,n..' must be greater than 0')elseif l=='renderPriority'then
assert(m%1==0,n..' must be an integer')else assert(m>=0,n..
' must be non-negative')end end k[l]=m end return k end local function g(h,i)
local j=table.clone(h)for k,l in i do j[k]=typeof(l)=='table'and g(h[k],l)or l
end return j end local h={}function h.new(i)if i==nil then i={}end return f(c,i,
c,'')end function h.update(i,j)return f(i,j,c,'')end function h.resolve(i)local
j=i.groups or{}return{enemy=g(i,j.enemy or{}),friendly=g(i,j.friendly or{})}end
return h end function a.b():typeof(b())local c=a.cache.b if not c then c={c=b()}
a.cache.b=c end return c.c end end do local function b()local c={Head=true,Torso
=true,UpperTorso=true,LowerTorso=true,['Left Arm']=true,['Right Arm']=true,[
'Left Leg']=true,['Right Leg']=true,LeftUpperArm=true,LeftLowerArm=true,LeftHand
=true,RightUpperArm=true,RightLowerArm=true,RightHand=true,LeftUpperLeg=true,
LeftLowerLeg=true,LeftFoot=true,RightUpperLeg=true,RightLowerLeg=true,RightFoot=
true}local function d(e)for f,g in e do g:Disconnect()end table.clear(e)end
local function e(f)local g=f.Character table.clear(f.parts)f.Humanoid=nil f.Root
=nil if not g then return end f.Humanoid=g:FindFirstChildOfClass'Humanoid'local
h=g:FindFirstChild'HumanoidRootPart'if h and h:IsA'BasePart'then f.Root=h end
for i,j in g:GetChildren()do if c[j.Name]and j:IsA'BasePart'then f.parts[#f.
parts+1]=j end end end local function f(g,h)d(g.characterConnections)for i,j in
g.components do j:Hide()end g.Character=h e(g)if h then local function i()if g.
Character==h then e(g)end end g.characterConnections[1]=h.ChildAdded:Connect(i)g
.characterConnections[2]=h.ChildRemoved:Connect(i)end end local g={}g.__index=g
function g.new(h,i)return setmetatable({Players=h,LocalPlayer=i,items={},
connections={},started=false,destroyed=false},g)end function g:Add(h)if self.
destroyed or h==self.LocalPlayer or self.items[h]then return end local i={Player
=h,parts={},components={},bounds={},connections={},characterConnections={}}self.
items[h]=i i.connections[1]=h.CharacterAdded:Connect(function(j)f(i,j)end)i.
connections[2]=h.CharacterRemoving:Connect(function(j)if i.Character==j then f(i
,nil)end end)f(i,h.Character)end function g:Remove(h)local i=self.items[h]if not
i then return end self.items[h]=nil d(i.connections)f(i,nil)for j,k in i.
components do k:Destroy()end table.clear(i.components)end function g:Start()if
self.started or self.destroyed then return end self.started=true self.
connections[1]=self.Players.PlayerAdded:Connect(function(h)self:Add(h)end)self.
connections[2]=self.Players.PlayerRemoving:Connect(function(h)self:Remove(h)end)
for h,i in self.Players:GetPlayers()do self:Add(i)end end function g:Destroy()if
self.destroyed then return end self.destroyed=true d(self.connections)for h in
self.items do self:Remove(h)end end return g end function a.c():typeof(b())local
c=a.cache.c if not c then c={c=b()}a.cache.c=c end return c.c end end do local 
function b()local c,d,e={Vector3.new(-1,-1,-1),Vector3.new(1,-1,-1),Vector3.new(
-1,1,-1),Vector3.new(1,1,-1),Vector3.new(-1,-1,1),Vector3.new(1,-1,1),Vector3.
new(-1,1,1),Vector3.new(1,1,1)},{{1,2},{1,3},{2,4},{3,4},{5,6},{5,7},{6,8},{7,8}
,{1,5},{2,6},{3,7},{4,8}},{}function e.getBounds(f,g)local h,i,j,k,l,m,n=g.
CFrame,math.huge,math.huge,math.huge,-math.huge,-math.huge,-math.huge for o,p in
f do if p.Parent~=g.Parent then continue end local q=h:ToObjectSpace(p.CFrame)
local r,s,t,u,v,w,x,y,z,A,B,C=q:GetComponents()local D=p.Size*0.5 local E,F,G=
math.abs(u)*D.X+math.abs(v)*D.Y+math.abs(w)*D.Z,math.abs(x)*D.X+math.abs(y)*D.Y+
math.abs(z)*D.Z,math.abs(A)*D.X+math.abs(B)*D.Y+math.abs(C)*D.Z i=math.min(i,r-E
)j=math.min(j,s-F)k=math.min(k,t-G)l=math.max(l,r+E)m=math.max(m,s+F)n=math.max(
n,t+G)end if i==math.huge then return end local o=Vector3.new((i+l)*0.5,(j+m)*
0.5,(k+n)*0.5)return h*CFrame.new(o),Vector3.new(l-i,m-j,n-k)end function e.
project(f,g,h,i)local j=f.ViewportSize if j.X<=0 or j.Y<=0 then return false end
local k,l=i.points or table.create(8),i.depths or table.create(8)i.points,i.
depths=k,l local m,n,o,p,q,r,s=math.max(0.01,-f.NearPlaneZ),math.huge,math.huge,
-math.huge,-math.huge,0,h*0.5 for t,u in c do local v=g:PointToWorldSpace(s*u)
local w=f:WorldToViewportPoint(v)k[t],l[t]=v,w.Z if w.Z>=m then r+=1 n,o=math.
min(n,w.X),math.min(o,w.Y)p,q=math.max(p,w.X),math.max(q,w.Y)end end if r==0
then return false end if r<8 then for t,u in d do local v,w=u[1],u[2]local x,y=l
[v],l[w]if(x>=m)~=(y>=m)then local z=(m-x)/(y-x)local A=f:WorldToViewportPoint(k
[v]:Lerp(k[w],z))n,o=math.min(n,A.X),math.min(o,A.Y)p,q=math.max(p,A.X),math.
max(q,A.Y)end end end if p<=n or q<=o or p<0 or q<0 or n>j.X or o>j.Y then
return false end i.left,i.top=n,o i.right,i.bottom=p,q return true end return e
end function a.d():typeof(b())local c=a.cache.d if not c then c={c=b()}a.cache.d
=c end return c.c end end do local function b()local c={}function c.check()
assert(Drawing and type(Drawing.new)=='function','ESP requires the Drawing API')
end function c.create(d,e)local f=Drawing.new(d)local g,h=pcall(function()for g,
h in e do f[g]=h end end)if not g then c.remove(f)error(
'ESP could not configure '..d..': '..tostring(h),2)end return f end function c.
remove(d)local e=pcall(function()d:Remove()end)if not e then local f,g=pcall(
function()d:Destroy()end)if not f then warn('ESP could not release a drawing: '
..tostring(g))end end end return c end function a.e():typeof(b())local c=a.cache
.e if not c then c={c=b()}a.cache.e=c end return c.c end end do local function b
()local c=a.e()local function d(e,f,g)local h=c.create(f,g)e.resources[#e.
resources+1]=h return h end local function e(f,g,h,i,j,k)local l,m=Vector2.new(h
,i),Vector2.new(j,k)f.lines[g].From=l f.lines[g].To=m f.outlines[g].From=l f.
outlines[g].To=m end local f={}f.__index=f function f.new()local g=setmetatable(
{resources={},lines={},outlines={},visible=false,destroyed=false},f)local h,i=
pcall(function()g.fill=d(g,'Square',{Visible=false,Filled=true,ZIndex=0})for h=1
,8 do g.outlines[h]=d(g,'Line',{Visible=false,ZIndex=1})g.lines[h]=d(g,'Line',{
Visible=false,ZIndex=2})end end)if not h then g:Destroy()error(i,2)end return g
end function f:Update(g,h)if self.destroyed then return end if not h.enabled
then self:Hide()return end local i,j=self.settings~=h,h.style=='corner'and 8 or
4 if i then for k=1,8 do local l,m=self.lines[k],self.outlines[k]l.Color=h.color
l.Thickness=h.thickness l.Transparency=h.opacity m.Color=h.outline.color m.
Thickness=h.thickness+h.outline.thickness*2 m.Transparency=h.outline.opacity end
self.fill.Color=h.fill.color self.fill.Transparency=h.fill.opacity self.settings
=h end local k,l,m,n=g.left-h.padding,g.top-h.padding,g.right+h.padding,g.bottom
+h.padding local o,p=m-k,n-l if h.style=='full'then e(self,1,k,l,m,l)e(self,2,m,
l,m,n)e(self,3,m,n,k,n)e(self,4,k,n,k,l)else local q,r=o*h.cornerLength,p*h.
cornerLength e(self,1,k,l+r,k,l)e(self,2,k,l,k+q,l)e(self,3,m-q,l,m,l)e(self,4,m
,l,m,l+r)e(self,5,k,n-r,k,n)e(self,6,k,n,k+q,n)e(self,7,m-q,n,m,n)e(self,8,m,n,m
,n-r)end if h.fill.enabled then self.fill.Position=Vector2.new(k,l)self.fill.
Size=Vector2.new(o,p)end if i or not self.visible then for q=1,8 do self.lines[q
].Visible=q<=j self.outlines[q].Visible=q<=j and h.outline.enabled end self.fill
.Visible=h.fill.enabled self.visible=true end end function f:Hide()if not self.
visible then return end for g,h in self.resources do h.Visible=false end self.
visible=false end function f:Destroy()if self.destroyed then return end self.
destroyed=true for g,h in self.resources do c.remove(h)end table.clear(self.
resources)table.clear(self.lines)table.clear(self.outlines)self.fill=nil self.
settings=nil self.visible=false end return f end function a.f():typeof(b())local
c=a.cache.f if not c then c={c=b()}a.cache.f=c end return c.c end end end local
b,c,d,e,f,g=a.a(),a.b(),a.c(),a.d(),a.e(),a.f()local h,i,j=b.Players,b.
RunService,b.Workspace local k=h.LocalPlayer local function l(m)if m.components.
box then m.components.box:Hide()end end local function m(n)return not n.Neutral
and not k.Neutral and n.Team~=nil and n.Team==k.Team end local n={}n.__index=n
function n.new(o)assert(i:IsClient()and k,'ESP must run on the client')f.check()
local p=setmetatable({settings=c.new(o),entities=d.new(h,k),destroyed=false,
bound=false},n)p.bindingName='esp-library:'..tostring(p)p.resolved=c.resolve(p.
settings)return p end function n:stop()if self.bound then i:
UnbindFromRenderStep(self.bindingName)self.bound=false end for o,p in self.
entities.items do l(p)end end function n:start()if self.bound or not self.
settings.enabled or not self.entities.started then return end i:
BindToRenderStep(self.bindingName,self.settings.renderPriority,function()local o
,p=pcall(self.render,self)if not o then self:stop()self.settings.enabled=false
warn('ESP paused after a rendering error: '..tostring(p))end end)self.bound=true
end function n:render()local o,p=j.CurrentCamera,self.settings.selection for q,r
in self.entities.items do local s=m(q)local t,u,v=self.resolved[s and'friendly'
or'enemy'],r.Root,r.Humanoid if not o or not t.enabled or not t.box.enabled or
not u or not u.Parent or not v or not v.Parent or(p=='enemies'and s)or(p==
'teammates'and not s)then l(r)continue end local w=v.Health<=0 if(t.deadPolicy==
'hide'and w)or(t.deadPolicy=='only'and not w)or(o.CFrame.Position-u.Position).
Magnitude>t.maxDistance then l(r)continue end local x,y=e.getBounds(r.parts,u)if
not x or not e.project(o,x,y,r.bounds)then l(r)continue end if not r.components.
box then r.components.box=g.new()end r.components.box:Update(r.bounds,t.box)end
end function n:AddPlayers()assert(not self.destroyed,
'ESP instance has been destroyed')self.entities:Start()self:start()return self
end function n:Set(o)assert(not self.destroyed,'ESP instance has been destroyed'
)local p=c.update(self.settings,o)local q=p.renderPriority~=self.settings.
renderPriority self.settings=p self.resolved=c.resolve(p)if q or not p.enabled
then self:stop()end self:start()return self end function n:SetEnabled(o)return
self:Set{enabled=o}end function n:Destroy()if self.destroyed then return end
self.destroyed=true self:stop()self.entities:Destroy()self.resolved=nil self.
settings=nil end return n