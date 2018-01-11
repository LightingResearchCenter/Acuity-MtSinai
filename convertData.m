function convertData

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
dbDir = fullfile(prjDir,'convertedData');
dbPath  = fullfile(dbDir,dbName);

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

n = numel(IDs);

%% Crop and convert T1 PERSON data
ii = 1;

for iSub = 1:n
    thisID = IDs{iSub};
    
    thisDiaryDir = T1DiaryDirs{iSub};
    thisDataDir = T1PersonDirs{iSub};
    
    % Convert data
    thisObj = files2obj(thisID,thisDataDir,'T1','HumanData',calPath,thisDiaryDir);
    
    if isempty(thisObj)
        continue
    end
    
    T1Person(ii,1) = thisObj;
    ii = ii + 1;
end


%% Convert T3 data
iP = 1;
iF = 1;
iB = 1;

for iSub = 1:n
    thisID = IDs{iSub};
    
    thisDiaryDir   = T3DiaryDirs{iSub};
    thisPersonDir  = T3PersonDirs{iSub};
    thisFixtureDir = T3FixtureDirs{iSub};
    thisBedDir     = T3BedDirs{iSub};
    
    % Convert data
    thisPerson  = files2obj(thisID,thisPersonDir,'T3','HumanData',calPath,thisDiaryDir);
    thisFixture = files2obj([thisID,'-fixture'],thisFixtureDir,'T3','StaticData',calPath);
    thisBed     = files2obj([thisID,'-bed'],thisBedDir,'T3','StaticData',calPath);
    
    if ~isempty(thisPerson)
        T3Person(iP,1) = thisPerson;
        iP = iP + 1;
    end
    
    if ~isempty(thisFixture)
        T3Fixture(iF,1) = thisFixture;
        iF = iF + 1;
    end
    
    if ~isempty(thisBed)
        T3Bed(iB,1) = thisBed;
        iB = iB + 1;
    end
    
    
end

dbT1pName  = [timestamp,'-T1-person.mat'];
dbT1pPath  = fullfile(dbDir,dbT1pName);
save(dbT1pPath,'T1Person');

dbT3pName  = [timestamp,'-T3-person.mat'];
dbT3pPath  = fullfile(dbDir,dbT3pName);
save(dbT3pPath,'T3Person');

dbT3bName  = [timestamp,'-T3-bed.mat'];
dbT3bPath  = fullfile(dbDir,dbT3bName);
save(dbT3bPath,'T3Bed');

dbT3fName  = [timestamp,'-T3-fixture.mat'];
dbT3fPath  = fullfile(dbDir,dbT3fName);
save(dbT3fPath,'T3Fixture');


end

function obj = files2obj(ID,dataDir,session,objType,calPath,varargin)
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
