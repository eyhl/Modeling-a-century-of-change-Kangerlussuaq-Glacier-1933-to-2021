function [data, errors] = get_mouginot2019_mb(field)
    if nargin < 1
        field = 'cumulativeMassBalance';
    end

    if strcmp(field, 'cumulativeMassBalance')
        data = xlsread('Data/validation/mouginot2019/pnas.1904242116.sd02.xlsx', '(4) MBcumul_Glaciers_R23p2');
        nan_indeces = find(isnan(data(173,:)));
        errors = data(173, nan_indeces(end)+1:end);
        data = data(173, 1:nan_indeces(1)-1);
    end
end