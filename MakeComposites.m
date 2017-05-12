function MakeComposites
%MAKE Summary of this function goes here
%   Detailed explanation goes here

addpath('C:\Users\jonesg5\Documents\GitHub\d12pack');

projectDir = '\\root\projects\Acuity_MtSinai';

dataDir = fullfile(projectDir,'CroppedData');

ls = dir(fullfile(dataDir,'*.mat'));
[~,idxMostRecent] = max(vertcat(ls.datenum));
dataName = ls(idxMostRecent).name;
dataPath = fullfile(dataDir,dataName);

exportDir = fullfile(projectDir,'Composites');

DataCluster = load(dataPath);

timestamp = upper(datestr(now,'mmmdd'));

objArray = DataCluster.T1Person;
for iObj = 1:numel(objArray)
    thisObj = objArray(iObj);
    
    if isempty(thisObj.Time)
        continue
    end
    
    titleText = {'Acuity - Mt Sinai';['ID: ',thisObj.ID,', Session: ',thisObj.Session.Name,', Device SN: ',num2str(thisObj.SerialNumber)]};
    
%     try
        d = d12pack.composite(thisObj,titleText);
%     catch err
%         close all
%         continue
%     end
    
    for iFile = 1:numel(d)
        
        fileName = [thisObj.ID,'_',thisObj.Session.Name,'_',timestamp,'_p',num2str(iFile),'.pdf'];
        filePath = fullfile(exportDir,fileName);
        saveas(d(iFile).Figure,filePath);
        close(d(iFile).Figure);
        
    end
end


objArray = DataCluster.T3Person;
for iObj = 1:numel(objArray)
    thisObj = objArray(iObj);
    
    if isempty(thisObj.Time)
        continue
    end
    
    titleText = {'Acuity - Mt Sinai';['ID: ',thisObj.ID,', Session: ',thisObj.Session.Name,', Device SN: ',num2str(thisObj.SerialNumber)]};
    
%     try
        d = d12pack.composite(thisObj,titleText);
%     catch err
%         close all
%         continue
%     end
    
    for iFile = 1:numel(d)
        
        fileName = [thisObj.ID,'_',thisObj.Session.Name,'_',timestamp,'_p',num2str(iFile),'.pdf'];
        filePath = fullfile(exportDir,fileName);
        saveas(d(iFile).Figure,filePath);
        close(d(iFile).Figure);
        
    end
end

end

