% Code for MAE131A Spring 25 Performance Scatter Midterm Exam / Quality of Participation Before Midterm
% Change the directory to where the csv files are downloaded
cd('C:\Users\tigrr\Downloads')

% Setting up data, where p_data is participation data and g_data is grades data
p_data = readtable('MegaDataFile - MAE 131A Active Learning Participation.csv');
g_data = readtable('MegaDataFile - MAE131A A00 Grades.csv');
p1_data = p_data(:,{'SISUserID','ActiveRecallScoreBeforeMidterm_Max90_'});
p2_data = p_data(:,{'SISUserID','ConceptMapScoreBeforeMidterm_Max60_'});
g_data = g_data(:,{'SISUserID','MidtermExam_971071_'});

% Joining the two data sets with the PID's as a key, using innerjoin to drop anyone that is not on both lists
q_data = innerjoin(p1_data,p2_data,'Keys','SISUserID');
q_data.TotalScore = q_data.ActiveRecallScoreBeforeMidterm_Max90_ + q_data.ConceptMapScoreBeforeMidterm_Max60_;

% Normalizing the data to be a fraction
q_data.TotalNormalized = q_data.TotalScore / 150;
quality = q_data.TotalNormalized;
exam_score = g_data.MidtermExam_971071_;

% Scatter Plot
figure(1), scatter(quality,exam_score,50,'filled')
xlabel('Quality of Participation Before Midterm')
ylabel('Midterm Exam Score')
title('MAE131A: Quality vs. Midterm Exam Performance')

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