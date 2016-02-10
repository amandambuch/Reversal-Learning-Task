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

function aq=ReversalTask_Aquisition(rewCat, day, scanned, folder_name, SubjectNumber,prob,blockLength, nTrials,trigger,buttonBox)
Screen('Preference','SkipSyncTests',1); % change this to 0 when actually running, skips sync tests for troubleshooting purposes


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
    
    scenesDir='StimuliPD/Aquisition/300Scenes/';
    objectsDir='StimuliPD/Aquisition/300Objects/';
    
    onsetlist=load('testonsets_1.mat'); % NEED TO FIX THIS
    onsetlist=onsetlist.onsetlist;

    maxtime=2.5;
    
if day == 1 %set and save randomized list    
    %% Locate and Choose the Stimuli

    %scenesDir='StimuliPD/Aquisition/800Scenes/'; %directory of 1st category
    scenes=dir([scenesDir, '*.jpg']);
    %objectsDir='StimuliPD/Aquisition/800Objects/';  %directory of 2nd category
    objects=dir([objectsDir, '*.jpg']);
    
    %nTrials=uint16(numel(scenes)); %total trial number for sum of both days based on total number of stimuli from 1 category (since scenes=objects)
    %nTrials now set in main
    %% Probability of Reward
    aq.prob=prob;  %now probability distribution is set in main functino
    aq.rewProb=zeros(1,nTrials); %create zero matrix of numel(nTrials) 
    x=aq.prob*(nTrials); % determine number of rewarded trials based on probability and total trial number
    aq.rewProb(1:x)=1; % change the rewarded trials from 0 to 1
    aq.rewProb=aq.rewProb(randperm(numel(aq.rewProb))); %randomize order of rewarded trials
    %disp(['# trials is ' num2str(nTrials) 'on line 107']);
    
    %% which is on left
    aq.stimOnLeft=ones(1,nTrials); %create matrix of ones to determine which category (1=scene, 2=object) will appear on the left
    x=nTrials/2; 
    aq.stimOnLeft(1:x)=2; %object =1/2 trials
    aq.stimOnLeft=aq.stimOnLeft(randperm(numel(aq.stimOnLeft))); % random ordering for Stimuli presented in stimBox1 on left (1=scene, 2=object)

    %% randomize
    nS=randperm(nTrials*2); %creates random order(permutation of nTrials) for scenes
    aq.trialsS=nS;
    nO=randperm(nTrials*2);  %a separate random list for objects
    aq.trialsO=nO;
    
    %% choose second half to load
    aq.scenesList= scenes(nS);  % apply random order to file name list
    scenesList=aq.scenesList; %had to duplicate because 'save' doesn't accept structure
    tempS=aq.scenesList;
    aq.objectsList= scenes(nO);
    objectsList=aq.objectsList;
    tempO=aq.objectsList;
    
    aq.halfScenesList=scenes(1:(floor(numel(tempS)/2))); % choose only half to be presented per day
    aq.halfObjectsList=objects(1:(floor(numel(tempO)/2)));
    halfScenesList=aq.halfScenesList; %duplicate save for use later
    halfObjectsList=aq.halfObjectsList;
    
    
    save(sprintf('%s/scenesList',folder_name),'scenesList'); % save total randomized directory list to load later
    save(sprintf('%s/objectsList',folder_name),'objectsList');
    %save(sprintf('%s/trialsS',folder_name),'aq.trialsS');    
    %save(sprintf('%s/trialsO',folder_name),'aq.trialsO');    
    
