% Code for MAE131A Spring 25 Median Split vs Performance Analysis Final Exam / Participation After Midterm
% Change the directory to where the csv files are downloaded
cd('C:\Users\tigrr\Downloads')

% Setting up data, where p_data is participation data and g_data is grades data
p_data = readtable('MegaDataFile - MAE 131A Active Learning Participation.csv');
g_data = readtable('MegaDataFile - MAE131A A00 Grades.csv');
p_data = p_data(:,{'SISUserID','TotalAmount_ActiveRecall_ConceptMapOnly_'});
g_data = g_data(:,{'SISUserID','FinalExamRawScore_924780_'});

% Joining the two data sets with the PID's as a key, using innerjoin to drop anyone that is not on both lists
data = innerjoin(p_data,g_data,'Keys','SISUserID');

% Finding the median participation in total
medianparticipation = median(p_data.TotalAmount_ActiveRecall_ConceptMapOnly_)

% Setting up split, group above median and group below, where those = median are included in below
groupAbove = data(data.TotalAmount_ActiveRecall_ConceptMapOnly_ > medianparticipation,:);
groupBelow = data(data.TotalAmount_ActiveRecall_ConceptMapOnly_ <= medianparticipation,:);

% Finding mean, std, median midterm exam score based on split and number in each group
meanAbove = mean(groupAbove.FinalExamRawScore_924780_)
meanBelow = mean(groupBelow.FinalExamRawScore_924780_)
stdAbove = std(groupAbove.FinalExamRawScore_924780_)
stdBelow = std(groupBelow.FinalExamRawScore_924780_)
medianAbove = median(groupAbove.FinalExamRawScore_924780_)
medianBelow = median(groupBelow.FinalExamRawScore_924780_)
NAbove = height(groupAbove)
NBelow = height(groupBelow)

% Doing a two-sample t-test to see if there is significant difference in the means of the groups
[h,p] = ttest2(groupAbove.FinalExamRawScore_924780_,groupBelow.FinalExamRawScore_924780_)

% Send back into original directory
cd('C:\Users\tigrr\UCSD\EPDL\mediansplit')
