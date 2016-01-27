% Behavioral Reversal Learning Task written by Amanda Buch
% Modified from shopping learning task written by Madeleine Sharp, MD
% in the lab of Daphna Shohamy, PhD at Columbia University
% Last Updated December 17, 2015

%MS changes made/questions (and see below): 
%1) nTrials/2 --> nTrials; 2)
%2)multiple reversals?
%3) added a variable coding for optimal choice (pr.optimal)....may be
%redundant...

function pr = ReversalTask_Practice(rewCat,day,noscreenclose)
Screen('Preference','SkipSyncTests',1); % change this to 0 when actually running, skips sync tests for troubleshooting purposes

% %% just for troubleshooting purposes, not running as function so I can see the variables in workspace
% 
% direc='../Subjects/'; % enter subject directory here
% 
% KbName('UnifyKeyNames');
% rand('state',sum(100*clock));
% okResp=KbName('space'); 
% 
% p.SubjectNumber=input('Input Subject Number (e.g. 1, or 12 -- no leading zeros necessary):  ' );
% p.day=input('Which day (1 or 2)?: '); %1st half list for 1st day; 2nd half list for 2nd day
% 
% p.practice=input('Are you doing the Practice?: (1=yes, 2=no) ');
% p.acquisition=input('Are you doing the Acquisition?: (1=yes, 2=no) ');
% p.versionRewardCat=input('Which stim set (1 or 2)?: '); %1=scenes 1st rewarded, 2=objects first rewarded
%     rewCat=p.versionRewardCat;
% p.                                                                                                                                                                                                                                                                                                                                                                            =input('Is this an fMRI experiment (1 or 2)?: (1=yes, 2=no)');
% 
% %%

%%% PRACTICE %%%

%% Setting up the environment
    % reset the state of rand to a random value
    rand('state',sum(100*clock));

    % Key Responses    
    KbName('UnifyKeyNames');
    escapeKey=KbName('q');
    leftResp=KbName('j');
    rightResp=KbName('k');
    okResp=KbName('space');

   % global pr % set the global variable for saving information

%% Start psychtoolbox, open the screen, and set initial infromation

    [window, windrect] = Screen('OpenWindow', 0); % get screen
    AssertOpenGL; % check for opengl compatability
    Screen('BlendFunction', window, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);  %enables alpha blending for on-line image processing
    HideCursor;
    
    black = BlackIndex(window);  % Retrieves the CLUT color code for black.
    white=WhiteIndex(window);
    Screen('FillRect', window, white ); % Colors the entire window white.
    
    priorityLevel=MaxPriority(window);  % set priority
    Priority(priorityLevel);
    
    Screen('TextSize', window, 36); %set text size
    Screen('TextColor', window, black);
    
    [cx,cy]=RectCenter(windrect); %center point of screen
    [xPoints, yPoints]=RectSize(windrect);    

%% Locate and Choose the Stimuli
    scenesDir='StimuliPD/Practice/scenes/';
    scenes=dir([scenesDir, '*.jpg']);
    objectsDir='StimuliPD/Practice/objects/';
    objects=dir([objectsDir, '*.jpg']); 

    if day==1 % list 1
        scenes=scenes(1:round(numel(scenes)/2));
        objects=objects(1:round(numel(objects)/2));
    else
        scenes=scenes((round(numel(scenes)/2)+1):numel(scenes));
        objects=objects((round(numel(objects)/2)+1):numel(objects));
    end
    
    nTrials=uint16(numel(scenes)) %+numel(objects)); % length(trials) numel(scenes)

    img=cell(numel(scenes),2);
    for i=1:numel(scenes); % now size of objects and scenes arrays are both 1/2 the size
        [o,~,alpha]=imread([scenesDir scenes(i).name], 'jpg');
        StimCell=cat(3,o,alpha);
        img{i,1}=Screen('MakeTexture',window, StimCell);
    end
    %cut this loop in half because there are different number of scenes and obj
    % though need to have same numbers otherwise the img{} is uneven
        
    for i=1:numel(objects);
        [o,~,alpha]=imread([objectsDir objects(i).name], 'jpg');
        StimRect=RectOfMatrix(o);
        StimCell=cat(3,o,alpha);
        img{i,2}=Screen('MakeTexture',window, StimCell);
        %imageNum=sscanf(mem(pic_count).name, '%d'); %this is to extract the actual number of the image file so that I can use that to store it in MemTexCell        
    end
    
    % change below for correct dimensions
    StimRect=StimRect*(yPoints/6*2)./StimRect(3); %makes the StimRect a fraction of the size of the screen window, keeping same proportions
    
    StimX1=cx-(RectWidth(StimRect)/2)-((yPoints/2.5)-RectWidth(StimRect))/2;
    StimX2=cx+(RectWidth(StimRect)/2)+((yPoints/2.5)-RectWidth(StimRect))/2;
    
    StimBox1=CenterRectOnPoint(StimRect,StimX1,cy);
    StimBox2=CenterRectOnPoint(StimRect,StimX2,cy);
    StimBox1Frame=CenterRectOnPoint(StimRect*1.2,StimX1,cy);
    StimBox2Frame=CenterRectOnPoint(StimRect*1.2,StimX2,cy);

    StimBox=CenterRectOnPoint([0 0 xPoints/4 xPoints/4],cx,cy);  % to squeeze the image to square, which is 1/4 of screen x-dim
    StimBoxFrame=CenterRectOnPoint([0 0 xPoints/4 xPoints/4]*1.2,cx,cy);