elseif day == 2  % load randomized lists for reward proability, scenes/objects order, and stimuli presented on left order and choose second half
    load(sprintf('%s/scenesList',folder_name)); %loads aq.scenesList
    load(sprintf('%s/objectsList',folder_name)); %loads aq.objectsList
 
    %% Probability of Reward
    aq.prob=prob;  %now probability distribution is set in main functino
    aq.rewProb=zeros(1,nTrials); %create zero matrix of numel(nTrials) 
    x=aq.prob*nTrials; % determine number of rewarded trials based on probability and total trial number
    aq.rewProb(1:x)=1; % change the rewarded trials from 0 to 1
    aq.rewProb=aq.rewProb(randperm(numel(aq.rewProb))); %randomize order of rewarded trials
    %disp(['# trials is ' num2str(nTrials) 'on line 107']);
    
    %% which is on left
    aq.stimOnLeft=ones(1,nTrials); %create matrix of ones to determine which category (1=scene, 2=object) will appear on the left
    x=nTrials/2; 
    aq.stimOnLeft(1:x)=2; %object =1/2 trials
    aq.stimOnLeft=aq.stimOnLeft(randperm(numel(aq.stimOnLeft))); % random ordering for Stimuli presented in stimBox1 on left (1=scene, 2=object)

    tempS=aq.scenesList;
	tempO=aq.objectsList;
    aq.halfScenesList=tempS((round(numel(tempS)/2))):round(numel(tempS));
    halfScenesList=aq.halfScenesList; %duplicating save for use later
    aq.halfObjectsList=tempO((round(numel(tempO)/2))):round(numel(tempO));
    halfObjectsList=aq.halfObjectsList;
end

    aq.chosenSide=NaN(1,nTrials);%creates null matrix that will be populated by participant choices
    aq.chosenStim=aq.chosenSide;
    aq.rt=aq.chosenSide;

    aq.reversalAt=randi([80 100],1,1); % sets reversal at random value between 80 and 100, want to avoid block transition
    b=0;
    aq.blockLength=blockLength; %now set in main function
    aq.breaks=NaN(1,nTrials/aq.blockLength-1);
    aq.breaksLength=aq.breaks;
    aq.reward=aq.breaks;
    
    aq.scenes=cell(numel(aq.halfScenesList),1);
    aq.objects=aq.scenes;
    img=cell(numel(aq.halfScenesList),2); % the stimuli converted to a screen texture for presentation later in script
    for i=1:numel(aq.halfScenesList) % now size of objects and scenes arrays are both 1/2 the size
        [o,~,alpha]=imread([scenesDir aq.halfScenesList(i).name], 'jpg');
        StimCell=cat(3,o,alpha);
        img{i,1}=Screen('MakeTexture',window, StimCell);
        aq.scenes(i)=cellstr(aq.halfScenesList(i).name);        
        [o,~,alpha]=imread([objectsDir aq.halfObjectsList(i).name], 'jpg');
        StimRect=RectOfMatrix(o);
        StimCell=cat(3,o,alpha);
        img{i,2}=Screen('MakeTexture',window, StimCell);
        aq.objects(i)=cellstr(aq.halfObjectsList(i).name);
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

   %%  Write Instructions and check for escape key
    DrawFormattedText(window,['Which category is more likely to be correct? \n\n Use the ''j'' key for Left \n use the ''k'' key for Right \n\n\n Press SPACE BAR to start'], 'center','center', [0 0 0]);
    Screen('Flip', window); % show text
    while(1)
        [keyIsDown,TimeStamp,keyCode] = KbCheck;
        if keyCode(okResp) %%allows examiner to press the space bar to pause the task if there is a problem, without terminating
            if scanned==1
            DrawFormattedText(window,['Please wait while we start the scan'],'center','center',[0 0 0]);
            Screen('Flip',window);
            keysofint=zeros(1,256);
            keysofint(ttl)=1;
            KbQueueCreate(trigger,keysofint);
            KbQueueStart;
            KbQueueWait;
            end
            break;
        end
        
    end

escape=0;
 while escape==0
    if escape==1;
        break % also provides an escape mechanism to stop the task
    end
    
 % preparing for first trial  
