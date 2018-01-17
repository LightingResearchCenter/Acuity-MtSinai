function MakeDaysigrams
%MAKE Summary of this function goes here
%   Detailed explanation goes here
timestamp = datestr(now,'yyyy-mm-dd HH-MM');

[githubDir,~,~] = fileparts(pwd);
d12packDir = fullfile(githubDir,'d12pack');
addpath(d12packDir);

projectDir = '\\root\projects\Acuity_MtSinai';
dataDir = fullfile(projectDir,'croppedData');
saveDir = fullfile(projectDir,'daysigrams');

ls = dir([dataDir,filesep,'*.mat']);

for iFile = 1:numel(ls)
    dataName = ls(iFile).name;
    dataPath = fullfile(dataDir,dataName);
    load(dataPath);
    
    for iObj = 1:numel(objArray)
        thisObj = objArray(iObj);
        
        if isempty(thisObj.Time)
            continue
        end
        
        titleText = {'Acuity - Mt Sinai';['ID: ',thisObj.ID,', Session: ',thisObj.Session.Name,', Device SN: ',num2str(thisObj.SerialNumber)]};
        
        d = d12pack.daysigram(thisObj,titleText);
        
        nFig = numel(d);
        savePaths = cell(nFig,1);
        for iFig = 1:numel(d)
            d(iFig).Title = titleText;
            
            name = [thisObj.ID,'_',thisObj.Session.Name,'_',timestamp,'_p',num2str(iFig),'.pdf'];
            savePaths{iFig} = fullfile(saveDir,name);
            saveas(d(iFig).Figure,savePaths{iFig})
            close(d(iFig).Figure)
        end
        nameAll = [thisObj.ID,'_',thisObj.Session.Name,'_',timestamp,'.pdf'];
        savePathAll = fullfile(saveDir,nameAll);
        append_pdfs(savePathAll, savePaths{:});
        delete(savePaths{:});
    end
end

end

