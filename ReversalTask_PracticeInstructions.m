% Behavioral Reversal Learning Task written by Amanda Buch
% Modified from shopping learning task written by Madeleine Sharp, MD
% in the lab of Daphna Shohamy, PhD at Columbia University
% Last Updated December 17, 2015

% MS: crashes at the post-practice instructions immed after putting image 6
% up, can't figure out why

function pr=ReversalTask_PracticeInstructions(rewCat, day)

% %% only for trouble shooting. 
% dir='../Subjects/'; % enter subject directory here
% 
% KbName('UnifyKeyNames');
% rand('state',sum(100*clock));
% okResp=KbName('space'); 
% 
% p.SubjectNumber=input('Input Subject Number (e.g. 1, or 12 -- no leading zeros necessary):  ' );
% p.day=input('Which day (1 or 2)?: '); %1st half list for 1st day; 2nd half list for 2nd day
%     day=p.day;
% 
% folder_name=(sprintf('Subjects/Subject%d/day%d',p.SubjectNumber,p.day));
% if ~exist(folder_name, 'dir')
%     mkdir (sprintf('%s',folder_name))
% else
%     disp(['Error directory exists for subject ' num2str(p.SubjectNumber) ' for day ' num2str(p.day)])
%     return
% end
% 
% p.practice=input('Are you doing the Practice?: (1=yes, 2=no) ');
% p.acquisition=input('Are you doing the Acquisition?: (1=yes, 2=no) ');
% p.versionRewardCat=input('Which stim set (1 or 2)?: '); %1=scenes 1st rewarded, 2=objects first rewarded
%     rewCat=p.versionRewardCat;
% p.scanned=input('Is this an fMRI experiment (1 or 2)?: (1=yes, 2=no)');
% 
% if p.versionRewardCat~= 1 && p.versionRewardCat~=2
%     Screen('CloseAll');
%     ShowCursor; 
%     disp('Invalid input!')
%     return
% end
% save (sprintf('%s/inputP',folder_name), 'p')
% %%

KbName('UnifyKeyNames');
rand('state',sum(100*clock));
okResp=KbName('space');
Screen('Preference','SkipSyncTests',1)

try
    [window, windrect] = Screen('OpenWindow', 0); % get screen
    AssertOpenGL; % check for opengl compatability
    Screen('BlendFunction', window, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);  %enables alpha bending
    black = BlackIndex(window);  % Retrieves the CLUT color code for black.
    white=WhiteIndex(window);
    Screen('FillRect', window, white ); % Colors the entire window black.
    priorityLevel=MaxPriority(window);  % set priority - also set after Screen init
    Priority(priorityLevel);
    [KeyIsDown, time, KeyCode]=KbCheck;% initialize ksey
    Screen('TextSize', window, 30); %set test size
    Screen('TextColor', window, black);
    [cx,cy]=RectCenter(windrect); %center point of screen
    [xPoints, yPoints]=RectSize(windrect);

    instructions='instructionsPD/inst/';

    %read in images
    for i=1:8 %#of instruction files in the folder
        [o,map,alpha] = imread([instructions num2str(i) '.jpg'], 'jpg');
        imgRect{i}=RectOfMatrix(o); %gets rects of ImagesArrays
        imgCell{i}=cat(3,o,alpha); %combines RBG matrix and alpha (transperency)
        imgTexCell{i}=Screen('MakeTexture', window, imgCell{i});
    end    

    %%%%%%%%% done reading images - prepare Display%%%%%%%%%%%%%%%%%%%%%%%

    %%% Pre-practice instructions
    
    for i=1:5 % these are the instructions that appear before the practice
        Screen('DrawTexture', window, imgTexCell{i});
        [VBLTimestamp startChoice]=Screen('Flip', window);
        [keyIsDown,TimeStamp,keyCode] = KbCheck;
        
        WaitSecs(.5);
        while(1)
            [keyIsDown,TimeStamp,keyCode] = KbCheck;
            
            if keyCode(okResp)
                
                break; %so move on to next screeen as soon as spacebar is pressed
            end
        end
    end
    
    %%% Practice -- calls other script
    % MS: give argument TRUE so that the screen does not close at the end of the
    % Practice script
    pr=ReversalTask_Practice(rewCat, day, true);
disp('finished practice');
    %%% Post-practice instruction

    %MS: 
    %needed to re-open screen even when I remove the screen close form
    %the end of the practice script
    %(when I tried simply removing the screen close, the post-practice
    %instructions were not displayed; instead there was a white non-reponsive screen for a while and then a flicker of the 3rd image
    
    %MS: thi snow mostly works but after the 3rd post practice image get a
    %flicker of image #5??!!
    [window, windrect] = Screen('OpenWindow', 0); % get screen    
    
    for i=6:8
disp('post-prac instr 1');

        Screen('DrawTexture', window, imgTexCell{i});
        [VBLTimestamp startChoice]=Screen('Flip', window);
        [keyIsDown,TimeStamp,keyCode] = KbCheck;
disp('post-prac instr 2');       
        WaitSecs(.5);
        while(1)
            [keyIsDown,TimeStamp,keyCode] = KbCheck;
            
            if keyCode(okResp)
                
                break;
            end
        end
disp('post-prac instr 3');    
    end
        
    Screen('CloseAll'); % close Screen, even if using the wrapper, because will re-open it at the beginning of each function; this flushes it, better for memory
%     ShowCursor;
%     fclose('all');
%     Priority(0);

   
    
catch% catch error
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    psychrethrow(psychlasterror);

end
end
