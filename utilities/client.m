% disp('Connecting to python script!');
% t = tcpclient('localhost', 50007);
% disp('Connected!!');
% char(read(t)) % convert bytes to chars
% str2double(char(read(t)))

disp('Connecting to python script!');
t = tcpclient('localhost', 50007);
disp('Connected!!');

write(t, "hello");
wait_for_message = 1;

flag = 1;
while (flag)
    while (wait_for_message)
            msg_length = t.NumBytesAvailable;
            if msg_length > 0
                bytes = read(t);
            %[bytes, count] = read(t, [1, t.BytesAvailable]);
                disp('Got it!!');
                wait_for_message = 0;
                disp(char(bytes))
    %                         if (count == 3 && bytes(1) == 'e' && bytes(2) == 'n' && bytes(3) == 'd') || (count == 7 && bytes(1) == 'n' && bytes(2) == 'e' && bytes(3) == 'x' && bytes(4) == 't' && bytes(5) == 'e' && bytes(6) == 'n' && bytes(7) == 'd')
    %                             disp('Connection closed, done!!');
    %                             end_train = 1;
    %                         end                        
            end
    end

    write(t, "hello");
    wait_for_message = 1;
end