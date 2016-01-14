% Behavioral Reversal Learning Task written by Amanda Buch
% Modified from shopping learning task written by Madeleine Sharp, MD
% in the lab of Daphna Shohamy, PhD at Columbia University
% Last Updated December 17, 2015
function ReversalTask_Instructions(rewCat,scanned)

KbName('UnifyKeyNames');
rand('state',sum(100*clock));

if scanned==2
    okResp=KbName('space');
else
    okResp=KbName('1!');
end

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
    for i=1:8
        [o,map,alpha] = imread([instructions num2str(i) '.jpg'], 'jpg');
        imgRect{i}=RectOfMatrix(o); %gets rects of ImagesArrays
        imgCell{i}=cat(3,o,alpha); %combines RBG matrix and alpha (transperency)
        imgTexCell{i}=Screen('MakeTexture', window, imgCell{i});
disp('read all in instructions-main');
    end    

    %%%%%%%%% done reading images - prepare Display%%%%%%%%%%%%%%%%%%%%%%%

    %%% Display instructions
    
    for i=1:numel(imgTexCell) % these are the final instructions before the real game
        Screen('DrawTexture', window, imgTexCell{i});
        [VBLTimestamp startChoice]=Screen('Flip', window);
        [keyIsDown,TimeStamp,keyCode] = KbCheck;
disp('instructions-main display loop');        
        WaitSecs(.5);
        while(1)
            [keyIsDown,TimeStamp,keyCode] = KbCheck;
            
            if keyCode(okResp)
                
                break; %so move on to next screeen as soon as spacebar is pressed
            end
        end
disp('instructions-main display loop-post taking specebar press');
    end
    
    Screen('CloseAll');

catch% catch error
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    psychrethrow(psychlasterror);

end
