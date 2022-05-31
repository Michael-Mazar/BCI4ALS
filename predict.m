function [prediction] = predict(X)
% X is a features matrix (or vector)

prediction = pyrunfile("./pythonTest/Classifier.py", ...
                        "prediction", action="predict", datapoints=X);
prediction = uint8(double(prediction));

end

