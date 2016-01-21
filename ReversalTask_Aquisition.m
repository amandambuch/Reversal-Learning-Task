% Behavioral Reversal Learning Task written by Amanda Buch
% Modified from shopping learning task written by Madeleine Sharp, MD
% in the lab of Daphna Shohamy, PhD at Columbia University
% Last Updated December 17, 2015

%MS changes (all changes labelled with MS in the script as well): 
%made all nTrials/2 into just nTrials -- i might be missing some strategy
%added strucure prefix to a bunch of variables eg. trialsS-->aq.trialsS
%changed scaned to 0/1 var
%added aq.optimal variable
%added a output matrix to save variables of interest in this format (easier
%for me for later)
%also saving out the space. just in case, useful especially in the
%beginning
%deleted save crashwork-maybe only causing me problems because not running as function

function aq=ReversalTask_Aquisition(rewCat, day, scanned, folder_name, SubjectNumber,prob,blockLength)
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
%     SubjectNumber=p.SubjectNumber;
% p.day=input('Which day (1 or 2)?: '); %1st half list for 1st day; 2nd half list for 2nd day
%     day=p.day; %MS since not running out of wrapper
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
%     scanned=p.scanned;
% 
% 
% save (sprintf('%s/inputP',folder_name), 'p')
%%

% aq is the structure that contains all the matrices to be saved
% disp('line here') are tempory for troubleshooting purposes

%% Setting up the environment
    rand('state',sum(100*clock));  % reset the state of rand to a random value

%MS: changed scanned to 1/2 coding

    
    % Key Responses    
    KbName('UnifyKeyNames');
    escapeKey=KbName('q');
    if scanned==2
        leftResp=KbName('j');
        rightResp=KbName('k');
        okResp=KbName('space');
    else
        leftResp=KbName('2@');
        rightResp=KbName('3#');
        okResp=KbName('1!');
        ttl=KbName('t');
    end
   
%% Start psychtoolbox, open the screen, and set initial infromation

try
    
    [window, windrect] = Screen('OpenWindow', 0); % get screen
    AssertOpenGL; % check for opengl compatability
    Screen('BlendFunction', window, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);  %enables alpha blending for online image processing
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
    disp(['Center is ',num2str(cx), ' ',num2str(cy), ' and winsize is ', num2str(xPoints), num2str(yPoints)])
    %pause
    
    %% Locate and Choose the Stimuli
    rnd=NaN;
    scenesDir='StimuliPD/Aquisition/300Scenes/';
    %scenesDir='StimuliPD/Aquisition/800Scenes/'; %directory of 1st category
    scenes=dir([scenesDir, '*.jpg']);
    objectsDir='StimuliPD/Aquisition/300Objects/';
    %objectsDir='StimuliPD/Aquisition/800Objects/';  %directory of 2nd category
    objects=dir([objectsDir, '*.jpg']);
   
    % MS: decide whether to split stimuli in half before or after
    % randomizing--will need to save out the list order for each subject so
    % that can be loaded on Day2
    
    % MS: what is rnd?
    
    % stimuli list; may need to save random stimuli order for each subject
    if day==1 && rnd~=1 % list 1 for day 1, takes 1st half of stimuli
        scenes=scenes(1:(floor(numel(scenes)/2)));
        objects=objects(1:(floor(numel(objects)/2)));
        rnd=1;
    elseif day==2 && rnd~=1 % list 2 for day 2, takes 2nd half of stimuli
        scenes=scenes((round(numel(scenes)/2))):round(numel(scenes));
        objects=objects((round(numel(objects)/2))):round(numel(objects));
        rnd=1;
    end
    
    nTrials=uint16(numel(scenes)); %*2); MS: trials=#scenes since both scene and object shown simult % length(trials) numel(scenes)
    aq.scenes=cell(numel(scenes),1);
    aq.objects=aq.scenes;
    img=cell(numel(scenes),2); % the stimuli converted to a screen texture for presentation later in script
    for i=1:numel(scenes); % now size of objects and scenes arrays are both 1/2 the size
        [o,~,alpha]=imread([scenesDir scenes(i).name], 'jpg');
        StimCell=cat(3,o,alpha);
        img{i,1}=Screen('MakeTexture',window, StimCell);
        aq.scenes(i)=cellstr(scenes(i).name);        
        [o,~,alpha]=imread([objectsDir objects(i).name], 'jpg');
        StimRect=RectOfMatrix(o);
        StimCell=cat(3,o,alpha);
        img{i,2}=Screen('MakeTexture',window, StimCell);
        aq.objects(i)=cellstr(objects(i).name);
        DrawFormattedText(window, ['Reading image #', num2str(i)], 'center','center', [0 0 0]); % temporary for coding purposes
        Screen('Flip', window);
    end  
    % will likely modify for stimuli to be added each block
    
    disp('line 67')
    % these can be modified depending on the size the stimuli should be
    % when presented on screen 
    StimRect=StimRect*(yPoints/6*2)./StimRect(3); %makes the StimRect a fraction of the size of the screen window, keeping same proportions
    
    StimX1=cx-(RectWidth(StimRect)/2)-((yPoints/2.5)-RectWidth(StimRect))/2;
    StimX2=cx+(RectWidth(StimRect)/2)+((yPoints/2.5)-RectWidth(StimRect))/2;
    
    StimBox1=CenterRectOnPoint(StimRect,StimX1,cy);
    StimBox2=CenterRectOnPoint(StimRect,StimX2,cy);
    StimBox1Frame=CenterRectOnPoint(StimRect*1.2,StimX1,cy);
    StimBox2Frame=CenterRectOnPoint(StimRect*1.2,StimX2,cy);

    StimBox=CenterRectOnPoint([0 0 xPoints/4 xPoints/4],cx,cy);  % to squeeze the image to square, which is 1/4 of screen x-dim
    StimBoxFrame=CenterRectOnPoint([0 0 xPoints/4 xPoints/4]*1.2,cx,cy);
    DrawFormattedText(window, ['Images prepared.'], 'center','center', [0 0 0]);
    Screen('Flip', window);

