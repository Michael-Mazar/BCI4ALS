disp('Connecting to python script!');
t = tcpclient('localhost', 50007);
disp('Connected!!');
char(read(t)) % convert bytes to chars
% str2double(char(read(t)))