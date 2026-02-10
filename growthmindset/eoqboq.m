% Side code for mediansplitavggrowth just to clean things up a bit
% This code will pull the EOQ and BOQ data needed and filter it before its use in other code

% Change the directory to where we need to pull the data from
cd('C:\Users\tigrr\Downloads')

% Now we need to pull the BOQ and EOQ data
boq_data = readtable('MegaDataFile - MAE 30A A00 and B00 BOQ Survey');
eoq_data = readtable('MegaDataFile - MAE30A EOQ Survey');
boq_data_fil = boq_data(contains(boq_data{:,2},'B00'),[18,29,43,53:55,70]);
eoq_data_fil = eoq_data(contains(eoq_data{:,2},'B00'),[18,29,43,53:55,126]);

% Attention check questions
% Convert the attention-check responses to numbers
% First we have to define a convert function

% Define a convert function (updated from previous to handle string and non-string values)
% regexp is just a function in form regexp(text,pattern,match,once)
% The text is just any data that is fed into convert
% pattern is ^\s*\d+ which ^ means start, \s* means zero or more whitespace (spaces),\d+ means one or more digits
% match is just searching for a match within the pattern we just gave
% once is just taking the first iteration of this
convert = @(x) str2double( regexp(string(x), "^\s*\d+", "match", "once") );

% Now we can convert out attention checks
% For BOQ
val18_boq = convert(boq_data_fil{:,1});
val29_boq = convert(boq_data_fil{:,2});
val43_boq = convert(boq_data_fil{:,3});
ac18_boq = (val18_boq == 5);
ac29_boq = (val29_boq == 1);
ac43_boq = ismember(val43_boq,[1,2]);
attn_checked_boq = ac18_boq & ac29_boq & ac43_boq; % Checks for students that answered all attention checks correctly
boq_data_fil = boq_data_fil(attn_checked_boq, :);

% For EOQ
% Convert the attention-check responses to numeric
val18_eoq = convert(eoq_data_fil{:,1});
val29_eoq = convert(eoq_data_fil{:,2});
val43_eoq = convert(eoq_data_fil{:,3});
ac18_eoq = (val18_eoq == 5);
ac29_eoq = (val29_eoq == 1);
ac43_eoq = (val43_eoq == 1);
attn_checked_eoq = ac18_eoq & ac29_eoq & ac43_eoq; % Checks for students that answered all attention checks correctly
eoq_data_fil = eoq_data_fil(attn_checked_eoq, :);

% Pulling the growth mindset questions (w/o attention check)
boq_data_fil = boq_data_fil(:,4:7);
eoq_data_fil = eoq_data_fil(:,4:7);

% Rename variable names and decide to rename them
baseNames = ["Q" + (1:3), "PID"];

% Add prefix to differentiate
boq_Names = "BOQ_" + baseNames;
eoq_Names = "EOQ_" + baseNames;

% Create new sets (We need the variable names later)
boq_data_fil2 = boq_data_fil;
eoq_data_fil2 = eoq_data_fil;

% Append to sets
boq_data_fil2.Properties.VariableNames = boq_Names;
eoq_data_fil2.Properties.VariableNames = eoq_Names;

% Now we remove duplicates, use stable to keep order although won't really matter since we have to innerjoin
% For boq
[~, idx_boq] = unique(boq_data_fil2{:,4}, 'stable');
boq_data_unq = boq_data_fil2(idx_boq,:);
% For eoq
[~, idx_eoq] = unique(eoq_data_fil2{:,4},'stable');
eoq_data_unq = eoq_data_fil2(idx_eoq,:);

% Now to use innerjoin to weed out anyone that isn't on both lists, since I named them different I have to use Left and Right Keys
fullsurvsetfil = innerjoin(boq_data_unq,eoq_data_unq,'LeftKeys','BOQ_PID','RightKeys','EOQ_PID');

% We need to use the convert function again for all the data to get only the double values to run t-test
varNames = fullsurvsetfil.Properties.VariableNames;
for i = 1:length(varNames)
	name = varNames{i};
	if (startsWith(name,"BOQ_") || startsWith(name,"EOQ_")) && ~endsWith(name, "PID")
		fullsurvsetfil.(name) = convert(fullsurvsetfil.(name));
	end
end

growthmindsetavgBOQ = (fullsurvsetfil.BOQ_Q1 + fullsurvsetfil.BOQ_Q2 + fullsurvsetfil.BOQ_Q3)/3;
growthmindsetavgEOQ = (fullsurvsetfil.EOQ_Q1 + fullsurvsetfil.EOQ_Q2 + fullsurvsetfil.EOQ_Q3)/3;
pid = fullsurvsetfil.BOQ_PID;
difference = growthmindsetavgEOQ-growthmindsetavgBOQ;
fullavg = table(difference,pid);

% Navigate to correct directory
cd('C:\Users\tigrr\UCSD\EPDL\growthmindset')