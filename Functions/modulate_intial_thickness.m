function [md, dh, dv, misfit_thk, misfit_vel, mean_thicknesses] = modulate_intial_thickness(md, n)
    save_path = "/data/eigil/work/lia_kq/Results";

    if ~exist('md','var')
        disp("Loading model from default Models/ folder")
        md = loadmodel('Models/Model_kangerlussuaq_transient.mat');
    elseif isstring(md)
        if strcmp(md, "init")
            disp('Starting a new model')
            config_name = "config-init.csv";
            md = run_model(config_name);
        end
        sprintf("Loading model from %s", md)
        md = loadmodel(fullfile(md, 'Model_kangerlussuaq_transient.mat'));
    end    
    config_name = "config-modulation.csv";

    dh = zeros(n, 1);
    dv = zeros(n, 1);
    misfit_thk = zeros(n, length(md.geometry.surface));
    misfit_vel = zeros(n, length(md.geometry.surface));
    
    % org = organizer('repository', ['./Models/modulated'], 'prefix', ['Model_kq_'], 'steps', 1); 
    % if perform(org, 'modulate_thickness')

    % ITERATION 1
    [rmse_thickness, rmse_velocity, misfit_thickness, misfit_velocity] = validate_model(md);
    mean_thicknesses(1) = mean(md.geometry.thickness); % 1062.7 
    dh(1) = rmse_thickness;
    dv(1) = rmse_velocity;

    fid = fopen('status.txt','w');
    for i = 2:n
        [rmse_thickness, rmse_velocity, misfit_thickness, misfit_velocity] = validate_model(md);
        md = update_thickness(md, misfit_thickness, 'global', 0.8); % tried 1/2, 2/3, 1
        mean_thicknesses(i) = mean(md.geometry.thickness); % 1062.7 
        dh(i) = rmse_thickness;
        dv(i) = rmse_velocity;
        misfit_thk(i, :) = misfit_thickness;
        misfit_vel(i, :) = misfit_velocity;

        disp('SOLVE')
        md = solve(md,'Transient','runtimename',false); %TODO: try to run this on its own, without updating thickness. Does the md.geom.thick change?
        disp('SAVE')
        save("/data/eigil/work/lia_kq/Models/modulate_thickness.mat" , 'md', '-v7.3');
        fprintf(fid, '%d    %f  %f\n', i, rmse_thickness, mean_thicknesses(i));
    end
    fclose(fid);

    save("Results/misfit_thickness.mat", 'misfit_thk', '-v7.3');
    save("/data/eigil/work/lia_kq/Results/mean_thicknesses.mat" , 'mean_thicknesses', '-v7.3');
    save("/data/eigil/work/lia_kq/Results/dh.mat" , 'dh', '-v7.3');


    % % ITERATION 2
    % [rmse_thickness, rmse_velocity, misfit_thickness, misfit_velocity] = validate_model(md);
    % md = update_thickness(md, misfit_thickness, 'global');
    % mean_thicknesses(4) = mean(md.geometry.thickness); % 1036.7

    % disp('SOLVE')
    % md = solve(md,'Transient','runtimename',false);
    % disp('SAVE')
    % save("/data/eigil/work/lia_kq/Models/modulate_thickness2.mat" , 'md', '-v7.3');
    % mean_thicknesses(5) = mean(md.geometry.thickness);
    % save("/data/eigil/work/lia_kq/Models/mean_thicknesses.mat" , 'mean_thicknesses', '-v7.3');

    %     
    
    % for i=1:n
    %     [rmse_thickness, rmse_velocity, misfit_thickness, misfit_velocity] = validate_model(md);
    %     md = update_thickness(md, misfit_thickness, 'global');
    %     disp('SOLVE')
    %     md = solve(md,'Transient','runtimename',false);
    %     disp('SAVE')
    %     save("/Models/modulate_thickness.mat" , 'md', '-v7.3');


    %     fprintf("Modulation iteration %d\n", i);
    %     [rmse_thickness, rmse_velocity, misfit_thickness, misfit_velocity] = validate_model(md);
    %     fprintf("RMSE Thickness = %f", rmse_thickness);

    %     dh(i) = rmse_thickness;
    %     dv(i) = rmse_velocity;
    %     misfit_thk(i, :) = misfit_thickness;
    %     misfit_vel(i, :) = misfit_velocity;
    %     plotmodel(md, 'data', md.geometry.thickness, 'figure', 31, 'title', sprintf('Avg. thickness = %f', mean(md.geometry.thickness, 'omitnan')));
    %     try
    %         saveas(gcf, fullfile(save_path, sprintf("%dthickness_before.png", i)))
    %     catch
    %         warning('Problem using function');
    %         try
    %             disp(fullfile(save_path, sprintf("%dthickness_before.png", i)))
    %         catch
    %             disp(save_path)
    %             try
    %                 disp(sprintf("%dthickness_before.png", i))
    %             catch
    %                 disp("sprintf issue")
    %             end
    %         end
    %     end
    %     save(sprintf("Results/misfit_thickness_%d.mat", i) , 'misfit_thickness', '-v7.3');
    %     plotmodel(md, 'data', misfit_thickness, 'figure', 32, 'title', sprintf('RMSE Thickness = %f', rmse_thickness));
    %     saveas(gcf, fullfile(save_path, sprintf("%drmse_thickness.png", i)))
    %     md = update_thickness(md, misfit_thickness, 'global');
    %     plotmodel(md, 'data', md.geometry.thickness, 'figure', 33, 'title', sprintf('Avg. thickness = %f', mean(md.geometry.thickness, 'omitnan')));
    %     saveas(gcf, fullfile(save_path, sprintf("%dthickness_after.png", i)))

    %     % fast solver
    %     md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
        
    %     % get output
    %     md.transient.requested_outputs={'default', 'IceVolume', 'IceVolumeAboveFloatation'}; %,'IceVolume','MaskIceLevelset', 'MaskOceanLevelset'};

    %     disp('SOLVE')
    %     md = solve(md,'Transient','runtimename',false);
    %     disp('SAVE')
    %     save("/Models/modulate_thickness.mat" , 'md', '-v7.3');

    %     % disp("Saving model")
    %     % save('Models/Model_kangerlussuaq_fronts.mat', 'md', '-v7.3'); % has to be saved as this, as step 5 in run_model loads this filename
    %     % md = run_model(config_name); %TODO: prøv at tække 150 meter fra start tykkelsen og kør igen. Sammenlign med baseline model
    %     close all

    %     % end
    % end

end