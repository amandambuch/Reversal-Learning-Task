function [buttonPress,pressTime] = KbQ_Func(device,allowKeys,endTime)

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
    [keyIsDown, firstPress]=KbQueueCheck();
end
  
keyInd=find(firstPress>0);
if sum(firstPress>0)>1 %if two keys pressed at once, take first
    keyInd=keyInd(1);  
end

buttonPress=KbName(keyInd);
pressTime=firstPress(keyInd);

KbQueueRelease()  % clear KbQueue
end
      