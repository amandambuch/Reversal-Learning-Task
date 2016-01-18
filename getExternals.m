function [trigger,KB,buttonBox] = getExternals()

d=PsychHID('Devices');
KB=0;
trigger=0;
buttonBox=0;
for n = 1:length(d)
    if strcmp(d(n).usageName,'Keyboard') % && d(n).usageValue==6
        if ~isempty(strfind(d(n).manufacturer,'Apple'))
            KB=n;
            
        elseif strmatch(d(n).product,'TRIGI-USB')% && d(n).usageValue==6
            trigger=n;
            
        elseif strmatch(d(n).product,'932') % && d(n).usageValue==6
            buttonBox=n;
        end
    end
end