%% Set Information for Trial Design 
% instantiate variables
    pr.rewProb=zeros(1,nTrials);
    pr.prob=.8;
    x=pr.prob*nTrials;
    pr.rewProb(1:x)=1;
    pr.rewProb=pr.rewProb(randperm(numel(pr.rewProb)));
disp(['# trials is ' num2str(nTrials) 'on line 88']);
%MS: why nTrials/2 --I chaged this for now
    trialsS=randperm(nTrials); %(nTrials/2); %creates random order for scenes
    trialsO=randperm(nTrials); %(nTrials/2); %a separate random list for objects
    pr.SorR=ones(1,nTrials);
    x=nTrials/2;
    pr.SorR(1:x)=2;
    pr.SorR=pr.SorR(randperm(numel(pr.SorR))); % Stimuli for stimBox1 on Left (1=scene, 2=object)
    
    pr.chosenSide=NaN(1,numel(nTrials));
    pr.chosenStim=pr.chosenSide;
    pr.rt=pr.chosenSide;
    pr.reversalAt=6;
%     trials1=NaN(1,nTrials);
%     trials2=trials1;
%%  Write Instructions and check for escape key
disp('line 103')
    DrawFormattedText(window,['Which category is more likely to be correct? \n\n Use the ''j'' key for Left \n use the ''k'' key for Right \n\n\n Press SPACE BAR to start'], 'center','center', [0 0 0]);
    Screen('Flip', window); % show text
    disp('line 105')
    while(1)
        [keyIsDown,TimeStamp,keyCode] = KbCheck;
        if keyCode(okResp) % allows examiner to press the space bar to pause the task if there is a problem, without terminating
            break;
        end
    end

escape=0;
 while escape==0
    if escape==1;
        break % escape mechanism to stop the task
    end

%% Start of Trial Aquisition %%
    reversal = 0;
    for t=1:nTrials %MS: why was this nTrials/2??
        if t>pr.reversalAt && reversal==0 % when trial number is greater than reversal point and reversal has not occured yet
            reversal=reversal+1;
            rewCat=abs(3-rewCat);
            disp(['reversing now for ', num2str(pr.reversalAt), ' and trial # ', num2str(t) ' out of ' num2str(nTrials/2) ...
                ' trials for reversal # ', num2str(reversal)])
        end
        [~, startTrial, KeyCode]=KbCheck;% initialize keys
        Screen('FillRect', window, white); % Color the entire window grey
        Screen('Flip', window);
        
        while (GetSecs-startTrial)<=.5 %checks each loop for held escape key
            if ~(KeyCode(escapeKey))
                [~, ~, KeyCode]=KbCheck;
                WaitSecs(0.001);
            else
                escape=1;
            end
        end
        if escape==1
            break
        end
        
        if pr.SorR(t) == 1 % Scene in stimBox1 on Left
            trials1=trialsS(t);
            trials2=trialsO(t);
        elseif pr.SorR(t) == 2 % Object in stimBox1 on Left
            trials1=trialsO(t);
            trials2=trialsS(t);
        end
        %%%% SHOW STIMULI %%%%
        disp(['t is ' num2str(t) 'and trials1 is ' num2str(trials1) ' and SorR is' num2str(pr.SorR(t)) ' and size of img' num2str(size(img))])
        
        Screen('DrawTexture', window, img{trials1,pr.SorR(t)}, [], StimBox1); % render stimuli image in StimBox1 (L); img{i,j} category chosen by SorR and image in list by j
        Screen('FrameRect',window, black, StimBox1, 4);
        Screen('DrawTexture', window, img{trials2,abs(pr.SorR(t)-3)}, [], StimBox2);
        Screen('FrameRect',window, black, StimBox2, 4);  
        [VBLTimestamp startChoice(t)]=Screen('Flip', window); % displays on screen and starts choice timing
