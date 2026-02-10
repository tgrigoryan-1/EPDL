% Code for MAE30A Growth Mindset Analysis via Median Split B00
% First we determine a median split for the groups w.r.t. the participation in active recall and concept maps
% Then we get the EOQ and BOQ data from the students, filter out students based on whether or not they are in both sets 
% and whether they passed the attention check
% Then group the growth mindset questions and take an average for each of the groups
% Take the difference of these averages from EOQ - BOQ and run an independant t-test on the group's differences to find signifance

close all, clear
cd('C:\Users\tigrr\UCSD\EPDL\growthmindset')
mediansplit
eoqboq
% This is EOQ-BOQ data in fullavg, and conceptmap + activerecall in part data
filteredset = innerjoin(fullavg,partdata,'LeftKeys','pid','RightKeys','pid_p');

% Finding the median participation in total
medianparticipation = median(filteredset.totalp)

% Setting up split, group above median and group below, where those = median are included in below
groupAbove = filteredset(filteredset.totalp > 5,:);
groupBelow = filteredset(filteredset.totalp <= 5,:);

% Now that we have a group above and a group below, run t-test on their growthmindset avg to see if there is significance
[~,pvalavg] = ttest2(groupAbove.difference,groupBelow.difference)
disp("-------------------------------------------------------------------------------------------------------------------------------")
if pvalavg <= 0.05
    disp("Growth Mindset Question Average Difference between above and below groups is significant with p = " + string(pvalavg));
else
    disp("Growth Mindset Question Average Difference between above and below groups is not significant with p = " + string(pvalavg));
end

% Try a linear regression model to see if as participation changes, does the difference in the growth mindset average difference
fitlm(filteredset.totalp,filteredset.difference)

% Send back to original directory
cd('C:\Users\tigrr\UCSD\EPDL\mediansplit')