function logger(entryMsg)
    disp(strjoin([string(datetime) '[LOG]' entryMsg]));
end