%  DrawFormattedText(window,'+','center','center',[0 0 0]);
%  Screen('Flip',window);

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
        %Screen('FillRect', window, white); % Color the entire window grey
        Screen('TextSize',window, [30]);
        Screen('TextStyle',window,[2]);
        DrawFormattedText(window,'+','center','center',[0 0 0]);
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
        
        if aq.stimOnLeft(t) == 1 % Place scene in stimBox1 on Left
            trials1=aq.trialsS(t); %MS: added aq.
            trials2=aq.trialsO(t);
        elseif aq.stimOnLeft(t) == 2 % Place object in stimBox1 on Left
            trials1=aq.trialsO(t);
            trials2=aq.trialsS(t);
        end
        %%%% SHOW STIMULI %%%%
        %disp(['t is ' num2str(t) 'and trials1 is ' num2str(trials1) ' and stimOnLeft is' num2str(aq.stimOnLeft(t)) ' and size of img' num2str(size(img))])
        disp(['t is ' num2str(t) ' and stimOnLeft is' num2str(aq.stimOnLeft(t)) ' and size of img' num2str(size(img))])
        
        Screen('DrawTexture', window, img{t,aq.stimOnLeft(t)}, [], StimBox1); % render stimuli image in StimBox1 (L); img{i,j} category chosen by stimOnLeft and image in list by j
        Screen('FrameRect',window, black, StimBox1, 4);
        Screen('DrawTexture', window, img{t,abs(aq.stimOnLeft(t)-3)}, [], StimBox2);
        Screen('FrameRect',window, black, StimBox2, 4);  
        [VBLTimestamp startChoice(t)]=Screen('Flip', window,ExpStart+onsetlist(t)); % displays on screen and starts choice timing    
        
        %% Response
       allowKeys=[leftResp rightResp];
       endTime=startChoice(t)+maxtime;
       
       if 0
       keyDown=1; %assume first that key is down
       
       %this is checking that key isnt down and must be the same length as the respnse while loop
            [keyDown,RT_Response,keyCode] = KbQ_Func(buttonBox,allowKeys,endTime)
            if isempty(KbName(keyCode))
                keyDown=0;
                break;
            end
            WaitSecs(.001) %do this loop or the first msec to make sure that key isnt held down
        end

            
                [keyDown,RT_Response,keyCode] = KbQ_Func(buttonBox,allowKeys,endTime);
                if KbName(keyCode)==leftResp|| KbName(keyCode)==rightResp %checks if left or right key was pressed
                    break;
                end
                WaitSecs(.001);
                           
       
         disp('line 198')

        aq.rt(t)=RT_Response-startChoice(t);% compute response time in milliseconds
        

        resp=keyCode; %find name of key that was pressed **however KbQ_Func now takes care of this, we think
        if iscell(resp) %checking if 2 keys were pressed and keeping 2nd
            resp=resp{2};
        end
        if length(resp)>1
            resp=NaN;
        end
        if isempty(resp)
            resp=NaN;
            aq.rt(t)=maxtime;
        end
        aq.keyPressed(t)=resp;

        % Add Yellow Frame to Chosen Stimuli
        Screen('DrawTexture', window, img{t,aq.stimOnLeft(t)}, [], StimBox1);
        Screen('FrameRect',window, black, StimBox1, 4);
        Screen('DrawTexture', window, img{t,abs(aq.stimOnLeft(t)-3)}, [], StimBox2);
        Screen('FrameRect',window, black, StimBox2, 4);  

        if isequal(resp,'j')
            aq.chosenSide(t)=1; % i.e. Left
            aq.chosenStim(t)=img{t,aq.stimOnLeft(t)}; 
            Screen('FrameRect',window, [255 255 0], StimBox1Frame, 6);
            Screen('Flip', window, ExpStart+onsetlist(t)+aq.rt(t)); % show response
            %WaitSecs(.5); %so show the feedback for 0.5sec
            resp=1;
        elseif isequal(resp,'k')
            aq.chosenSide(t)=2; % i.e. Right
            aq.chosenStim(t)=img{t,abs(aq.stimOnLeft(t)-3)};
            Screen('FrameRect',window, [255 255 0], StimBox2Frame, 6);
            Screen('Flip', window, ExpStart+onsetlist(t)+aq.rt(t)); % show response
            %WaitSecs(.5);
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
            [VBLTimestamp startFB(t)]=Screen('Flip', window, ExpStart+onsetlist(t)+aq.rt(t)); %in this case aq.rt is the Maxtime
            aq.reward(t)=NaN;
            aq.optimal(t)=NaN;
            %WaitSecs(.5);
        elseif aq.rewProb(t)==1
            if (resp==1 && aq.stimOnLeft(t)==rewCat) || (resp==2 && abs(3-aq.stimOnLeft(t))==rewCat)
