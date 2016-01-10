% Behavioral Reversal Learning Task written by Amanda Buch
% Modified from shopping learning task written by Madeleine Sharp, MD
% in the lab of Daphna Shohamy, PhD at Columbia University
% Last Updated December 17, 2015
function pr=ReversalTask_PracticeInstructions(rewCat, day)

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
    pr=ReversalTask_Practice(rewCat, day);
    
    %%% Post-practice instruction
    
    for i=6:8
        Screen('DrawTexture', window, imgTexCell{i});
        [VBLTimestamp startChoice]=Screen('Flip', window);
        [keyIsDown,TimeStamp,keyCode] = KbCheck;
        
        WaitSecs(.5);
        while(1)
            [keyIsDown,TimeStamp,keyCode] = KbCheck;
            
            if keyCode(okResp)
                
                break;
            end
        end
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