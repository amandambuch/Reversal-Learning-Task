%%%%%%%%%%%%%%%%%
% Behavioral Reversal Learning Task written by Amanda Buch
% Modified from shopping learning task written by Madeleine Sharp, MD
% in the lab of Daphna Shohamy, PhD at Columbia University
% Last Updated December 17, 2015

%MS: commented out the scanner-relevant bit because can't find getexternals
%or equivalent function

function ReversalTask_MAIN
% main file that runs sections of task and takes initial input
direc='../Subjects/'; % enter subject directory here

KbName('UnifyKeyNames');
rand('state',sum(100*clock));
okResp=KbName('space'); 

p.SubjectNumber=input('Input Subject Number (e.g. 1, or 12 -- no leading zeros necessary):  ' );
p.day=input('Which day (1 or 2)?: '); %1st half list for 1st day; 2nd half list for 2nd day

folder_name=(sprintf('Subjects/Subject%d/day%d',p.SubjectNumber,p.day));
if ~exist(folder_name, 'dir')
    mkdir (sprintf('%s',folder_name))
else
    disp(['Error directory exists for subject ' num2str(p.SubjectNumber) ' for day ' num2str(p.day)])
    return
end

p.practice=input('Are you doing the Practice?: (1=yes, 2=no) ');
p.acquisition=input('Are you doing the Acquisition?: (1=yes, 2=no) ');
p.versionRewardCat=input('Which stim set (1 or 2)?: '); %1=scenes 1st rewarded, 2=objects first rewarded
p.scanned=input('Is this an fMRI experiment (1=yes, 2=no)?:  ');

if p.versionRewardCat~= 1 && p.versionRewardCat~=2
    Screen('CloseAll');
    ShowCursor; 
    disp('Invalid input!')
    return
end
save (sprintf('%s/inputP',folder_name), 'p')

if p.practice==1
    pr=ReversalTask_PracticeInstructions(p.versionRewardCat, p.day);
%     clearvars -except 'SubjectNumber' 'okResp' 'practice' 'acquisition' 'performance' ...
%     'memory' 'stimSet' 'listNum' 'versionRewardCat'
    %pr = ReversalTask_Practice(p.versionRewardCat,p.day);
    save(sprintf('%s/practicePR',folder_name),'pr')
end


[trigger,kb,buttonBox]=getExternals; 

if p.scanned==2;
    kb=1; 
    trigger=kb;
     buttonBox=kb;
elseif p.scanned==1
     error=0;
     if trigger==0
         err=MException('AcctError:Incomplete', 'trigger box not detected');
         error=1;
     end
     if kb==0
         err=MException('AcctError:Incomplete', 'internal key board not detected');
         error=1;
     end
     if buttonBox==0
         err=MException('AcctError:Incomplete', 'Button Box not detected');
         error=1;
     end
     
     if error
         throw(err)
     end
 end

if p.acquisition ==1
     ReversalTask_Instructions(p.versionRewardCat,p.scanned);
     %PD_Aquisition(SubjectNumber, stimSet, versionRewardCat,folder_name,scanned);
%     clearvars -except 'SubjectNumber' 'okResp' 'practice' 'acquisition' 'performance' ...
%         'memory' 'stimSet' 'listNum' 'versionRewardCat'
     prob=.8; % move variable to top
     blockLength=50;
     nTrials=150; %total number of trials for 1 day
     aq = ReversalTask_Aquisition(p.versionRewardCat,p.day,p.scanned,folder_name, p.SubjectNumber,prob,blockLength,nTrials,trigger,buttonBox);

% end
save(sprintf('%s/aquisitionAQfin',folder_name),'aq')
    
end
