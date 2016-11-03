function DataCluster = CropAndConvert

%% Reset MATLAB
close all
clear
clc

%% Enable dependencies
[githubDir,~,~] = fileparts(pwd);
d12packDir      = fullfile(githubDir,'d12pack');
addpath(d12packDir);

%% Map paths
timestamp = datestr(now,'yyyy-mm-dd_HHMM');
rootDir = '\\root\projects';
calPath = fullfile(rootDir,'DaysimeterAndDimesimeterReferenceFiles',...
    'recalibration2016','calibration_log.csv');
prjDir  = fullfile(rootDir,'Acuity_MtSinai');
dbName  = [timestamp,'.mat'];
dbPath  = fullfile(prjDir,'CroppedData',dbName);

% Map subject folders
subjectListing = dir(prjDir);
isSubject = ~cellfun(@isempty,regexp({subjectListing.name}','^\d{3}$'));
isDir = [subjectListing.isdir]';
subjectListing = subjectListing(isSubject & isDir,:);
IDs = {subjectListing.name}';
subjectDirs = fullfile(prjDir,IDs);

% Map subdirectories
T1DiaryDirs = fullfile(subjectDirs,'T1','diary');
T1PersonDirs = fullfile(subjectDirs,'T1','person');

T3DiaryDirs = fullfile(subjectDirs,'T3','diary');
T3PersonDirs = fullfile(subjectDirs,'T3','person');
T3FixtureDirs = fullfile(subjectDirs,'T3','fixture');
T3BedDirs = fullfile(subjectDirs,'T3','bed');


%% Crop and convert T1 PERSON data
ii = 1;
for iSub = 1:numel(IDs)
    thisID = IDs{iSub};
    
    thisDiaryDir = T1DiaryDirs{iSub};
    thisDataDir = T1PersonDirs{iSub};
    
    % Convert data
    thisObj = convertData(thisID,thisDataDir,'T1','HumanData',calPath,thisDiaryDir);
    
    if isempty(thisObj)
        continue
    end
    
    % Crop the data
    thisObj = crop(thisObj);
    
    T1Person(ii,1) = thisObj;
    ii = ii + 1;
end

%% Crop and convert T3 PERSON data
ii = 1;
for iSub = 1:numel(IDs)
    thisID = IDs{iSub};
    
    thisDiaryDir = T3DiaryDirs{iSub};
    thisDataDir = T3PersonDirs{iSub};
    
    % Convert data
    thisObj = convertData(thisID,thisDataDir,'T3','HumanData',calPath,thisDiaryDir);
    
    if isempty(thisObj)
        continue
    end
    
    % Crop the data
    thisObj = crop(thisObj);
    
    T3Person(ii,1) = thisObj;
    ii = ii + 1;
end

%% Crop and convert T3 FIXTURE data
ii = 1;
for iSub = 1:numel(IDs)
    thisID = [IDs{iSub},'-fixture'];
    
    thisDataDir = T3FixtureDirs{iSub};
    
    % Convert data
    thisObj = convertData(thisID,thisDataDir,'T3','StaticData',calPath);
    
    if isempty(thisObj)
        continue
    end
    
    % Crop the data
    thisObj = crop(thisObj);
    
    T3Fixture(ii,1) = thisObj;
    ii = ii + 1;
end

%% Crop and convert T3 BED data
ii = 1;
for iSub = 1:numel(IDs)
    thisID = [IDs{iSub},'-bed'];
    
    thisDataDir = T3BedDirs{iSub};
    
    % Convert data
    thisObj = convertData(thisID,thisDataDir,'T3','StaticData',calPath);
    
    if isempty(thisObj)
        continue
    end
    
    % Crop the data
    thisObj = crop(thisObj);
    
    T3Bed(ii,1) = thisObj;
    ii = ii + 1;
end

%% Save converted data to file
DataCluster = struct('T1Person',T1Person,'T3Person',T3Person,'T3Fixture',T3Fixture,'T3Bed',T3Bed);
save(dbPath,'DataCluster');

end

function obj = convertData(ID,dataDir,session,objType,calPath,varargin)
tz = 'America/New_York';

logListing   = dir(fullfile(dataDir,'*-LOG.txt'));
if isempty(logListing)
    warning([ID,' ',session,' missing data.']);
    obj = [];
    return
end
loginfoPath = fullfile(dataDir,logListing(1).name);
datalogPath = regexprep(loginfoPath,'-LOG\.txt$','-DATA.txt');

switch objType
    case 'HumanData'
        obj = d12pack.HumanData;
    case 'StaticData'
        obj = d12pack.StaticData;
    otherwise
        error('Unsupported object type.');
end

obj.CalibrationPath = calPath;
obj.RatioMethod     = 'newest';
obj.ID              = ID;
obj.TimeZoneLaunch	= tz;
obj.TimeZoneDeploy	= tz;

% Import the original data
obj.log_info = obj.readloginfo(loginfoPath);
obj.data_log = obj.readdatalog(datalogPath);

% Add Session
obj.Session = struct('Name',session);

% Import bed log if one exists
if (nargin >= 6) && isa(obj,'d12pack.HumanData')
    diaryDir = varargin{1};
    diaryListing = dir(fullfile(diaryDir,'*.xlsx'));
    if ~isempty(diaryListing)
        diaryPath = fullfile(diaryDir,diaryListing(1).name);
        obj.BedLog = d12pack.BedLogData;
        obj.BedLog = obj.BedLog.import(diaryPath,tz);
    end
end

end
