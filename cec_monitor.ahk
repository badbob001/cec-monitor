#persistent
#singleInstance force
logfile:="C:\Program Files (x86)\Pulse-Eight\USB-CEC Adapter\cec_monitor.log"
tvon:="C:\Program Files (x86)\Pulse-Eight\USB-CEC Adapter\tv_on.cmd"
tvoff:="C:\Program Files (x86)\Pulse-Eight\USB-CEC Adapter\tv_off.cmd"
ceclocation:="C:\Program Files (x86)\Pulse-Eight\USB-CEC Adapter"

GUID_MONITOR_POWER_ON:="02731015-4510-4526-99e6-e5a17ebd1aea"
GUID_CONSOLE_DISPLAY_STATE:="6fe69556-704a-47a0-8f24-c28d936fda47"
global monitorStatus:=1
global newGUID:=""

varSetCapacity(newGUID,16,0)
if a_OSVersion in WIN_8,WIN_8.1,WIN_10
	dllCall("Rpcrt4\UuidFromString","Str",GUID_CONSOLE_DISPLAY_STATE,"UInt",&newGUID)
else
	dllCall("Rpcrt4\UuidFromString","Str",GUID_MONITOR_POWER_ON,"UInt",&newGUID)
rhandle:=dllCall("RegisterPowerSettingNotification","UInt",a_scriptHwnd,"Str",strGet(&newGUID),"Int",0)
onMessage(0x218,"WM_POWERBROADCAST")
setTimer,checkMonitor,500
return

checkMonitor:
while(!monitorStatus){
	if(a_index=1) {
		FileAppend,% "OFF " . A_Now . "monitorStatus:[" . monitorStatus . "]; a_timeidlephysical:[" . A_TimeIdlePhysical . "]`n", %logfile%
		if (A_TimeIdlePhysical >= 5000) {
			Run, %tvoff%, %ceclocation%, min
		}
	}
	sleep 500
}
while(monitorStatus){
	if(a_index=1) {
		FileAppend,% "ON  " . A_Now . "monitorStatus:[" . monitorStatus . "]; a_timeidlephysical:[" . A_TimeIdlePhysical . "]`n", %logfile%
		Run, %tvon%, %ceclocation%, min
	}
    	sleep 500
}
return


WM_POWERBROADCAST(wParam,lParam){
	static PBT_POWERSETTINGCHANGE:=0x8013
	if(wParam=PBT_POWERSETTINGCHANGE){
		if(subStr(strGet(lParam),1,strLen(strGet(lParam))-1)=strGet(&newGUID)){
			monitorStatus:=numGet(lParam+0,20,"UInt")?1:0			
		}
	}
	return
}