%% Response
       keyDown=1; %assume first that key is down
        while (GetSecs - startChoice(t))<=4 %this is checking that key isn't down and must be the same length as the respnse while loop
            [keyIsDown,RT_Response,keyCode] = KbCheck;
            if isempty(KbName(keyCode))
                keyDown=0;
                break;
            end
            WaitSecs(.001) %do this loop or the first msec to make sure that key isn't held down
        end

        if keyDown==0
            while (GetSecs - startChoice(t))<=4 %max choice time 
                [keyIsDown,RT_Response,keyCode] = KbCheck;
                if keyCode(leftResp)|| keyCode(rightResp) %checks if left or right key was pressed
                    break;
                end
                WaitSecs(.001);
            end                
        else
            keyCode=zeros(size(keyCode));
        end
         
        pr.rt(t)=(1000*(RT_Response-startChoice(t)));% compute response time in milliseconds

        resp=KbName(keyCode); %find name of key that was pressed
        if iscell(resp) %checking if 2 keys were pressed and keeping 2nd
            resp=resp{2};
        end
        if length(resp)>1
            resp=NaN;
        end
        if isempty(resp)
            resp=NaN;
            pr.rt(t)=NaN;
        end
        pr.keyPressed(t)=resp;

        % Add Yellow Frame to Chosen Stimuli
        Screen('DrawTexture', window, img{trials1,pr.SorR(t)}, [], StimBox1);
        Screen('FrameRect',window, black, StimBox1, 4);
        Screen('DrawTexture', window, img{trials2,abs(pr.SorR(t)-3)}, [], StimBox2);
        Screen('FrameRect',window, black, StimBox2, 4);  

        if isequal(resp,'j')
            pr.chosenSide(t)=1; % i.e. Left
            pr.chosenStim(t)=img{trials1,pr.SorR(t)}; 
            Screen('FrameRect',window, [255 255 0], StimBox1Frame, 6);
            Screen('Flip', window); % show response
            WaitSecs(.5); %so show the feedback for 0.5sec
            resp=1;
        elseif isequal(resp,'k')
            pr.chosenSide(t)=2; % i.e. Right
            pr.chosenStim(t)=img{trials2,abs(pr.SorR(t)-3)};
            Screen('FrameRect',window, [255 255 0], StimBox2Frame, 6);
            Screen('Flip', window); % show response
            WaitSecs(.5);
            resp=2;
        else
            pr.chosenSide(t)=NaN;
            pr.chosenStim(t)=NaN;    
            resp=NaN; %there is no waitsecs here so that if no resp was recorded, go straight to next piece of code 
        end
        disp('line 212')
disp(num2str(resp))
disp(num2str(pr.rewProb(t)))
disp('line 215')


%% Show Feedback Based on Choice
        % when chosen category = rewarded category, rewarded most of the
        % time (rewProb = 1)
        % when chosen category ~= rewarded category, rewarded some of the
        % time (rewProb = 0)
        
%%        
%%MS: need to think whether it makes sense to have a single list of
%%semi-prob outcome assignments so that can match people

%%
%MS: i think it's better if we don't show the chosen image at feedback
%%

        if isnan(resp) % Does not respond in time?
            [nx, ny,TB]=DrawFormattedText(window,' Too Slow! ', 'center','center', [0 0 0]);
            Screen('FillRect', window, white, [TB(1)+2 TB(2)+3 TB(3)+2 TB(4)+3]);
            DrawFormattedText(window,' Too Slow! ', 'center','center', [0 0 0]);
            [VBLTimestamp startFB(t)]=Screen('Flip', window);
            pr.reward(t)=NaN;
            WaitSecs(2);
        elseif pr.rewProb(t)==1
            if (resp==1 && pr.SorR(t)==rewCat) || (resp==2 && abs(3-pr.SorR(t))==rewCat)
