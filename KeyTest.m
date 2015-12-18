function KeyTest(device,okResp,leftResp,rightResp,window)

allowKeys=[okResp,leftResp,rightResp];
endTime=0;
outMC=0;
while outMC==0
    DrawFormattedText(window, 'Please click the INDEX finger button','center', 'center');
    Screen('flip',window)
    while 1
        [buttonPress,pressTime] = KbQ_Func(device,allowKeys,endTime);
        if strcmp(buttonPress,KbName(leftResp))
            outMC=1;
            Screen('flip',window)
            WaitSecs(1.5)
            break;
        else
            DrawFormattedText(window, 'Wrong Button','center', 'center');
            Screen('flip',window)
            WaitSecs(1)
            break
        end
    end
end


outMC=0;
while outMC==0
    DrawFormattedText(window, 'Please click the MIDDLE finger button','center', 'center');
    Screen('flip',window)
    while 1
        [buttonPress,pressTime] = KbQ_Func(device,allowKeys,endTime);
        if strcmp(buttonPress,KbName(rightResp))
            outMC=1;
            Screen('flip',window)
            WaitSecs(1.5)
            break;
        else
            DrawFormattedText(window, 'Wrong Button','center', 'center');
            Screen('flip',window)
            WaitSecs(1)
            break
        end
    end
end

outMC=0;
while outMC==0
    DrawFormattedText(window, 'Please click the THUMB button','center', 'center');
    Screen('flip',window)
    while 1
        [buttonPress,pressTime] = KbQ_Func(device,allowKeys,endTime);
        if strcmp(buttonPress,KbName(okResp))
            outMC=1;
            Screen('flip',window)
            WaitSecs(1.5)
            break;
        else
            DrawFormattedText(window, 'Wrong Button','center', 'center');
            Screen('flip',window)
            WaitSecs(1)
            break
        end
    end
end