%% Set Information for Trial Design 
%(instantiates variables)
    aq.rewProb=zeros(1,nTrials);
    aq.prob=.8;
    x=aq.prob*nTrials;
    aq.rewProb(1:x)=1;
    aq.rewProb=aq.rewProb(randperm(numel(aq.rewProb)));
disp(['# trials is ' num2str(nTrials) 'on line 107']);
    aq.trialsS=randperm(nTrials); %MS: /2); %creates random order for scenes
    aq.trialsO=randperm(nTrials); %MS: /2); %a separate random list for objects
    aq.SorR=ones(1,nTrials); %which category will appear on the left
    x=nTrials/2;
    aq.SorR(1:x)=2;
    aq.SorR=aq.SorR(randperm(numel(aq.SorR))); % Stimuli for stimBox1 on Left (1=scene, 2=object)
    aq.chosenSide=NaN(1,nTrials);
    aq.chosenStim=aq.chosenSide;
    aq.rt=aq.chosenSide;
    aq.reversalAt=randi([10 15],1,1); % sets reversal at random value between 80 and 100, want to avoid block transition
    %aq.reversalAt=10;
    b=0;
    aq.blockLength=30; %MS: 40;
    aq.breaks=NaN(1,nTrials/aq.blockLength-1);
    aq.breaksLength=aq.breaks;
    aq.reward=aq.breaks;

   %%  Write Instructions and check for escape key
    DrawFormattedText(window,['Which category is more likely to be correct? \n\n Use the ''j'' key for Left \n use the ''k'' key for Right \n\n\n Press SPACE BAR to start'], 'center','center', [0 0 0]);
    Screen('Flip', window); % show text
    while(1)
        [keyIsDown,TimeStamp,keyCode] = KbCheck;
        if keyCode(okResp) %%allows examiner to press the space bar to pause the task if there is a problem, without terminating
            break;
        end
    end

