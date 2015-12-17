% Behavioral Reversal Learning Task written by Amanda Buch
% Modified from shopping learning task written by Madeleine Sharp, MD
% Columbia University
% Last Updated December 17, 2015
function PDReversalTask
% main file that runs sections of task and takes initial input
dir='../Subjects/'; % enter subject directory here

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

if p.versionRewardCat~= 1 && p.versionRewardCat~=2
    Screen('CloseAll');
    ShowCursor; 
    disp('Invalid input!')
    return
end
save (sprintf('%s/inputP',folder_name), 'p')

if practice==1
    PD_Practice_Instructions(p.versionRewardCat);
%     clearvars -except 'SubjectNumber' 'okResp' 'practice' 'acquisition' 'performance' ...
%     'memory' 'stimSet' 'listNum' 'versionRewardCat'
    pr = PD_Practice(p.versionRewardCat,p.day);
end
save(sprintf('%s/practicePR',folder_name),'pr')

if acquisition ==1
     PD_Instructions(versionRewardCat);
     PD_Aquisition(SubjectNumber, stimSet, versionRewardCat,folder_name);
%     clearvars -except 'SubjectNumber' 'okResp' 'practice' 'acquisition' 'performance' ...
%         'memory' 'stimSet' 'listNum' 'versionRewardCat'
     aq = PD_Practice(p.versionRewardCat,p.day);

% end
save(sprintf('%s/aquisitionAQfin',folder_name),'aq')
    
end
