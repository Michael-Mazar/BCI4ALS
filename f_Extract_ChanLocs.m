function f_Extract_ChanLocs()
chanlocs = struct('labels', { 'cz' 'c3' 'c4' 'fc1' 'fc2' 'fc5' ...
    'fc6' 'cp1' 'cp2' 'cp5' 'cp6', 'O1', 'O2'});
pop_chanedit(chanlocs);
% Following this mannually save the channels location by
% 1. Loading the standard file format
% 2. Saving as loc file type
% 3. Rename the new file to chan_locs.locs
end