%                 if resp==1
%                     Screen('DrawTexture', window, img{trials1,rewCat}, [], StimBox); %%%% 
%                 elseif resp==2
%                     Screen('DrawTexture', window, img{trials2,rewCat}, [], StimBox); %%%% 
%                 end
%                 Screen('FrameRect',window, [0 255 0], StimBoxFrame, 6); %make frame green
                Screen('TextSize',window, [50]);
                Screen('TextStyle',window,[2]);
                
                DrawFormattedText(window,'+','center','center',[0 0 0]);
                Screen('Flip',window, ExpStart+onsetlist(t)+aq.rt(t)+0.5);%put up crosshair after yellow frame is up for 0.5sec
                
                DrawFormattedText(window,'You won!!', 'center','center', [0 255 0]);
                %DrawFormattedText(window,'You won!!', 'center',cy-400, [0 255 0]);
                [VBLTimestamp startFB2(t)]=Screen('Flip', window, ExpStart+onsetlist(t)+aq.rt(t)+1.5);%put up FB after the crosshair has been on for 1sec
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
                
                DrawFormattedText(window,'+','center','center',[0 0 0]);
                Screen('Flip',window, ExpStart+onsetlist(t)+aq.rt(t)+0.5);%put up crosshair after yellow frame is up for 0.5sec
                
                DrawFormattedText(window,'Wrong!!', 'center','center', [255 0 0]);
                %DrawFormattedText(window,'Wrong!!', 'center',cy-400, [255 0 0]);
                [VBLTimestamp startFB2(t)]=Screen('Flip', window, ExpStart+onsetlist(t)+aq.rt(t)+1.5);%put up FB after the crosshair has been on for 1sec
                aq.reward(t)=0;
                aq.optimal(t)=0;
                WaitSecs(1);
            end
        elseif aq.rewProb(t)==0
           if (resp==1 && aq.stimOnLeft(t)==rewCat) || (resp==2 &&  abs(3-aq.stimOnLeft(t))==rewCat)
%                if resp==1
%                 Screen('DrawTexture', window, img{trials1,rewCat}, [], StimBox); %%%% 
%                elseif resp==2
%                 Screen('DrawTexture', window, img{trials2,rewCat}, [], StimBox); %%%% 
%                end
%                 Screen('FrameRect',window, [255 0 0], StimBoxFrame, 6); %make frame red               
                Screen('TextSize',window, [50]);
                Screen('TextStyle',window,[2]);
                
                DrawFormattedText(window,'+','center','center',[0 0 0]);
                Screen('Flip',window, ExpStart+onsetlist(t)+aq.rt(t)+0.5); %put up crosshair after yellow frame is up for 0.5sec
                
                DrawFormattedText(window,'Wrong!!', 'center','center', [255 0 0]);
                %DrawFormattedText(window,'Wrong!!', 'center',cy-400, [255 0 0]);
                [VBLTimestamp startFB2(t)]=Screen('Flip', window, ExpStart+onsetlist(t)+aq.rt(t)+1.5);%put up FB after the crosshair has been on for 1sec
                aq.reward(t)=0;
                aq.optimal(t)=1;
                WaitSecs(1);
           elseif (resp==1 && aq.stimOnLeft(t)~=rewCat) || (resp==2 &&  abs(3-aq.stimOnLeft(t))~=rewCat)
