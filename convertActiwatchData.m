function varargout = convertActiwatchData
%CONVERTACTIWATCHDATA Summary of this function goes here
%   Detailed explanation goes here

% Map file paths
timestamp = datestr(now,'yyyy-mm-dd_HHMM');
project = '\\root\projects\Acuity_MtSinai\Analyzed actiwatch data';
dataDir = fullfile(project,'Analyzed subject data');
dbPath  = fullfile(project,[timestamp,'.mat']);

ls = dir(fullfile(dataDir,'*.xlsx'));

excelPaths = fullfile(dataDir,{ls.name}');



% Preallocate dataArray
dataArray = struct;

% Setup wait bar
nFile = numel(excelPaths);
h = waitbar(0, ['Please wait processing sheet 0 of ',num2str(nFile)]);

ii = 1;

for iFile = 1:numel(excelPaths)
    waitbar(iFile/nFile, h, ['Please wait processing file ',num2str(iFile),' of ',num2str(nFile)]);
    thisFile = excelPaths{iFile};
    
    % Find the sheets we want
    [~,sheets0]	= xlsfinfo(thisFile);
    
    sheets = sheets0(~contains(sheets0,'sleep'))';
    sleepSheets = sheets0(contains(sheets0,'sleep'))';
    subjects = regexprep(sheets,'(\d\d\d) (T\d)','$1');
    sessions = regexprep(sheets,'(\d\d\d) (T\d)','$2');
    
    
    % Iterate through sheets
    for iSheet = 1:numel(sheets)
        
        
        thisSheet   = sheets{iSheet};
        thisSubject = subjects{iSheet};
        thisSession = sessions{iSheet};
        thisSleepSheet   = [thisSession,' sleep'];
        
        % Read data from file
        data             = importActiwatchExcel(thisFile,thisSheet);
        if isempty(data) || ~ismember(thisSleepSheet,sleepSheets)
            continue;
        end
        sleep = importActiwatchCalc(thisFile,thisSleepSheet);
        
        % Limit bounds to dates worn
        compliance = ~(isnan(data.Activity) | strcmp(data.IntervalStatus,'EXCLUDED'));
        
        % Save to data array
        data.Observation = true(size(data.DateTime));
        data.Compliance  = compliance & data.Observation;
        
        dataArray(ii).subject = thisSubject;
        dataArray(ii).session = thisSession;
        dataArray(ii).data = data;
        dataArray(ii).sleep = sleep;
        
        ii = ii + 1;
    end
    
end

delete(h);

save(dbPath,'dataArray');

if nargout > 0
    varargout{1} = dataArray;
end

end