%                 if resp==1
%                     Screen('DrawTexture', window, img{trials1,rewCat}, [], StimBox); %%%% 
%                 elseif resp==2
%                     Screen('DrawTexture', window, img{trials2,rewCat}, [], StimBox); %%%% 
%                 end
%                 Screen('FrameRect',window, [0 255 0], StimBoxFrame, 6); %make frame green
                Screen('TextSize',window, [50]);
                Screen('TextStyle',window,[2]);
                %DrawFormattedText(window,'You won!!', 'center',cy-400, [0 255 0]);
                DrawFormattedText(window,'You won!!', 'center','center', [0 255 0]);
                [VBLTimestamp startFB2(t)]=Screen('Flip', window);
                pr.reward(t)=1;
                pr.optimal(t)=1; %MS: here feedback is congruent, so won=optimal
                WaitSecs(1);
            else % rewprob = 1 but chosen category ~= rewarded category
%                 if resp==1
%                     Screen('DrawTexture', window, img{trials1,abs(3-rewCat)}, [], StimBox); %%%% 
%                 elseif resp==2
%                     Screen('DrawTexture', window, img{trials2,abs(3-rewCat)}, [], StimBox); %%%% 
%                 end
%                 Screen('FrameRect',window, [255 0 0], StimBoxFrame, 6); %make frame red               
                Screen('TextSize',window, [50]);
                Screen('TextStyle',window,[2]);
                DrawFormattedText(window,'Wrong!!', 'center','center', [255 0 0]);
                %DrawFormattedText(window,'Wrong!!', 'center',cy-400, [255 0 0]);
                [VBLTimestamp startFB2(t)]=Screen('Flip', window);
                pr.reward(t)=0;
                pr.optimal(t)=0;
                WaitSecs(1);
            end
        elseif pr.rewProb(t)==0
           if (resp==1 && pr.SorR(t)==rewCat) || (resp==2 &&  abs(3-pr.SorR(t))==rewCat)
%                if resp==1
%                 Screen('DrawTexture', window, img{trials1,rewCat}, [], StimBox); %%%% 
%                elseif resp==2
%                 Screen('DrawTexture', window, img{trials2,rewCat}, [], StimBox); %%%% 
%                end
%                 Screen('FrameRect',window, [255 0 0], StimBoxFrame, 6); %make frame red               
                Screen('TextSize',window, [50]);
                Screen('TextStyle',window,[2]);
                DrawFormattedText(window,'Wrong!!', 'center','center', [255 0 0]);
                %DrawFormattedText(window,'Wrong!!', 'center',cy-400, [255 0 0]);
                [VBLTimestamp startFB2(t)]=Screen('Flip', window);
                pr.reward(t)=0;
                pr.optimal(t)=1; %MS: here feedback is non-congruent, so won=non-optimal
                WaitSecs(1);
           elseif (resp==1 && pr.SorR(t)~=rewCat) || (resp==2 &&  abs(3-pr.SorR(t))~=rewCat)
%                 if resp==1
%                     Screen('DrawTexture', window, img{trials1,abs(3-rewCat)}, [], StimBox); %%%% 
%                 elseif resp==2
%                     Screen('DrawTexture', window, img{trials2,abs(3-rewCat)}, [], StimBox); %%%% 
%                 end
%                 Screen('FrameRect',window, [0 255 0], StimBoxFrame, 6); %make frame green
                Screen('TextSize',window, [50]);
                Screen('TextStyle',window,[2]);
                DrawFormattedText(window,'you won!!', 'center','center', [0 255 0]);
                %DrawFormattedText(window,'You won!!', 'center',cy-400, [0 255 0]);
                [VBLTimestamp startFB2(t)]=Screen('Flip', window);
                pr.reward(t)=1;
                pr.optimal(t)=0;
                WaitSecs(1);
           end
        end    
        [VBLTimestamp FBOffTime(t)]=Screen('Flip', window);    % remove feedback               
      
    end % end trial loop        
    escape=1;          % Exit after last trial
  end %end the while loop
 %catch
 
 disp('end')
 
%MS: the if statement beow was Jochen's idea to control whether screen closes
%or not.  But in the end I re-open it before the post-practice instructions
%  if nargin < 3 || ~islogical(noscreenclose) || ~noscreenclose % this is to avoid closing the screen so that the practice_instructions can continue to be displayed post practice
%  disp('went into true state')
%      Screen('CloseAll');
%  end

  %rethrow(MException);
end