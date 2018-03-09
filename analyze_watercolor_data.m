
subject = '20076';

d = {'data_08March2018 3:23:31PM.mat', 'data_08March2018 3:22:15PM.mat'...
    };

data = [];
for ii = 1:length(d)
    
    tmp = load(fullfile('dat', subject, d{ii}));
    
    data = [data; tmp.data];
    
end

plot_watercolor_data(params, data);