%                 if resp==1
%                     Screen('DrawTexture', window, img{trials1,abs(3-rewCat)}, [], StimBox); %%%% 
%                 elseif resp==2
%                     Screen('DrawTexture', window, img{trials2,abs(3-rewCat)}, [], StimBox); %%%% 
%                 end
%                 Screen('FrameRect',window, [0 255 0], StimBoxFrame, 6); %make frame green
                Screen('TextSize',window, [50]);
                Screen('TextStyle',window,[2]);
                
                DrawFormattedText(window,'+','center','center',[0 0 0]);
                Screen('Flip',window, ExpStart+onsetlist(t)+aq.rt(t)+0.5);
                
                DrawFormattedText(window,'You won!!', 'center','center', [0 255 0]);
                %DrawFormattedText(window,'You won!!', 'center',cy-400, [0 255 0]);
                [VBLTimestamp startFB2(t)]=Screen('Flip', window, ExpStart+onsetlist(t)+aq.rt(t)+1.5); %put up FB after the crosshair has been on for 1sec
                aq.reward(t)=1;
                aq.optimal(t)=0;
                WaitSecs(1);
           end
        end
        
        DrawFormattedText(window,'+','center','center',[0 0 0]);
        [VBLTimestamp FBOffTime(t)]=Screen('Flip', window, ExpStart+onsetlist(t)+aq.rt(t)+2.5);    % remove feedback after 1sec (ie 2sec since
    
        
    %% MS: create an output matrix
    
        outputmat(t,1)=SubjectNumber;
        outputmat(t,2)=t;
        outputmat(t,3)=day;
        %outputmat(t,4)=trials1; eliminated these - now halfScenesList and
        %halfObjectsList used - have stimuli names in random permutation
        %for half being used for day
        %outputmat(t,5)=trials2;
        %outputmat(t,4)=aq.halfScenesList.name;
        %outputmat(t,5)=aq.halfObjectsList.name;
        outputmat(t,4)=aq.stimOnLeft(t); %this is image category on Left?
        outputmat(t,5)=rewCat;
        outputmat(t,6)=resp; %1=left, 2=right
        outputmat(t,7)=aq.rewProb(t);
        outputmat(t,8)=aq.reward(t); %feedback they were acually given
        outputmat(t,9)=aq.optimal(t);
        %MS: i want to also save the number of the images shown on each
        %trial. Not sure which variable best for this. The img variable
        %does not seem to be saving the correct number as the numbers don't
        %match anything else that I can find
    
    
    
    %%
        
    %% Save frequently and set blocks
            if mod(t,10)==1
                save(sprintf('%s/day%d/aquisitionAQ',folder_name),'aq');
                save(sprintf('%s/day%d/AQmat',folder_name),'outputmat');
            end
            % below is where we could move the image loading to
            if mod(t,aq.blockLength)==0 && t<nTrials %MS changed block length to 6 for testing
                b=b+1;
                aq.breaks(b)=GetSecs;
                Screen('TextSize',window, [30]);
                Screen('TextStyle',window,[2]);
                DrawFormattedText(window,'Please take a break for as long as you need. \n\n Press the SPACE BAR when you are ready to start again.', 'center','center', [0 0 0]);            
                Screen('Flip',window);
                while(1)
                    [keyIsDown,TimeStamp,keyCode] = KbCheck;
                    if keyCode(okResp) %end the break when spacebar is pressed
                        if scanned==1
                            DrawFormattedText(window,['Please wait while we re-boot the scanner'],'center','center',[0 0 0]);
                            Screen('Flip',window);
                            keysofint=zeros(1,256);
                            keysofint(ttl)=1;
                            KbQueueCreate(trigger,keysofint);
                            KbQueueStart;
                            KbQueueWait;
                        end
                        break;
                    end
                end
                aq.breaksLength(b)=GetSecs-aq.breaks(b);
                ExpStart=ExpStart+aq.breaksLength(b);
            end
            
    end % end trial loop
        save(sprintf('%s/day%d/aquisitionAQ',folder_name),'aq')
        save(sprintf('%s/day%d/AQmat',folder_name),'outputmat');
        save(sprintf('%s/day%d/space',folder_name))
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
