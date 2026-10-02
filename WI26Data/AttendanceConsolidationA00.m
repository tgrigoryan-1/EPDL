% Code to consolidate attendance surveys from multiple excel sheets
% while assigning NaN values to those who missed attendance surveys
% but filled out at least 1

clear all, clc

% Navigate to directory of Excel Files downloaded as .csv files
cd('C:\Users\tigrr\Downloads\AttendanceA00')


% ----Master Set Creation----

% Define a master set (Name in form "Last, first", Proper PID with formatting, SISLoginID)
master_Set = readtable('Attendance Logger A00 - EDITED BY TIGRAN TO MAKE DATA ANALYSIS EASIER - Total attendance.csv', 'TextType', 'string');
% Trim columns to only have the indicator values (originally had total attendance trackers)
master_Set = master_Set(:,[1:2,4]);

% Setup individual indicator data sets
master_Email = strip(string(master_Set.Email));								% Pulls the emails from the master set and makes
																			% them into strings (some contain numbers)

master_PID_num = strip(regexprep(string(master_Set.SISUserID), '\D', ''));	% Pulls PID values, sets them to string, then
																			% removes the 'A' from the front to make it 
																			% easier to compare to those from the attendance
																			% surveys since not everyone followed the guidlines
																			% for reporting their PID's

master_Name_lower = lower(strip(string(master_Set.Student)));				% Pulls name values and makes them lower case for
																			% easier comparison with attendance surveys

% ----File Setup----

% Set the files within the folder to a variable using dir() allowing easy iteration

files = dir('Attendance Logger A00 - EDITED BY TIGRAN TO MAKE DATA ANALYSIS EASIER - Lecture *.csv');	
																% Essentially pulling all files with name that
																% starts with Attendance Survey Logger A00 and
																% ends with .csv (have to be in the same folder
																% and have to start with the same title, since
																% from the same Google Sheet, they automatically
																% start with the same name)


% ----Fix Sorting----
% Extract the lecture numbers from the file names to sort them properly because
% it will assume the order is 1 10 11 12 2 3
lectureNumbers = zeros(numel(files), 1);
for f = 1:numel(files)
    % Find the digits right after the word "Lecture " in the filename
    numToken = regexp(files(f).name, 'Lecture (\d+)', 'tokens', 'once');
    if ~isempty(numToken)
        lectureNumbers(f) = str2double(numToken{1});
    end
end

% Sort the numbers and rearrange the 'files' array so 2 comes before 10
[~, sortOrder] = sort(lectureNumbers);
files = files(sortOrder);




% ----Iteration----
% Need to iterate through all attendance surveys and consolidate data
for k = 1:numel(files)													% Iterates from 1 to 20, just made it numel(files)
																		% to make it more scalable

	AS = readtable(files(k).name, 'TextType', 'string');				% Reads the current iteration attendance sheet
	AS(:, 1) = [];														% Removes timestamp since format is the same for all

	% ----Standardization----
	% MATLAB hates it when I give it long complicated names so to make
	% both mine and MATLAB's life easier we rename the columns
    AS.Properties.VariableNames{1} = 'Email';
    AS.Properties.VariableNames{2} = 'Name';
    AS.Properties.VariableNames{3} = 'PID';

    % Now we make the headers all nice and pretty for the questions
    % Pull the original names
    questionHeaders = AS.Properties.VariableNames(4:end);				% Do from 4 to end because from 1 to 3 were our indicators
    																	% and anything after is a question that we want data for

    % Attach the prefix to the raw headers first because MATLAB
    % just hates me and loves to give me errors
    rawSheetHeaders = sprintf("Att_Sheet%d_", k) + string(questionHeaders);
    
    % Use makeValidName to clean it and safely enforce the 63-character limit (I LOVE YOU MATLAB PLEASE DON'T GIVE ME AN ERROR)
    sheetHeaders = matlab.lang.makeValidName(rawSheetHeaders);
    
    % Put them back into the table
    AS.Properties.VariableNames(4:end) = cellstr(sheetHeaders);
    
    qCols = string(AS.Properties.VariableNames(4:end));

    % ----Preallocation----
    % MATLAB handles numbers and strings differently in the cases where they
    % are missing values: for string it is standard to return missing while
    % for numbers it is standard to return NaN
    % In order to preallocate, we set according to how many students are in 
    % the master roster
    % Looping through each question column
    for c = 1:length(qCols)
        colName = qCols(c); % gives name as "Attendance_Sheet2_(whatever the question was)" 

        % Checks whether column is numbers or strings
        if isnumeric(AS.(colName))
            % If numeric, fill the new column in master_Set with NaNs
            master_Set.(colName) = NaN(height(master_Set), 1);
        else
            % If string, fill the new column in master_Set with 'missing' string values
            master_Set.(colName) = repmat(string(missing), height(master_Set), 1);			% Repeats the missing for the entire list of students
        end
    end
    

    % ----Identification----
    % Looping through all of the students who submitted the given attendance survey
    for i = 1:height(AS)
        sEmail = strip(lower(string(AS.Email(i))));
        sName = strip(lower(string(AS.Name(i))));
        sPID_num = strip(regexprep(string(AS.PID(i)), '\D', ''));

        match_case = 0;

        % Iterate through every student in the master roster to find a match
        % because MATLAB hates me and won't let me use find properly
        for m = 1:height(master_Set)
            
            % Grab the current master student's info
            currMasterPID = master_PID_num(m);
            currMasterEmail = master_Email(m);
            currMasterName = master_Name_lower(m);

            % ----PID Check----
            if strlength(sPID_num) > 0 && sPID_num == currMasterPID
                match_case = m;
                break; % Found, kill the search
            end

            % ----Email Check----
            if strlength(sEmail) > 0 && sEmail == currMasterEmail
                match_case = m;
                break; % Found, kill the search
            end

            % ----Name Check----
            if strlength(sName) > 0
                nameParts = split(sName, [" ", ","]);
                nameParts(nameParts == "") = [];

                if length(nameParts) >= 2
                    % Check if First and Last exist in this specific master name
                    if contains(currMasterName, nameParts(1)) && contains(currMasterName, nameParts(2))
                        match_case = m;
                        break; % Found, kill the search
                    end
                end
            end
        end

        % ----Adding the Student----
        if match_case > 0
            for j = 1:length(qCols)
                colName_iter = qCols(j); 
                master_Set.(colName_iter)(match_case) = AS.(colName_iter)(i);
            end
        else
            fprintf('Could not match student: %s (PID: %s, Email: %s)\n', sName, sPID_num, sEmail);
        end
    end


end

% Test
% disp(master_Set)

% Write the final consolidated data
writetable(master_Set, 'Final Consolidated Attendance A00.csv');

% Navigate back to original directory
cd('C:\Users\tigrr\UCSD\EPDL\WI26Data')