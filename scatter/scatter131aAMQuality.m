% Code for MAE131A Spring 25 Performance Scatter Final Exam / Quality of Participation
% Change the directory to where the csv files are downloaded
cd('C:\Users\tigrr\Downloads')

% Setting up data, where p_data is participation data and g_data is grades data
p_data = readtable('MegaDataFile - MAE 131A Active Learning Participation.csv');
g_data = readtable('MegaDataFile - MAE131A A00 Grades.csv');
p1_data = p_data(:,{'SISUserID','ActiveRecallScore_Max190_'});
p2_data = p_data(:,{'SISUserID','ConceptMapScore_Max120_'});
g_data = g_data(:,{'SISUserID','FinalExamRawScore_924780_'});

% Joining the two data sets with the PID's as a key, using innerjoin to drop anyone that is not on both lists
q_data = innerjoin(p1_data,p2_data,'Keys','SISUserID');
q_data.TotalScore = q_data.ActiveRecallScore_Max190_ + q_data.ConceptMapScore_Max120_;

% Normalizing the data to be a fraction
q_data.TotalNormalized = q_data.TotalScore / 310;
quality = q_data.TotalNormalized;
exam_score = g_data.FinalExamRawScore_924780_;

% Scatter Plot
figure(1), scatter(quality,exam_score,50,'filled')
xlabel('Quality of Participation')
ylabel('Final Exam Score')
title('MAE131A: Quality vs. Final Exam Performance')

% Line of best fit
hold on;
% Fitting polynomial of degree 1 to data
coeff = polyfit(quality, exam_score, 1);
% Creating value for quality to plot the line onto
xfit = linspace(min(quality), max(quality), 100);
% Evaluating the line at the new x values
yfit = polyval(coeff, xfit);
% Plot the line
plot(xfit, yfit, 'r-', 'LineWidth', 1.5);
% Legend showing the coefficients in the y = mx + b equation used to fit
legend('Student Data', sprintf('Linear Fit: y = %.2fx + %.2f', coeff(1), coeff(2)));
hold off;

% Send back into original directory
cd('C:\Users\tigrr\UCSD\EPDL')