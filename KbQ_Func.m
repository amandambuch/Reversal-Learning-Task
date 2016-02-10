function [keyIsDown,RT_Response,keyCode] = KbQ_Func(device,allowKeys,endTime)

% allowKeys is a vector of allowable input - set to 0 if all keys are
% allowed
% set endTime to 0 if responses are untimed 

if allowKeys==0
    allowKeyCodes=ones(1,256);
else
    allowKeyCodes=zeros(1,256);    
    allowKeyCodes(allowKeys)=1;
end

if endTime==0
    endTime=GetSecs+99999999999;
end


% KbQueue set up


KbQueueCreate(device,allowKeyCodes);KbQueueStart();
keyIsDown=0;
while keyIsDown==0 && GetSecs<endTime
	%first press contains key identity and RT
    [keyIsDown, firstPress]=KbQueueCheck();
end
 
%indices of firstPress refer to key code
keyInd=find(firstPress>0);
if sum(firstPress>0)>1 %if two keys pressed at once, take first
    keyInd=keyInd(1);  
end

keyCode=KbName(keyInd);

%values in firstPress refer to reaction times for each key
RT_Response=firstPress(keyInd);


KbQueueRelease()  % clear KbQueue
end
      