escape=0;
 while escape==0
    if escape==1;
        break % also provides an escape mechanism to stop the task
    end
    
    %%
    startTime=datestr(now);
    ExpStart=GetSecs;
        
    %% Start of Trial Aquisition %%
    reversal=0;
    for t=1:nTrials %MS: i'm probably missing something but I changed all the nTrials/2 to nTrials...
        if t>aq.reversalAt && reversal==0 % when trial number is greater than reversal point and reversal has not occured yet
            reversal=reversal+1;
            rewCat=abs(3-rewCat);
            disp(['reversing now for ', num2str(aq.reversalAt), ' and trial # ', num2str(t) ' out of ' num2str(nTrials/2) ...
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
        
        if aq.SorR(t) == 1 % Place scene in stimBox1 on Left
            trials1=aq.trialsS(t); %MS: added aq.
            trials2=aq.trialsO(t);
        elseif aq.SorR(t) == 2 % Place object in stimBox1 on Left
            trials1=aq.trialsO(t);
            trials2=aq.trialsS(t);
        end
        %%%% SHOW STIMULI %%%%
        disp(['t is ' num2str(t) 'and trials1 is ' num2str(trials1) ' and SorR is' num2str(aq.SorR(t)) ' and size of img' num2str(size(img))])
        
        Screen('DrawTexture', window, img{trials1,aq.SorR(t)}, [], StimBox1); % render stimuli image in StimBox1 (L); img{i,j} category chosen by SorR and image in list by j
        Screen('FrameRect',window, black, StimBox1, 4);
        Screen('DrawTexture', window, img{trials2,abs(aq.SorR(t)-3)}, [], StimBox2);
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
         disp('line 198')

        aq.rt(t)=(1000*(RT_Response-startChoice(t)));% compute response time in milliseconds

        resp=KbName(keyCode); %find name of key that was pressed
        if iscell(resp) %checking if 2 keys were pressed and keeping 2nd
            resp=resp{2};
        end
        if length(resp)>1
            resp=NaN;
        end
        if isempty(resp)
            resp=NaN;
            aq.rt(t)=NaN;
        end
        aq.keyPressed(t)=resp;

        % Add Yellow Frame to Chosen Stimuli
        Screen('DrawTexture', window, img{trials1,aq.SorR(t)}, [], StimBox1);
        Screen('FrameRect',window, black, StimBox1, 4);
        Screen('DrawTexture', window, img{trials2,abs(aq.SorR(t)-3)}, [], StimBox2);
        Screen('FrameRect',window, black, StimBox2, 4);  

        if isequal(resp,'j')
            aq.chosenSide(t)=1; % i.e. Left
            aq.chosenStim(t)=img{trials1,aq.SorR(t)}; 
            Screen('FrameRect',window, [255 255 0], StimBox1Frame, 6);
            Screen('Flip', window); % show response
            WaitSecs(.5); %so show the feedback for 0.5sec
            resp=1;
        elseif isequal(resp,'k')
            aq.chosenSide(t)=2; % i.e. Right
            aq.chosenStim(t)=img{trials2,abs(aq.SorR(t)-3)};
            Screen('FrameRect',window, [255 255 0], StimBox2Frame, 6);
            Screen('Flip', window); % show response
            WaitSecs(.5);
            resp=2;
        else
            aq.chosenSide(t)=NaN;
            aq.chosenStim(t)=NaN;    
            resp=NaN; %there is no waitsecs here so that if no resp was recorded, go straight to next piece of code 
        end

        %% Show Feedback Based on Choice
        % when chosen category = rewarded category, rewarded most of the
        % time (rewProb = 1)
        % when chosen category ~= rewarded category, rewarded some of the
        % time (rewProb = 0)
        if isnan(resp) % Does not respond in time?
            [nx, ny,TB]=DrawFormattedText(window,' Too Slow! ', 'center','center', [0 0 0]);
            Screen('FillRect', window, white, [TB(1)+2 TB(2)+3 TB(3)+2 TB(4)+3]);
            DrawFormattedText(window,' Too Slow! ', 'center','center', [0 0 0]);
            [VBLTimestamp startFB(t)]=Screen('Flip', window);
            aq.reward(t)=NaN;
            aq.optimal(t)=NaN;
            WaitSecs(2);
        elseif aq.rewProb(t)==1
            if (resp==1 && aq.SorR(t)==rewCat) || (resp==2 && abs(3-aq.SorR(t))==rewCat)
%                 if resp==1
%                     Screen('DrawTexture', window, img{trials1,rewCat}, [], StimBox); %%%% 
%                 elseif resp==2
%                     Screen('DrawTexture', window, img{trials2,rewCat}, [], StimBox); %%%% 
%                 end
%                 Screen('FrameRect',window, [0 255 0], StimBoxFrame, 6); %make frame green
                Screen('TextSize',window, [50]);
                Screen('TextStyle',window,[2]);
                DrawFormattedText(window,'You won!!', 'center','center', [0 255 0]);
                %DrawFormattedText(window,'You won!!', 'center',cy-400, [0 255 0]);
                [VBLTimestamp startFB2(t)]=Screen('Flip', window);
                aq.reward(t)=1;
                aq.optimal(t)=1;
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
                aq.reward(t)=0;
                aq.optimal(t)=0;
                WaitSecs(1);
            end
        elseif aq.rewProb(t)==0
           if (resp==1 && aq.SorR(t)==rewCat) || (resp==2 &&  abs(3-aq.SorR(t))==rewCat)
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
                aq.reward(t)=0;
                aq.optimal(t)=1;
                WaitSecs(1);
           elseif (resp==1 && aq.SorR(t)~=rewCat) || (resp==2 &&  abs(3-aq.SorR(t))~=rewCat)
%                 if resp==1
%                     Screen('DrawTexture', window, img{trials1,abs(3-rewCat)}, [], StimBox); %%%% 
%                 elseif resp==2
%                     Screen('DrawTexture', window, img{trials2,abs(3-rewCat)}, [], StimBox); %%%% 
%                 end
%                 Screen('FrameRect',window, [0 255 0], StimBoxFrame, 6); %make frame green
                Screen('TextSize',window, [50]);
                Screen('TextStyle',window,[2]);
                DrawFormattedText(window,'You won!!', 'center','center', [0 255 0]);
                %DrawFormattedText(window,'You won!!', 'center',cy-400, [0 255 0]);
                [VBLTimestamp startFB2(t)]=Screen('Flip', window);
                aq.reward(t)=1;
                aq.optimal(t)=0;
                WaitSecs(1);
           end
        end    
        [VBLTimestamp FBOffTime(t)]=Screen('Flip', window);    % remove feedback               
    
        
    %% MS: create an output matrix
    
        outputmat(t,1)=SubjectNumber;
        outputmat(t,2)=t;
        outputmat(t,3)=day;
        outputmat(t,4)=trials1;
        outputmat(t,5)=trials2;
        outputmat(t,6)=aq.SorR(t); %this is image category on Left?
        outputmat(t,7)=rewCat;
        outputmat(t,8)=resp; %1=left, 2=right
        outputmat(t,9)=aq.rewProb(t);
        outputmat(t,10)=aq.reward(t); %feedback they were acually given
        outputmat(t,11)=aq.optimal(t);
        %MS: i want to also save the number of the images shown on each
        %trial. Not sure which variable best for this. The img variable
        %does not seem to be saving the correct number as the numbers don't
        %match anything else that I can find
    
    
    
    %%
        
    %% Save frequently and set blocks
            if mod(t,10)==1
                save(sprintf('%s/aquisitionAQ',folder_name),'aq');
                save(sprintf('%s/AQmat',folder_name),'outputmat');
            end
            % below is where we could move the image loading to
            if mod(t,aq.blockLength)==0 && t<nTrials %MS changed block length to 6 for testing
                b=b+1;
                aq.breaks(b)=GetSecs;
                Screen('TextSize',window, [30]);
                Screen('TextStyle',window,[2]);
                DrawFormattedText(window,'Please take a break for as long as you need. \n\n Press the SPACE BAR when you are ready to start again.', 'center','center', [0 0 0]);
                Screen('Flip', window)             
                while(1)
                    [keyIsDown,TimeStamp,keyCode] = KbCheck;
                    if keyCode(okResp) %end the break when spacebar is pressed
                        break;
                    end
                end
                aq.breaksLength(b)=GetSecs-aq.breaks(b);
            end
            
    end % end trial loop
        save(sprintf('%s/aquisitionAQ',folder_name),'aq')
        save(sprintf('%s/AQmat',folder_name),'outputmat');
        save(sprintf('%s/space',folder_name))
        escape=1;
 end
 
    aq.totalPoints=nansum(aq.reward)*10;
    DrawFormattedText(window,['You are finished! \n\n You won ' num2str(aq.totalPoints,'%1.0f') ' points \n\n Please inform the experimenter.'], 'center','center', [0 0 0]);    
    Screen('Flip', window);    
    WaitSecs(5);   
    while(1)
        [~,~,keyCode] = KbCheck;
        if keyCode(okResp)
            break;
        end
    end
    Screen('CloseAll');
    escape=1;          %#ok<NASGU> % Exit after last trial
catch
    Screen('CloseAll');
    %save(sprintf('%s/crashwork',folder_name),'crashWork'); %this saves the workspace (minus those cells) in event of a crash, for debugging
    ShowCursor;
    fclose('all');
    Priority(0);
    psychrethrow(psychlasterror);
 end %end the while loop
end    
