function [subjectName] = getSubjectName(file)
    fileName = file.name;
    splittedFileName = split(fileName, '_');
    subjectName = splittedFileName{1};
end