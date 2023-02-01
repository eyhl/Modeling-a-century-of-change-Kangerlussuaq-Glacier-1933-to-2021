function [z_yearly_mean] = interpCryoSAT(md, ncfile_folder)
    files = dir(ncfile_folder);
    files = files(~ismember({files.name},{'.','..'}));
        % disp(append(files(i).folder, files(i).name));

    z_int_list = zeros(length(md.mesh.x), length(files));
    for i=1:length(files)
        % disp(append(files(i).folder, files(i).name));
        % ncdisp([files(i).folder, '/', files(i).name], 'xgrid');                        
        x = ncread([files(i).folder, '/', files(i).name], "xgrid");                        
        y = ncread([files(i).folder, '/', files(i).name], "ygrid");
        z = ncread([files(i).folder, '/', files(i).name], "z_swath_idw");
        F = scatteredInterpolant(double(x), double(y), double(z), 'natural', 'nearest');                              
        z_int_list(:, i) = F(md.mesh.x, md.mesh.y);                                                                           
    end

    z_yearly_mean = mean(z_int_list, 2, 'omitnan');
end


