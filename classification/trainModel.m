function [trainingResult] = trainModel()
% Wrapper for the train functionality in Python
trainingResult = pyrunfile("train.py", "result");

end

