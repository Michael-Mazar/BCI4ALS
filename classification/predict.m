function [prediction] = predict(X)
% X is a features matrix (or vector)

prediction = pyrunfile("predict.py", "prediction", datapoints=X);
prediction = uint8(double(prediction));

end

