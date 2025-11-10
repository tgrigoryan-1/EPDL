% Code for MAE131A Spring 25 Median Split vs Performance Analysis Midterm Exam / Participation Before Midterm
% Change the directory to where the csv files are downloaded
cd('C:\Users\tigrr\Downloads')

% Setting up data, where p_data is participation data and g_data is grades data
p_data = readtable('MegaDataFile - MAE 131A Active Learning Participation.csv');
g_data = readtable('MegaDataFile - MAE131A A00 Grades.csv');
p_data = p_data(:,{'SISUserID','AmountBeforeMidterm'});
g_data = g_data(:,{'SISUserID','MidtermExam_971071_'});

% Joining the two data sets with the PID's as a key, using innerjoin to drop anyone that is not on both lists
data = innerjoin(p_data,g_data,'Keys','SISUserID');

% Finding the median participation in total
medianparticipation = median(p_data.AmountBeforeMidterm)

% Setting up split, group above median and group below, where those = median are included in below
groupAbove = data(data.AmountBeforeMidterm > medianparticipation,:);
groupBelow = data(data.AmountBeforeMidterm <= medianparticipation,:);

% Finding mean, std, median midterm exam score based on split and number in each group
meanAbove = mean(groupAbove.MidtermExam_971071_)
meanBelow = mean(groupBelow.MidtermExam_971071_)
stdAbove = std(groupAbove.MidtermExam_971071_)
stdBelow = std(groupBelow.MidtermExam_971071_)
medianAbove = median(groupAbove.MidtermExam_971071_)
medianBelow = median(groupBelow.MidtermExam_971071_)
NAbove = height(groupAbove)
NBelow = height(groupBelow)

% Doing a two-sample t-test to see if there is significant difference in the means of the groups
[h,p] = ttest2(groupAbove.MidtermExam_971071_,groupBelow.MidtermExam_971071_)

% Send back into original directory
cd('C:\Users\tigrr\UCSD\EPDL\mediansplit')