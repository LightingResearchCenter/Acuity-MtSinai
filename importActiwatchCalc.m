function sleep = importActiwatchCalc(filePath,sheet)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Read data from file
[~,~,raw] = xlsread(filePath,sheet,'','basic');


% Select start and end dates
sleepStartDates = raw(3:end,3);
sleepStartTimes = raw(3:end,5);
sleepEndDates   = raw(3:end,6);
sleepEndTimes   = raw(3:end,8);

% Filter out emty and nonnumeric cells
fValid = @(x) isnumeric(x) & ~isnan(x);

sleepStartDates = cell2mat(sleepStartDates(cellfun(fValid, sleepStartDates)));
sleepStartTimes = cell2mat(sleepStartTimes(cellfun(fValid, sleepStartTimes)));
sleepEndDates   = cell2mat(sleepEndDates(  cellfun(fValid, sleepEndDates  )));
sleepEndTimes   = cell2mat(sleepEndTimes(  cellfun(fValid, sleepEndTimes  )));

% Convert Excel dates to datetime and store in structs
sleep = struct;

sleep.start = datetime(sleepStartDates+sleepStartTimes,'ConvertFrom','excel','TimeZone','local');
sleep.end   = datetime(sleepEndDates+sleepEndTimes,  'ConvertFrom','excel','TimeZone','local');

end

