function dbPath = CropAndConvert

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
dbDir = fullfile(prjDir,'CroppedData');
dbPath  = fullfile(dbDir,dbName);

% Check for previous DB
dbListing = dir(fullfile(dbDir,'*.mat'));
if ~isempty(dbListing)
    [~,idxMostRecent] = max(vertcat(dbListing.datenum));
    previousDbName = dbListing(idxMostRecent).name;
    previousDbPath = fullfile(dbDir,previousDbName);
    previousDB = load(previousDbPath);
else
    previousDB = [];
end

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

%% Create DB file and object
DB = matfile(dbPath,'Writable',true);


n = numel(IDs);

%% Crop and convert T1 PERSON data
if ~isempty(previousDB)
    T1Person = previousDB.T1Person;
    ii = numel(T1Person) + 1;
    previousIDs = {previousDB.T1Person.ID}';
else
    ii = 1;
    previousIDs = {''};
end

for iSub = 1:n
    thisID = IDs{iSub};
    
    if any(strcmp(thisID,previousIDs))
        continue
    end
    
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
    DB.T1Person = T1Person;
    ii = ii + 1;
end

%% Crop and convert T3 data
if ~isempty(previousDB)
    T3Person = previousDB.T3Person;
    T3Fixture = previousDB.T3Fixture;
    T3Bed = previousDB.T3Bed;
    ii = numel(T1Person) + 1;
    previousIDs = {previousDB.T3Person.ID}';
else
    ii = 1;
    previousIDs = {''};
end

for iSub = 1:n
    thisID = IDs{iSub};
    
    if any(strcmp(thisID,previousIDs))
        continue
    end
    
    thisDiaryDir   = T3DiaryDirs{iSub};
    thisPersonDir  = T3PersonDirs{iSub};
    thisFixtureDir = T3FixtureDirs{iSub};
    thisBedDir     = T3BedDirs{iSub};
    
    % Convert data
    thisPerson  = convertData(thisID,thisPersonDir,'T3','HumanData',calPath,thisDiaryDir);
    thisFixture = convertData([thisID,'-fixture'],thisFixtureDir,'T3','HumanData',calPath,thisDiaryDir);
    thisBed     = convertData([thisID,'-bed'],thisBedDir,'T3','HumanData',calPath,thisDiaryDir);
    
    if isempty(thisPerson)
        continue
    end
    
    % Crop the data
    thisPerson = crop(thisPerson);
    t1 = min(thisPerson.Time(thisPerson.Observation));
    t2 = max(thisPerson.Time(thisPerson.Observation));
    thisFixture.Observation = thisFixture.Time >= t1 & thisFixture.Time <= t2;
    thisBed.Observation = thisBed.Time >= t1 & thisBed.Time <= t2;
    
    T3Person(ii,1) = thisPerson;
    DB.T3Person = T3Person;
    
    T3Fixture(ii,1) = thisFixture;
    DB.T3Fixture = T3Fixture;
    
    T3Bed(ii,1) = thisBed;
    DB.T3Bed = T3Bed;
    
    ii = ii + 1;
end

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
