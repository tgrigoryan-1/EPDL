% Code for MAE131A Spring 25 Median Split vs Performance Analysis Final Exam / Participation After Midterm
% This code runs the same code as mediansplit131AM.m but excluding two standard deviations above average

% Change the directory to where the csv files are downloaded
cd('C:\Users\tigrr\Downloads')

% Setting up data, where p_data is participation data and g_data is grades data
p_data = readtable('MegaDataFile - MAE 131A Active Learning Participation.csv');
g_data = readtable('MegaDataFile - MAE131A A00 Grades.csv');
p_data = p_data(:,{'SISUserID','TotalAmount_ActiveRecall_ConceptMapOnly_'});
g_data = g_data(:,{'SISUserID','FinalExamRawScore_924780_'});

% Joining the two data sets with the PID's as a key, using innerjoin to drop anyone that is not on both lists
data = innerjoin(p_data,g_data,'Keys','SISUserID');

% Compute mean and std of participation
mean_score = mean(data.FinalExamRawScore_924780_);
std_score = std(data.FinalExamRawScore_924780_);

% Define upper and lower cutoffs (2 standard deviations)
lower_cutoff = mean_score - 2*std_score;
upper_cutoff = mean_score + 2*std_score;

% Filter out students that are above and below 2 std
logvec = data.FinalExamRawScore_924780_ >= lower_cutoff & data.FinalExamRawScore_924780_ <= upper_cutoff;

% Remake the data with this filter applied
datafil = data(logvec,:);

% Define new mediansplit based on filtered cohort
medianparticipation = median(datafil.TotalAmount_ActiveRecall_ConceptMapOnly_)

% Split the above median group and the below/= median group
groupAbove = datafil(datafil.TotalAmount_ActiveRecall_ConceptMapOnly_ > medianparticipation,:);
groupBelow = datafil(datafil.TotalAmount_ActiveRecall_ConceptMapOnly_ <= medianparticipation,:);

% Print values needed
meanAbove = mean(groupAbove.FinalExamRawScore_924780_)
stdAbove = std(groupAbove.FinalExamRawScore_924780_)
medianAbove = median(groupAbove.FinalExamRawScore_924780_)
meanBelow = mean(groupBelow.FinalExamRawScore_924780_)
stdBelow = std(groupBelow.FinalExamRawScore_924780_)
medianBelow = median(groupBelow.FinalExamRawScore_924780_)
NAbove = height(groupAbove)
NBelow = height(groupBelow)

% Doing a two-sample t-test to see if there is significant difference in the means of the groups
[h,p] = ttest2(groupAbove.FinalExamRawScore_924780_,groupBelow.FinalExamRawScore_924780_)

% Send back into original directory
cd('C:\Users\tigrr\UCSD\EPDL')