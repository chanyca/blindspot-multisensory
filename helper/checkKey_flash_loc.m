function [responded, endTask, secs, num] = checkKey_flash_loc
    % while KbCheck; end % Wait until all keys are released.

    num = 99;
    clear keyCode
    KbName('UnifyKeyNames')
    responded = false;
    endTask = false;

    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(KbName('ESCAPE'))
            responded = true;
            endTask = true;
            num = 99;
        elseif keyCode(KbName('1')) || keyCode(KbName('1!'))
            num = 1;
        elseif keyCode(KbName('2')) || keyCode(KbName('2@'))
            num = 2;
        elseif keyCode(KbName('3')) || keyCode(KbName('3#'))
            num = 3;
        elseif keyCode(KbName('4')) || keyCode(KbName('4$'))
            num = 4;
        elseif keyCode(KbName('5')) || keyCode(KbName('5%'))
            num = 5;
        elseif keyCode(KbName('Return')) %|| any(keyCode(KbName('return'))) || keyCode(KbName('enter'))
            responded = true;
            num = 99;
        elseif IsWin && keyCode(KbName('BackSpace'))
            num = 7;
        elseif IsOSX && keyCode(KbName('DELETE'))
            num = 7;
        end
        
        KbReleaseWait;
    end

 
end