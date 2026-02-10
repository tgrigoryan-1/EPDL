% Side code for mediansplitavggrowth just to clean things up a bit
% This code will make two groups with a median split for B00 MAE 30A

% Change the directory to where we need to pull the data from
cd('C:\Users\tigrr\Downloads')

% First pull the Active Learning Participation data
% p_data is the data of participants, 1 representing the first sheet and 2 representing the second sheet
p_data1 = readtable('MegaDataFile - MAE30A B00 Active Learning Participation');
p_data1 = p_data1(:,{'SISUserID','ActiveRecallAmount_Max16_','ConceptMapAmount_Max4_'});

pid_p = p_data1.SISUserID;
totalp = p_data1.ActiveRecallAmount_Max16_ + p_data1.ConceptMapAmount_Max4_;
partdata = table(pid_p,totalp);

% Navigate to correct directory
cd('C:\Users\tigrr\UCSD\EPDL\growthmindset')
